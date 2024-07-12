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
-- Filename         : ip4l_beh_models.vhd
-- Design Name      : ip4l_beh_models
-- Version          : v1r0
-- Release Date     : 28th February 2018
-- Purpose          : Spacewire: ECSS-E-50-12A (24 January 2003)
--  
-- This is a set of traffic generators and data loggers for use with the 4Links
-- interface used for the Data Flow Links (DFL) between IP blocks.
-- It is based on a FIFO flow with a Input Ready (IR) and Output Ready (OR) 
-- handshaking functionality, with the master and slave always implementing a
-- two cycle response.
-- Both 8bit and 9bit data interfaces are implemented.
-- 
-- Revision History :
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.TEXTIO.all;
-- 4Links packages 
use work.ip4l_data_types.all;

package ip4l_beh_models is

  -- Transactor to send 8bit data over the DataFlowLink
  procedure dfl8_master 
    (
    constant STIM_FILE_NAME : in string;

    signal dfl_clk  : in    std_logic;
	signal dfl_rst  : in    boolean;
	
    signal dfl_data :   out std_logic_vector(7 downto 0);
	signal dfl_or   :   out boolean;
	signal dfl_ir   : in    boolean
  );

  -- Transactor to receive 8bit data over the DataFlowLink
  procedure dfl8_slave
  (
    constant STIM_FILE_NAME : in string;
	
    signal dfl_clk  : in    std_logic;
	signal dfl_rst  : in    boolean;
	
    signal dfl_data : in    std_logic_vector(7 downto 0);
	signal dfl_or   : in    boolean;
	signal dfl_ir   :   out boolean
  );
  
  -- Transactor to send 9bit data over the DataFlowLink
  procedure dfl9_master 
    (
    constant STIM_FILE_NAME : in string;

    signal dfl_clk  : in    std_logic;
	signal dfl_rst  : in    boolean;
	
    signal dfl_data :   out std_logic_vector(8 downto 0);
	signal dfl_or   :   out boolean;
	signal dfl_ir   : in    boolean
  );

  -- Transactor to receive 9bit data over the DataFlowLink
  procedure dfl9_slave
  (
    constant STIM_FILE_NAME : in string;
	
    signal dfl_clk  : in    std_logic;
	signal dfl_rst  : in    boolean;
	
    signal dfl_data : in    std_logic_vector(8 downto 0);
	signal dfl_or   : in    boolean;
	signal dfl_ir   :   out boolean
  );

  end ip4l_beh_models;

package body ip4l_beh_models is

-------------------------------------------------------------------------------
-- Data Flow Link 8bit Bus Functional Models
-------------------------------------------------------------------------------

-- This is the 8bit traffic generator to drive data into the FIFO interface
-- of 4Links IP
  procedure dfl8_master
    (
      constant STIM_FILE_NAME : in string;

      signal dfl_clk  : in    std_logic;
	  signal dfl_rst  : in    boolean;
	
      signal dfl_data :   out std_logic_vector(7 downto 0);
	  signal dfl_or   :   out boolean;
	  signal dfl_ir   : in    boolean
    ) is
    variable line_in : line;
	variable vect_out : bit_vector(7 downto 0);
	file stim_file : text is in STIM_FILE_NAME;
  begin
    -- Wait until reset is complete
	while (dfl_rst = true) loop
	  wait until dfl_clk = '1';
	end loop;
	
    -- Start stimulus output
    assert false report "dfl8_master start of stimulus output" severity note;
    while not endfile(stim_file) loop

	readline(stim_file, line_in);
	  read (line_in, vect_out);

	  -- Data ready to send to slave
	  dfl_or <= true;	  
      dfl_data <= to_stdlogicvector(vect_out);

	  -- wait for slave to be able to receive data
	  while (dfl_ir = false) loop
	    wait on dfl_ir;
	  end loop;
	  wait until dfl_clk = '1';

	  -- clear data down for one clock cycle; two cycle response model
	  dfl_or <= false;
      dfl_data <= (others => 'X');
	  wait until dfl_clk = '1';
	end loop;
	
    assert false report "dfl8_master end of stimulus file" severity note;
	wait;
  end procedure dfl8_master;

