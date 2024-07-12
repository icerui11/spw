----------------------------------------------------------------------------------------------------------------------------------
-- File Description  --
----------------------------------------------------------------------------------------------------------------------------------
-- @ File Name				:
-- @ Engineer				: 
-- @ Role					:
-- @ Company				:

-- @ VHDL Version			:
-- @ Supported Toolchain	:
-- @ Target Device			:

-- @ Revision #				:

-- File Description         :

-- Document Number			:  xxx-xxxx-xxx
----------------------------------------------------------------------------------------------------------------------------------
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
context work.spw_context;


----------------------------------------------------------------------------------------------------------------------------------
-- Entity Declarations --
----------------------------------------------------------------------------------------------------------------------------------
entity xilinx_single_port_single_clock_ram is 
	generic(
		ram_type	: string  	:= "auto";			-- ram type to infer (auto, distributed, block, register, ultra)
		data_width	: natural 	:= 8;				-- bit-width of ram element
		addr_width	: natural 	:= 32;				-- address width of RAM
		ram_str		: string	:= "HELLO_WORLD"		
	);
	port(
		-- standard register control signals --
		clk_in 		: in 	std_logic := '0';											-- clock in (rising_edge)
		enable_in 	: in 	std_logic := '0';											-- enable input (active high)
		
		wr_en		: in 	std_logic := '0';											-- write enable (asserted high)
		addr		: in 	std_logic_vector(addr_width-1 downto 0) := (others => '0');	-- write address
		wr_data     : in    std_logic_vector(data_width-1 downto 0) := (others => '0');	-- write data
		rd_data		: out 	std_logic_vector(data_width-1 downto 0) := (others => '0')	-- read data
		
	);
end entity xilinx_single_port_single_clock_ram;

---------------------------------------------------------------------------------------------------------------------------------
-- Code Description & Developer Notes --
---------------------------------------------------------------------------------------------------------------------------------

	-- See Xilinx User Guide UG974 for US+ ram_style options. --
	-- Instantiates Single-port, Single-clock, Read-first Xilinx RAM. 

architecture rtl of xilinx_single_port_single_clock_ram is

	attribute ram_style : string;
	----------------------------------------------------------------------------------------------------------------------------
	-- Constant Declarations --
	----------------------------------------------------------------------------------------------------------------------------

	----------------------------------------------------------------------------------------------------------------------------
	-- Type Declarations --
	----------------------------------------------------------------------------------------------------------------------------
--	subtype mem_element is std_logic_vector(data_width-1 downto 0);				-- declare size of each memory element in RAM
--	type t_ram is array (natural range <>) of mem_element;						-- declare RAM as array of memory element
	
	
	-- initialized each memory element as N, where N is the address of the memory element
	impure function init_ram_count(ram_depth: integer) return t_ram is		-- create function to initialize RAM using a counter
		variable v_counter	 : unsigned;
		variable ram_content : t_ram(0 to (2**addr_width)-1);
	begin
		for i in 0 to ram_depth-1 loop
			ram_content(i) := std_logic_vector(v_counter);
			v_counter := (v_counter+1) mod data_width;
		end loop;
		return ram_content;
	end; 
	
	-- convert character to standard logic vector
	impure function to_slv(char: character) return std_logic_vector is
		variable ascii	: integer;
	begin
		ascii := character'pos(char);
		return std_logic_vector(to_unsigned(ascii, data_width));
	end;
	
	-- convert string to array of memory elements
	impure function str_to_char(str: string; ram_size: integer) return t_ram is
	   variable str_limit: string(1 to ram_size);	
	   variable char_arr: t_ram(0 to ram_size-1) := (others =>(others => '0'));   -- create byte array to store character ascii values
	begin
		if(str'length > ram_size) then						-- string larger than memory ?
			for i in 0 to data_width-1 loop					-- limit data output to valid size of memory
				char_arr(i) := to_slv(str(i+1));            -- string start count from (1 to X), array is (0 to X-1).
			end loop;
		else												-- string smaller than or equal to memory size ?
			for i in 0 to str'length-1 loop					-- put whole string into memeory
				char_arr(i) := to_slv(str(i+1));            -- string start count from (1 to X), array is (0 to X-1).
			end loop;
		end if;
	    return char_arr;									-- return memroy array 
	end;
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Entity Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Component Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Signal Declarations --
	----------------------------------------------------------------------------------------------------------------------------
--	signal s_ram : t_ram(0 to (2**addr_width)-1) := init_ram_count(2**addr_width);	-- declare ram and initialize using above function
	signal s_ram : t_ram := (others => (others => '0'));-- str_to_char(ram_str, (2**addr_width));	-- load HELLO_WORLD into memory, set unused bits '0';
	----------------------------------------------------------------------------------------------------------------------------
	-- Variable Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Alias Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Attribute Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	attribute ram_style of s_ram : signal is ram_type;		-- declare ram style (Xilinx synthesis attribute)
	
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
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Synchronous Processes --
	----------------------------------------------------------------------------------------------------------------------------
	ram_proc:process(clk_in)
	begin
		if(rising_edge(clk_in)) then
			if(enable_in = '1') then
				if(wr_en = '1') then
					s_ram(to_integer(unsigned(addr))) <= wr_data;
				end if;
				rd_data <= s_ram(to_integer(unsigned(addr)));
			end if;
		end if;
	end process;

	----------------------------------------------------------------------------------------------------------------------------
	-- Asynchronous Processes --
	----------------------------------------------------------------------------------------------------------------------------
end rtl;