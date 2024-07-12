----------------------------------------------------------------------------------------------------------------------------------
-- File Description  --
----------------------------------------------------------------------------------------------------------------------------------
-- @ File Name				:	rmap_crc_calculator.vhd
-- @ Engineer				:	James E Logan
-- @ Role					:	FPGA Engineer
-- @ Company				:	4Links ltd
-- @ Date					: 	27/06/2023

-- @ VHDL Version			:   2008
-- @ Supported Toolchain	:	Xilinx Vivado IDE
-- @ Target Device			: 	Xilinx US+ Family

-- @ Revision #				:	2

-- File Description         : 	crc calculator for 4Links RMAP initiator IP 

-- Document Number			:  	xxx-xxxx-xxx
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
use work.all;

context work.rmap_context;
----------------------------------------------------------------------------------------------------------------------------------
-- Entity Declarations --
----------------------------------------------------------------------------------------------------------------------------------
entity rmap_crc_calculator is
	port( 
		
		-- standard register control signals --
		clk_in				: in 	std_logic := '0';				-- clk input, rising edge trigger
		rst_in				: in 	std_logic := '0';				-- reset input, active high
		enable  			: in 	std_logic := '0';				-- enable input, asserted high. 
		
		-- byte in
		spw_data			: in 	std_logic_vector(8 downto 0) := (others => '0'); 	-- spw_data byte
		spw_data_valid		: in 	std_logic := '0';						-- assert when input data is valid 
		spw_data_ready		: out 	std_logic := '0';						-- asserted when input data is ready to be read
		
		-- CRC bypass input 
		crc_ignore			: in 	std_logic := '0';						-- assert to bypass CRC calculation (for path address)
		
		-- crc byte out
		crc_clear			: in 	std_logic := '0';						-- force clear CRC (header to data transition, new frame, etc etc)
		crc_data 			: out 	std_logic_vector(8 downto 0) := (others => '0');	-- crc output
		crc_data_valid		: out 	std_logic := '0';						-- asserted when crc output is valid 
		
		output_con			: out 	std_logic := '0';						-- spw_data(8) on 4links IP
		output_data			: out 	std_logic_vector(7 downto 0) := (others => '0');	-- spw data byte output
		output_valid		: out 	std_logic := '0';						-- asserted when output valid 
		output_ready		: in 	std_logic := '0'						-- assert when output data is ready to be read 
		
    );
end rmap_crc_calculator;


---------------------------------------------------------------------------------------------------------------------------------
-- Code Description & Developer Notes --
---------------------------------------------------------------------------------------------------------------------------------


architecture rtl of rmap_crc_calculator is

	----------------------------------------------------------------------------------------------------------------------------
	-- Constant Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Type Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	type t_crc_states is (idle, get_byte, calc_crc, output_byte);
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
	signal s_crc_state : t_crc_states := idle;
	
	signal Tx_CRC 		: std_logic_vector(7 downto 0) := (others => '0');
	signal byte_data 	: std_logic_vector(8 downto 0) := (others => '0');
	
	signal con_reg		: std_logic := '0';
	
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
	crc_data(8) <= '0';
	g1: for i in 0 to 7 generate
		crc_data(7-i) <= Tx_CRC(i);
	end generate g1;
	----------------------------------------------------------------------------------------------------------------------------
	-- Synchronous Processes --
	----------------------------------------------------------------------------------------------------------------------------
	process(clk_in)
	begin
		if(rising_edge(clk_in)) then
			if(rst_in = '1') then
				crc_data_valid <= '0';
				spw_data_ready <= '0';
				output_valid <= '0';
				s_crc_state <= idle;
			else
				
				case s_crc_state is
					when idle =>							-- defualt state
					
						bit_count <= 1;
						spw_data_ready <= '0';
						crc_data_valid <= '0';
						Tx_CRC <= (others => '0');
						if(enable = '1') then
							s_crc_state <= get_byte;
						end if;
						
					when get_byte =>						-- read byte on input 
						
						spw_data_ready <= '1';
						if(spw_data_valid = '1' and spw_data_ready = '1') then		-- handshake valid ?
							spw_data_ready 	<= '0';									-- de-assert spw ready
							byte_data 		<= spw_data;							-- read-in byte data
							if(crc_ignore = '1') then								-- crc ignore set ?
								s_crc_state <= output_byte;							-- go to output data state 
							elsif((spw_data = c_spw_EOP) or (spw_data = c_spw_EEP)) then	-- EOP or EEP ?
								s_crc_state <= output_byte;							-- output raw character 
							else													-- valid data for crc ?
								crc_data_valid <= '0';
								s_crc_state <= calc_crc;							-- calculate crc for byte 	
								
								Tx_CRC 	<= 	Tx_CRC(6 downto 2)
									& (spw_data(0) xor Tx_CRC(7) xor Tx_CRC(1))
									& (spw_data(0) xor Tx_CRC(7) xor Tx_CRC(0))
									& (spw_data(0) xor Tx_CRC(7));

							end if;
						end if;
						
					when calc_crc =>												-- calculate crc (takes 8 clock cycles)
	
						Tx_CRC 	<= 	Tx_CRC(6 downto 2)
									& (byte_data(bit_count) xor Tx_CRC(7) xor Tx_CRC(1))
									& (byte_data(bit_count) xor Tx_CRC(7) xor Tx_CRC(0))
									& (byte_data(bit_count) xor Tx_CRC(7));
						if(bit_count = 7) then		-- repeated for each bit ?
							s_crc_state <= output_byte;
							bit_count <= 1;
							crc_data_valid <= '1';		-- declare crc valid 
						else						-- repeat until done 8 times ?
							bit_count <= bit_count + 1;
						end if;
	
					
					when output_byte =>
						output_con 		<= byte_data(8);
						output_data 	<= byte_data(7 downto 0);
						output_valid 	<= '1';
						
					--	if(output_ready = '1') then
					--		output_valid <= '1';
					--	end if;
						
						if(output_valid = '1' and output_ready = '1') then
							output_valid <= '0';
							if((byte_data = c_spw_EOP) or (byte_data = c_spw_EEP)) then -- EOP or EEP ?
								s_crc_state <= idle;
							else
								s_crc_state <= get_byte;
								spw_data_ready <= '1';
							end if;
						end if;
						
					when others =>
						s_crc_state <= idle;
						
				end case;
				
				if(crc_clear = '1') then -- force clear CRC value as requires. 
					Tx_CRC <= (others => '0');
				end if;
				
			end if;
		end if;
	end process;


end rtl;

