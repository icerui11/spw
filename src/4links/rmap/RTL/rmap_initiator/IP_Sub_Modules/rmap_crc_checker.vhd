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
library work;
use work.all;
context work.rmap_context;
----------------------------------------------------------------------------------------------------------------------------------
-- Entity Declarations --
----------------------------------------------------------------------------------------------------------------------------------
entity rmap_crc_checker is
	port( 
		
		-- standard register control signals --
		clk_in	: in 	std_logic := '0';		-- clk input, rising edge trigger
		rst_in	: in 	std_logic := '0';		-- reset input, active high
		enable  : in 	std_logic := '0';		-- enable input, asserted high. 
		-- ports connecting to SpW IP --
		spw_Rx_Data	: in 	std_logic_vector(8 downto 0):= (others => '0');
		spw_Rx_OR	: in 	std_logic := '0';
		spw_Rx_IR	: out 	std_logic := '0';
		
		-- Rx data (output) ports to RMAP reply controller logic
		rx_data		: out 	std_logic_vector(8 downto 0) := (others => '0');
		rx_valid	: out   std_logic := '0';
		rx_ready	: in 	std_logic := '0';
		
		-- CRC output ports to RMAP reply controller logic --
		crc_OKAY	: out 	std_logic := '0';	-- asserted when CRC result = x"00".
		crc_out		: out 	std_logic_vector(8 downto 0) := (others => '0');
		crc_valid 	: out 	std_logic := '0'
		
    );
end rmap_crc_checker;


---------------------------------------------------------------------------------------------------------------------------------
-- Code Description & Developer Notes --
---------------------------------------------------------------------------------------------------------------------------------


architecture rtl of rmap_crc_checker is

	----------------------------------------------------------------------------------------------------------------------------
	-- Constant Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Type Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	type crc_states is (		-- fsm for Reply CRC calculator
		idle, 
		get_first_byte,
		get_byte, 
		calc_crc,
		check_crc,
		out_data
	);
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
	signal crc_state 	: crc_states := idle;
	
	signal crc_buf		: std_logic_vector(8 downto 0) := (others => '0');
	signal crc_buf_rev	: std_logic_vector(8 downto 0) := (others => '0');
	signal Rx_CRC		: std_logic_vector(8 downto 0) := (others => '0');
	
	signal has_replies	: std_logic := '0';
	
	signal bit_count	: integer range 1 to 7 := 1;
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
	crc_out <= Rx_CRC;
	rx_data <= crc_buf;
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Synchronous Processes --
	----------------------------------------------------------------------------------------------------------------------------
	crc_fsm: process(clk_in)
	begin
		if(rising_edge(clk_in)) then
			if(rst_in = '1') then
				has_replies <= '0';
				bit_count 	<=  1;
				Rx_CRC 		<= (others => '0');
				crc_state <= idle;
				crc_valid <= '0';
			else
				case crc_state is
				
					when idle =>
						has_replies <= '0';
						bit_count 	<=  1;
						Rx_CRC 		<= (others => '0');
						if(enable = '1') then
							crc_state <= get_first_byte;
						end if;
						
					when get_first_byte =>	-- get first byte, check if logical or SpW Path address
					
						has_replies <= '0';
						spw_Rx_IR <= '1';
					
						if(spw_Rx_IR = '1' and spw_Rx_OR = '1') then
							spw_Rx_IR <= '0';
							crc_buf <= spw_Rx_Data;
							if((spw_Rx_Data  = c_spw_EOP) or (spw_Rx_Data = c_spw_EEP)) then 	-- EOP or EEP Detected ?
								crc_state <= out_data;										-- push to output interface									
								rx_valid <= '1';
							elsif(spw_rx_Data(7 downto 5) = "000") then		-- is reply address (spW paths are 0-31)
								has_replies <= '1';							-- is a reply address ?
								crc_state 	<= out_data;					-- bypass.... 
								rx_valid <= '1';
							elsif (has_replies = '1' and spw_Rx_Data(7 downto 0) /= x"FE") then
								crc_state 	<= out_data;					-- bypass....
								rx_valid <= '1';
								has_replies <= '1';
							else											-- is a valid logical address
								crc_state <= calc_crc;						-- calculate CRC
								crc_valid <= '0';
								Rx_CRC(7 downto 0) 	<= 	Rx_CRC(6 downto 2)	-- will be x"00" on valid Header or Data CRC byte 
									& (spw_Rx_Data(0) xor Rx_CRC(7) xor Rx_CRC(1))
									& (spw_Rx_Data(0) xor Rx_CRC(7) xor Rx_CRC(0))
									& (spw_Rx_Data(0) xor Rx_CRC(7));
							end if;

						end if;
						
						
					when get_byte =>

						spw_Rx_IR <= '1';
						
						if(spw_Rx_IR = '1' and spw_Rx_OR = '1') then
							spw_Rx_IR <= '0';
							crc_buf <= spw_Rx_Data;
							if(spw_Rx_Data  = c_spw_EOP or spw_Rx_Data = c_spw_EEP) then 	-- EOP or EEP Detected ?
								crc_state <= out_data;										-- push to output interface	
								rx_valid <= '1';								
							else											-- is a valid logical address
								crc_state <= calc_crc;
								crc_valid <= '0';
								Rx_CRC(7 downto 0) 	<= 	Rx_CRC(6 downto 2)	-- will be x"00" on valid Header or Data CRC byte 
									& (spw_Rx_Data(0) xor Rx_CRC(7) xor Rx_CRC(1))
									& (spw_Rx_Data(0) xor Rx_CRC(7) xor Rx_CRC(0))
									& (spw_Rx_Data(0) xor Rx_CRC(7));
							end if;
						end if;
					
					when calc_crc =>

						Rx_CRC(7 downto 0) 	<= 	Rx_CRC(6 downto 2)	-- will be x"00" on valid Header or Data CRC byte 
									& (crc_buf(bit_count) xor Rx_CRC(7) xor Rx_CRC(1))
									& (crc_buf(bit_count) xor Rx_CRC(7) xor Rx_CRC(0))
									& (crc_buf(bit_count) xor Rx_CRC(7));
						if(bit_count = 7) then		-- repeated for each bit ?
							crc_state <= check_crc;	
							crc_valid <= '1';
							bit_count <= 1;
							
						else						-- repeat until done 8 times ?
							bit_count <= bit_count + 1;
						end if;
						
					when check_crc =>
			
						crc_OKAY <= '0';
						if(Rx_CRC(7 downto 0) = x"00") then	-- set crc okay if 0x00 
							crc_OKAY <= '1';
						end if;
						rx_valid <= '1';
						crc_state <= out_data;
						
					when out_data =>
					
						if(rx_valid and rx_ready) then
							rx_valid <= '0';
							if(crc_buf = c_spw_EOP or crc_buf = c_spw_EEP) then 
								crc_state <= idle;
							elsif(has_replies = '1') then
								crc_state <= get_first_byte;	-- not yet got first byte (logical address) 
								spw_Rx_IR <= '1';
							else 
								crc_state <= get_byte;
								spw_Rx_IR <= '1';
							end if;
						end if;
						
					when others =>
						crc_state <= idle;
				end case;
				
			end if;
		end if;
	end process;


end rtl;