----------------------------------------------------------------------------------------------------------------------------------
-- File Description  --
----------------------------------------------------------------------------------------------------------------------------------
-- @ File Name				:	uart_ip_4l_axi
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

----------------------------------------------------------------------------------------------------------------------------------
-- Entity Declarations --
----------------------------------------------------------------------------------------------------------------------------------
entity uart_ip_4l_axi is
	generic(
		g_clk_freq  :  integer    := 20_000_000;  	--	frequency of system clock in Hertz
		g_baud_rate :  integer    := 9_600;      	--	data link baud rate in bits/second
		g_parity    :  integer    := 1;           	--	0 for no parity, 1 for parity
		g_parity_eo :  std_logic  := '0'			--	'0' for even, '1' for odd parity
	);
	port( 
		
		-- standard register control signals --
		clk_in		: in 	std_logic := '0';		-- clk input, rising edge trigger
		rst_in		: in 	std_logic := '0';		-- reset input, active high
		
		tx_data		: in 	std_logic_vector(7 downto 0) := (others => '0');
		tx_valid	: in 	std_logic := '0';
		tx_ready	: out 	std_logic := '0';
		
		rx_data		: out 	std_logic_vector(7 downto 0) := (others => '0');
		rx_valid 	: out 	std_logic  := '0';
		rx_ready	: in 	std_logic  := '0';
		rx_error 	: out 	std_logic  := '0';
		
		UART_TX		: out 	std_logic := '0';
		UART_RX 	: in 	std_logic := '0'
		
    );
end uart_ip_4l_axi;


---------------------------------------------------------------------------------------------------------------------------------
-- Code Description & Developer Notes --
---------------------------------------------------------------------------------------------------------------------------------


architecture rtl of uart_ip_4l_axi is

	----------------------------------------------------------------------------------------------------------------------------
	-- Constant Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Type Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	type t_tx_state is (get_tx, submit);
	type t_rx_state is (get_rx, submit);
	----------------------------------------------------------------------------------------------------------------------------
	-- Function Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Component Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Signal Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	signal 	tx_state 		: t_tx_state := get_tx;
	signal 	rx_state 		: t_rx_state := get_rx;
	
	signal	tx_ena   		: std_logic := '0';                            					--	initiate transmission
	signal	tx_data_reg  	: std_logic_vector(7 downto 0) := (others => '0');  			--	data to transmit
	signal	tx_busy  		: std_logic := '0';                             				--	transmission in progress
	signal	tx_busy_old  	: std_logic := '0';                             				--	transmission in progress

	signal	rx_busy  		: std_logic := '0';                             				--	data reception in progress
	signal	rx_busy_old  	: std_logic := '0';                             				--	data reception in progress
	signal	rx_error_reg	: std_logic := '0';                             				--	start, parity, or stop bit error detected
	signal	rx_data_reg  	: std_logic_vector(7 downto 0) := (others => '0');  			--	data received
	
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
	-- instantiate UART entity 
	uart_inst: entity work.uart_ip_4l(rtl)
	generic map(
		clk_freq  	=> g_clk_freq  	,	--	frequency of system clock in Hertz
		baud_rate 	=> g_baud_rate 	,	--	data link baud rate in bits/second
		os_rate   	=> 32   		,	--	oversampling rate to find center of receive bits (in samples per baud period)
		d_width   	=> 8   			,	--	data bus width
		parity    	=> g_parity    	,	--	0 for no parity, 1 for parity
		parity_eo 	=> g_parity_eo 		--	'0' for even, '1' for odd parity
	)      
	port map(
		clk      	=> 	clk_in		,   --	system clock
		reset  		=> 	rst_in		,   --	synchronous reset
	
		tx_ena   	=>	tx_ena 		,  	--	initiate transmission
		tx_data  	=>  tx_data_reg ,	--	data to transmit
		tx_busy  	=>  tx_busy 	,	--	transmission in progress

		rx_busy  	=> 	rx_busy  	,	--	data reception in progress
		rx_error 	=>  rx_error_reg,	--	start, parity, or stop bit error detected
		rx_data  	=>  rx_data_reg	,	--	data received
		
		tx       	=> 	UART_TX		,	--	transmit pin
		rx       	=> 	UART_RX			--	receive pin
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
	-- axi interface logic for TX side interface
	tx_axi_proc: process(clk_in)
	begin  
		if(rising_edge(clk_in)) then
			if(rst_in = '1') then
				tx_ready 	<= '0';		
				tx_ena 		<= '0';  
				tx_busy_old	<= '0';			
				tx_state 	<= get_tx;
			else
				tx_busy_old <= tx_busy; 
				case tx_state is 
					when get_tx =>									-- get TX data from user interface 
						
						tx_data_reg <= tx_data;						-- clock in tx_data into register 
						if(tx_valid = '1' and tx_busy = '0' ) then	-- only assert ready when valid is asserted and busy is de-asserted
							tx_ready <= '1';
						end if;
						
						if(tx_ready = '1' and tx_valid = '1') then	-- ready valid handshake at interface ?
							tx_ready <= '0';
							tx_state <= submit;						-- go to submission state 
						end if;
						
					when submit =>									-- push TX data to IP interface 
	
						tx_ena <= '1';								-- assert TX enable 
						if(tx_busy_old = '0' and tx_busy = '1') then-- transition from not-busy to busy ?
							tx_ena <= '0';							-- de-assert enable 
							tx_state <= get_tx;						-- get next byte from transmission 
						end if;
						
				end case;
			end if;
		end if;
	end process;
	
	-- axi interface logic for RX side interface 
	rx_axi_proc: process(clk_in)
	begin
		if(rising_edge(clk_in)) then
			if(rst_in = '1') then
				rx_busy_old <= '0';
				rx_valid <= '0';
				rx_state <= get_rx;
			else
				rx_busy_old <= rx_busy;
				case rx_state is
					when get_rx =>	-- get RX data from IP interface
					
						rx_error 	<= rx_error_reg;	-- load error port reg
						rx_data 	<= rx_data_reg;		-- load data port reg
						
						if(rx_busy_old = '1' and rx_busy = '0') then	-- new rx data received ?
							rx_state 	<= submit;	-- submit to user interface 
						end if;
					
					when submit =>	-- submit RX data to user logic interface 
						
						rx_valid <= '1';							-- assert rx_valid 
						if(rx_valid = '1' and rx_ready = '1') then	-- ready and valid asserted ? 
							rx_valid <= '0';						-- de-assert valid 
							rx_state <= get_rx;						-- retrieve next RX byte 
						end if;
				end case;
			
			end if;
		end if;
	end process;


end rtl;