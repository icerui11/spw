----------------------------------------------------------------------------------------------------------------------------------
-- File Description  --
----------------------------------------------------------------------------------------------------------------------------------
-- @ File Name				:	SpW_Sim_lib.vhd
-- @ Engineer				: 	James E Logan
-- @ Role					:	FPGA & Electronics Engineer
-- @ Company				:	4Links 

-- @ VHDL Version			:	1987
-- @ Supported Toolchain	:	Xilinx Vivado IDE/Intel Quartus 18.1+
-- @ Target Device			:	N/A

-- @ Revision #				: 	1

-- File Description         :	Library for Simulating SpW_ip_tb.vhd
--								 

-- Document Number			:	xxx-xxxx-xxx
----------------------------------------------------------------------------------------------------------------------------------
library ieee;			
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;	-- for extended textio functions
use ieee.math_real.all;

library std;					-- should coimpile by default, added just in case....
use std.textio.all;				-- for basic textio functions

package SpW_Sim_lib is

	--------------------------------------------------------------------------------------------------------------------------
	-- Global config constants -- 
	--------------------------------------------------------------------------------------------------------------------------
	-- SpaceWire Control Characters -- 
	constant c_SpW_FCT 		: 	std_logic_vector(2 downto 0) := "001";	-- note documentation usually shows LSB -> MSB bit arrangement. Parity excluded
	constant c_SpW_EOP		: 	std_logic_vector(2 downto 0) := "101";
	constant c_SpW_EEP		: 	std_logic_vector(2 downto 0) := "011";
	constant c_SpW_ESC		: 	std_logic_vector(2 downto 0) := "111";
	
	-- SpaceWire Simulation Debug Output Codes	--
	constant c_SpW_Sim_FCT	: 	string(1 to 3) := "FCT";
	constant c_SpW_Sim_EOP	: 	string(1 to 3) := "EOP";
	constant c_SpW_Sim_EEP	: 	string(1 to 3) := "EEP";
	constant c_SpW_Sim_ESC	: 	string(1 to 3) := "ESC";
	constant c_SpW_Sim_DAT	: 	string(1 to 3) := "DAT";
	constant c_SpW_Sim_TIM	: 	string(1 to 3) := "TIM";
	
	
	--------------------------------------------------------------------------------------------------------------------------
	-- Subtype & Type Declarations --
	--------------------------------------------------------------------------------------------------------------------------
	
	type t_nonet_array 		is array (natural range <>) of std_logic_vector(8 downto 0);
	type t_octet_array 		is array (natural range <>) of std_logic_vector(7 downto 0);
	type t_bool_array		is array (natural range <>) of boolean;
	type t_int_array		is array (natural range <>) of integer range 0 to 2;
	type t_word_array		is array (natural range <>) of std_logic_vector(15 downto 0);
	type t_nibble_array		is array (natural range <>) of std_logic_vector(3 downto 0);
	
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
	
	-- enter 4-bit SPW code, returns spacewire Token Code
	function get_spw_char(spw_char: std_logic_vector(3 downto 0)) return string;
	
	-- convert boolean value to std_logic;
	function bool_2_logic(b1: boolean) return std_logic;
	
	-- concatenate two spacewire characters to produce full code 
	-- function get_spw_code(spw_char: std_logic_vector(3 downto 0)) return string;
	
	
	--------------------------------------------------------------------------------------------------------------------------
	--	Procedure Prototype Declerations --
	--------------------------------------------------------------------------------------------------------------------------
	
	-- generates clock signal for test-benching...
	procedure clock_gen(
		signal clock			: inout std_logic;	-- clock signal
		constant clock_num 		: natural;			-- number of clock pulses
		constant clock_period 	: time				-- clock period
	);
	
	-- transmit UART data
	procedure uart_tx_proc(
		signal 	tx				: inout std_logic;
		variable data_bits		: std_logic_vector;
		variable baud			: integer;
		variable parity			: natural;
		variable stop_bits		: natural
	);
	
	-- receive UART data 
	procedure uart_rx_proc(
		signal 	 rx				: in 	std_logic;
		variable data_bits		: out 	std_logic_vector;
		signal   IQR			: inout std_logic;
		variable baud			: integer;
		variable parity			: natural;
		variable stop_bits		: natural
	);
	
	-- poll spacewire D/S lines, output debug data
	procedure spw_get_poll(
		signal spw_raw			: out 	std_logic_vector(13 downto 0);	-- raw packet received
		signal spw_data			: out 	std_logic_vector(8 downto 0);	-- data packet received (Con_bit & (7 downto 0))
		signal spw_time			: out 	std_logic_vector(7 downto 0);	-- space_wire timecode data received
		signal spw_char			: out 	string(1 to 3);					-- command nibble received
		signal spw_parity		: out 	std_logic;						-- parity bit output
		signal spw_d			: in 	std_logic;						-- spacewire data signal
		signal spw_s			: in 	std_logic;						-- spacewire strobe signal
		constant period		    : 	    natural							-- polling period (ns)
	);
	
	procedure wait_clocks(
		constant clk_period		: time;
		variable clk_num		: natural
	);
	
	
	
