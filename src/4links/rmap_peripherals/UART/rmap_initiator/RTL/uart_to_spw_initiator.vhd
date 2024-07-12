----------------------------------------------------------------------------------------------------------------------------------
-- File Description  --
----------------------------------------------------------------------------------------------------------------------------------
-- @ File Name				:	uart_to_spw_initiator.vhd
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
use work.all;

----------------------------------------------------------------------------------------------------------------------------------
-- Package Declarations --
----------------------------------------------------------------------------------------------------------------------------------
context work.rmap_context;

----------------------------------------------------------------------------------------------------------------------------------
-- Entity Declarations --
----------------------------------------------------------------------------------------------------------------------------------
entity uart_to_spw_initiator is
	generic(
		g_clk_freq  : integer := 20_000_000;
		g_mode		: string  := "custom"
	);
    port( 
        -- standard register control signals --
        clk_in_p		: in 	std_logic := '0';		-- clk input, rising edge trigger
		clk_in_n		: in 	std_logic := '0';		-- clk input, rising edge trigger
        rst_in			: in 	std_logic := '0';		-- reset input, active high
        enable  		: in 	std_logic := '0';		-- enable input, asserted high. 
		
		-- UART Ports --
		UART_RX			: in 	std_logic := '0';		-- UART RX Pin
		UART_TX			: out 	std_logic := '0';		-- UART TX Pin
		
		-- Status LEDS --
		Connected_LED	: out 	std_logic := '0';		-- Connected LED, Asserted when SpaceWire CoDec registers as Connected 
		
		-- SpW IO (custom)
		DDR_din_r		: in 	std_logic := '0';
		DDR_din_f       : in	std_logic := '0';
		DDR_sin_r       : in	std_logic := '0';
		DDR_sin_f       : in	std_logic := '0';
		SDR_Dout		: out	std_logic := '0';
		SDR_Sout		: out	std_logic := '0';
		
		-- SpW IO (diff & single)
		Din_p			: in 	std_logic := '0';
		Din_n           : in 	std_logic := '0';
		Sin_p           : in 	std_logic := '0';
		Sin_n           : in 	std_logic := '0';
		Dout_p          : out 	std_logic := '0';
		Dout_n          : out 	std_logic := '0';
		Sout_p          : out 	std_logic := '0';
		Sout_n          : out 	std_logic := '0'
		
    );
end uart_to_spw_initiator;


---------------------------------------------------------------------------------------------------------------------------------
-- Code Description & Developer Notes --
---------------------------------------------------------------------------------------------------------------------------------