-- This is the 8bit traffic logger to store data from the FIFO interface
-- of 4Links IP
  procedure dfl8_slave
    (
      constant STIM_FILE_NAME : in string;
	  
      signal dfl_clk  : in    std_logic;
	  signal dfl_rst  : in    boolean;
	
      signal dfl_data : in    std_logic_vector(7 downto 0);
	  signal dfl_or   : in    boolean;
	  signal dfl_ir   :   out boolean
    ) is
	variable data_in : std_logic_vector(7 downto 0);
    variable line_out : line;
	variable vect_out : bit_vector(7 downto 0);
	file stim_file : text is out STIM_FILE_NAME;
  begin
    -- Wait until reset is complete
	while (dfl_rst = true) loop
	  wait until dfl_clk = '1';
	end loop;
	
    -- Start stimulus logging
    assert false report "dfl8_slave starting stimulus logging" severity note;
    while (dfl_rst = false) loop

	  -- Ready to receive data from master
	  dfl_ir <= true;

	  -- wait for data to be ready from master
	  while (dfl_or = false) loop
	    wait on dfl_or;
	  end loop;
	  wait until dfl_clk = '1';
	  
	  -- Capture data from master
      data_in := dfl_data;
      vect_out := to_bitvector(data_in);

	  -- Write data to file
	  write(line_out, vect_out);
      writeline(stim_file, line_out);
       
	  -- clear data down for one clock cycle; two cycle response model
	  dfl_ir <= false;
	  wait until dfl_clk = '1';
	end loop;
	
  end procedure dfl8_slave;

-------------------------------------------------------------------------------
-- Data Flow Link 9bit Bus Functional Models
-------------------------------------------------------------------------------

-- This is the 9bit traffic generator to drive data into the FIFO interface
-- of 4Links IP
  procedure dfl9_master
    (
      constant STIM_FILE_NAME : in string;

      signal dfl_clk  : in    std_logic;
	  signal dfl_rst  : in    boolean;
	
      signal dfl_data :   out std_logic_vector(8 downto 0);
	  signal dfl_or   :   out boolean;
	  signal dfl_ir   : in    boolean
    ) is
    variable line_in : line;
	variable vect_out : bit_vector(8 downto 0);
	file stim_file : text is in STIM_FILE_NAME;
  begin
    -- Wait until reset is complete
	while (dfl_rst = true) loop
	  wait until dfl_clk = '1';
	end loop;
	
    -- Start stimulus output
    assert false report "dfl8_master start of stimulus output" severity note;
    while not endfile(stim_file) loop

	readline(stim_file, line_in);
	  read (line_in, vect_out);

	  -- Data ready to send to slave
	  dfl_or <= true;	  
      dfl_data <= to_stdlogicvector(vect_out);

	  -- wait for slave to be able to receive data
	  while (dfl_ir = false) loop
	    wait on dfl_ir;
	  end loop;
	  wait until dfl_clk = '1';

	  -- clear data down for one clock cycle; two cycle response model
	  dfl_or <= false;
      dfl_data <= (others => 'X');
	  wait until dfl_clk = '1';
	end loop;
	
    assert false report "dfl8_master end of stimulus file" severity note;
	wait;
  end procedure dfl9_master;

-- This is the 9bit traffic logger to store data from the FIFO interface
-- of 4Links IP
  procedure dfl9_slave
    (
      constant STIM_FILE_NAME : in string;
	  
      signal dfl_clk  : in    std_logic;
	  signal dfl_rst  : in    boolean;
	
      signal dfl_data : in    std_logic_vector(8 downto 0);
	  signal dfl_or   : in    boolean;
	  signal dfl_ir   :   out boolean
    ) is
	variable data_in : std_logic_vector(8 downto 0);
    variable line_out : line;
	variable vect_out : bit_vector(8 downto 0);
	file stim_file : text is out STIM_FILE_NAME;
  begin
    -- Wait until reset is complete
	while (dfl_rst = true) loop
	  wait until dfl_clk = '1';
	end loop;
	
    -- Start stimulus logging
    assert false report "dfl8_slave starting stimulus logging" severity note;
    while (dfl_rst = false) loop

	  -- Ready to receive data from master
	  dfl_ir <= true;

	  -- wait for data to be ready from master
	  while (dfl_or = false) loop
	    wait on dfl_or;
	  end loop;
	  wait until dfl_clk = '1';
	  
	  -- Capture data from master
      data_in := dfl_data;
      vect_out := to_bitvector(data_in);

	  -- Write data to file
	  write(line_out, vect_out);
      writeline(stim_file, line_out);
       
	  -- clear data down for one clock cycle; two cycle response model
	  dfl_ir <= false;
	  wait until dfl_clk = '1';
	end loop;
	
  end procedure dfl9_slave;
	
end ip4l_beh_models;




