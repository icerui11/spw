----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.10.2023 12:24:19
-- Design Name: 
-- Module Name: uart_to_target_tb - bench
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;
context work.rmap_context;

entity uart_to_target_tb is
--  Port ( );
end uart_to_target_tb;

architecture bench of uart_to_target_tb is
	
	constant c_clk_freq    		: 	natural     := 20_000_000;
	
	constant c_uart_addr : std_logic_vector := b"0000_0000";		-- address values used for data mux 
	constant c_mem_addr  : std_logic_vector := b"0100_0000"; 	-- address values used for data mux 
	constant c_led_addr  : std_logic_vector := b"1000_0000"; 	-- address values used for data mux 
	constant c_gpio_addr : std_logic_vector := b"1100_0000"; 	-- address values used for data mux 
	
	signal  sys_clk				: 	std_logic 	:= '0';
	signal 	target_clk_p		: 	std_logic 	:= '0';
	signal 	target_clk_n		: 	std_logic 	:= '1';
	signal 	target				: 	r_rmap_target_interface	:=  c_rmap_target_interface;	-- create array of target interfaces
	signal 	rst_in				: 	std_logic 	:= '1';	
	
	signal	init_UART_RX			: 	std_logic 	:= '1';		-- UART RX Pin
	signal	init_UART_TX			: 	std_logic 	:= '0';		-- UART TX Pin
	signal	init_D_in				: 	std_logic 	:= '0';		-- SpaceWire Data Input Pin
	signal	init_S_in				: 	std_logic 	:= '0';		-- SpaceWire Strobe Input Pin
	signal	init_D_out				: 	std_logic 	:= '0';		-- SpaceWire Data Output Pin
	signal	init_S_out				: 	std_logic 	:= '0';		-- SpaceWire Strobe Output Pin
	signal	init_Connected_LED		: 	std_logic 	:= '0';		-- Connected LED, Asserted when SpaceWire CoDec registers as Connected 
	
	signal	targ_UART_RX			: 	std_logic 	:= '1';		-- UART RX Pin
	signal	targ_UART_TX			: 	std_logic 	:= '0';		-- UART TX Pin
	signal	targ_D_in				: 	std_logic 	:= '0';		-- SpaceWire Data Input Pin
	signal	targ_S_in				: 	std_logic 	:= '0';		-- SpaceWire Strobe Input Pin
	signal	targ_D_out				: 	std_logic 	:= '0';		-- SpaceWire Data Output Pin
	signal	targ_S_out				: 	std_logic 	:= '0';		-- SpaceWire Strobe Output Pin
	signal	targ_Connected_LED		: 	std_logic 	:= '0';		-- Connected LED, Asserted when SpaceWire CoDec registers as Connected 
	
	signal 	targ_GPIO_OUT			: t_byte := (others => '0');
	signal 	targ_LED_OUT			: std_logic_vector(3 downto 0) := (others => '0');

begin
	
	
	tx_stim_gen: process
	begin
		wait for 20.7 us;
		rst_in <= '0';
		wait for 164.4 ns;
		
		-- set target logical address
		uart_tx_proc_c(
			init_UART_RX,
			x"F3",
			9600,
			0,
			1
		);
		
		-- set target memory address
		uart_tx_proc_c(
			init_UART_RX,
			c_gpio_addr,
			9600,
			0,
			1
		);
		
		-- set Instruction (read/write, increment addr/static addr) in this case write, no increment
		uart_tx_proc_c(
			init_UART_RX,
			b"0000_0001",
			9600,
			0,
			1
		);
		
		-- set data size (4 bytes in this case)
		uart_tx_proc_c(
			init_UART_RX,
			b"0000_0001",
			9600,
			0,
			1
		);
		
		-- 1st data byte
		uart_tx_proc_c(
			init_UART_RX,
			x"F0",
			9600,
			0,
			1
		);
		
