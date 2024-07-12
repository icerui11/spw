----------------------------------------------------------------------------------------------------------------------------------
-- File Description  --
----------------------------------------------------------------------------------------------------------------------------------
-- @ File Name				:	rmap_initiator.vhd
-- @ Engineer				:	James E Logan
-- @ Role					:	FPGA Engineer
-- @ Company				:	4Links ltd
-- @ Date					: 	26/06/2023

-- @ VHDL Version			:   2008
-- @ Supported Toolchain	:	Xilinx Vivado IDE
-- @ Target Device			: 	Xilinx US+ Family

-- @ Revision #				:	2

-- File Description         : 	4Links RMAP initiator IP Top-Level File 

-- Document Number			: 	xxx-xxxx-xxx
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
library work;
use work.all;
context work.rmap_context;
----------------------------------------------------------------------------------------------------------------------------------
-- Entity Declarations --
----------------------------------------------------------------------------------------------------------------------------------
entity rmap_initiator is
	generic(
		-- generics for configuring 4Links SpW CoDec IP
		g_clock_freq		: real				:= 125_000_000.0;
		g_tx_fifo_size		: integer 			:= 16;
		g_rx_fifo_size		: integer 			:= 16;
		g_tx_fifo_interface	: boolean 			:= false;
		g_rx_fifo_interface	: boolean			:= false;
		g_mode				: string 			:= "custom"      -- Diff, Single or Custom (IO Modes of SpW Codec)
	);
	port( 
		-- standard register control signals --
		clock				: in 	std_logic := '0';		-- clk input, rising edge trigger
		clock_b				: in 	std_logic := '1';
		rst_in				: in 	std_logic := '0';		-- reset input, active high
		enable  			: in 	std_logic := '0';		-- enable input, asserted high. 
		
		-- timecode channels --
		tx_time				: in 	std_logic_vector(7 downto 0) := (others => '0');
		tx_time_valid		: in 	std_logic := '0';
		tx_time_ready		: out 	std_logic := '0';
		
		rx_time				: out 	std_logic_vector(7 downto 0) := (others => '0');
		rx_time_valid		: out 	std_logic := '0';
		rx_time_ready		: in 	std_logic := '0';
		
		--  if FIFO interfaces are used  -- 
		cmd_channel_in		: in    r_cmd_controller_logic_in := c_cmd_logic_in_init;
		cmd_channel_out		: out   r_cmd_controller_logic_out := c_cmd_logic_out_init;
		
		reply_channel_in	: in    r_reply_controller_logic_in := c_reply_logic_in_init;
		reply_channel_out	: out   r_reply_controller_logic_out := c_reply_logic_out_init;
		
		-- if parallel interfaces are used (fifo interface variable is false) -- 
		tx_logical_address		: in 	t_byte := (others => '0');
		tx_protocol_id			: in 	t_byte := (others => '0');
		tx_instruction			: in 	t_byte := (others => '0');
		tx_Key	    			: in 	t_byte := (others => '0');
		tx_reply_addresses		: in 	t_byte_array(0 to 11) := (others => (others => '0'));
		tx_init_log_addr	    : in 	t_byte := (others => '0');
		tx_Tranaction_ID		: in 	std_logic_vector(15 downto 0) := (others => '0');
		tx_Address   			: in 	std_logic_vector(39 downto 0) := (others => '0');
		tx_Data_Length     		: in 	std_logic_vector(23 downto 0) := (others => '0');
		
		tx_header_ready			: out	std_logic := '0';
		tx_header_valid 		: in 	std_logic := '0';
		
		tx_data					: in  	t_byte := (others => '0');
		tx_data_valid			: in  	std_logic := '0';
		tx_data_ready			: out 	std_logic := '0';
		
		tx_error				: out 	t_byte := (others => '0');
		tx_error_valid			: out 	std_logic := '0';
		tx_error_ready			: in 	std_logic := '0';
		
		rx_enable				: in 	std_logic := '0';
		rx_init_log_addr	    : out 	t_byte := (others => '0');
		rx_protocol_id			: out 	t_byte := (others => '0');
		rx_instruction			: out 	t_byte := (others => '0');
		rx_Status	    		: out 	t_byte := (others => '0');
		rx_target_log_addr		: out 	t_byte := (others => '0');
		rx_Tranaction_ID		: out 	std_logic_vector(15 downto 0) := (others => '0');
		rx_Data_Length     		: out 	std_logic_vector(23 downto 0) := (others => '0');
		
		rx_header_ready			: in	std_logic := '0';
		rx_header_valid 		: out 	std_logic := '0';
		
		rx_data					: out  	t_byte := (others => '0');
		rx_data_valid			: out  	std_logic := '0';
		rx_data_ready			: in 	std_logic := '0';
		
		rx_error				: out 	t_byte := (others => '0');
		rx_error_valid			: out 	std_logic := '0';
		rx_error_ready			: in 	std_logic := '0';
		
		crc_good				: out 	std_logic := '1';
		
		-- SpaceWire IP Status & Control Channels ----------------------------------------
		spw_Rx_ESC_ESC      : out 	std_logic := '0';                                   --
		spw_Rx_ESC_EOP      : out 	std_logic := '0';                                   --
		spw_Rx_ESC_EEP      : out 	std_logic := '0';                                   --
		spw_Rx_Parity_error : out 	std_logic := '0';                                   --
		spw_Rx_bits         : out  	std_logic_vector(1 downto 0) := (others => '0');	--
		spw_Rx_rate         : out 	std_logic_vector(15 downto 0) := (others => '0');   --  
		spw_Disable     	: in	std_logic := '0';                                   --
		spw_Connected       : out   std_logic := '0';                                   --
		spw_Error_select    : in	std_logic_vector(3 downto 0) := (others => '0');    --
		spw_Error_inject    : in	std_logic := '0';                                   --
		----------------------------------------------------------------------------------
		
		-- SpW IO (custom)
		DDR_din_r			: in 	std_logic := '0';
		DDR_din_f           : in	std_logic := '0';
		DDR_sin_r           : in	std_logic := '0';
		DDR_sin_f           : in	std_logic := '0';
		SDR_Dout			: out	std_logic := '0';
		SDR_Sout			: out	std_logic := '0';
		
		-- SpW IO (diff & single)
		Din_p				: in 	std_logic := '0';
		Din_n               : in 	std_logic := '0';
		Sin_p               : in 	std_logic := '0';
		Sin_n               : in 	std_logic := '0';
		Dout_p              : out 	std_logic := '0';
		Dout_n              : out 	std_logic := '0';
		Sout_p              : out 	std_logic := '0';
		Sout_n              : out 	std_logic := '0'
    );
