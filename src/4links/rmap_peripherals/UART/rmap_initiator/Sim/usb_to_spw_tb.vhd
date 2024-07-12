----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.10.2023 12:24:19
-- Design Name: 
-- Module Name: usb_to_spw_tb - bench
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

entity usb_to_spw_tb is
--  Port ( );
end usb_to_spw_tb;

architecture bench of usb_to_spw_tb is
	
	constant c_clk_freq    		: 	natural     := 20_000_000;
	signal  sys_clk				: 	std_logic 	:= '0';
	signal 	target_clk_p		: 	std_logic 	:= '0';
	signal 	target_clk_n		: 	std_logic 	:= '1';
	signal 	target				: 	r_rmap_target_interface:=  c_rmap_target_interface;	-- create array of target interfaces
	signal 	rst_in				: 	std_logic 	:= '1';	
	signal	UART_RX				: 	std_logic 	:= '1';		-- UART RX Pin
	signal	UART_TX				: 	std_logic 	:= '0';		-- UART TX Pin
	signal	D_in				: 	std_logic 	:= '0';		-- SpaceWire Data Input Pin
	signal	S_in				: 	std_logic 	:= '0';		-- SpaceWire Strobe Input Pin
	signal	D_out				: 	std_logic 	:= '0';		-- SpaceWire Data Output Pin
	signal	S_out				: 	std_logic 	:= '0';		-- SpaceWire Strobe Output Pin
	signal	Connected_LED		: 	std_logic 	:= '0';		-- Connected LED, Asserted when SpaceWire CoDec registers as Connected 