end package SpW_Sim_lib;

package body SpW_Sim_lib is 
	
	--------------------------------------------------------------------------------------------------------------------------
	--	Function Body Declerations  --
	--------------------------------------------------------------------------------------------------------------------------
	-- returns XORed value of two 4-bit unsigned numbers

	
	-- return log2 of function
	function log2(i1 : integer) return integer is
		variable log_val  : integer := 1;
		variable v_i1     : integer := i1;
	begin
		if(i1 > 1) then		-- valid input (i1 > 1)
			while (v_i1 > 1) loop
				log_val := log_val + 1;
				v_i1	:= v_i1/2;
			end loop;
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
	
	-- enter 4-bit SPW code, returns spacewire Token Code
	function get_spw_char(spw_char: std_logic_vector(3 downto 0)) return string is
		variable return_string	:	string(1 to 3);				-- string to return
		variable v_char			: 	std_logic_vector(2 downto 0);
	begin
		v_char 	:= spw_char(3 downto 1);
		case(v_char) is							-- check input matches valid Character values
			when c_SpW_FCT =>
				return_string := "FCT";
			
			when c_SpW_EOP =>
				return_string := "EOP";
			
			when c_SpW_EEP =>
				return_string := "EEP";
			
			when c_SpW_ESC =>
				return_string := "ESC";
				
			when others =>								-- no match with valid char values ?
				return_string := "BAD";				-- return invalid argument
				
		end case;
		
		return return_string;
	end function;
	
	
	
	-- output boolean argument as std_logic
	function bool_2_logic(b1: boolean) return std_logic is
		variable logic :	std_logic;
	begin
		if(b1 = true) then
			logic := '1';
		else
			logic := '0';
		end if;
		return logic;
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
	
	
	-- used to poll the SpW Channel. Outputs Debug data
	procedure spw_get_poll(
		signal spw_raw			: out 	std_logic_vector(13 downto 0);	-- raw packet received (defaults bits to unknown if not used)
		signal spw_data			: out 	std_logic_vector(8 downto 0);	-- data packet received (Con_bit & (7 downto 0))
		signal spw_time			: out 	std_logic_vector(7 downto 0);	-- space_wire timecode data received
		signal spw_char			: out 	string(1 to 3);					-- command nibble received
		signal spw_parity		: out 	std_logic;						-- parity bit output
		signal spw_d			: in 	std_logic;						-- spacewire data signal
		signal spw_s			: in 	std_logic;						-- spacewire strobe signal
		constant period		    : 		natural							-- polling period (ns)
	)is 
		variable data_bits		: std_logic_vector(13 downto 0);			-- buffer to store data bits
		variable xor_val 		: std_logic	:= '0';							-- buffer to store XOR value of D/S
		variable v_period		: time 		:= period * 1 ns;				-- period to wait (ns)
		
	begin	
		data_bits 	:= (others => 'U');									-- manually buffers unknown (for debug)
		init: loop														-- wait around for first clock edge
			xor_val := spw_d xor spw_s;
			wait for v_period;
			exit init when xor_val /= (spw_d xor spw_s);		
		end loop init;
		
		data_bits(0) := spw_d;											-- load first bit from first clock edge (parity bit)
		
		for i in 1 to 3 loop											-- get the rest of the nibble
			rx_loop: loop
				xor_val := spw_d xor spw_s;
				wait for v_period;		
				exit rx_loop when xor_val /= (spw_d xor spw_s);
			end loop rx_loop;
			data_bits(i) := spw_d;
		end loop;
		
	
		if(data_bits(1) = '0') then													-- data SPW frame ?
			spw_char <= "DAT";														-- report DATA info packet
			for i in 4 to 9 loop													-- repeat to get the rest of the fata frame (10 bits total. 6 more to go)
				rx_loop2: loop
					xor_val := spw_d xor spw_s;
					wait for v_period;	
					exit rx_loop2 when xor_val /= (spw_d xor spw_s);
				end loop rx_loop2;
				data_bits(i) := spw_d;
			end loop;
			spw_data(7 downto 0) <= data_bits(9 downto 2);							-- assign output variable data bit
			spw_data(8)			 <= data_bits(1);
		else																		-- else, Control SPW frame ?
		
			case(data_bits(3 downto 1)) is
				when c_SpW_FCT =>
					spw_char <= "FCT";
					
				when c_SpW_EOP =>
					spw_char <= "EOP";
				
				when c_SpW_EEP =>
					spw_char <= "EEP";
				
				when c_SpW_ESC =>
					spw_char <= "ESC";													-- output Escape character
	
					for i in 4 to 5 loop												-- read in next two bits, check for time code
						rx_loop3: loop
							xor_val := spw_d xor spw_s;
							wait for v_period;		
							exit rx_loop3  when xor_val /= (spw_d xor spw_s);
						end loop rx_loop3;
						data_bits(i) := spw_d;											-- for 5th data bit
					end loop;
					
					if(data_bits(5) = '1') then											-- not a time code ?
						for i in 6 to 7 loop											-- get the rest of the packet
							rx_loop4: loop
								xor_val := spw_d xor spw_s;
								wait for v_period;		
								exit rx_loop4  when xor_val /= (spw_d xor spw_s);
							end loop rx_loop4;
							data_bits(i) := spw_d;
						end loop;	
						spw_char <= get_spw_char(data_bits(7 downto 4));				-- output 
					else																-- is a time code ?
						spw_char <= "TIM";												-- report TIME info packet
						for i in 6 to 13 loop											-- get the time code data...
							rx_loop5: loop
								xor_val := spw_d xor spw_s;
								wait for v_period;		
								exit rx_loop5  when xor_val /= (spw_d xor spw_s);
							end loop rx_loop5;
							data_bits(i) := spw_d;									
						end loop; 
						spw_time <= data_bits(13 downto 6);								-- output timecode data 
					end if;
				
				when others =>
					spw_char <= "BAD";
				
			end case;
		end if;
		spw_parity <= data_bits(0);
		spw_raw <= data_bits;														-- output raw spw data

	end spw_get_poll;
	
	procedure wait_clocks(
		constant clk_period		: time;			-- clock period
		variable clk_num		: natural		-- number of clocks to wait for 
	) is
	begin
		for i in 0 to clk_num-1 loop			-- create for loop in range
			wait for clk_period;				-- wait for clk_period
		end loop;								-- end loop, will exit once all iterations complete
	end wait_clocks;							
	

end package body SpW_Sim_lib;

--------------------------------------------------------------------------------------------------------------------------
--	END OF FILE --
--------------------------------------------------------------------------------------------------------------------------