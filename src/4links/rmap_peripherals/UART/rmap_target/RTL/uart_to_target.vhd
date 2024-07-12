----------------------------------------------------------------------------------------------------------------------------------
-- File Description  --
----------------------------------------------------------------------------------------------------------------------------------
-- @ File Name				:	uart_to_target
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
-- use work.ip4l_data_types.all;
context work.rmap_context;
----------------------------------------------------------------------------------------------------------------------------------
-- Entity Declarations --
----------------------------------------------------------------------------------------------------------------------------------
entity uart_to_target is
	generic(
		g_clk_freq 		: integer 	:= 20_000_000;
		g_mode			: string 	:= "custom";
		g_target_addr	: t_byte 	:= x"F3"
	);
    port( 
        
        -- standard register control signals --
        clk_in_p		: in 	std_logic 						:= '0';		-- clk input, rising edge trigger
		clk_in_n		: in 	std_logic 						:= '0';		-- clk input, rising edge trigger
		
        rst_in			: in 	std_logic 						:= '0';		-- reset input, active high
		
		-- UART Ports --
		UART_RX			: in 	std_logic 						:= '0';		-- UART RX Pin
		UART_TX			: out 	std_logic 						:= '0';		-- UART TX Pin
		
		GPIO_OUT		: out 	std_logic_vector(7 downto 0) 	:= (others => '0');
		
		LED_OUT			: out 	std_logic_vector(3 downto 0) 	:= (others => '0');
		
		-- Status LEDS --
		Connected_LED	: out 	std_logic 						:= '0';		-- Connected LED, Asserted when SpaceWire CoDec registers as Connected 
		
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
end uart_to_target;


---------------------------------------------------------------------------------------------------------------------------------
-- Code Description & Developer Notes --
---------------------------------------------------------------------------------------------------------------------------------


architecture rtl of uart_to_target is

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
	
	signal  locked_en                   : 	std_logic 						:= '0';
	
	signal 	UART_tx_data		    	:	t_byte 							:= (others => '0');
	signal 	UART_tx_valid				:	std_logic 						:= '0';	
	signal 	UART_tx_ready				:	std_logic 						:= '0';
	
	signal 	UART_rx_data		   		:	t_byte 							:= (others => '0');
	signal 	UART_rx_valid	    		:	std_logic 						:= '0';		
	signal 	UART_rx_ready	    		:	std_logic 						:= '0';	
    signal 	UART_rx_error	    		:	std_logic 						:= '0';	
	
	signal 	target						: 	r_rmap_target_interface			:=  c_rmap_target_interface;	-- create array of target interfaces
	
	signal 	mem_wr_enable				:	std_logic 						:= '0';
	signal 	mem_wr_address	            :	std_logic_vector(3 downto 0) 	:= (others => '0');
	signal 	mem_wr_data		            :	std_logic_vector(7 downto 0) 	:= (others => '0');
	signal 	mem_rd_data		            :	std_logic_vector(7 downto 0) 	:= (others => '0');
	
	signal 	gpio_wr_enable				: 	std_logic 						:= '0';		
	signal 	gpio_wr_data		    	:	std_logic_vector(7 downto 0) 	:= (others => '0');
	signal 	gpio_rd_data		        :	std_logic_vector(7 downto 0) 	:= (others => '0');

	signal 	LED_wr_enable				: 	std_logic 						:= '0';		
	signal 	LED_wr_data		            :	std_logic_vector(3 downto 0) 	:= (others => '0');
	signal 	LED_rd_data		            :	std_logic_vector(3 downto 0) 	:= (others => '0');
	
	signal Connected_LED_reg            : 	std_logic := '0';
	
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
	
	target_inst: entity work.rmap_target_full(rtl)
	generic map(
		g_freq 			=> g_clk_freq * 1.0,
		g_fifo_depth 	=> 16,
		g_mode			=> g_mode
	)
	port map( 
		
		clock              		=> 	clk_in_p,
		clock_b			   		=> 	clk_in_n,
		async_reset        		=> 	reset_sync,
		reset              		=> 	reset_sync,
		
		Rx_Time              	=>	target.Rx_Time  				,  
		Rx_Time_OR           	=>	target.Rx_Time_OR           	,
		Rx_Time_IR           	=>	target.Rx_Time_IR           	,
	
		Tx_Time              	=>	target.Tx_Time              	,
		Tx_Time_OR           	=>  target.Tx_Time_OR           	,
		Tx_Time_IR           	=>  target.Tx_Time_IR           	,

		Rx_ESC_ESC           	=>	target.Rx_ESC_ESC           	,
		Rx_ESC_EOP           	=>  target.Rx_ESC_EOP           	,
		Rx_ESC_EEP           	=>  target.Rx_ESC_EEP           	,
		Rx_Parity_error      	=>  target.Rx_Parity_error      	,
		Rx_bits              	=>  target.Rx_bits              	,
		Rx_rate              	=>  target.Rx_rate             		,
	
		Disable              	=>	target.Disable              	,
		Connected            	=>  Connected_LED_reg       		,
		Error_select         	=>  target.Error_select         	,
		Error_inject         	=>  target.Error_inject         	,

		-- SpW	     
		DDR_din_r				=> 	DDR_din_r						,
		DDR_din_f               => 	DDR_din_f   					,
		DDR_sin_r               => 	DDR_sin_r   					,
		DDR_sin_f               => 	DDR_sin_f   					,
		SDR_Dout	            => 	SDR_Dout						,
		SDR_Sout	            => 	SDR_Sout						,
		
		Din_p					=> 	Din_p							,			
		Din_n                   => 	Din_n                           ,
		Sin_p                   => 	Sin_p                           ,
		Sin_n                   => 	Sin_n                           ,
		Dout_p                  => 	Dout_p                          ,
		Dout_n                  => 	Dout_n                          ,
		Sout_p                  => 	Sout_p                          ,
		Sout_n                  => 	Sout_n                          ,
		
		-- Memory Interface                                         
		Address           	 	=>	target.Address              	,
		wr_en             	 	=>  target.wr_en                	,
		Write_data        	 	=>  target.Write_data           	,
		Bytes             	 	=>  target.Bytes                	,	-- connect together BYTES and READ_BYTES...
		Read_data         	 	=>  target.Read_data            	,
		Read_bytes        	 	=>  target.Bytes                	,
	
		-- Bus handshake                                            
		RW_request         		=>	target.RW_request           	,
		RW_acknowledge     		=>  target.RW_acknowledge       	,
		
		-- Control/Status                                           
		Echo_required      		=>	target.Echo_required        	,
		Echo_port          		=>  target.Echo_port            	,
	
		Logical_address    		=>	target.Logical_address      	,
		Key                		=>  target.Key                  	,
		Static_address     		=>  target.Static_address       	,
		
		Checksum_fail      		=>	target.Checksum_fail        	,
		
		Request            		=>	target.Request              	,
		Reject_target      		=>  target.Reject_target        	,
		Reject_key         		=>  target.Reject_key           	,
		Reject_request     		=>  target.Reject_request       	,
		Accept_request     		=>  target.Accept_request       	,
	
		Verify_overrun     		=>	target.Verify_overrun       	,

		OK                 		=>	target.OK                   	,
		Done               		=>	target.Done              
		
	);
	
	target_ram_inst:entity work.xilinx_single_port_single_clock_ram(rtl) 
	generic map(
		ram_type	=> "auto",			-- ram type to infer (auto, distributed, block, register, ultra)
		data_width	=> 8,				-- bit-width of ram element
		addr_width	=> 4,				-- address width of RAM
		ram_str		=> "HELLO_WORLD"		
	)
	port map(
		-- standard register control signals --
		clk_in 		=> clk_in_p,								-- clock in (rising_edge)
		enable_in 	=> '1',										-- enable input (active high)
		
		wr_en		=> mem_wr_enable	,
		addr		=> mem_wr_address	,
		wr_data     => mem_wr_data		,
		rd_data		=> mem_rd_data		
	);
	
	constroller_inst: entity target_mem_controller(rtl)
	generic map( 
		g_log_addr 	=> g_target_addr							-- controller Target Logical address
	)
	port map( 
		
		-- standard register control signals --
		clk_in						=> 	clk_in_p		,		-- clk input, rising edge trigger
		rst_in						=> 	reset_sync		,		-- reset input, active high
		
		-- UART Interface
		UART_tx_data		    	=>	UART_tx_data				,
		UART_tx_valid				=>  UART_tx_valid				,
		UART_tx_ready				=>  UART_tx_ready				,
		
		UART_rx_data		   		=>  UART_rx_data				,
		UART_rx_valid	    		=>  UART_rx_valid				,
		UART_rx_ready	    		=>  UART_rx_ready				,
		UART_rx_error	    		=>  UART_rx_error				,

		-- Memory Interface			
		mem_wr_enable				=>	mem_wr_enable				,
		mem_address	            	=>  mem_wr_address				,
		mem_wr_data		            =>  mem_wr_data					,
		mem_rd_data		            =>  mem_rd_data					,

		-- GPIO Interface 			
		gpio_wr_enable				=>	gpio_wr_enable				,
		gpio_wr_data		        =>  gpio_wr_data				,
		gpio_rd_data		        =>  gpio_rd_data				,

		-- LED outputs			
		LED_wr_enable				=>	LED_wr_enable				,
		LED_wr_data		        	=>  LED_wr_data					,
		LED_rd_data		        	=>  LED_rd_data					,

		Address						=>	target.Address				,					            			
        wr_en              			=>	target.wr_en       			,	
        Write_data         			=>	target.Write_data  			,	
        Read_data          			=>	target.Read_data   			,	
        Read_bytes         			=>	target.Read_bytes  			,	

        -- Bus handshake          				                    
        RW_request         			=>	target.RW_request     		,		
        RW_acknowledge     			=>	target.RW_acknowledge 		,		

        Logical_address    			=>	target.Logical_address		,		

        Request            			=>	target.Request        		,		
        Reject_request     			=>	target.Reject_request 		,		
        Accept_request     			=>	target.Accept_request 		,		
 
        Done               			=>	target.Done           				

    );

	----------------------------------------------------------------------------------------------------------------------------
	-- Component Instantiations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Asynchronous Signal Assignments --
	----------------------------------------------------------------------------------------------------------------------------
	gpio_rd_data 	<= GPIO_OUT;
	LED_rd_data 	<= LED_OUT;
	Connected_LED <= not(Connected_LED_reg);
	----------------------------------------------------------------------------------------------------------------------------
	-- Synchronous Processes --
	----------------------------------------------------------------------------------------------------------------------------

	rst_proc: process(clk_in_p)
	begin
		if(rising_edge(clk_in_p)) then
			reset_sync <= rst_in;
		end if;
	end process;

	gpio_proc: process(clk_in_p)
	begin
		if(rising_edge(clk_in_p)) then
			if(reset_sync = '1') then
				GPIO_OUT <= (others => '0');
			else
				if(gpio_wr_enable = '1') then
					GPIO_OUT <= gpio_wr_data;
				end if;
			
			end if;
		end if;
	
	end process;
	
	led_proc: process(clk_in_p)
	begin
		if(rising_edge(clk_in_p)) then
			if(reset_sync = '1') then
				LED_OUT <= (others => '0');
			else
				if(LED_wr_enable = '1') then
					LED_OUT <= LED_wr_data;
				end if;
			end if;
		end if;
	end process;
	
	
end rtl;