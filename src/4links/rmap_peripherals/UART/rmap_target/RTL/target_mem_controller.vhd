----------------------------------------------------------------------------------------------------------------------------------
-- File Description  --
----------------------------------------------------------------------------------------------------------------------------------
-- @ File Name				:	target_mem_controller
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
-- use work.ip4l_data_types.all;
context work.rmap_context;
----------------------------------------------------------------------------------------------------------------------------------
-- Entity Declarations --
----------------------------------------------------------------------------------------------------------------------------------
entity target_mem_controller is
	generic( 
		g_log_addr 	: t_byte := x"F3"				-- controller Target Logical address
	);
	port( 
		
		-- standard register control signals --
		clk_in						: in 	std_logic := '0';		-- clk input, rising edge trigger
		rst_in						: in 	std_logic := '0';		-- reset input, active high
		
		
		-- UART Interface
		UART_tx_data		    	: out	t_byte 							:= (others => '0');
		UART_tx_valid				: out	std_logic 						:= '0';	
		UART_tx_ready				: in	std_logic 						:= '0';
		
		UART_rx_data		   		: in	t_byte 							:= (others => '0');
		UART_rx_valid	    		: in	std_logic 						:= '0';		
		UART_rx_ready	    		: out	std_logic 						:= '0';	
		UART_rx_error	    		: in	std_logic 						:= '0';	
		
		-- Memory Interface
		mem_wr_enable				: out	std_logic 						:= '0';
		mem_address	            	: out	std_logic_vector(3 downto 0) 	:= (others => '0');
		mem_wr_data		            : out	std_logic_vector(7 downto 0) 	:= (others => '0');
		mem_rd_data		            : in	std_logic_vector(7 downto 0) 	:= (others => '0');
		
		-- GPIO Interface 
		gpio_wr_enable				: out	std_logic 						:= '0';
		gpio_wr_data		        : out	std_logic_vector(7 downto 0) 	:= (others => '0');
		gpio_rd_data		        : in	std_logic_vector(7 downto 0) 	:= (others => '0');
		
		-- LED outputs
		LED_wr_enable				: out	std_logic 						:= '0';
		LED_wr_data		        	: out	std_logic_vector(3 downto 0) 	:= (others => '0');
		LED_rd_data		        	: in	std_logic_vector(3 downto 0) 	:= (others => '0');
		
		Address            			: in	std_logic_vector(39 downto 0)	:= (others => '0');
		wr_en              			: in	std_logic 						:= '0';
		Write_data         			: in	std_logic_vector( 7 downto 0)	:= (others => '0');
		Read_data          			: out   std_logic_vector( 7 downto 0)	:= (others => '0');
		Read_bytes         			: out   std_logic_vector(23 downto 0)	:= (others => '0');

		-- Bus handshake
		RW_request         			: in 	std_logic						:= '0';
		RW_acknowledge     			: out   std_logic						:= '0';

		Logical_address    			: in 	std_logic_vector(7 downto 0)	:= (others => '0');

		Request            			: in 	std_logic						:= '0';
		Reject_request     			: out   std_logic						:= '0';
		Accept_request     			: out   std_logic						:= '0';

		Done               			: in 	std_logic						:= '0'
		
		
		
    );
end target_mem_controller;


---------------------------------------------------------------------------------------------------------------------------------
-- Code Description & Developer Notes --
---------------------------------------------------------------------------------------------------------------------------------


architecture rtl of target_mem_controller is

	----------------------------------------------------------------------------------------------------------------------------
	-- Constant Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	constant c_uart_addr : t_binary := b"00";		-- address values used for data mux 
	constant c_mem_addr  : t_binary := b"01"; 	-- address values used for data mux 
	constant c_led_addr  : t_binary := b"10"; 	-- address values used for data mux 
	constant c_gpio_addr : t_binary := b"11"; 	-- address values used for data mux 
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Type Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	type t_state is(
		idle			,
		check_log_addr	,
		rmap_accepted	
	);
	----------------------------------------------------------------------------------------------------------------------------
	-- Function Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Component Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Signal Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	signal con_state 	: t_state 	:= idle;
	signal addr_reg		: t_byte 	:= (others => '0');
	signal led_reg		: std_logic_vector(3 downto 0) := (others => '0');
	signal gpio_reg		: t_byte 	:= (others => '0');
	
	
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
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Component Instantiations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Asynchronous Signal Assignments --
	----------------------------------------------------------------------------------------------------------------------------

	----------------------------------------------------------------------------------------------------------------------------
	-- Synchronous Processes --
	----------------------------------------------------------------------------------------------------------------------------
	process(clk_in)
	begin
		if(rising_edge(clk_in)) then
			UART_tx_valid				<= '0';
			Read_data		 			<= (others => '0');
			RW_acknowledge 				<= '0';
			mem_wr_enable 				<= '0';
			mem_address					<= (others => '0');
			mem_wr_data					<= (others => '0');
			gpio_wr_enable				<= '0'; 	
			gpio_wr_data				<= (others => '0');
			LED_wr_enable				<= '0';
			LED_wr_data					<= (others => '0');
		
			if(rst_in = '1') then
				con_state <= idle;
			else
				case con_state is
					
					when idle => 
						if(Request = '1') then
							con_state <= check_log_addr;
						end if;
					
					when check_log_addr =>
					
						accept_request <= '0';
						accept_request <= '1';
						addr_reg <= address(7 downto 0);
						
						if(logical_address = g_log_addr) then
							Reject_request <= '0';
							accept_request <= '1';
							con_state <= rmap_accepted;
						end if;
						
					when rmap_accepted =>	
			
						RW_acknowledge 	<= '1';

						case addr_reg(7 downto 6) is
							when c_uart_addr 	=>
							
								UART_tx_data 	<= Write_data;
								UART_tx_valid	<= RW_request;
								RW_acknowledge 	<= UART_tx_ready;
								
							when c_mem_addr	=>
								
								mem_wr_enable	<=	wr_en;
								mem_address		<=  address(5 downto 2);
								mem_wr_data		<=  Write_data; 
								Read_data 		<=  mem_rd_data;
								
							when c_gpio_addr    =>
							
								gpio_wr_enable	<=	wr_en;
								gpio_wr_data	<=  Write_data;		
								Read_data 		<=  gpio_rd_data;	
								
						    when c_led_addr    	=>
							
								LED_wr_enable			<= wr_en;
							    LED_wr_data		    	<= Write_data(3 downto 0);
								Read_data(3 downto 0) 	<=  LED_rd_data;	
							    
							when others =>
								null;
						end case;
						
						if(Done = '1') then
							con_state <= idle;
						end if;

				end case;
			
			end if;
		end if;
	end process;
	
end rtl;