begin
	
	
	tx_stim_gen: process
	begin
		wait for 20.7 us;
		rst_in <= '0';
		wait for 164.4 ns;
		
		-- set target logical address
		uart_tx_proc_c(
			UART_RX,
			x"F3",
			9600,
			0,
			1
		);
		
		-- set target memory address
		uart_tx_proc_c(
			UART_RX,
			x"05",
			9600,
			0,
			1
		);
		
		-- set Instruction (read/write, increment addr/static addr) in this case write /w increment address 
		uart_tx_proc_c(
			UART_RX,
			x"03",
			9600,
			0,
			1
		);
		
		-- set data size (4 bytes in this case)
		uart_tx_proc_c(
			UART_RX,
			b"0000_0100",
			9600,
			0,
			1
		);
		
		-- 1st data byte
		uart_tx_proc_c(
			UART_RX,
			x"01",
			9600,
			0,
			1
		);
		
		-- 2nd data byte 
		uart_tx_proc_c(
			UART_RX,
			x"02",
			9600,
			0,
			1
		);
		
		--3rd data byte 
		uart_tx_proc_c(
			UART_RX,
			x"03",
			9600,
			0,
			1
		);
		
		-- 4th data byte 
		uart_tx_proc_c(
			UART_RX,
			x"04",
			9600,
			0,
			1
		);
		
		-- set target logical address
		uart_tx_proc_c(
			UART_RX,
			x"F3",
			9600,
			0,
			1
		);
		
		-- set target memory address
		uart_tx_proc_c(
			UART_RX,
			x"05",
			9600,
			0,
			1
		);
		
		-- set Instruction (read/write, increment addr/static addr) in this case read /w increment address 
		uart_tx_proc_c(
			UART_RX,
			b"0000_0010",
			9600,
			0,
			1
		);
		
		-- set payload length of 4 bytes 
		uart_tx_proc_c(
			UART_RX,
			b"0000_0100",
			9600,
			0,
			1
		);
		
		
		wait for 15.45 ms;
		
		report "stim finished" severity failure;
	wait;
	end process;
	
	
	tar_clk_gen_p: process
	begin
		clock_gen(
			target_clk_p,
			50 ns
		);
	end process;
	
	tar_clk_gen_n: process
	begin
		clock_gen(
			target_clk_n,
			50 ns
		);
	end process;
	
	sys_clk_gen: process
	begin
		clock_gen(
			sys_clk,
			83.333 ns
		);
	end process;
	
	dut: entity work.usb_to_spw_initiator_top_level(rtl)
	generic map(
		g_clk_freq => c_clk_freq
	)
    port map( 
        
        -- standard register control signals --
        clk_in			=> 	sys_clk,
        rst_in			=> 	rst_in,
        enable  		=> 	'1',
		
		-- UART Ports --
		UART_RX			=> 	UART_RX,		-- UART RX Pin
		UART_TX			=> 	UART_TX,		-- UART TX Pin
		
		-- SpaceWire Input Ports --
		D_in			=> 	D_in,			-- SpaceWire Data Input Pin
		S_in			=>	S_in,			-- SpaceWire Strobe Input Pin
		
		-- SpaceWire Output Ports --
		D_out			=> 	D_out,			-- SpaceWire Data Output Pin
		S_out			=> 	S_out,			-- SpaceWire Strobe Output Pin
		
		-- Status LEDS --
		Connected_LED	=> 	Connected_LED	-- Connected LED, Asserted when SpaceWire CoDec registers as Connected 
		
    );
	
	target_inst: entity work.rmap_target_full(rtl)
	generic map(
		g_freq 			=> c_clk_freq * 1.0,
		g_fifo_depth 	=> 16,
		g_mode			=> "single"
	)
	port map( 
		
		clock              		=> 	target_clk_p,
		clock_b			   		=> 	target_clk_n,
		async_reset        		=> 	rst_in,
		reset              		=> 	rst_in,
		
		Rx_Time              	=>	target.Rx_Time  			,  
		Rx_Time_OR           	=>	target.Rx_Time_OR           ,
		Rx_Time_IR           	=>	target.Rx_Time_IR           ,
	
		Tx_Time              	=>	target.Tx_Time              ,
		Tx_Time_OR           	=>  target.Tx_Time_OR           ,
		Tx_Time_IR           	=>  target.Tx_Time_IR           ,

		Rx_ESC_ESC           	=>	target.Rx_ESC_ESC           ,
		Rx_ESC_EOP           	=>  target.Rx_ESC_EOP           ,
		Rx_ESC_EEP           	=>  target.Rx_ESC_EEP           ,
		Rx_Parity_error      	=>  target.Rx_Parity_error      ,
		Rx_bits              	=>  target.Rx_bits              ,
		Rx_rate              	=>  target.Rx_rate              ,

		Disable              	=>	target.Disable              ,
		Connected            	=>  target.Connected            ,
		Error_select         	=>  target.Error_select         ,
		Error_inject         	=>  target.Error_inject         ,

		-- SpW	     
		Din_p                	=>  D_out                       ,
		Sin_p                	=>  S_out                       ,
		Dout_p               	=>  D_in                        ,
		Sout_p               	=>  S_in                        ,

		-- Memory Interface                                         
		Address           	 	=>	target.Address              ,
		wr_en             	 	=>  target.wr_en                ,
		Write_data        	 	=>  target.Write_data           ,
		Bytes             	 	=>  target.Bytes                ,
		Read_data         	 	=>  target.Read_data            ,
		Read_bytes        	 	=>  target.Bytes                ,
	
		-- Bus handshake                                            
		RW_request         		=>	target.RW_request           ,
		RW_acknowledge     		=>  target.RW_acknowledge       ,
		
		-- Control/Status                                           
		Echo_required      		=>	target.Echo_required        ,
		Echo_port          		=>  target.Echo_port            ,
	
		Logical_address    		=>	target.Logical_address      ,
		Key                		=>  target.Key                  ,
		Static_address     		=>  target.Static_address       ,
		
		Checksum_fail      		=>	target.Checksum_fail        ,
		
		Request            		=>	target.Request              ,
		Reject_target      		=>  target.Reject_target        ,
		Reject_key         		=>  target.Reject_key           ,
		Reject_request     		=>  target.Reject_request       ,
		Accept_request     		=>  target.Accept_request       ,
	
		Verify_overrun     		=>	target.Verify_overrun       ,

		OK                 		=>	target.OK                   ,
		Done               		=>	target.Done              
		
	);
	
	target.Accept_request    	<= '1';
	target.RW_acknowledge   	<= '1';
	
	target_ram_inst:entity work.xilinx_single_port_single_clock_ram(rtl) 
	generic map(
		ram_type	=> "auto",			-- ram type to infer (auto, distributed, block, register, ultra)
		data_width	=> 8,				-- bit-width of ram element
		addr_width	=> 8,				-- address width of RAM
		ram_str		=> "HELLO_WORLD"		
	)
	port map(
		-- standard register control signals --
		clk_in 		=> target_clk_p,							-- clock in (rising_edge)
		enable_in 	=> '1',										-- enable input (active high)
		
		wr_en		=> target.wr_en,							-- write enable (asserted high)
		addr		=> target.Address(7 downto 0),
		wr_data     => target.Write_data,
		rd_data		=> target.Read_data
	);

end bench;
