----------------------------------------------------------------------------------------------------------------------------------
-- File Description  --
----------------------------------------------------------------------------------------------------------------------------------
-- @ File Name				:	
-- @ Engineer				:	James E Logan
-- @ Role					:	FPGA Engineer
-- @ Company				:	4Links ltd
-- @ Date					: 	dd/mm/yyyy

-- @ VHDL Version			:   1987, 1993, 2008
-- @ Supported Toolchain	:	Xilinx Vivado IDE
-- @ Target Device			: 	Xilinx US+ Family

-- @ Revision #				:	2

-- File Description         :

-- Document Number			:  xxx-xxxx-xxx
----------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Copyright (c) 2018-2023, 4Links Ltd All rights reserved.
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
use work.all;
use work.ip4l_data_types.all;
use work.SpW_Sim_lib.all; 

library UNISIM;
use UNISIM.Vcomponents.all;


----------------------------------------------------------------------------------------------------------------------------------
-- Entity Declarations --
----------------------------------------------------------------------------------------------------------------------------------
entity spw_hw_tb is
    constant c_spw_clk_freq			: real := 100_000_000.0;
    constant c_sys_clk_freq			: real := 300_000_000.0;

    constant c_spw_clk_period		: time := (1_000_000_000.0/c_spw_clk_freq) * 1 ns;
    constant c_sys_clk_period		: time := (1_000_000_000.0/c_sys_clk_freq) * 1 ns;

    constant c_clk_num				: natural := 1_000_000_000;
end spw_hw_tb;

---------------------------------------------------------------------------------------------------------------------------------
-- Code Description & Developer Notes --
---------------------------------------------------------------------------------------------------------------------------------


