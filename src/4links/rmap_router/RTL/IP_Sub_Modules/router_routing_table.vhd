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
context work.router_context;

----------------------------------------------------------------------------------------------------------------------------------
-- Entity Declarations --
----------------------------------------------------------------------------------------------------------------------------------
entity router_routing_table is 
	generic(
		data_width	: natural := 32;			-- bit-width of ram element (0-31 = port number)
		addr_width	: natural := 8				-- address width of RAM (256 address, (0 -> 31) and 255 are reserved)
	);
	port(
		-- standard register control signals --
		clk_in 		: in 	std_logic := '0';											-- clock in (rising_edge)
		enable_in 	: in 	std_logic := '0';											-- enable input (active high)
		
		wr_en		: in 	std_logic := '0';											-- write enable (asserted high)
		wr_addr		: in 	std_logic_vector(addr_width-1 downto 0) := (others => '0');	-- write address
		wr_data     : in    std_logic_vector(data_width-1 downto 0) := (others => '0');	-- write data
		
		rd_addr		: in 	std_logic_vector(addr_width-1 downto 0) := (others => '0'); -- read address 
		rd_data		: out 	std_logic_vector(data_width-1 downto 0) := (others => '0')	-- read data
		
	);
end entity router_routing_table;

---------------------------------------------------------------------------------------------------------------------------------
-- Code Description & Developer Notes --
---------------------------------------------------------------------------------------------------------------------------------

	-- See Xilinx User Guide UG974 for US+ ram_style options. --
	-- Instantiates Single-port, Single-clock, Read-first Xilinx RAM. 

architecture rtl of router_routing_table is

	attribute ram_style : string;
	----------------------------------------------------------------------------------------------------------------------------
	-- Constant Declarations --
	----------------------------------------------------------------------------------------------------------------------------

	----------------------------------------------------------------------------------------------------------------------------
	-- Type Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	subtype mem_element is std_logic_vector(data_width-1 downto 0);				-- declare size of each memory element in RAM
	type t_ram is array (natural range <>) of mem_element;						-- declare RAM as array of memory element
	
	
--	-- initialized each memory element as N, where N is the address of the memory element
--	impure function init_ram_ports(ram_depth: integer) return t_ram is		-- create function to initialize RAM using a counter
--		variable v_counter	 : natural range 0 to 31;
--		variable ram_content : t_ram(0 to (2**addr_width)-1) := (others => (others => '0'));
--	begin
--		for i in 0 to ram_depth-1 loop
--			ram_content(i)(v_counter) := '1';
--			v_counter := (v_counter + 1) mod 32;
--		end loop;
--		ram_content(4) := x"000000FF";
--		return ram_content;
--	end; 
	
	function init_router_mem (ram_depth : integer) return t_ram is
		variable ratio : integer := 4;
		variable v_counter : integer range 1 to c_num_ports-1  := 1;
		variable v_ram : t_ram(0 to (ram_depth*ratio)-1);
		Variable element : std_logic_vector(31 downto 0) := (others => '0');
	begin
		v_ram(0) := (0 => '1', others => '0');
		v_ram(1) := (others => '0');
		v_ram(2) := (others => '0');
		v_ram(3) := (others => '0');
		for i in 1 to ram_depth-1 loop
			element := (others => '0');
			element(v_counter) := '1';
			if(v_counter = c_num_ports-1) then
				v_counter := 1;
			else
				v_counter := (v_counter + 1);
			end if;
			for j in 0 to ratio-1 loop
				v_ram(j+(ratio*i)) := element(((8*(j+1))-1) downto (8*j));
			end loop;
		
		end loop;
		
		return v_ram;
	end function;
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Entity Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Component Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Signal Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	signal s_ram : t_ram(0 to (2**addr_width)-1) := init_router_mem(256);	-- declare ram and initialize using above function
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
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Synchronous Processes --
	----------------------------------------------------------------------------------------------------------------------------
	ram_proc:process(clk_in)
	begin
		if(rising_edge(clk_in)) then
			if(enable_in = '1') then
				if(wr_en = '1') then
					s_ram(to_integer(unsigned(wr_addr))) <= wr_data;
				end if;
				rd_data <= s_ram(to_integer(unsigned(rd_addr)));
			end if;
		end if;
	end process;

	----------------------------------------------------------------------------------------------------------------------------
	-- Asynchronous Processes --
	----------------------------------------------------------------------------------------------------------------------------
end rtl;