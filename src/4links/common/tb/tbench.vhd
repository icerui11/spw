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
-- Filename         : tbench.vhd
-- Design Name      : tbench
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
--library unisim; 
--use unisim.vcomponents.all;
-- 4Links packages 
--use work.ip4l_data_types.all;
--use work.spw_link_code.all;
use work.ip4l_beh_models.all;

use work.all;

entity tbench is
  generic (

    message   : string := "SpaceWire Test Bench";
    clkfreq : integer := 125  -- system clock frequency in MHz
  );
end; 

architecture behaviour of tbench is

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
  signal fm_port_Data_1           : std_logic_vector(7 downto 0);
  signal fm_port_OR_1             : boolean;
  signal fm_port_IR_1             : boolean;
           		   
-- BFM 9bit test signals
  signal to_port_Data_1           : std_logic_vector(8 downto 0);
  signal to_port_OR_1             : boolean;
  signal to_port_IR_1             : boolean;
              
begin

--  assert false report message severity note;
  send_text(message);
  
-- clock and reset

  clk <= not clk after clock_period/2 * 1 ns; -- 
  rst <= false after real(clock_period)*4.0 * 1 ns; -- release reset after 4 clock cycles

-------------------------------------------------------------------------------
-- Data Flow Link 8bit Bus Functional Models test
-------------------------------------------------------------------------------
	
  dfl8_master(
    STIM_FILE_NAME => "stim8_in.txt",
	
    dfl_clk   => clk,
	dfl_rst   => rst,	
	
	dfl_data  => fm_port_data_1,
	dfl_or    => fm_port_or_1,
	dfl_ir    => fm_port_ir_1);

  dfl8_slave(
    STIM_FILE_NAME => "stim8_out.txt",
	
    dfl_clk   => clk,
	dfl_rst   => rst,
	
	dfl_data  => fm_port_data_1,
	dfl_or    => fm_port_or_1,
	dfl_ir    => fm_port_ir_1);

-------------------------------------------------------------------------------
-- Data Flow Link 9bit Bus Functional Models test
-------------------------------------------------------------------------------

  dfl9_master(
    STIM_FILE_NAME => "stim9_in.txt",
	
    dfl_clk   => clk,
	dfl_rst   => rst,	
	
	dfl_data  => to_port_data_1,
	dfl_or    => to_port_or_1,
	dfl_ir    => to_port_ir_1);

  dfl9_slave(
    STIM_FILE_NAME => "stim9_out.txt",
	
    dfl_clk   => clk,
	dfl_rst   => rst,
	
	dfl_data  => to_port_data_1,
	dfl_or    => to_port_or_1,
	dfl_ir    => to_port_ir_1);
	
end behaviour;