architecture bench of spw_hw_tb is

	----------------------------------------------------------------------------------------------------------------------------
	-- Constant Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	constant c_tx_ascii_str	: string := "HELLO_WORLD";		-- string to send on TX SpW IP
	constant c_rx_ascii_str : string := "HELLO_WORLD";		-- string to send on RX SpW IP
	constant c_mode			: string := "diff";				-- select Double-Ended (DE) or Single-Ended(SE) Operation 
	----------------------------------------------------------------------------------------------------------------------------
	-- Type Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	type ascii_mem is array (natural range <>) of std_logic_vector(7 downto 0);
	----------------------------------------------------------------------------------------------------------------------------
	-- Function Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Component Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Signal Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	signal sys_clk_p			: std_logic := '0';
	signal sys_clk_n    		: std_logic := '1';
	
	signal rst_in 	    		: std_logic := '1';
	signal enable       		: std_logic := '0';
	
	signal tx_rx_cmd_out		: std_logic_vector(2 downto 0) := (others => '0');	
	signal tx_rx_cmd_valid		: std_logic := '0';
	signal tx_rx_cmd_ready		: std_logic := '0';
	
	signal tx_rx_data_out		: std_logic_vector(7 downto 0) := (others => '0');
	signal tx_rx_data_valid     : std_logic := '0';
	signal tx_rx_data_ready     : std_logic := '0';
	
	signal rx_rx_cmd_out		: std_logic_vector(2 downto 0) := (others => '0');	
	signal rx_rx_cmd_valid		: std_logic := '0';
	signal rx_rx_cmd_ready		: std_logic := '0';

	signal rx_rx_data_out		: std_logic_vector(7 downto 0) := (others => '0');
	signal rx_rx_data_valid     : std_logic := '0';
	signal rx_rx_data_ready     : std_logic := '0';
	
	signal spw_Din_p    		: std_logic := '0';
	signal spw_Din_n    		: std_logic := '1';
	signal spw_Sin_p    		: std_logic := '0';
	signal spw_Sin_n    		: std_logic := '1';
	
	signal spw_Dout_p   		: std_logic := '0';
	signal spw_Dout_n   		: std_logic := '1';
	signal spw_Sout_p   		: std_logic := '0';
	signal spw_Sout_n   		: std_logic := '1';
	
	signal spw_tx_data_clk		: std_logic := '0';
	signal spw_rx_data_clk		: std_logic := '0';
	signal mmcm_locked      	: std_logic := '0';
	
	signal spw_debug_tx_raw		: std_logic_vector(13 downto 0);	-- raw packet received
	signal spw_debug_tx_data	: std_logic_vector(8 downto 0);		-- data packet received (Con_bit & (7 downto 0))
	signal spw_debug_tx_time	: std_logic_vector(7 downto 0);		-- space_wire timecode data received
	signal spw_debug_tx_char	: string(1 to 3);					-- command nibble received
	signal spw_debug_tx_parity	: std_logic;						-- parity bit output
	
	signal rx_rx_ascii_buf		: ascii_mem(0 to (c_tx_ascii_str'length)-1) := (others => (others => '0'));
	signal spw_rx_clock			: std_logic := '0';		
	signal spw_connected        : boolean := false;
	signal spw_rx_rx_command	: string(1 to 3);
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Variable Declarations --
	----------------------------------------------------------------------------------------------------------------------------

	----------------------------------------------------------------------------------------------------------------------------
	-- Alias Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	alias a_mmcm_locked_tx 		is << signal spw_hw_tb.u_spw_hw_tx.mmcm_locked :  std_logic >>;
	alias a_mmcm_locked_rx 		is << signal spw_hw_tb.u_spw_hw_rx.mmcm_locked :  std_logic >>;		
	
	alias a_spw_tx_dout 		is << signal spw_hw_tb.u_spw_hw_tx.spw_Dout_p  : std_logic >>;
	alias a_spw_tx_sout 		is << signal spw_hw_tb.u_spw_hw_tx.spw_Sout_p	: std_logic >>;
	alias a_spw_rx_dout 		is << signal spw_hw_tb.u_spw_hw_rx.spw_Dout_p	: std_logic >>;
	alias a_spw_rx_Sout 		is << signal spw_hw_tb.u_spw_hw_rx.spw_Sout_p	: std_logic >>;
	
	alias a_spw_tx_connected	is << signal spw_hw_tb.u_spw_hw_tx.spw_Connected : boolean >>;
	alias a_spw_rx_connected	is << signal spw_hw_tb.u_spw_hw_rx.spw_Connected : boolean >>;
	
	alias a_spw_tx_clock		is << signal spw_hw_tb.u_spw_hw_tx.clock	: std_logic >>;
	alias a_spw_tx_clock_b		is << signal spw_hw_tb.u_spw_hw_tx.clock_b 	: std_logic >>;
	alias a_spw_rx_clock		is << signal spw_hw_tb.u_spw_hw_rx.clock	: std_logic >>;
	alias a_spw_rx_clock_b		is << signal spw_hw_tb.u_spw_hw_rx.clock_b 	: std_logic >>;
	
	
begin

	----------------------------------------------------------------------------------------------------------------------------
	-- Entity Instantiations --
	----------------------------------------------------------------------------------------------------------------------------
	u_spw_hw_tx: entity spw_hello_world_logic(rtl)
	generic map(
		g_clock_freq	=> 	c_spw_clk_freq,
		g_tx_fifo_depth	=>	16,
		g_rx_fifo_depth	=> 	16,
		g_ram_str		=>	c_tx_ascii_str,
		g_mode			=>	c_mode
	)
	port map(
		-- standard register control signals --
		mmcm_clk_in1_p 	=> 	sys_clk_p,		
		mmcm_clk_in1_n	=> 	sys_clk_n,
		rst_in			=> 	rst_in, 		
		enable  		=> 	enable,
		
		rx_cmd_out		=>  tx_rx_cmd_out,		
		rx_cmd_valid	=>  tx_rx_cmd_valid,
		rx_cmd_ready	=>  tx_rx_cmd_ready,	
		
		rx_data_out		=>  tx_rx_data_out,		
		rx_data_valid	=>  tx_rx_data_valid,	
		rx_data_ready	=>	tx_rx_data_ready,	

		-- SpW Rx IO   
		spw_Din_p 		=> 	spw_Din_p,
		spw_Din_n       => 	spw_Din_n,
		spw_Sin_p       => 	spw_Sin_p,
		spw_Sin_n       => 	spw_Sin_n,

		-- SpW Tx IO   
		spw_Dout_p      => 	spw_Dout_p,
		spw_Dout_n      => 	spw_Dout_n,
		spw_Sout_p      => 	spw_Sout_p,
		spw_Sout_n      => 	spw_Sout_n
	);
	
	u_spw_hw_rx: entity spw_hello_world_logic(rtl)
	generic map(
		g_clock_freq	=> 	c_spw_clk_freq,
		g_tx_fifo_depth	=>	16,
		g_rx_fifo_depth	=> 	16,
		g_ram_str		=>	c_rx_ascii_str,
		g_mode			=>  c_mode
	)
	port map(
		-- standard register control signals --
		
		mmcm_clk_in1_p 	=> 	sys_clk_p,		
		mmcm_clk_in1_n	=> 	sys_clk_n,
		rst_in			=> 	rst_in, 		
		enable  		=> 	enable,
		
		rx_cmd_out		=>  rx_rx_cmd_out,		
		rx_cmd_valid	=>  rx_rx_cmd_valid,	
		rx_cmd_ready	=>  rx_rx_cmd_ready,	
	 
		rx_data_out		=>  rx_rx_data_out,		
		rx_data_valid	=>  rx_rx_data_valid,	
		rx_data_ready	=>	rx_rx_data_ready,								

		-- SpW Rx IO   
		spw_Din_p 		=>  spw_Dout_p,
		spw_Din_n       =>  spw_Dout_n,
		spw_Sin_p       =>  spw_Sout_p,
		spw_Sin_n       =>  spw_Sout_n,

		-- SpW Tx IO   
		spw_Dout_p      =>	spw_Din_p, 
		spw_Dout_n      =>	spw_Din_n, 
		spw_Sout_p      =>	spw_Sin_p, 
		spw_Sout_n      =>	spw_Sin_n 
	);
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Component Instantiations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Asynchronous Signal Assignments --
	----------------------------------------------------------------------------------------------------------------------------
	spw_tx_data_clk    	<= a_spw_tx_Dout xor a_spw_tx_Sout;			-- recover spacewire Tx data clock
	spw_rx_data_clk		<= a_spw_rx_Dout xor a_spw_rx_Sout;			-- recover spacewire Rx data clock
	mmcm_locked        	<= a_mmcm_locked_tx and a_mmcm_locked_rx;	-- get mmcm status 
	spw_rx_clock 		<= a_spw_rx_clock;
	spw_connected       <= a_spw_tx_connected and a_spw_rx_connected;
	----------------------------------------------------------------------------------------------------------------------------
	-- Asynchronous Processes --
	----------------------------------------------------------------------------------------------------------------------------
	stim_gen: process
	begin
		report "starting stimulus @ : " & to_string(now) severity note;
		rst_in <= '1';
		report "waiting for MMCM output LOCKED : " & to_string(now) severity note;
		wait until mmcm_locked = '1';
		report "MMCM output LOCKED @ : " & to_string(now) severity note;
		wait for 1.245 us;
		report "de-asserting reset @ : " & to_string(now) severity note;
		rst_in <= '0';
		wait for c_spw_clk_period;
		enable <= '1';
		rx_rx_data_ready <= '1';
		rx_rx_cmd_ready <= '1';
		wait until spw_rx_rx_command = "EOP";
		wait for 12.56 us;
		report "stim finished @ : " & to_string(now) severity failure;			-- stimulus finished, stop simulation. 
		wait;
	end process;
	
	
	p_sys_clk_gen: process		-- generate positive system clock
	begin
		clock_gen(sys_clk_p, c_clk_num, c_sys_clk_period);
	end process;
	
	n_sys_clk_gen: process		-- generate negative system clock 
	begin
		clock_gen(sys_clk_n, c_clk_num, c_sys_clk_period);
	end process;
	
	spw_tx_debug: process		-- debug Tx Data
	begin
		wait until (mmcm_locked = '1' and rst_in = '0');
		spw_debug_loop: loop
			spw_get_poll(spw_debug_tx_raw, spw_debug_tx_data, spw_debug_tx_time, spw_debug_tx_char, spw_debug_tx_parity, spw_Dout_p, spw_Sout_p, 1);
		end loop spw_debug_loop;
	end process;
	
	fill_rx_buffer: process		-- fill RX buffer with transmitted ASCII characters
	begin
		wait until spw_Connected = true;
		for i in 0 to rx_rx_ascii_buf'length loop
			wait until rx_rx_data_valid = '1' or rx_rx_cmd_valid = '1';
			wait until falling_edge(spw_rx_clock);
			if(rx_rx_data_valid = '1' and rx_rx_data_ready = '1') then
				rx_rx_ascii_buf(i) <= rx_rx_data_out;
			elsif(rx_rx_cmd_valid = '1' and rx_rx_cmd_ready = '1') then
				spw_rx_rx_command <= get_spw_char('1' & rx_rx_cmd_out);
			else
				report "error in AXI handshake @ element : " & to_string(i) severity failure;
			end if;
			wait until falling_edge(spw_rx_clock);
		end loop;
		--wait;
	end process;

end bench;