architecture rtl of uart_to_spw_initiator is

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
	-- Component Declarations --
	----------------------------------------------------------------------------------------------------------------------------

	----------------------------------------------------------------------------------------------------------------------------
	-- Signal Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	signal 	reset_sync					: 	std_logic 						:= '0';
	
	signal 	locked_en					:	std_logic 						:= '0';
	signal	rx_enable					: 	std_logic := '0';
	signal	tx_time						: 	std_logic_vector(7 downto 0) := (others => '0');
	signal	tx_time_valid				: 	std_logic := '0';
	signal	tx_time_ready				: 	std_logic := '0';
	signal	rx_time						: 	std_logic_vector(7 downto 0) := (others => '0');
	signal	rx_time_valid				: 	std_logic := '0';
	signal	rx_time_ready				: 	std_logic := '0';
	signal	tx_error					: 	std_logic_vector(7 downto 0) := (others => '0');
	signal	tx_error_valid				: 	std_logic := '0';
	signal	tx_error_ready				: 	std_logic := '1';
	signal	rx_error					: 	std_logic_vector(7 downto 0) := (others => '0');
	signal	rx_error_valid				: 	std_logic := '0';
	signal	rx_error_ready				: 	std_logic := '0';
	signal	tx_header_valid				: 	std_logic := '0';
	signal	tx_header_ready				: 	std_logic := '0';
	signal	tx_data						: 	std_logic_vector(7 downto 0) := (others => '0');
	signal	tx_data_valid				: 	std_logic := '0';
	signal	tx_data_ready				: 	std_logic := '0';
	signal	rx_header_valid				: 	std_logic := '0';
	signal	rx_header_ready 			: 	std_logic := '0';
	signal	rx_data						: 	std_logic_vector(7 downto 0) := (others => '0');
	signal	rx_data_valid				: 	std_logic := '0';
	signal	rx_data_ready 				: 	std_logic := '0';
	signal	tx_logical_address			: 	t_byte := (others => '0');
	signal	tx_protocol_id				: 	t_byte := (others => '0');
	signal	tx_instruction				: 	t_byte := (others => '0');
	signal	tx_Key	    				: 	t_byte := (others => '0');
	signal	tx_reply_addresses			: 	t_byte_array(0 to 11) := (others => (others => '0'));
	signal	tx_init_log_addr	    	: 	t_byte := (others => '0');
	signal	tx_Tranaction_ID			: 	std_logic_vector(15 downto 0) := (others => '0');
	signal	tx_Address   				: 	std_logic_vector(39 downto 0) := (others => '0');
	signal	tx_Data_Length     			: 	std_logic_vector(23 downto 0) := (others => '0');
	signal	rx_logical_address			: 	t_byte := (others => '0');
	signal	rx_protocol_id				: 	t_byte := (others => '0');
	signal	rx_instruction				: 	t_byte := (others => '0');
	signal	rx_Status	    			: 	t_byte := (others => '0');
	signal	rx_target_log_addr			: 	t_byte := (others => '0');
	signal	rx_init_log_addr	    	: 	t_byte := (others => '0');
	signal	rx_Tranaction_ID			: 	std_logic_vector(15 downto 0) := (others => '0');
	signal	rx_Data_Length     			: 	std_logic_vector(23 downto 0) := (others => '0');
	signal	crc_good					: 	std_logic := '1';
	signal	spw_Rx_ESC_ESC      		: 	std_logic := '0';                                   
	signal	spw_Rx_ESC_EOP      		: 	std_logic := '0';                                   
	signal	spw_Rx_ESC_EEP      		: 	std_logic := '0';                                   
	signal	spw_Rx_Parity_error 		: 	std_logic := '0';                                   
	signal	spw_Rx_bits         		: 	std_logic_vector(1 downto 0) := (others => '0');	
	signal	spw_Rx_rate         		: 	std_logic_vector(15 downto 0) := (others => '0');     
	signal	spw_Disable     			: 	std_logic := '0';                                   
	signal	spw_Connected       		: 	std_logic := '0';                                   
	signal	spw_Error_select    		: 	std_logic_vector(3 downto 0) := (others => '0');   
	signal  spw_Error_inject        	:   std_logic := '0'; 
	
	signal 	UART_tx_data		    	:	t_byte 		:= (others => '0');
	signal 	UART_tx_valid				:	std_logic 	:= '0';	
	signal 	UART_tx_ready				:	std_logic 	:= '0';
	
	signal 	UART_rx_data		   		:	t_byte 		:= (others => '0');
	signal 	UART_rx_valid	    		:	std_logic 	:= '0';		
	signal 	UART_rx_ready	    		:	std_logic 	:= '0';	
    signal 	UART_rx_error	    		:	std_logic 	:= '0';	
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Variable Declarations --
	----------------------------------------------------------------------------------------------------------------------------

	
	----------------------------------------------------------------------------------------------------------------------------
	-- Attribute Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