end rmap_initiator;


---------------------------------------------------------------------------------------------------------------------------------
-- Code Description & Developer Notes --
---------------------------------------------------------------------------------------------------------------------------------
-- Stitch together entity Instantiations to create rmap_initiator IP ! 
-- Command and Reply CRC engines are instantiated within the Command and Reply Controller entities.
--
--
architecture rtl of rmap_initiator is

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
	
	-- tx Command Controller Signal Declarations (as records) -- 

	signal s_cmd_spw_in		: r_cmd_controller_spw_in		:= c_cmd_spw_in_init;
	signal s_cmd_spw_out	: r_cmd_controller_spw_out		:= c_cmd_spw_out_init;
	
	-- rx Reply Controller Signal Declarations (as records) -- 

	signal s_reply_spw_in	: r_reply_controller_spw_in		:= c_reply_spw_in_init;
	signal s_reply_spw_out	: r_reply_controller_spw_out	:= c_reply_spw_out_init;
	

	------------------------------------------------------------------------------
	-- SpW CoDec IP Signals ------------------------------------------------------
	------------------------------------------------------------------------------
	-- tx data channels															--
	signal spw_Tx_con				: 		std_logic;                          --
	signal spw_Tx_data         		:    	t_nonet;                            --
	signal spw_Tx_OR           		:    	boolean;                          	--
	signal spw_Tx_IR           		:  		boolean;                            --
	-- rx data channels															--
	signal spw_Rx_raw				: 		std_logic_vector(8 downto 0);       --
	signal spw_Rx_con				: 		std_logic;                          --
	signal spw_rx_data         		:    	t_nonet;                            --
	signal spw_Rx_OR           		:  		boolean;                            --
	signal spw_Rx_IR           		:    	boolean;                            --
	-- error inject channels													--
	signal spw_Rx_ESC_ESC_bool      :  		boolean;                            --
	signal spw_Rx_ESC_EOP_bool      :  		boolean;                            --
	signal spw_Rx_ESC_EEP_bool      :  		boolean;                            --
	signal spw_Rx_Parity_error_bool :  		boolean;                            --
	signal spw_rx_bits_num			:		integer range 0 to 2 := 0;			--
	--  rx time channels														--
	signal spw_Rx_Time         		:  		t_byte;                             --
	signal spw_Rx_Time_OR      		:  		boolean;                            --
	signal spw_Rx_Time_IR      		:    	boolean;                            --
	-- tx time channels															--
	signal spw_Tx_Time         		:    	t_byte;                             --
	signal spw_Tx_Time_OR      		:    	boolean;                            --
	signal spw_Tx_Time_IR			: 		boolean;							--
	-- spw status and control ports												--
	signal spw_Connected_bool   	:  		boolean;                            --
	------------------------------------------------------------------------------
	
	signal tx_link_idle			: 		std_logic := '0';
	signal rx_link_idle			: 		std_logic := '0';
	
	signal sync_reset           :       std_logic := '0';
	
	
	---------------------------------------------------------------------------------------------------------------------------
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
	-- 4Links SpaceWire CoDec IP
	-- copy into design entity architecture -- 
	u_spw_inst: entity rmap_spw_wrap(rtl) 
	generic map(
		g_clock_frequency   =>	g_clock_freq,  
		g_rx_fifo_size      =>  g_rx_fifo_size,      
		g_tx_fifo_size      =>  g_tx_fifo_size,      
		g_mode				=>  g_mode				
	)
	port map( 
		-- clock & reset signals
		clock               =>	clock,					           
		clock_b             =>  clock_b,        
		reset               =>  sync_reset, 
		
		-- Data Channels          
		Tx_data             =>  s_cmd_spw_out.spw_tx.wdata,               
		Tx_OR               =>  spw_tx_OR,        
		Tx_IR               =>  spw_tx_IR,                 
      
		Rx_data             =>  s_reply_spw_in.spw_rx.rdata,         
		Rx_OR               =>  spw_rx_OR,         
		Rx_IR               =>  spw_rx_IR,         
		
		-- Error Channels 
		Rx_ESC_ESC          =>  spw_rx_ESC_ESC_bool,      
		Rx_ESC_EOP          =>  spw_rx_ESC_EOP_bool,      
		Rx_ESC_EEP          =>  spw_rx_ESC_EEP_bool,      
		Rx_Parity_error     =>  spw_rx_Parity_error_bool, 
		Rx_bits             =>  spw_rx_bits_num,     
		Rx_rate             =>  spw_rx_rate,         
   
		-- Time Code Channels
		Rx_Time             =>  rx_time,         
		Rx_Time_OR          =>  spw_rx_Time_OR,      
		Rx_Time_IR          =>  spw_rx_Time_IR,      

		Tx_Time             =>  tx_time,         
		Tx_Time_OR          =>  spw_tx_Time_OR,      
		Tx_Time_IR          =>  spw_tx_Time_IR,      
    
		-- Control Channels           	
		Disable             =>  to_bool(spw_Disable),         
		Connected           =>  spw_Connected_bool,       
		Error_select        =>  spw_Error_select,    
		Error_inject        =>  to_bool(spw_Error_inject),    
		
		-- DDR/SDR IO, only when "custom" mode is used
		-- when instantiating, if not used, you can ignore these ports. 
		DDR_din_r			=>	DDR_din_r,		
		DDR_din_f           =>  DDR_din_f,   
		DDR_sin_r           =>  DDR_sin_r,   
		DDR_sin_f           =>  DDR_sin_f,   
		SDR_Dout			=>  SDR_Dout,	
		SDR_Sout			=>  SDR_Sout,	

		-- SpW IO Ports, not used when "custom" mode.  	                
		Din_p               =>  Din_p,  	-- Used when Diff & Single     
		Din_n               =>  Din_n,      -- Used when Diff only
		Sin_p               =>  Sin_p,  	-- Used when Diff & Single       
		Sin_n               =>  Sin_n,      -- Used when Diff only
		Dout_p              =>  Dout_p,		-- Used when Diff & Single      
		Dout_n              =>  Dout_n,     -- Used when Diff only
		Sout_p              =>  Sout_p,  	-- Used when Diff & Single      
		Sout_n              =>  Sout_n     	-- Used when Diff only
	);
	
	gen_tx_interface: if(g_tx_fifo_interface  = true) generate
	
		u_rmap_tx_controller: entity rmap_command_controller
		port map( 
			-- standard register control signals --
			clock			=> 	clock,					-- clk input, rising edge trigger
			rst_in			=>	sync_reset,					-- reset input, active high
			enable  		=> 	enable,					-- enable input, asserted high. 
			
			logic_in		=>	cmd_channel_in,			    -- logic_input signals as record
			logic_out		=> 	cmd_channel_out,		      	-- logic_output signals as record
			spw_in			=>	s_cmd_spw_in,		
			spw_out			=> 	s_cmd_spw_out	
		);
		
		
	else generate
		u_rmap_tx_controller: entity rmap_command_controller_parallel_interface(rtl)
		port map( 
			-- standard register control signals --
			clock					=> 	clock				,			-- clk logic_input, rising edge trigger
			rst_in					=> 	sync_reset			,			-- reset logic_input, active high
			enable  				=> 	enable				,			-- enable logic_input, asserted high. 
			
			tx_logical_address		=>	tx_logical_address	,
			tx_protocol_id			=>  tx_protocol_id		,
			tx_instruction			=>  tx_instruction		,
			tx_Key	    			=>  tx_Key	    		,
			tx_reply_addresses		=>  tx_reply_addresses	,
			tx_init_log_addr	    =>  tx_init_log_addr	,
			tx_Tranaction_ID		=>  tx_Tranaction_ID	,
			tx_Address   			=>  tx_Address   		,
			tx_Data_Length     		=>  tx_Data_Length     	,
		
			tx_header_ready			=>  tx_header_ready		,
			tx_header_valid 		=>  tx_header_valid 	,
		
			tx_data					=>  tx_data				,
			tx_data_valid			=>  tx_data_valid		,
			tx_data_ready			=>  tx_data_ready		,

			tx_error				=>  tx_error			,
			tx_error_valid			=>  tx_error_valid		,
			tx_error_ready			=>  tx_error_ready		,
			
			spw_in					=> 	s_cmd_spw_in		,
			spw_out					=>	s_cmd_spw_out
		
		);
		
	
	end generate gen_tx_interface;
	
	gen_rx_interface: if(g_rx_fifo_interface  = true) generate
	
		u_rmap_rx_controller: entity rmap_reply_controller
		port map( 
			-- standard register control signals --
			clk_in          	=>	clock,						-- clk input, rising edge trigger
			rst_in				=>	sync_reset,					-- reset input, active high
			rx_enable  			=>	rx_enable,					-- enable input, asserted high. 

			logic_in            =>	reply_channel_in,
			logic_out           =>	reply_channel_out,
			spw_in            	=>	s_reply_spw_in,
			spw_out            	=>	s_reply_spw_out	
		);
		
	else generate
		
		u_rmap_rx_controller: entity rmap_reply_controller_parallel_interface(rtl)
		port map( 
			-- standard register control signals --
			clk_in					=> 	clock				,				-- clk input, rising edge trigger
			rst_in					=> 	sync_reset			,				-- reset input, active high
			rx_enable  				=> 	rx_enable			,			-- enable input, asserted high. 
			
			rx_init_log_addr		=>	rx_init_log_addr	,	
			rx_protocol_id			=>	rx_protocol_id		,	
			rx_instruction			=>	rx_instruction		,	
			rx_Status	    		=>	rx_Status	    	,	
			rx_target_log_addr		=>	rx_target_log_addr	,	 
			rx_Tranaction_ID		=>	rx_Tranaction_ID	,	
			rx_Data_Length     		=>	rx_Data_Length     	,	

			rx_header_ready			=>	rx_header_ready		,	
			rx_header_valid 		=>	rx_header_valid 	,	

			rx_data					=>	rx_data				,	
			rx_data_valid			=>	rx_data_valid		,	
			rx_data_ready			=>	rx_data_ready		,	

			rx_error				=>	rx_error			,	
			rx_error_valid			=>	rx_error_valid		,	
			rx_error_ready			=>	rx_error_ready		,	
	
			crc_good				=>	crc_good			,			
			
			spw_in					=>	s_reply_spw_in		,
			spw_out					=>	s_reply_spw_out	
		);
	
	end generate gen_rx_interface;

	
	----------------------------------------------------------------------------------------------------------------------------
	-- Component Instantiations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Asynchronous Signal Assignments --
	----------------------------------------------------------------------------------------------------------------------------
	-- timecode channels --
	spw_tx_Time_OR 	<= to_bool(tx_time_valid);
	tx_time_ready 	<= to_std(spw_Tx_Time_IR);
	
	rx_time_valid	<= to_std(spw_rx_time_OR);
	spw_rx_time_IR 	<= to_bool(rx_time_ready);
	
	s_cmd_spw_in.spw_tx.wready <= to_std(spw_Tx_IR);
	spw_Tx_OR <= to_bool(s_cmd_spw_out.spw_tx.wvalid);
	
	s_reply_spw_in.spw_rx.rvalid <= to_std(spw_rx_OR);
	spw_Rx_IR <= to_bool(s_reply_spw_out.spw_rx.rready);
	
	-- status channels
	s_cmd_spw_in.link_connected 	<= to_std(spw_Connected_bool);
	s_reply_spw_in.link_connected 	<= to_std(spw_Connected_bool);
	
	spw_Connected 		<= to_std(spw_Connected_bool);
	spw_Rx_ESC_ESC      <= to_std(spw_rx_ESC_ESC_bool);
	spw_Rx_ESC_EOP      <= to_std(spw_rx_ESC_EOP_bool);
	spw_Rx_ESC_EEP      <= to_std(spw_rx_ESC_EEP_bool);
	spw_Rx_Parity_error <= to_std(spw_rx_Parity_error_bool);
	
	spw_rx_bits <= std_logic_vector(to_unsigned(spw_rx_bits_num, spw_rx_bits'length));

	
	----------------------------------------------------------------------------------------------------------------------------
	-- Synchronous Processes --
	----------------------------------------------------------------------------------------------------------------------------
	reset_sync: process(clock)
    begin
        if(rising_edge(clock)) then
            sync_reset <= rst_in;
        end if;
    end process;



end rtl;