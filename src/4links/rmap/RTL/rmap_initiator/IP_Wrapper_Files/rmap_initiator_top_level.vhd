----------------------------------------------------------------------------------------------------------------------------------
-- File Description  --
----------------------------------------------------------------------------------------------------------------------------------
-- @ File Name				:	
-- @ Engineer				:	James E Logan
-- @ Role					:	FPGA Engineer
-- @ Company				:	4Links ltd
-- @ Date					: 	dd/mm/yyyy

-- @ VHDL Version			:   1987, 1993, 2008
-- @ Supported Toolchain	:	Xilinx Vivado IDE
-- @ Target Device			: 	Xilinx US+ Family

-- @ Revision #				:	2

-- File Description         :

-- Document Number			:  xxx-xxxx-xxx
----------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Copyright (c) 2018-2023, 4Links Ltd All rights reserved.
--
-- Redistribution and use in source and synthesised forms, with or without 
-- modification, are permitted provided that the following conditions are met:
-- 1. Redistributions of source code must retain the above copyright notice, 
--    this list of conditions and the following disclaimer.
-- 2. Redistributions in synthesised form must reproduce the above copyright 
--    notice, this list of conditions and the following disclaimer in the 
--    documentation and/or other materials provided with the distribution.
-- 3. All advertising materials mentioning features or use of this code
--    must display the following acknowledgement: This product includes
--    code developed by 4Links Ltd.
-- 4. Neither the name of 4Links Ltd nor the names of its contributors may be
--    used to endorse or promote products derived from this code without 
--    specific prior written permission.
--
-- THIS CODE IS PROVIDED BY 4LINKS LTD "AS IS" AND ANY EXPRESS OR IMPLIED
-- WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
-- MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
-- EVENT SHALL 4LINKS LTD BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
-- SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
-- OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
-- WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
-- OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS CODE, EVEN IF 
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
-- Library Declarations  --
----------------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

----------------------------------------------------------------------------------------------------------------------------------
-- Package Declarations --
----------------------------------------------------------------------------------------------------------------------------------
context work.rmap_context;

