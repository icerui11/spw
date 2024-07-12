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

-- @ Revision #				:	1

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
entity spw_hello_world_controller is
	generic(
		g_addr_width	: natural := 4;								 	-- address width of connecting RAM
		g_count_max 	: integer range 1 to ((2**16)-1)	:= 256;  	-- count period between character reads
		g_num_chars		: positive := 11 								-- number of characters to send from RAM
	);
	port( 
		
		-- standard register control signals --
		clk_in	: in 	std_logic := '0';		-- clk input, rising edge trigger
		rst_in	: in 	std_logic := '0';		-- reset input, active high
		enable  : in 	std_logic := '0';		-- enable input, asserted high. 
		
		-- RAM signals
		ram_enable		: out 	std_logic									:= '0';
		ram_data_in		: in 	std_logic_vector(7 downto 0) 				:= (others => '0');	-- data read from RAM
		ram_addr_out	: out 	std_logic_vector(g_addr_width-1 downto 0) 	:= (others => '0');	-- address to ram data
		
		-- SpW Data Signals
		spw_Tx_data		: out   std_logic_vector(7 downto 0)	:= (others => '0');		-- SpW Tx_data
		spw_Tx_Con		: out 	std_logic						:= '0';					-- SpW character control bit
		spw_Tx_OR		: out 	std_logic						:= '0';					-- SpW Tx_data Output Ready
		spw_Tx_IR		: in 	std_logic						:= '1';					-- SpW Tx_data Input Ready	
		
		spw_Rx_data		: in   	std_logic_vector(7 downto 0)	:= (others => '0');		-- SpW Rx_data
		spw_Rx_Con		: in 	std_logic						:= '0';					-- SpW character control bit
		spw_Rx_OR		: in 	std_logic						:= '0';					-- SpW Rx_data Output Ready
		spw_Rx_IR		: out 	std_logic						:= '1';					-- SpW Rx_data Input Ready	
		
		rx_cmd_out		: out 	std_logic_vector(2 downto 0)	:= (others => '0');		-- control char output bits
		rx_cmd_valid	: out 	std_logic;												-- asserted when valid command to output
		rx_cmd_ready	: in 	std_logic;												-- assert to receive rx command. 
		
		rx_data_out		: out 	std_logic_vector(7 downto 0)	:= (others => '0');		-- received spacewire data output
		rx_data_valid	: out 	std_logic := '0';										-- valid rx data on output
		rx_data_ready	: in 	std_logic := '1';										-- assert to receive rx data
		
		-- SpW Control Signals
		spw_Connected	: in 	std_logic	:= '0';										-- asserted when SpW Link is Connected
		spw_Rx_ESC_ESC	: in 	std_logic 	:= '0';    
		spw_ESC_EOP 	: in	std_logic 	:= '0';    
		spw_ESC_EEP     : in	std_logic 	:= '0';
		spw_Parity_error: in	std_logic 	:= '0';
		
		error_out		: out 	std_logic 	:= '0'									      -- assert when error
    );
end spw_hello_world_controller;


---------------------------------------------------------------------------------------------------------------------------------
-- Code Description & Developer Notes --
---------------------------------------------------------------------------------------------------------------------------------


