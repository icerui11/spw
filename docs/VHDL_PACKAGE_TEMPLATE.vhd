----------------------------------------------------------------------------------------------------------------------------------
-- File Description  --
----------------------------------------------------------------------------------------------------------------------------------
-- @ File Name				:	my_package.vhd
-- @ Engineer				:	NAME
-- @ Role					:	ROLE
-- @ Company				:	COMPANY
-- @ Date					: 	dd/mm/yyyy

-- @ VHDL Version			:	1987
-- @ Supported Toolchain	:	Xilinx Vivado IDE/Intel Quartus 18.1+
-- @ Target Device			:	N/A

-- @ Revision #				: 	1

-- File Description         :	Standard work library containing useful functions, data types, constants and simulation
--								constructs for RTL & Testbenching. 

-- Document Number			:	TBD
----------------------------------------------------------------------------------------------------------------------------------
library ieee;			
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;	-- for extended textio functions
use ieee.math_real.all;

library std;					-- should coimpile by default, added just in case....
use std.textio.all;				-- for basic textio functions


package my_package is

	--------------------------------------------------------------------------------------------------------------------------
	-- Global config constants -- 
	--------------------------------------------------------------------------------------------------------------------------

	--------------------------------------------------------------------------------------------------------------------------
	-- Subtype & Type Declarations --
	--------------------------------------------------------------------------------------------------------------------------

	
	-- C-Style Data Types ----------------------------------------------------	
	subtype uint32_t 		is integer range 0 to 2*((2**16)-1)+1;		    --
	subtype uint16_t		is integer range 0 to (2**16)-1;  				--
	subtype uint8_t		    is integer range 0 to (2**8)-1;   				--
																			--
	subtype int32_t		    is integer range -(2**31) to (2**31)-1;   		--
	subtype int16_t 		is integer range -(2**15) to (2**15)-1;  		--
	subtype int8_t			is integer range -(2**7)  to (2**7)-1;			--
	--------------------------------------------------------------------------

	
	--------------------------------------------------------------------------------------------------------------------------
	-- Subtype & Type Constants --
	--------------------------------------------------------------------------------------------------------------------------

	
	--------------------------------------------------------------------------------------------------------------------------
	-- Component Declarations --
	--------------------------------------------------------------------------------------------------------------------------
	
	
	--------------------------------------------------------------------------------------------------------------------------
	--	Records	Declerations --
	--------------------------------------------------------------------------------------------------------------------------

	
	
	--------------------------------------------------------------------------------------------------------------------------
	--	Record Init Constant Declerations --
	--------------------------------------------------------------------------------------------------------------------------


	--------------------------------------------------------------------------------------------------------------------------
	--	Function Prototype Declerations --
	--------------------------------------------------------------------------------------------------------------------------
	
	
	-- returns log2 of arguement 
	function log2(i1 : integer) return integer;
	
	-- perform i1 - i2 using 2's compliment addition
	function subtract_2s(i1: signed; i2: signed) return signed;
	
	
	--------------------------------------------------------------------------------------------------------------------------
	--	Procedure Prototype Declerations --
	--------------------------------------------------------------------------------------------------------------------------
	
	-- generates clock signal for test-benching...
	procedure clock_gen(
		signal clock			: inout std_logic;	-- clock signal
		constant clock_num 		: natural;			-- number of clock pulses
		constant clock_period 	: time				-- clock period
	);
	
	procedure uart_tx_proc(
		signal 	tx				: inout std_logic;
		variable data_bits		: std_logic_vector;
		variable baud			: integer;
		variable parity			: natural;
		variable stop_bits		: natural
	);
	
	procedure uart_rx_proc(
		signal 	 rx				: in 	std_logic;
		variable data_bits		: out 	std_logic_vector;
		signal   IQR			: inout std_logic;
		variable baud			: integer;
		variable parity			: natural;
		variable stop_bits		: natural
	);
	
end package my_package;