----------------------------------------------------------------------------------------------------------------------------------
-- Entity Declarations --
----------------------------------------------------------------------------------------------------------------------------------
entity rmap_initiator_top_level is
	generic(
		g_clock_freq		: real				:= 20_000_000.0;	-- IP clock frequency Hz
		g_tx_fifo_size		: integer 			:= 16;				-- Tx Stall depth
		g_rx_fifo_size		: integer 			:= 16;				-- Rx Stall depth
		g_tx_fifo_interface	: boolean 			:= false;			-- generate Tx interface as Fifo ?
		g_rx_fifo_interface	: boolean			:= false;			-- generate Rx interface as Fifo ?
		g_mode				: string 			:= "custom"        	-- Diff, Single or Custom. Use Custom and put DDR registers outside of core
	);
	port( 
		-- Standard Register Channels --
		clock				: in 	std_logic := '0';		-- clk input, rising edge trigger
		clock_b				: in 	std_logic := '1';
		rst_in				: in 	std_logic := '0';		-- reset input, active high
		enable  			: in 	std_logic := '0';		-- enable input, asserted high.
		----------------------------------------------------------------------------------
		-- Time Code Channels --
		tx_time				: in 	std_logic_vector(7 downto 0) := (others => '0');
		tx_time_valid		: in 	std_logic := '0';
		tx_time_ready		: out 	std_logic := '0';
		
		rx_time				: out 	std_logic_vector(7 downto 0) := (others => '0');
		rx_time_valid		: out 	std_logic := '0';
		rx_time_ready		: in 	std_logic := '0';
		----------------------------------------------------------------------------------
		-- Tx Command Channels --
		tx_assert_path		: in 	std_logic := '0';
		tx_assert_char		: in 	std_logic := '0';
		tx_header			: in 	std_logic_vector(7 downto 0) := (others => '0');
		tx_header_valid		: in 	std_logic := '0';
		tx_header_ready		: out 	std_logic := '0';
		
		tx_data				: in 	std_logic_vector(7 downto 0) := (others => '0');
		tx_data_valid		: in 	std_logic := '0';
		tx_data_ready		: out 	std_logic := '0';
		----------------------------------------------------------------------------------
		-- Rx Reply Channels --
		rx_assert_char		: out 	std_logic := '0';
		rx_header			: out 	std_logic_vector(7 downto 0) := (others => '0');
		rx_header_valid		: out 	std_logic := '0';
		rx_header_ready 	: in 	std_logic := '0';
		
		rx_data				: out 	std_logic_vector(7 downto 0) := (others => '0');
		rx_data_valid		: out 	std_logic := '0';
		rx_data_ready 		: in 	std_logic := '0';
		
		----------------------------------------------------------------------------------
		-- Tx Error Channels --
		tx_error			: out 	std_logic_vector(7 downto 0) := (others => '0');
		tx_error_valid		: out 	std_logic := '0';
		tx_error_ready		: in 	std_logic := '0';
		----------------------------------------------------------------------------------
		-- Rx Error Channels --
		rx_error			: out 	std_logic_vector(7 downto 0) := (others => '0');
		rx_error_valid		: out 	std_logic := '0';
		rx_error_ready		: in 	std_logic := '0';
		----------------------------------------------------------------------------------
	
		tx_logical_address		: in 	t_byte := (others => '0');
		tx_protocol_id			: in 	t_byte := (others => '0');
		tx_instruction			: in 	t_byte := (others => '0');
		tx_Key	    			: in 	t_byte := (others => '0');
		tx_reply_addresses		: in 	t_byte_array(0 to 11) := (others => (others => '0'));
		tx_init_log_addr	    : in 	t_byte := (others => '0');
		tx_Tranaction_ID		: in 	std_logic_vector(15 downto 0) := (others => '0');
		tx_Address   			: in 	std_logic_vector(39 downto 0) := (others => '0');
		tx_Data_Length     		: in 	std_logic_vector(23 downto 0) := (others => '0');
		
		rx_init_log_addr	    : out 	t_byte := (others => '0');
		rx_protocol_id			: out 	t_byte := (others => '0');
		rx_instruction			: out 	t_byte := (others => '0');
		rx_Status	    		: out 	t_byte := (others => '0');
		rx_target_log_addr		: out 	t_byte := (others => '0');
		rx_Tranaction_ID		: out 	std_logic_vector(15 downto 0) := (others => '0');
		rx_Data_Length     		: out 	std_logic_vector(23 downto 0) := (others => '0');
		
		crc_good				: out 	std_logic := '1';
		
		spw_Rx_ESC_ESC      : out 	std_logic := '0';                                   
		spw_Rx_ESC_EOP      : out 	std_logic := '0';                                   
		spw_Rx_ESC_EEP      : out 	std_logic := '0';                                   
		spw_Rx_Parity_error : out 	std_logic := '0';                                   
		spw_Rx_bits         : out  	std_logic_vector(1 downto 0) := (others => '0');	
		spw_Rx_rate         : out 	std_logic_vector(15 downto 0) := (others => '0');     
		spw_Disable     	: in	std_logic := '0';                                   
		spw_Connected       : out   std_logic := '0';                                   
		spw_Error_select    : in	std_logic_vector(3 downto 0) := (others => '0');    
		spw_Error_inject    : in	std_logic := '0';                                   
		
		DDR_din_r			: in 	std_logic := '0';
		DDR_din_f           : in	std_logic := '0';
		DDR_sin_r           : in	std_logic := '0';
		DDR_sin_f           : in	std_logic := '0';
		SDR_Dout			: out	std_logic := '0';
		SDR_Sout			: out	std_logic := '0';
		
		Din_p				: in 	std_logic := '0';
		Din_n               : in 	std_logic := '0';
		Sin_p               : in 	std_logic := '0';
		Sin_n               : in 	std_logic := '0';
		Dout_p              : out 	std_logic := '0';
		Dout_n              : out 	std_logic := '0';
		Sout_p              : out 	std_logic := '0';
		Sout_n              : out 	std_logic := '0'
		
    );
end rmap_initiator_top_level;


---------------------------------------------------------------------------------------------------------------------------------
-- Code Description & Developer Notes --
---------------------------------------------------------------------------------------------------------------------------------


