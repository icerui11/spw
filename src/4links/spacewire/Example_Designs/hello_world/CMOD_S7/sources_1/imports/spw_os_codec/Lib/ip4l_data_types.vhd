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
-- Filename         : ip4l_data_types.vhd
-- Design Name      : ip4l_data_types
-- Version          : v1r0
-- Release Date     : 11th February 2018
-- Purpose          : Spacewire: ECSS-E-50-12A (24 January 2003)
--  
-- Revision History :
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package ip4l_data_types is

  subtype dibit                     is std_logic_vector( 1 downto 0);
  subtype quadbit                   is std_logic_vector( 3 downto 0);
  subtype hexbit                    is std_logic_vector( 5 downto 0);
  subtype octet                     is std_logic_vector( 7 downto 0);
  subtype nonet                     is std_logic_vector( 8 downto 0);
  subtype unadectet                 is std_logic_vector(10 downto 0);
  subtype word                      is std_logic_vector(15 downto 0);
  subtype long                      is std_logic_vector(31 downto 0);
  subtype triple                    is std_logic_vector(47 downto 0);
  subtype quad                      is std_logic_vector(63 downto 0);

  subtype sfp_pins                  is std_logic_vector( 9 downto 2);
  type    sfp_array                 is array ( integer range <> ) of sfp_pins;

  subtype address_4K                is std_logic_vector(11 downto 0);
  
  subtype u_word                    is unsigned(15 downto 0);
  subtype u_long                    is unsigned(31 downto 0);

  type    char_array                is array ( integer range <> ) of character;

  type    dibit_array               is array ( integer range <> ) of dibit;
  type    quadbit_array             is array ( integer range <> ) of quadbit;
  type    hexbit_array              is array ( integer range <> ) of hexbit;
  type    octet_array               is array ( integer range <> ) of octet;
  type    nonet_array               is array ( integer range <> ) of nonet;
  type    unadectet_array           is array ( integer range <> ) of unadectet;
  type    word_array                is array ( integer range <> ) of word;
  type    long_array                is array ( integer range <> ) of long;
  type    triple_array              is array ( integer range <> ) of triple;
  type    quad_array                is array ( integer range <> ) of quad;

  type    address_4K_array          is array ( integer range <> ) of address_4K;

  type    u_word_array              is array ( integer range <> ) of u_word;
  type    u_long_array              is array ( integer range <> ) of u_long;

  type    boolean_array             is array ( integer range <> ) of boolean;
  type    std_logic_array           is array ( integer range <> ) of std_logic;
  
  type 	mem_type is array ( 2047 downto 0 ) of nonet;
  
	type mem_prot_t is protected						-- create protected type for memory and memory operations
		procedure write_mem(						-- procedure to WRITE to memory
			signal    addr		: in 	integer;	-- Write address	
			signal    wr_data	: in 	nonet		-- data to write to memory
		);
		
		procedure read_mem(							-- procedure to READ from memory
			signal    addr		: in  	integer;	-- Read address
			signal    rd_data	: out 	nonet		-- data read from memory
		);
		
		impure function debug_mem return mem_type;

	end protected mem_prot_t;	
  
  function merge    ( X    : in octet_array   ) return octet;
  function merge    ( X    : in nonet_array   ) return nonet;
  function merge    ( X    : in word_array    ) return word;
  function merge    ( X    : in long_array    ) return long;
  
  --function merge    ( X    : in u_word_array  ) return u_word;
  --function merge    ( X    : in u_long_array  ) return u_long;

  function sum      ( X    : in u_word_array  ) return u_word;
  function sum      ( X    : in u_long_array  ) return u_long;

  function "and"    ( X, Y : in boolean_array ) return boolean_array;
  function "or"     ( X, Y : in boolean_array ) return boolean_array;
  function "not"    ( X    : in boolean_array ) return boolean_array;
  function "="      ( X, Y : in boolean_array ) return boolean;
  function "/="     ( X, Y : in boolean_array ) return boolean;
  function ">="     ( X, Y : in boolean_array ) return boolean;
  function all_true ( X    : in boolean_array ) return boolean;
  function any      ( X    : in boolean_array ) return boolean;
  function "="      ( X : in std_logic_vector; Y : in std_logic ) return boolean_array;
  
  function bitrev   ( A : in std_logic_vector ) return std_logic_vector;

  function active_high ( X : in boolean ) return std_logic;
  function active_low  ( X : in boolean ) return std_logic;

  function active_high ( X : in boolean_array ) return std_logic_vector;

  function active_high ( X : in std_logic        ) return boolean;
  function active_low  ( X : in std_logic        ) return boolean;
  function active_high ( X : in std_logic_vector ) return boolean_array;
  function active_low  ( X : in std_logic_vector ) return boolean_array;

  function vector      ( X : in std_logic; N : in integer ) return std_logic_vector;

  function shr ( X : in std_logic; V : in std_logic_vector; N : in natural ) return std_logic_vector;
  function shr ( X : in std_logic_vector; V : in std_logic_vector ) return std_logic_vector;
  function shr ( X : in std_logic; V : in std_logic_vector ) return std_logic_vector;

  subtype FP16                      is word;   -- value = mantissa * (10^exponent)

  subtype exponent_range            is integer range -32 to +31;
  subtype mantissa_range            is integer range 100 to 999;

  function exponent ( F : in FP16 ) return exponent_range;
  function mantissa ( F : in FP16 ) return mantissa_range;


  
  subtype Timestamp                 is unsigned(63 downto 0);


  type    Time_code                 is record
                                         reserved_1 : std_logic;
                                         reserved_2 : std_logic;
                                         time       : unsigned(5 downto 0);
                                      -- sequence
                                         time_stamp : unsigned(9 downto 0);
                                       end record;

  type    Time_code_array           is array ( natural range <> ) of Time_code;
  
  constant zero_time_code : Time_code := ( '0', '0', "000000", "0000000000" );
  

  function INC ( A : in std_logic_vector ) return std_logic_vector;
  function INC ( A : in std_logic_vector; I : integer ) return std_logic_vector;
  function DEC ( A : in std_logic_vector ) return std_logic_vector;
  function DEC ( A : in std_logic_vector; I : integer ) return std_logic_vector;


  function version_string ( A : in octet ) return String;
  function ports_char ( A : in integer ) return character;
  
  function bool_to_std (X : in boolean ) return std_logic;
  function std_to_bool (X : in std_logic ) return boolean;


