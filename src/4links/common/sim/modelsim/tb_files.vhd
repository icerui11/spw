-------------------------------------------------------------------------------
-- Copyright (c) 2018, 4Links Ltd All rights reserved.
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
--
-- Filename         : tb_files.vhd
-- Design Name      : tb_files
-- Version          : v1r0
-- Release Date     : 11th February 2018
-- Purpose          : Spacewire: ECSS-E-50-12A (24 January 2003)
--  
--
-- Revision History :
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.TEXTIO.all;

use work.all;

entity tb_files is
  generic (

    message   : string := "SpaceWire Test Bench";
    clkfreq : integer := 125  -- system clock frequency in MHz
  );
end; 

architecture behaviour of tb_files is

-------------------------------------------------------------------------------
  procedure send_text
    (
	text_string : string
    ) is
  begin 
    assert false report text_string severity note;
  end send_text;

-------------------------------------------------------------------------------

  signal clk                      : std_logic := '0';			-- Clock
  signal rst                      : boolean := true;			-- Reset
  constant clock_period           : integer := 1000/clkfreq;
  constant clock_frequency        : real    := real(125*1000000);
 
-- BFM 8bit test signals
  signal data_vect                : std_logic_vector(7 downto 0);
              
begin

--  assert false report message severity note;
  send_text(message);
  
-- clock and reset

  clk <= not clk after clock_period/2 * 1 ns; -- 
  rst <= false after real(clock_period)*4.0 * 1 ns; -- release reset after 4 clock cycles

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
	
  p_readfile: process 
    variable line_in : line;
	variable vect_out : bit_vector(7 downto 0);
	file stim_file : text is in "stim_in.txt";
  begin
    -- Wait until reset is complete
	while (rst = true) loop
	  wait until clk = '1';
	end loop;
	-- Generate traffic
    while not endfile(stim_file) loop
	  readline(stim_file, line_in);
	  read(line_in, vect_out);
	  data_vect <= to_stdlogicvector(vect_out);
	  wait until clk ='1';
	end loop;
    assert false report "End of Stimulus File" severity failure;
  end process p_readfile;

  p_writefile: process 
    variable line_in : line;
	variable vect_out : bit_vector(7 downto 0);
	file stim_file : text is out "stim_out.txt";
  begin
    -- Wait until reset is complete
	while (rst = true) loop
	  wait until clk = '1';
	end loop;
	-- Log traffic
    while true loop
	  wait until clk ='1';
	  vect_out := to_bitvector(data_vect);
	  write(line_in, vect_out);
	  writeline(stim_file, line_in);
	end loop;
	wait;
  end process p_writefile;
	
end behaviour;