begin

	----------------------------------------------------------------------------------------------------------------------------
	-- Entity Instantiations --
	----------------------------------------------------------------------------------------------------------------------------


	-- instantiate RMAP Initiator + SpaceWire CoDec (use parallel IO mode)
	u_initiator_inst: entity rmap_initiator_top_level(rtl)
	generic map(
		g_clock_freq		=>  	g_clk_freq * 1.0	,	-- convert from integer to REAL type
		g_tx_fifo_size		=>  	16					,
		g_rx_fifo_size		=>	 	16					,
		g_tx_fifo_interface	=> 		false				,
		g_rx_fifo_interface	=> 		false				,
		g_mode				=>		g_mode       			-- Diff, Single or Custom. Use Custom and put DDR registers outside of core
	)
	port map( 
		-- Standard Register Channels --
		clock				=> clk_in_p					,
		clock_b				=> clk_in_n				,
		rst_in				=> reset_sync				,
		enable  			=> '1'						,
			
		tx_time				=> tx_time					,	
		tx_time_valid		=> tx_time_valid		    ,
		tx_time_ready		=> tx_time_ready		    ,

		rx_time				=> rx_time				    ,
		rx_time_valid		=> rx_time_valid		    ,
		rx_time_ready		=> rx_time_ready		    ,

		tx_error			=> tx_error			        ,
		tx_error_valid		=> tx_error_valid		    ,
		tx_error_ready		=> tx_error_ready		    ,

		rx_error			=> rx_error			        ,
		rx_error_valid		=> rx_error_valid		    ,
		rx_error_ready		=> rx_error_ready		    ,

		tx_header_valid		=> tx_header_valid		    ,
		tx_header_ready		=> tx_header_ready		    ,

		tx_data				=> tx_data				    ,
		tx_data_valid		=> tx_data_valid		    ,
		tx_data_ready		=> tx_data_ready		    ,

		rx_header_valid		=> rx_header_valid		    ,
		rx_header_ready 	=> rx_header_ready 	        ,

		rx_data				=> rx_data				    ,
		rx_data_valid		=> rx_data_valid		    ,
		rx_data_ready 		=> rx_data_ready 		    ,

		tx_logical_address	=> tx_logical_address	    ,
		tx_protocol_id		=> tx_protocol_id		    ,
		tx_instruction		=> tx_instruction		    ,
		tx_Key	    		=> tx_Key	    		    ,
		tx_reply_addresses	=> tx_reply_addresses	    ,
		tx_init_log_addr	=> tx_init_log_addr	        ,
		tx_Tranaction_ID	=> tx_Tranaction_ID	        ,
		tx_Address   		=> tx_Address   		    ,
		tx_Data_Length     	=> tx_Data_Length     	    ,
	
		rx_init_log_addr	=> rx_init_log_addr	        ,
		rx_protocol_id		=> rx_protocol_id		    ,
		rx_instruction		=> rx_instruction		    ,
		rx_Status	    	=> rx_Status	    	    ,
		rx_target_log_addr	=> rx_target_log_addr	    ,
		rx_Tranaction_ID	=> rx_Tranaction_ID	        ,
		rx_Data_Length     	=> rx_Data_Length     	    ,
	
		crc_good			=> crc_good			        ,

		spw_Rx_ESC_ESC      => spw_Rx_ESC_ESC           ,
		spw_Rx_ESC_EOP      => spw_Rx_ESC_EOP           ,
		spw_Rx_ESC_EEP      => spw_Rx_ESC_EEP           ,
		spw_Rx_Parity_error => spw_Rx_Parity_error      ,
		spw_Rx_bits         => spw_Rx_bits              ,
		spw_Rx_rate         => spw_Rx_rate              ,
		spw_Disable     	=> spw_Disable     	        ,
		spw_Connected       => spw_Connected            ,
		spw_Error_select    => spw_Error_select         ,
		spw_Error_inject    => spw_Error_inject         ,

		DDR_din_r			=> DDR_din_r			    ,
		DDR_din_f           => DDR_din_f                ,
		DDR_sin_r           => DDR_sin_r                ,
		DDR_sin_f           => DDR_sin_f                ,
		SDR_Dout			=> SDR_Dout			        ,
		SDR_Sout			=> SDR_Sout					,
		
		Din_p				=> Din_p					,	
		Din_n               => Din_n                    ,
		Sin_p               => Sin_p                    ,
		Sin_n               => Sin_n                    ,
		Dout_p              => Dout_p                   ,
		Dout_n              => Dout_n                   ,
		Sout_p              => Sout_p                   ,
		Sout_n              => Sout_n  
		
    );
	
	-- instantiate UART controller Logic (also contains AXI-Lite UART IP)
	u_uart_inst: entity uart_ip_4l_axi(rtl)
	generic map(
		g_clk_freq  => (g_clk_freq)		,  	--	frequency of system clock in Hertz
		g_baud_rate => 9_600			,   --	data link baud rate in bits/second
		g_parity    => 0				,   --	0 for no parity, 1 for parity
		g_parity_eo => '0'					--	'0' for even, '1' for odd parity
	)
	port map( 
		
		-- standard register control signals --
		clk_in		=>	clk_in_p			,
		rst_in		=>  reset_sync     		,
		
		tx_data		=>	UART_tx_data		,
		tx_valid	=>	UART_tx_valid		,
		tx_ready	=>	UART_tx_ready		,

		rx_data		=>	UART_rx_data		,
		rx_valid 	=>	UART_rx_valid		,
		rx_ready	=>	UART_rx_ready		,
		rx_error 	=>	UART_rx_error		,

		UART_TX		=>	UART_TX				,
		UART_RX 	=>	UART_RX		
		
    );

	
	-- responsible for UART RX data to RMAP command/ TimeCode Broadcast conversion
	uart_cmd_logic_inst: entity rmap_command_logic(rtl)
	port map( 
		
		clk_in					=>	clk_in_p						,			
		rst_in					=>	reset_sync					,

		UART_in					=>	UART_rx_data				,
		UART_in_valid			=>	UART_rx_valid          		,
		UART_in_ready			=>	UART_rx_ready         	 	,

		INIT_tx_time			=>	tx_time						,
		INIT_tx_time_valid	    =>	tx_time_valid	            ,
		INIT_tx_time_ready	    =>	tx_time_ready	            ,

		INIT_tx_logical_address	=>	tx_logical_address			,
		INIT_tx_protocol_id		=>  tx_protocol_id		        ,
		INIT_tx_instruction		=>  tx_instruction		        ,
		INIT_tx_Key	    		=>  tx_Key	    		        ,
		INIT_tx_reply_addresses	=>  tx_reply_addresses	        ,
		INIT_tx_init_log_addr	=>  tx_init_log_addr	        ,
		INIT_tx_Tranaction_ID	=>  tx_Tranaction_ID	        ,
		INIT_tx_Address   		=>  tx_Address   		        ,
		INIT_tx_Data_Length     =>  tx_Data_Length     	        ,

		INIT_tx_header_valid   	=>	tx_header_valid				,
		INIT_tx_header_ready	=>	tx_header_ready				,

		INIT_tx_data			=>	tx_data						,
		INIT_tx_data_valid	    =>	tx_data_valid	            ,
		INIT_tx_data_ready	    =>	tx_data_ready	            

    );
	
	-- responsible for RMAP replies/received timecode to UART TX 
	uart_reply_logic_inst: entity rmap_reply_logic(rtl)
	port map( 
		
		-- standard register control signals --
		clk_in						=>	clk_in_p				,
		rst_in						=>	reset_sync			,

		UART_out  					=>	UART_tx_data		,
		UART_valid					=>	UART_tx_valid		,
		UART_ready					=>	UART_tx_ready		,
		
		INIT_rx_enable				=>	rx_enable			,
		INIT_rx_error				=>	rx_error			,
		INIT_rx_error_valid			=>	rx_error_valid		,
		INIT_rx_error_ready			=>	rx_error_ready		,
		
		INIT_rx_time				=>	rx_time				,				
		INIT_rx_time_valid 			=>  rx_time_valid 		,	
		INIT_rx_time_ready			=>  rx_time_ready		,	
	
		INIT_rx_data				=>  rx_data				,	
		INIT_rx_data_valid			=>  rx_data_valid		,	
		INIT_rx_data_ready 			=>  rx_data_ready 		,	

		INIT_rx_init_log_addr	    =>  rx_init_log_addr	,    
		INIT_rx_protocol_id			=>  rx_protocol_id		,	
		INIT_rx_instruction			=>  rx_instruction		,	
		INIT_rx_Status	    		=>  rx_Status	    	,	
		INIT_rx_target_log_addr		=>  rx_target_log_addr	,	
		INIT_rx_Tranaction_ID		=>  rx_Tranaction_ID	,	
		INIT_rx_Data_Length     	=>  rx_Data_Length     	,	

		INIT_rx_header_valid		=>  rx_header_valid		,	
		INIT_rx_header_ready 		=>  rx_header_ready 	,	

		INIT_crc_good				=>  crc_good				
		
    );
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Component Instantiations --
	----------------------------------------------------------------------------------------------------------------------------

	----------------------------------------------------------------------------------------------------------------------------
	-- Asynchronous Signal Assignments --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Synchronous Processes --
	----------------------------------------------------------------------------------------------------------------------------
	rst_proc: process(clk_in_p)
	begin
		if(rising_edge(clk_in_p)) then
			reset_sync <= rst_in;
			if(reset_sync = '1') then
				Connected_LED <= '0';
			else
				Connected_LED <= spw_Connected;
			end if;
		end if;
	end process;


end rtl;