--		rst_in <= '1';
--		wait for 164.4 ns;
--		rst_in <= '0';
		
		-- set target logical address
		uart_tx_proc_c(
			init_UART_RX,
			x"F3",
			9600,
			0,
			1
		);
		
		-- set target memory address
		uart_tx_proc_c(
			init_UART_RX,
			c_gpio_addr,
			9600,
			0,
			1
		);
		
		-- set Instruction (read/write, increment addr/static addr) in this case read, no increment
		uart_tx_proc_c(
			init_UART_RX,
			b"0000_0000",
			9600,
			0,
			1
		);
		
		-- set payload length of 4 bytes 
		uart_tx_proc_c(
			init_UART_RX,
			b"0000_0001",
			9600,
			0,
			1
		);
		
		
		-- set target logical address
		uart_tx_proc_c(
			init_UART_RX,
			x"F3",
			9600,
			0,
			1
		);
		
		-- set target memory address
		uart_tx_proc_c(
			init_UART_RX,
			c_uart_addr,
			9600,
			0,
			1
		);
		
		-- set Instruction (read/write, increment addr/static addr) in this case write /w increment address 
		uart_tx_proc_c(
			init_UART_RX,
			b"0000_0011",
			9600,
			0,
			1
		);
		
		-- set payload length of 4 bytes 
		uart_tx_proc_c(
			init_UART_RX,
			b"0000_00100",
			9600,
			0,
			1
		);
		
		-- set payload length of 4 bytes 
		uart_tx_proc_c(
			init_UART_RX,
			x"01",
			9600,
			0,
			1
		);
		
		-- set payload length of 4 bytes 
		uart_tx_proc_c(
			init_UART_RX,
			x"02",
			9600,
			0,
			1
		);
		
		-- set payload length of 4 bytes 
		uart_tx_proc_c(
			init_UART_RX,
			x"03",
			9600,
			0,
			1
		);
		
		-- set payload length of 4 bytes 
		uart_tx_proc_c(
			init_UART_RX,
			x"04",
			9600,
			0,
			1
		);
		report "last byte sent on RX" severity warning;
		wait for 15.45 ms;
		
		report "stim finished" severity failure;
	wait;
	end process;
	
	
	sys_clk_gen: process
	begin
		clock_gen(
			sys_clk,
			83.333 ns
		);
	end process;
	
	init_dut: entity work.usb_to_spw_initiator_top_level(rtl)
	generic map(
		g_clk_freq => c_clk_freq
	)
    port map( 
        
        -- standard register control signals --
        clk_in			=> 	sys_clk,
        rst_in			=> 	rst_in,
        enable  		=> 	'1',
		
		-- UART Ports --
		UART_RX			=> 	init_UART_RX,		-- UART RX Pin
		UART_TX			=> 	init_UART_TX,		-- UART TX Pin
		
		-- SpaceWire Input Ports --
		D_in			=> 	init_D_in,			-- SpaceWire Data Input Pin
		S_in			=>	init_S_in,			-- SpaceWire Strobe Input Pin
		
		-- SpaceWire Output Ports --
		D_out			=> 	init_D_out,			-- SpaceWire Data Output Pin
		S_out			=> 	init_S_out,			-- SpaceWire Strobe Output Pin
		
		-- Status LEDS --
		Connected_LED	=> 	init_Connected_LED	-- Connected LED, Asserted when SpaceWire CoDec registers as Connected 
		
    );
	
	target_dut: entity work.uart_to_rmap_top_level(rtl)
	generic map(
		g_clk_freq 		=> 	c_clk_freq,
		g_target_addr	=> 	x"F3"
	)
    port map( 
        
        -- standard register control signals --
        clk_in			=> 	sys_clk				,
        rst_in			=> 	rst_in				,
        enable  		=> 	'1'	                ,				
		
		-- UART Ports --
		UART_RX			=>	targ_UART_RX		,			
		UART_TX			=>  targ_UART_TX		,	

		-- SpaceWire Input --                   
		D_in			=>  init_D_out			,
		S_in			=>  init_S_out			,

		-- SpaceWire Output 
		D_out			=>  init_D_in			,
		S_out			=>  init_S_in			,

		GPIO_OUT		=>  targ_GPIO_OUT		,
		LED_OUT			=>  targ_LED_OUT		,	
		-- Status LEDS --  
		Connected_LED	=>  targ_Connected_LED	
		
    );
	
	
	
end bench;