package body my_package is 
	
	--------------------------------------------------------------------------------------------------------------------------
	--	Function Body Declerations  --
	--------------------------------------------------------------------------------------------------------------------------
	-- returns XORed value of two 4-bit unsigned numbers

	
	-- return log2 of function
	function log2(i1 : integer) return integer is
		variable log_val  : integer := 0;
		variable v_i1     : integer := i1;
	begin
		if(v_i1 > 1) then		-- valid input (i1 > 1)
			while (v_i1 > 1) loop
				log_val := log_val + 1;
				v_i1	:= v_i1/2;
			end loop;
		else
			log_val := 1;
		end if;
		return log_val;
	end function;
	
	-- perform 2's compliment subtraction by using addition
	function subtract_2s(i1: signed; i2: signed) return signed is
		variable  retval : signed := (others => '0');
	begin
		retval := i1 + (not(i2) + 1);	-- performs i1 - i2;
		return retval;
	end function;
	
	
	
	--------------------------------------------------------------------------------------------------------------------------
	--	Procedure Body Declerations --
	--------------------------------------------------------------------------------------------------------------------------
	
	-- generates clock signal for test-benching
	procedure clock_gen(
		signal   clock			: inout std_logic;	-- clock signal
		constant clock_num 		: natural;			-- number of clock pulses
		constant clock_period 	: time				-- clock period
	) is
	begin
		for i in 0 to clock_num loop
			wait for clock_period/2;
			clock <= not clock;
			wait for clock_period/2;
			clock <= not clock;
		end loop;
		report "clock gen finished" severity failure;
		wait;
	end clock_gen;
	
	-- procedure for writing uart data
	procedure uart_tx_proc(											-- procedure to send UART Tx data
		signal 	 tx				: inout std_logic;
		variable data_bits		: std_logic_vector;
		variable baud			: integer;
		variable parity			: natural;
		variable stop_bits		: natural
	) is
		variable bit_counter	: natural := 0;
		variable start_bits		: natural := 1;
		variable v_baud         : integer;
		variable uart_clk		: time;
	begin
        v_baud  := 1_000_000_000/baud; 
		uart_clk 	:= (v_baud * ns);							-- get uart clock period from baud (nano seconds)
		tx <= '1';												-- TX idles high
		wait for uart_clk;										-- idle high for 1 uart clock period
		
		for i in 0 to start_bits-1 loop							-- start bits loop
			tx <= '0';											-- assert Tx low for start condition
			wait for (uart_clk);								-- wait for uart clk
		end loop;
		
		for i in 0 to (data_bits'length)-1 loop					-- data bits loop
			tx <= data_bits(bit_counter);						-- set TX bitMSB first
			bit_counter := bit_counter + 1;						-- set next Tx bit
			wait for uart_clk;									-- wait for clk period
		end loop;
		
		if (parity > 0) then									-- valid parity set ?
			for i in 0 to parity-1 loop							-- set parity 
				tx <= '0';										-- assert Tx low for parity
				wait for uart_clk;								-- wait for clk period
			end loop;
		end if;
		
		for i in 0 to stop_bits-1 loop							-- set stop bits
			tx <= '1';											-- assert TX high on stop bits
			wait for uart_clk;									-- wait for clk period
		end loop;
	
	
	end uart_tx_proc;
	
	-- procedure for reading UART data
	procedure uart_rx_proc(
		signal 	 rx				: in 	std_logic;
		variable data_bits		: out 	std_logic_vector;
		signal   IQR			: inout std_logic;
		variable baud			: integer;
		variable parity			: natural;
		variable stop_bits		: natural
	) is
		variable uart_old		: std_logic := '1';
		variable bit_counter	: natural := 0;
		variable start_bits		: natural := 1;
		variable uart_clk		: time;
		variable v_baud         : integer;
		variable rx_bits 		: std_logic_vector(data_bits'length-1 downto 0) := (others => '0');
	begin
		v_baud  	:= (1_000_000_000/baud); 
		uart_clk 	:= (v_baud * ns);		-- get uart_clk (ns)
		
		RX_loop:loop												-- loop, looking for start condition
			uart_old := rx;											-- store previous value of RX line
			wait for uart_clk/2;									-- wait for clock period
			IQR <= '0';
			exit RX_loop when (uart_old = '1' and rx = '0');		-- exit when start bit detected.
		end loop;
		
		for i in 0 to data_bits'length-1 loop	-- get data bits...
			wait for uart_clk;
			rx_bits(bit_counter) := rx;			-- load data bits (MSB first)
			bit_counter := bit_counter + 1;		-- decrement data bits counter
		end loop;
		
		if(parity > 0) then						-- valid parity bits set ? 
			for i in 0 to parity-1 loop			-- loop through parity periods
				wait for uart_clk;
			end loop;
		end if;
		
		for i in 0 to stop_bits-1 loop
			stop_loop: loop
				wait for uart_clk/2;
				exit stop_loop when rx = '1';
			end loop;
		end loop;
		
		data_bits := rx_bits;					-- output Received data
		IQR <= '1';
		
	end uart_rx_proc;
	
	

end package body my_package;

--------------------------------------------------------------------------------------------------------------------------
--	END OF FILE --
--------------------------------------------------------------------------------------------------------------------------