architecture rtl of rmap_initiator_top_level is

	----------------------------------------------------------------------------------------------------------------------------
	-- Constant Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Type Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Function Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Entity Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Component Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Signal Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	signal	cmd_channel_in		: r_cmd_controller_logic_in := c_cmd_logic_in_init;
	signal	cmd_channel_out		: r_cmd_controller_logic_out := c_cmd_logic_out_init;
	signal	reply_channel_in	: r_reply_controller_logic_in := c_reply_logic_in_init;
	signal	reply_channel_out	: r_reply_controller_logic_out := c_reply_logic_out_init;
	
	signal	p_tx_logical_address		: 	t_byte := (others => '0');
	signal	p_tx_protocol_id			: 	t_byte := (others => '0');
	signal	p_tx_instruction			: 	t_byte := (others => '0');
	signal	p_tx_Key	    			: 	t_byte := (others => '0');
	signal	p_tx_reply_addresses		: 	t_byte_array(0 to 11) := (others => (others => '0'));
	signal	p_tx_init_log_addr	   	 	: 	t_byte := (others => '0');
	signal	p_tx_Tranaction_ID			: 	std_logic_vector(15 downto 0) := (others => '0');
	signal	p_tx_Address   				: 	std_logic_vector(39 downto 0) := (others => '0');
	signal	p_tx_Data_Length     		: 	std_logic_vector(23 downto 0) := (others => '0');

	signal	p_tx_header_ready			: 	std_logic := '0';
	signal	p_tx_header_valid 			: 	std_logic := '0';

	signal	p_tx_data					: 	t_byte := (others => '0');
	signal	p_tx_data_valid				: 	std_logic := '0';
	signal	p_tx_data_ready				: 	std_logic := '0';

	signal	p_tx_error					: 	t_byte := (others => '0');
	signal	p_tx_error_valid			: 	std_logic := '0';
	signal	p_tx_error_ready			: 	std_logic := '0';
	
	signal	p_rx_init_log_addr	    	: 	t_byte := (others => '0');
	signal	p_rx_protocol_id			: 	t_byte := (others => '0');
	signal	p_rx_instruction			: 	t_byte := (others => '0');
	signal	p_rx_Status	    			: 	t_byte := (others => '0');
	signal	p_rx_target_log_addr		: 	t_byte := (others => '0');
	signal	p_rx_Tranaction_ID			: 	std_logic_vector(15 downto 0) := (others => '0');
	signal	p_rx_Data_Length     		: 	std_logic_vector(23 downto 0) := (others => '0');
	
	signal	p_rx_header_ready			: 	std_logic := '0';
	signal	p_rx_header_valid 			: 	std_logic := '0';
	
	signal	p_rx_data					: 	t_byte := (others => '0');
	signal	p_rx_data_valid				: 	std_logic := '0';
	signal	p_rx_data_ready				: 	std_logic := '0';

	signal	p_rx_error					: 	t_byte := (others => '0');
	signal	p_rx_error_valid			: 	std_logic := '0';
	signal	p_rx_error_ready			: 	std_logic := '0';

	signal	p_crc_good					: 	std_logic := '1';
	

	
	----------------------------------------------------------------------------------------------------------------------------
	-- Variable Declarations --
	----------------------------------------------------------------------------------------------------------------------------

	----------------------------------------------------------------------------------------------------------------------------
	-- Alias Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Attribute Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