end ip4l_data_types;

package body ip4l_data_types is

	type mem_prot_t is protected body					-- protected type body
        variable mem : mem_type;					-- instantiate variable as memory. 
        
        procedure write_mem(						-- write_memory procedure body
            signal    addr    	: in	integer;
            signal    wr_data	: in 	nonet
        )is
        
        begin
            mem(addr) := wr_data;					-- assign memory @ address to write data
        end procedure write_mem;
        
        procedure read_mem(
            signal    addr      : in 	integer;
            signal    rd_data   : out 	nonet
        ) is      
        begin
            rd_data <= mem(addr);					-- assign rd_data to memory @ address;
        end procedure read_mem;
		
		impure function debug_mem return mem_type is
		begin
			return mem;
		end function debug_mem;
		
        
    end protected body mem_prot_t;


  function bitrev ( A : in std_logic_vector ) return std_logic_vector is
    variable r : std_logic_vector(A'range);
    begin
      for i in A'range
      loop
        r(i) := A(A'high + A'low - i);
      end loop;
      return r;
  end function;


  function merge ( X : in octet_array ) return octet is
    variable r : octet;
    begin
      r := (others => '0');
      for i in X'high downto X'low
      loop
        r := r or X(i);
      end loop;
      return r;
    end function;


  function merge ( X : in nonet_array ) return nonet is
    variable r : nonet;
    begin
      r := (others => '0');
      for i in X'high downto X'low
      loop
        r := r or X(i);
      end loop;
      return r;
    end function;


  function merge ( X : in word_array ) return word is
    variable r : word;
    begin
      r := (others => '0');
      for i in X'high downto X'low
      loop
        r := r or X(i);
      end loop;
      return r;
    end function;


  function merge ( X : in long_array ) return long is
    variable r : long;
    begin
      r := (others => '0');
      for i in X'high downto X'low
      loop
        r := r or X(i);
      end loop;
      return r;
    end function;


  function sum ( X : in u_word_array ) return u_word is
    variable r : u_word;
    begin
      r := (others => '0');
      for i in X'high downto X'low
      loop
        r := r + X(i);
      end loop;
      return r ;
    end function;


  function sum ( X : in u_long_array ) return u_long is
    variable r : u_long;
    begin
      r := (others => '0');
      for i in X'high downto X'low
      loop
        r := r + X(i);
      end loop;
      return r;
    end function;


  function "and" ( X, Y : in boolean_array ) return boolean_array is
    variable r : boolean_array(X'high downto X'low);
    begin
      for i in X'high - X'low downto 0
      loop
        r(i) := X(i+X'low) and Y(i+Y'low);
      end loop;
      return r;
    end function;


  function "or" ( X, Y : in boolean_array ) return boolean_array is
    variable r : boolean_array(X'high downto X'low);
    begin
      for i in X'high downto X'low
      loop
        r(i) := X(i) or Y(i);
      end loop;
      return r;
    end function;


  function "not" ( X : in boolean_array ) return boolean_array is
    variable r : boolean_array(X'high downto X'low);
    begin
      for i in X'high downto X'low
      loop
        r(i) := not X(i);
      end loop;
      return r;
    end function;


  function "=" ( X, Y : in boolean_array ) return boolean is
    variable r : boolean;
    begin
      r := true;
      for i in X'high downto X'low
      loop
        r := r and (X(i) = Y(i));
      end loop;
      return r;
    end function;


  function "/=" ( X, Y : in boolean_array ) return boolean is
    variable r : boolean;
    begin
      r := false;
      for i in X'high downto X'low
      loop
        r := r or (X(i) /= Y(i));
      end loop;
      return r;
    end function;


  function ">=" ( X, Y : in boolean_array ) return boolean is
    variable r : boolean;
    begin
      r := true;
      for i in X'high downto X'low
      loop
        r := r and (X(i) or not Y(i));
      end loop;
      return r;
    end function;


  function all_true ( X : in boolean_array ) return boolean is
    variable r : boolean;
    begin
      r := true;
      for i in X'high downto X'low
      loop
        r := r and X(i);
      end loop;
      return r;
    end function;


  function any ( X : in boolean_array ) return boolean is
    variable r : boolean;
    begin
      r := false;
      for i in X'high downto X'low
      loop
        r := r or X(i);
      end loop;
      return r;
    end function;


  function "=" ( X : in std_logic_vector; Y : in std_logic ) return boolean_array is
    variable r : boolean_array(X'high downto X'low);
    begin
      for i in X'high downto X'low
      loop
        r(i) := X(i) = Y;
      end loop;
      return r;
    end function;


  function exponent ( F : in FP16 ) return exponent_range is
    variable v : integer range 0 to 63;
    begin
      v := to_integer( unsigned( F(15 downto 10) ) );
      return v - 32; 
    end function;
    
  function mantissa ( F : in FP16 ) return mantissa_range is
    variable v : integer range 0 to 1023;
    begin
      v := to_integer( unsigned( F( 9 downto  0) ) );
      if 100 <= v and v <= 999
        then return v;
        else return 100;
      end if;
    end function;
    

  function active_high ( X : in boolean ) return std_logic is
    begin
      if X
        then return '1';
        else return '0';
      end if;
    end function;

  function active_low ( X : in boolean ) return std_logic is
    begin
      if X
        then return '0';
        else return '1';
      end if;
    end function;

  function active_high ( X : in boolean_array ) return std_logic_vector is
    variable r : std_logic_vector(X'high downto X'low);
    begin
      for i in X'high downto X'low
      loop
        r(i) := active_high( X(i) );
      end loop;
      return r;
    end function;


  function active_high ( X : in std_logic ) return boolean is
    begin
      return X = '1';
    end function;

  function active_low ( X : in std_logic ) return boolean is
    begin
      return X = '0';
    end function;

  function active_high ( X : in std_logic_vector ) return boolean_array is
    variable r : boolean_array( X'high downto X'low );
    begin
      for i in X'high downto X'low
      loop
        r(i) := X(i) = '1';
      end loop;
      return r;
    end function;

  function active_low ( X : in std_logic_vector ) return boolean_array is
    variable r : boolean_array( X'high downto X'low );
    begin
      for i in X'high downto X'low
      loop
        r(i) := X(i) = '0';
      end loop;
      return r;
    end function;


  function vector      ( X : in std_logic; N : in integer ) return std_logic_vector is
    variable r : std_logic_vector( N-1 downto 0 );
    begin
      for i in N-1 downto 0
      loop
        r(i) := X;
      end loop;
      return r;
    end function;


  function shr ( X : in std_logic; V : in std_logic_vector; N : in natural ) return std_logic_vector is
    variable r : std_logic_vector( V'high downto V'low );
    begin
      r( r'high downto r'high-N+1                       ) := ( others => X );
      r(                          r'high-N downto r'low ) :=               V(V'high downto V'low+N);
      return r;
    end function;


  function shr ( X : in std_logic; V : in std_logic_vector ) return std_logic_vector is
    variable r : std_logic_vector( V'high downto V'low );
    begin
      r( r'high                       ) := X;
      r(        r'high-1 downto r'low ) :=  V(V'high downto V'low+1);
      return r;
    end function;


  function shr ( X : in std_logic_vector; V : in std_logic_vector ) return std_logic_vector is
    variable N : natural := X'high - X'low + 1;
    variable r : std_logic_vector( V'high downto V'low );
    begin
      r( r'high downto r'high-N+1                       ) := X;
      r(                          r'high-N downto r'low ) :=   V(V'high downto V'low+N);
      return r;
    end function;



  function INC ( A : in std_logic_vector ) return std_logic_vector is
    variable b, c : unsigned(A'high downto A'low);
    begin b := unsigned(A); c := b + 1; return std_logic_vector(c);
  end function;

  function INC ( A : in std_logic_vector; I : integer ) return std_logic_vector is
    variable b, c : unsigned(A'high downto A'low);
    begin b := unsigned(A); c := b + I; return std_logic_vector(c);
  end function;


  function DEC ( A : in std_logic_vector ) return std_logic_vector is
    variable b, c : unsigned(A'high downto A'low);
    begin b := unsigned(A); c := b - 1; return std_logic_vector(c);
  end function;

  function DEC ( A : in std_logic_vector; I : integer ) return std_logic_vector is
    variable b, c : unsigned(A'high downto A'low);
    begin b := unsigned(A); c := b - I; return std_logic_vector(c);
  end function;

  function version_string ( A : in octet ) return String is
    constant hex : String(1 to 16) := "0123456789ABCDEF";
    begin
      return hex( 1 + to_integer( unsigned( A(7 downto 4) ) ) ) & "." & hex( 1 + to_integer( unsigned( A(3 downto 0) ) ) );
  end function;

  function ports_char ( A : in integer ) return character is
    constant hex : String(1 to 16) := "0123456789ABCDEF";
    begin
      if 0 <= A and A <= 15
        then return hex( 1 + A );
        else return '?';
      end if;
  end function;
  
  -- Function to convert boolean to std_logic
  function bool_to_std ( X : in boolean) return std_logic is
    begin
	  if X then
	    return '1';
	  else
	    return '0';
	  end if;
	end bool_to_std;

  -- Function to convert std_logic to boolean
  function std_to_bool ( X : in std_logic) return boolean is
    begin
	  if X = '1' then
	    return true;
	  else
	    return false;
	  end if;
	end std_to_bool;

end ip4l_data_types;