architecture rtl of spw_hello_world_controller is

	----------------------------------------------------------------------------------------------------------------------------
	-- Constant Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	constant c_spw_eop	: 	std_logic_vector(7 downto 0) := x"02";
	----------------------------------------------------------------------------------------------------------------------------
	-- Type Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	type t_states is (ready, read_mem, spw_tx, char_delay, eop_tx);	-- declare state machine states. 
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Entity Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Component Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Signal Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	signal s_state : t_states := ready;	-- declare state machines, init safe. 
	
	signal s_addr_counter	: natural range 0 to (2**g_addr_width)-1 := 0;	-- counts RAM read address
	signal s_time_counter	: natural range 0 to g_count_max-1 := 0;		-- counts time between memory reads...
	
	signal s_char_reg		: std_logic_vector(7 downto 0) := (others => '0');	-- register for storing SpW Characters from RAM
	signal rx_ready			: std_logic := '0';
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
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Component Instantiations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Asynchronous Signal Assignments --
	----------------------------------------------------------------------------------------------------------------------------
	ram_addr_out 	<= std_logic_vector(to_unsigned(s_addr_counter, ram_addr_out'length));	-- output ram read address. 
	rx_ready 		<= rx_cmd_ready or rx_data_ready;	-- rx output ready ?
	

	----------------------------------------------------------------------------------------------------------------------------
	-- Synchronous Processes --
	----------------------------------------------------------------------------------------------------------------------------
	control_tx_fsm: process(clk_in)
	begin
		if(rising_edge(clk_in)) then
			ram_enable 		<= '1';
			spw_Tx_OR 		<= '0';
			if(rst_in = '1') then							-- Synchronous reset condition. 
				s_addr_counter 	<= 0;
				s_time_counter	<= 0;
				spw_Tx_Con 		<= '0';
				spw_Tx_data		<= (others => '0');
				spw_Tx_OR		<= '0';
				ram_enable 		<= '0';
				s_state 		<= ready;
			else
				case s_state is 
					
					when ready =>															-- ready state
						
						s_addr_counter 	<= 0;												-- reset memory address counter. 
						if(enable = '1' and spw_Connected = '1') then						-- enabled and Spacewire Connected ?
							s_state 		<= read_mem;									-- go to read mem
						end if;	
						
					when read_mem =>														-- read memory state
						
						s_char_reg <= ram_data_in;											-- read RAM data into buffer. 
						s_state <= spw_tx;													-- got to spw transmit state
					
					when spw_tx =>															-- spacewire transmit state
						
						spw_Tx_data <= s_char_reg;											-- output stored data
						if(spw_Tx_IR = '1') then											-- spw ready for data ?
							spw_Tx_OR <= '1';												-- assert Tx data output ready. 
						end if;	
							
						if(spw_Tx_IR = '1' and spw_Tx_OR = '1') then						-- IR/OR handshake valid on spw Tx data ?
							s_addr_counter 	<= (s_addr_counter + 1) mod g_num_chars;		-- increment characers, rollover counter. 
							spw_Tx_OR 		<= '0';											-- de-assert Tx data output ready
							s_state			<= char_delay;									-- go to character delay state
						end if;	
						
					when char_delay =>														-- character delay state
						
						s_time_counter <= (s_time_counter + 1) mod g_count_max;				-- increment time counter...
						if(s_time_counter = g_count_max-1) then								-- time counter max ?
							s_state <= read_mem;											-- go to read_mem state. 
						end if;
						
						if((s_time_counter = g_count_max-1) and s_addr_counter = 0) then	-- address counter rolled over and max count reached ?	
							s_char_reg 	<= c_spw_eop;
							s_state 	<= eop_tx;											-- go to transmit EOP state.
						end if;
					
					when eop_tx =>															-- transmit EOP state. 
					
						spw_Tx_Con		<= '1';
						spw_Tx_data 	<= s_char_reg;
						
						if(spw_Tx_IR = '1') then											-- spw ready for data ?
							spw_Tx_OR <= '1';												-- assert Tx data output ready. 
						end if;					
				
						if(spw_Tx_IR = '1' and spw_Tx_OR = '1') then						-- IR/OR handshake valid on spw Tx data ?
							spw_Tx_OR 		<= '0';											-- de-assert Tx data output ready
							spw_Tx_Con		<= '0';
							s_state			<= ready;										-- go to ready state
						end if;
						
					when others =>															-- others state, for safe FSM operation. 
						s_state <= ready;													-- default ready state...
				end case;	
			end if;
		end if;
	end process;
	
	-- interface for receiving Rx Data. AXI Handshake style 
	control_rx: process(clk_in)	
	begin
		if(rising_edge(clk_in)) then							-- Synchronous to rising edge
		    error_out <= (spw_Rx_ESC_ESC or spw_ESC_EOP  or spw_ESC_EEP or spw_Parity_error);
			spw_Rx_IR <= '0';									-- default spw_Rx_IR low
			if(rst_in = '1') then								-- if synchronous reset asserted ?
				rx_data_valid 	<= '0';							-- de-assert rx_data valid
				rx_cmd_valid 	<= '0';							-- de-assert rx_cmd valid
			else												-- reset de-asserted ?
			
				if(rx_data_ready = '1') then					-- rx data output logic ready ?
					rx_data_valid <= '0';						-- de-assert rx data valid
				end if;
				
				if(rx_cmd_ready = '1') then						-- rx cmd output logic ready ?	
					rx_cmd_valid <= '0';						-- de-assert rx cmd valid
				end if;
				
				if(spw_Rx_OR = '1' and rx_ready = '1') then		-- new data from spacewire codec and rx receive logic is ready?
					spw_Rx_IR <= '1';							-- assert spacewire Rx IR register
				end if;

				-- earlier rx_data_valid/rx_cmd_valid assignments are overwritten if valid data/cmd detected 
				if(spw_Rx_OR = '1' and spw_Rx_IR = '1') then	-- spacewire codec OR/IR handshake valid ?
					spw_Rx_IR <= '0';							-- de-assert spacewire Rx Input Ready signal
					rx_data_out 	<= spw_Rx_data(7 downto 0);	-- output potential data bits
					rx_cmd_out 		<= spw_Rx_data(2 downto 0);	-- output potential character bits 
					rx_cmd_valid 	<= spw_Rx_Con;				-- assert cmd valid if command received
					rx_data_valid   <= not spw_Rx_Con;			-- assert data valid if data received
				end if;					
				
			end if;
		end if;
	end process;
	----------------------------------------------------------------------------------------------------------------------------
	-- Asynchronous Processes --
	----------------------------------------------------------------------------------------------------------------------------


end rtl;