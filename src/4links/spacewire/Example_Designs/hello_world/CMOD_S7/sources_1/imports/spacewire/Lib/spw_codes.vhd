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
-- Filename         : spw_codes.vhd
-- Design Name      : spw_codes
-- Version          : v1r0
-- Release Date     : 11th February 2018
-- Purpose          : Spacewire: ECSS-E-50-12A (24 January 2003)
--  
-- Revision History :
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.ip4l_data_types.all;

package spw_codes is

  function SpW_Data( A : in octet ) return nonet;
  function SpW_Data_bits( A : in nonet ) return octet;

  constant SPW_FCT        : nonet := B"1_0000_0000";  -- 100
  constant SPW_EEP        : nonet := B"1_0000_0001";  -- 101
  constant SPW_EOP        : nonet := B"1_0000_0010";  -- 102
  constant SPW_ESC        : nonet := B"1_0000_0011";  -- 103
  
  constant SPW_ESC_FCT    : nonet := B"1_0000_0100";  -- 104
  constant SPW_ESC_EEP    : nonet := B"1_0000_0101";  -- 105
  constant SPW_ESC_EOP    : nonet := B"1_0000_0110";  -- 106
  constant SPW_ESC_ESC    : nonet := B"1_0000_0111";  -- 107
  
  constant SPW_TIMEOUT    : nonet := B"1_0000_1000";  -- 108
  constant SPW_PERROR1    : nonet := B"1_0000_1001";  -- 109
  constant SPW_PERROR2    : nonet := B"1_0000_1010";  -- 10A
  constant SPW_PERROR3    : nonet := B"1_0000_1011";  -- 10B
  
  constant STORE      : nonet := B"1_0000_1100";  -- 10C
  constant FORWARD    : nonet := B"1_0000_1101";  -- 10D
  constant ATOM       : nonet := B"1_0000_1110";  -- 10E unused
  constant MOTA       : nonet := B"1_0000_1111";  -- 10F unused
  
  constant JOIN       : nonet := B"1_0001_0000";  -- 110
  constant BARRIER    : nonet := B"1_0001_0001";  -- 111
  constant RESIGN     : nonet := B"1_0001_0010";  -- 112
  constant EVENT      : nonet := B"1_0001_0011";  -- 113
  
  --constant unused_114 : nonet := B"1_0001_0100";
  --constant unused_115 : nonet := B"1_0001_0101";
  constant OVERLONG   : nonet := B"1_0001_0100";
  constant UNFINISHED : nonet := B"1_0001_0101";
  constant TOOSLOW    : nonet := B"1_0001_0110";
  --constant unused_117 : nonet := B"1_0001_0111";
  
  --constant unused_118 : nonet := B"1_0001_1000";
  --constant unused_119 : nonet := B"1_0001_1001";
  --constant unused_11A : nonet := B"1_0001_1010";
  --constant unused_11B : nonet := B"1_0001_1011";
  
  --constant unused_11C : nonet := B"1_0001_1100";
  --constant unused_11D : nonet := B"1_0001_1101";
  --constant unused_11E : nonet := B"1_0001_1110";
  --constant unused_11F : nonet := B"1_0001_1111";
  
  --constant unused_120 : nonet := B"1_0010_0000";
  --constant unused_121 : nonet := B"1_0010_0001";
  --constant unused_122 : nonet := B"1_0010_0010";
  --constant unused_123 : nonet := B"1_0010_0011";
  
  --constant unused_124 : nonet := B"1_0010_0100";
  --constant unused_125 : nonet := B"1_0010_0101";
  --constant unused_126 : nonet := B"1_0010_0110";
  --constant unused_127 : nonet := B"1_0010_0111";
  
  --constant unused_128 : nonet := B"1_0010_1000";
  --constant unused_129 : nonet := B"1_0010_1001";
  --constant unused_12A : nonet := B"1_0010_1010";
  --constant unused_12B : nonet := B"1_0010_1011";
  
  --constant unused_12C : nonet := B"1_0010_1100";
  --constant unused_12D : nonet := B"1_0010_1101";
  --constant unused_12E : nonet := B"1_0010_1110";
  --constant unused_12F : nonet := B"1_0010_1111";
  
  constant DELAY      : nonet := B"1_0011_0000";
                           -- to B"1_0011_1111"
  
  constant PORT_SEL   : nonet := B"1_0100_0000";
                           -- to B"1_0100_1111"
  
  -- 8 codes with a following-byte-count
  constant TSTAMP     : nonet := B"1_1000_1000";  -- 188   + 8-bytes time
  
  constant TCODE      : nonet := B"1_1001_0001";  -- 191   + 1-byte code
  
  constant TRUNCATED  : nonet := B"1_1010_0000";  -- 1A0 ...
  --constant unused_1An : nonet := B"1_1010_0000";
  
  constant REPEAT_1   : nonet := B"1_1011_0001";  -- 1B1   + 1-byte count
  constant REPEAT_2   : nonet := B"1_1011_0010";  -- 1B2   + 2-byte count
  constant REPEAT_3   : nonet := B"1_1011_0011";  -- 1B3   + 3-byte count
  --constant unused_1Bn : nonet := B"1_1011_0000";  -- 1B0
  
  constant unused_1Cn : nonet := B"1_1100_0000";  -- 1C0
                           -- to B"1_1100_1111"
  
  constant unused_1Dn : nonet := B"1_1101_0000";  -- 1D0
                           -- to B"1_1101_1111"
  
  constant unused_1En : nonet := B"1_1110_0000";  -- 1E0
                           -- to B"1_1110_1111"
  
  constant unused_1Fn : nonet := B"1_1111_0000";  -- 1F0
                           -- to B"1_1111_1111"


-------------------------------------------------------------------------------
-- Error Injection codes for spw.vhd					   
  constant FORCE_LINK_FAIL    : std_logic_vector(3 downto 0) := "0001";
  constant UNFORCE_LINK_FAIL  : std_logic_vector(3 downto 0) := "0010";
  constant FORCE_PARITY_ERROR : std_logic_vector(3 downto 0) := "0011";
  constant FORCE_ESC_EOP      : std_logic_vector(3 downto 0) := "0100";
  constant FORCE_ESC_EEP      : std_logic_vector(3 downto 0) := "0101";
  constant FORCE_ESC_ESC      : std_logic_vector(3 downto 0) := "0110";
  constant FORCE_NO_FCT       : std_logic_vector(3 downto 0) := "0111";
  constant FORCE_BABBLE_ONE   : std_logic_vector(3 downto 0) := "1000";
  constant FORCE_BABBLE_MANY  : std_logic_vector(3 downto 0) := "1001";
  constant FORCE_NO_EOP       : std_logic_vector(3 downto 0) := "1010";
  --constant FORCE_???????      : std_logic_vector(3 downto 0) := "1011";
  --constant FORCE_???????      : std_logic_vector(3 downto 0) := "1100";
  --constant FORCE_???????      : std_logic_vector(3 downto 0) := "1101";
  --constant FORCE_???????      : std_logic_vector(3 downto 0) := "1110";
  --constant FORCE_???????      : std_logic_vector(3 downto 0) := "1111";
-------------------------------------------------------------------------------

end spw_codes;


package body spw_codes is

  function SpW_Data( A : in octet ) return nonet is
    begin
      return '0' & A;
  end function;

  
  function SpW_Data_bits( A : in nonet ) return octet is
    begin
      return A(7 downto 0);
  end function;


end spw_codes;