begin

	----------------------------------------------------------------------------------------------------------------------------
	-- Entity Instantiations --
	----------------------------------------------------------------------------------------------------------------------------
	rmap_inst: entity work.rmap_initiator(rtl)
	generic map(
		-- generics for configuring 4Links SpW CoDec IP
		g_clock_freq		=> 	g_clock_freq,		
		g_tx_fifo_size		=> 	g_tx_fifo_size,		
		g_rx_fifo_size		=> 	g_rx_fifo_size,		
		g_tx_fifo_interface	=>	g_tx_fifo_interface,
		g_rx_fifo_interface =>	g_rx_fifo_interface,
		g_mode				=>	g_mode					-- Diff, Single or Custom.
	)
	port map( 
		-- standard register control signals --
		clock				=>	clock,			
		clock_b				=>  clock_b,			
		rst_in				=>  rst_in,			
		enable  			=>  enable,  		
		
		rx_enable			=> 	enable,
		-- timecode channels -- 	
		tx_time				=>  tx_time,				
		tx_time_valid		=>  tx_time_valid,		
		tx_time_ready		=>  tx_time_ready,	
     
		rx_time				=>  rx_time,			
		rx_time_valid		=>  rx_time_valid,	
		rx_time_ready		=>  rx_time_ready,	
		
		cmd_channel_in		=> cmd_channel_in,		
		cmd_channel_out		=> cmd_channel_out,		
		reply_channel_in	=> reply_channel_in,	
		reply_channel_out	=> reply_channel_out,	
		
		tx_logical_address	=>	p_tx_logical_address		,
		tx_protocol_id		=>	p_tx_protocol_id		    ,
		tx_instruction		=>	p_tx_instruction		    ,
		tx_Key	    		=>	p_tx_Key	    		    ,
		tx_reply_addresses	=>	p_tx_reply_addresses	    ,
		tx_init_log_addr	=>	p_tx_init_log_addr	    	,
		tx_Tranaction_ID	=>	p_tx_Tranaction_ID	    	,
		tx_Address   		=>	p_tx_Address   		    	,
		tx_Data_Length     	=>	p_tx_Data_Length     	    ,

		tx_header_ready		=>	p_tx_header_ready		    ,
		tx_header_valid 	=>	p_tx_header_valid 	    	,

		tx_data				=>	p_tx_data				    ,
		tx_data_valid		=>	p_tx_data_valid		   		,
		tx_data_ready		=>	p_tx_data_ready		    	,

		tx_error			=>	p_tx_error			    	,
		tx_error_valid		=>	p_tx_error_valid		    ,
		tx_error_ready		=>	p_tx_error_ready		    ,
		
		rx_init_log_addr	=>	p_rx_init_log_addr	    	,
		rx_protocol_id		=>	p_rx_protocol_id		    ,
		rx_instruction		=>	p_rx_instruction		    ,
		rx_Status	    	=>	p_rx_Status	    	    	,
		rx_target_log_addr	=>	p_rx_target_log_addr	    ,
		rx_Tranaction_ID	=>	p_rx_Tranaction_ID	    	,
		rx_Data_Length     	=>	p_rx_Data_Length     	    ,
       
		rx_header_ready		=>	p_rx_header_ready		    ,
		rx_header_valid 	=>	p_rx_header_valid 	    	,

		rx_data				=>	p_rx_data				    ,
		rx_data_valid		=>	p_rx_data_valid		    	,
		rx_data_ready		=>	p_rx_data_ready		   		,

		rx_error			=>	p_rx_error			   	 	,
		rx_error_valid		=>	p_rx_error_valid		    ,
		rx_error_ready		=>	p_rx_error_ready		    ,
		
		crc_good			=>	p_crc_good			    	,
		
		
		-- SpaceWire IP Status & Control Channels --
		spw_Rx_ESC_ESC      => spw_Rx_ESC_ESC,        
		spw_Rx_ESC_EOP      => spw_Rx_ESC_EOP,        
		spw_Rx_ESC_EEP      => spw_Rx_ESC_EEP,        
		spw_Rx_Parity_error => spw_Rx_Parity_error,   
		spw_Rx_bits         => spw_Rx_bits,         	
		spw_Rx_rate         => spw_Rx_rate,           
		spw_Disable     	=> spw_Disable,     	  
		spw_Connected       => spw_Connected,         
		spw_Error_select    => spw_Error_select,      
		spw_Error_inject    => spw_Error_inject,      
		--------------------------------------------
		-- SpW IO (custom)
		DDR_din_r			=> DDR_din_r,	
		DDR_din_f           => DDR_din_f,   
		DDR_sin_r           => DDR_sin_r,   
		DDR_sin_f           => DDR_sin_f,   
		SDR_Dout			=> SDR_Dout,	
		SDR_Sout			=> SDR_Sout,	

		Din_p				=> Din_p,		
		Din_n               => Din_n,       
		Sin_p               => Sin_p,       
		Sin_n               => Sin_n,       
		Dout_p              => Dout_p,      
		Dout_n              => Dout_n,      
		Sout_p              => Sout_p,      
		Sout_n              => Sout_n     
    );


	----------------------------------------------------------------------------------------------------------------------------
	-- Component Instantiations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Asynchronous Signal Assignments --
	----------------------------------------------------------------------------------------------------------------------------
	gen_tx_interface: if(g_tx_fifo_interface = true) generate
	
		cmd_channel_in.tx_header.wdata(7 downto 0) 		<= tx_header;
		cmd_channel_in.tx_header.wvalid 		<= tx_header_valid;
		tx_header_ready 					<= cmd_channel_out.tx_header.wready;
		
		cmd_channel_in.tx_data.wdata(7 downto 0)		<= tx_data;
		cmd_channel_in.tx_data.wvalid 		<= tx_data_valid;
		tx_data_ready						<= cmd_channel_out.tx_data.wready;
		
		
		
		cmd_channel_in.tx_header.wdata(8) 	<= tx_assert_char;
		cmd_channel_in.tx_data.wdata(8) 	<= tx_assert_char;
		
		cmd_channel_in.assert_target 		<= tx_assert_path;
		
		cmd_channel_in.tx_error.rready 	<= tx_error_ready;
		tx_error						<= cmd_channel_out.tx_error.rdata;
		tx_error_valid					<= cmd_channel_out.tx_error.rvalid;
		
		
	else generate	-- generate parallel Tx/Rx interfaces if fifo select is false 
		
		p_tx_logical_address	<=  tx_logical_address		;
		p_tx_protocol_id		<=  tx_protocol_id			;
		p_tx_instruction		<=  tx_instruction			;
		p_tx_Key	    		<=  tx_Key	    			;
		p_tx_reply_addresses	<=  tx_reply_addresses		;
		p_tx_init_log_addr		<=  tx_init_log_addr		;
		p_tx_Tranaction_ID		<=  tx_Tranaction_ID		;
		p_tx_Address   			<=  tx_Address   			;
		p_tx_Data_Length     	<=  tx_Data_Length     		;

		p_tx_header_valid 		<= 	tx_header_valid			;	
		tx_header_ready  		<=  p_tx_header_ready		;	
	
		p_tx_data 				<= 	tx_data					;	
		p_tx_data_valid 		<= 	tx_data_valid			;	
		tx_data_ready			<= 	p_tx_data_ready			;	
	
		tx_error				<= p_tx_error				;
		tx_error_valid			<= p_tx_error_valid			;
		p_tx_error_ready	 	<= tx_error_ready			;
	
	end generate gen_tx_interface;
	
	gen_rx_interface: if(g_rx_fifo_interface = true) generate
		
		
		rx_header 							<= reply_channel_out.rx_header.rdata(7 downto 0);
		rx_header_valid 					<= reply_channel_out.rx_header.rvalid;
		reply_channel_in.rx_header.rready 	<= rx_header_ready;

		rx_data 							<= reply_channel_out.rx_data.rdata(7 downto 0);
		rx_data_valid 						<= reply_channel_out.rx_data.rvalid;
		reply_channel_in.rx_data.rready 	<= rx_data_ready;
		
		rx_assert_char <= reply_channel_out.rx_data.rdata(8) or reply_channel_out.rx_data.rdata(8);

		reply_channel_in.rx_error.rready 	<= rx_error_ready;
		rx_error							<= reply_channel_out.rx_error.rdata;
		rx_error_valid						<= reply_channel_out.rx_error.rvalid;
		
	else generate	-- generate parallel Tx/Rx interfaces if fifo select is false 
		
		rx_init_log_addr		<= 	p_rx_init_log_addr	    ;
		rx_protocol_id			<= 	p_rx_protocol_id		;
		rx_instruction			<= 	p_rx_instruction		;
		rx_Status	    		<= 	p_rx_Status	    		;
		rx_target_log_addr		<= 	p_rx_target_log_addr	;
		rx_Tranaction_ID		<= 	p_rx_Tranaction_ID		;
		rx_Data_Length     		<= 	p_rx_Data_Length     	;
	
		crc_good				<= 	p_crc_good				;
		
		rx_header_valid	        <= 	p_rx_header_valid		;	
		p_rx_header_ready 		<= 	rx_header_ready 		;	
	
		rx_data					<= p_rx_data				;
		rx_data_valid			<= p_rx_data_valid			;
		p_rx_data_ready 		<= rx_data_ready 			;
	
	
		rx_error				<= p_rx_error				;
		rx_error_valid		    <= p_rx_error_valid			;
		p_rx_error_ready		<= rx_error_ready			;
	
	end generate gen_rx_interface;
	
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Synchronous Processes --
	----------------------------------------------------------------------------------------------------------------------------


end rtl;