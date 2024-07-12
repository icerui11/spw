----------------------------------------------------------------------------------------------------------------------------------
-- File Description  --
----------------------------------------------------------------------------------------------------------------------------------
-- @ File Name				:	SpW_ip_tb.vhd
-- @ Engineer				:	James E Logan
-- @ Role					:	FPGA Engineer
-- @ Company				:	4Links ltd
-- @ Date					: 	16/06/2023

-- @ VHDL Version			:   2008
-- @ Supported Toolchain	:	Xilinx Vivado IDE
-- @ Target Device			: 	Xilinx US+ Family, KCU116 Eval

-- @ Revision #				:	1

-- File Description         : 4Links SpW CoDec IP testbench (basic) for Vivado. 

-- Document Number			:  xxx-xxxx-xxx
----------------------------------------------------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use ieee.numeric_std.all;

use work.ip4l_data_types.all;
use work.spw_codes.all;
use work.SpW_Sim_lib.all;
use work.all;


entity SpW_ip_tb is
--  Port ( );
end SpW_ip_tb;

architecture bench of SpW_ip_tb is
	
	type nonet_mem is array (natural range <>) of nonet;
	type octet_mem is array (natural range <>) of octet;
	
	constant c_clock_frequency 	: 		real      	:=  125_000_000.0;	-- clock frequency (in Hz)
	constant c_rx_fifo_size    	: 		integer   	:=  16;				-- number of SpW packets in RX fifo
	constant c_tx_fifo_size    	: 		integer   	:=  16;				-- number of SpW packets in TX fifo
	constant c_mode				: 		string 		:= "diff";
	
	constant clk_period			: 		time        := (1_000_000_000.0 / c_clock_frequency) * 1 ns;	-- clock period (ns)
	constant clk_num			: 		natural 	:= 1_000_000_000;								-- number of clock transitions, ignored...
	
	signal	clock               :     	std_logic	:= '0';			-- pos clock, init low
	signal	clock_b             :     	std_logic	:= '1';			-- neg clock, init high
	signal	reset               :     	std_logic	:= '1';			-- DUT reset, active high, init high
	
	-- Channels
	signal	Tx_data         ,Tx_data_2            :  		nonet;						-- 9 bits of Tx Data (data to send)
	signal	Tx_OR           ,Tx_OR_2              :  		boolean;					-- Tx data Output Ready
	signal	Tx_IR           ,Tx_IR_2              :  		boolean;					-- Tx data Input Ready
	
	signal	Rx_data         ,Rx_data_2            :  		nonet;						-- 9 bits of Rx Data (data received)
	signal	Rx_OR           ,Rx_OR_2              :  		boolean;					-- Rx data Output Ready
	signal	Rx_IR           ,Rx_IR_2              :  		boolean;					-- Rx data Input Ready

	signal	Rx_ESC_ESC      ,Rx_ESC_ESC_2         :   		boolean;
	signal	Rx_ESC_EOP      ,Rx_ESC_EOP_2         :   		boolean;
	signal	Rx_ESC_EEP      ,Rx_ESC_EEP_2         :   		boolean;
	signal	Rx_Parity_error ,Rx_Parity_error_2    :   		boolean;
	signal	Rx_bits         ,Rx_bits_2            :   		integer range 0 to 2;
	signal	Rx_rate         ,Rx_rate_2            :   		std_logic_vector(15 downto 0) := (others => '0');
	
	signal	Rx_Time         ,Rx_Time_2            :  		octet;
	signal	Rx_Time_OR      ,Rx_Time_OR_2         :  		boolean;
	signal	Rx_Time_IR      ,Rx_Time_IR_2         :  		boolean;

	signal	Tx_Time         ,Tx_Time_2            :  		octet;
	signal	Tx_Time_OR      ,Tx_Time_OR_2         :  		boolean;
	signal	Tx_Time_IR      ,Tx_Time_IR_2         :  		boolean;

	-- Control		             
	signal	Disable         ,Disable_2            :  		boolean;
	signal	Connected       ,Connected_2          :  		boolean;
	signal	Error_select    ,Error_select_2       :  		std_logic_vector(3 downto 0) := (others => '0');
	signal	Error_inject    ,Error_inject_2       :  		boolean;
	
	-- SpW Ports, Init low. 
	signal	Din_p               :  		std_logic	:= '0';
	signal	Din_n               :  		std_logic	:= '0';
	signal	Sin_p               :  		std_logic	:= '0';
	signal	Sin_n               :  		std_logic	:= '0';
	signal	Dout_p              :  		std_logic	:= '0';
	signal	Dout_n              :  		std_logic	:= '0';
	signal	Sout_p              :  		std_logic	:= '0';
	signal	Sout_n              :  		std_logic	:= '0';
	
	signal 	spw_debug_tx		: 		std_logic_vector(8 downto 0)	:= (others => '0');
	signal 	spw_debug_raw		: 		std_logic_vector(13 downto 0)	:= (others => '0');
	signal 	spw_debug_parity	: 		std_logic;
	signal 	spw_debug_cmd		: 		string(1 to 3);
	signal 	spw_debug_time		: 		std_logic_vector(7 downto 0) 	:= (others => '0');
	
	signal 	rx_data_buf			: 		nonet_mem(0 to 7) := (others => (others => '0'));	-- rx data buffer
	
	signal 	ip_connected			: 		std_logic;
--  signal 	spw_debug_cmd_flip	: 		std_logic_vector(0 to 3);
	signal 	Tx_Rec_Clock			: 		std_logic 	:= '0';
	signal 	Rx_Rec_Clock			: 		std_logic 	:= '0';
--	signal 	rx_mem_debug         :       mem_type;
	
	-- Alias Declerations --
	
	alias TxD					 		is << signal SpW_ip_tb.SpW_DUT_tx.dout : std_logic >>;		-- spacewire DUT TxD signal
	alias TxS					 		is << signal SpW_ip_tb.SpW_DUT_tx.sout : std_logic >>;		-- spacewire DUT TxS signal 
	alias RxD							is << signal SpW_ip_tb.SpW_DUT_rx.dout : std_logic >>;		-- spacewire DUT RxD signal
	alias RxS							is << signal SpW_ip_tb.SpW_DUT_rx.sout : std_logic >>;		-- spacewire DUT RxS signal
--  alias rx_2c_memory					is << variable SpW_ip_tb.SpW_DUT_rx.u_spw.u_spw_fifo_2c.sv_mem : mem_prot_t>>;	-- not supported in xilinx

begin
	
--	rx_mem_debug <= << variable SpW_ip_tb.SpW_DUT_rx.u_spw.u_spw_fifo_2c.sv_mem : mem_prot_t>>.debug_mem; -- not supported in Xilinx
	
	-- copy into design entity architecture -- 
	spw_DUT_tx: entity spw_wrap_top_level(rtl) 
	generic map(
		g_clock_frequency   =>	c_clock_frequency,  
		g_rx_fifo_size      =>  c_rx_fifo_size,      
		g_tx_fifo_size      =>  c_tx_fifo_size,      
		g_mode				=>  c_mode				
	)
	port map( 
		-- clock & reset signals
		clock               =>	clock,					           
		clock_b             =>  clock_b,        
		reset               =>  reset, 
		
		-- Data Channels          
		Tx_data             =>  Tx_data,         
		Tx_OR               =>  Tx_OR,           
		Tx_IR               =>  Tx_IR,           
      
		Rx_data             =>  Rx_data,         
		Rx_OR               =>  Rx_OR,           
		Rx_IR               =>  Rx_IR,           
		
		-- Error Channels 
		Rx_ESC_ESC          =>  Rx_ESC_ESC,      
		Rx_ESC_EOP          =>  Rx_ESC_EOP,      
		Rx_ESC_EEP          =>  Rx_ESC_EEP,      
		Rx_Parity_error     =>  Rx_Parity_error, 
		Rx_bits             =>  Rx_bits,         
		Rx_rate             =>  Rx_rate,         
   
		-- Time Code Channels
		Rx_Time             =>  Rx_Time,         
		Rx_Time_OR          =>  Rx_Time_OR,      
		Rx_Time_IR          =>  Rx_Time_IR,      
 
		Tx_Time             =>  Tx_Time,         
		Tx_Time_OR          =>  Tx_Time_OR,      
		Tx_Time_IR          =>  Tx_Time_IR,      
    
		-- Control Channels           	
		Disable             =>  Disable,         
		Connected           =>  Connected,       
		Error_select        =>  Error_select,    
		Error_inject        =>  Error_inject,    
		

		-- SpW IO Ports, not used when "custom" mode.  	                
		Din_p               =>  Din_p,  	-- Used when Diff & Single     
		Din_n               =>  Din_n,      -- Used when Diff only
		Sin_p               =>  Sin_p,  	-- Used when Diff & Single       
		Sin_n               =>  Sin_n,      -- Used when Diff only
		Dout_p              =>  Dout_p,		-- Used when Diff & Single      
		Dout_n              =>  Dout_n,     -- Used when Diff only
		Sout_p              =>  Sout_p,  	-- Used when Diff & Single      
		Sout_n              =>  Sout_n     	-- Used when Diff only
	);
	
	SpW_DUT_rx: entity spw_wrap_top_level(rtl) 
	generic map(
		g_clock_frequency   =>	c_clock_frequency,  
		g_rx_fifo_size      =>  c_rx_fifo_size,      
		g_tx_fifo_size      =>  c_tx_fifo_size,      
		g_mode				=>  c_mode				
	)
	port map( 
		-- clock & reset signals
		clock               =>	clock,					           
		clock_b             =>  clock_b,        
		reset               =>  reset, 
		
		-- Data Channels          
		Tx_data             =>  Tx_data_2,         
		Tx_OR               =>  Tx_OR_2,           
		Tx_IR               =>  Tx_IR_2,           
      
		Rx_data             =>  Rx_data_2,         
		Rx_OR               =>  Rx_OR_2,           
		Rx_IR               =>  Rx_IR_2,           
		
		-- Error Channels 
		Rx_ESC_ESC          =>  Rx_ESC_ESC_2,      
		Rx_ESC_EOP          =>  Rx_ESC_EOP_2,      
		Rx_ESC_EEP          =>  Rx_ESC_EEP_2,      
		Rx_Parity_error     =>  Rx_Parity_error_2, 
		Rx_bits             =>  Rx_bits_2,         
		Rx_rate             =>  Rx_rate_2,         
   
		-- Time Code Channels
		Rx_Time             =>  Rx_Time_2,         
		Rx_Time_OR          =>  Rx_Time_OR_2,      
		Rx_Time_IR          =>  Rx_Time_IR_2,      
 
		Tx_Time             =>  Tx_Time_2,         
		Tx_Time_OR          =>  Tx_Time_OR_2,      
		Tx_Time_IR          =>  Tx_Time_IR_2,      
    
		-- Control Channels           	
		Disable             =>  Disable_2,         
		Connected           =>  Connected_2,       
		Error_select        =>  Error_select_2,    
		Error_inject        =>  Error_inject_2,    
		

		-- SpW IO Ports, not used when "custom" mode.  	                
		Din_p               =>  Dout_p,  	-- Used when Diff & Single     
		Din_n               =>  Dout_n,      -- Used when Diff only
		Sin_p               =>  Sout_p,  	-- Used when Diff & Single       
		Sin_n               =>  Sout_n,      -- Used when Diff only
		Dout_p              =>  Din_p,		-- Used when Diff & Single      
		Dout_n              =>  Din_n,     -- Used when Diff only
		Sout_p              =>  Sin_p,  	-- Used when Diff & Single      
		Sout_n              =>  Sin_n     	-- Used when Diff only
	);
	
--	Tx_Rec_Clock <= TxD xor TxS;	-- recover TX clock from D/S (sanity check)
	Tx_Rec_Clock <= Dout_p xor Sout_p;		-- recover Tx Data Clock for DUT
	Rx_Rec_Clock <= Din_p xor Sin_p;		-- recover Rx Data Clock for DUT
	
	-- generate pos system clock
	clockp_gen: process
	begin
		clock_gen(clock, clk_num, clk_period);	-- see sim lib
	end process;
	
	-- generate neg system clock
	clockn_gen: process
	begin
		clock_gen(clock_b, clk_num, clk_period);	-- see sim lib
	end process;
	
	debug_data: process
	begin
		wait until reset = '0';	-- wait until reset is de-asserted. 
		tx_debug_loop:loop	
			spw_get_poll(spw_debug_raw, spw_debug_tx, spw_debug_time, spw_debug_cmd, spw_debug_parity, Dout_p, Sout_p, 1);	-- see sim lib
		end loop tx_debug_loop; 
	end process;
	
	tx_cmd_check:process
		variable wait_periods : natural := 4;
	begin
		wait until reset = '0';
		tx_cmd_loop: loop
			case spw_debug_cmd is
				when c_SpW_Sim_EOP =>
					report "EOP at time: " & to_string(now) severity note;
				when C_SpW_Sim_EEP =>
					report "EEP at time: " & to_string(now) severity warning;
				when others =>
					null;
			end case;
			wait_clocks(clk_period, wait_periods);	-- see sim lib
		end loop tx_cmd_loop;
	end process;
	
	-- generate stimulus, replaced with user stimulus as desired !
	stim_gen: process
		variable 	stim_time	: 	time 		:= 1 us;
		variable 	v_tx_data 	: 	unsigned(8 downto 0) := (others => '0');
		variable 	rx_buf_addr	: 	integer range 0 to rx_data_buf'length := 0;
		variable 	v_rx_data		: std_logic_vector(8 downto 0) := (others => '0');
	begin
		reset <= '1';									-- on start up, keep reset asserted
		
		wait for 16.456 us;								-- wait for > 500us before de-asserting reset
		
		report "de-asserting RESET" severity note;
		reset <= '0';									-- de-assert reset
		report "waiting for SpW Uplink to Connect" severity note;
		
		wait until (Connected and Connected_2) = true;	-- wait for SpW instances to establish connection
		report "SpW Uplink Connected !" severity note;

		wait for 3.532 us;
		
		-- load Tx data to send --
		if(Tx_IR = false) then
			wait until Tx_IR = true;
		end if;
		wait for clk_period;
		Tx_Data  <= "001010110";						-- Load TX SpW Data port 
		Tx_OR <= true;									-- set Tx Data OR port
		wait for clk_period;							-- wait for data to be clocked in
		report "SpW Data Loaded : " & to_string(Tx_data) severity note;
		Tx_OR <= false;									-- de-assert TxOR
		
		-- wait for valid data to appear on SpW Rx output
		wait until Rx_OR_2 = true;
		wait for clk_period/2;							-- wait one clock cycle 
		Rx_IR_2 <= true;								-- assert IR true to read (one clock cycle)
		wait for clk_period;							
		Rx_IR_2 <= false;								-- de-assert IR
		
		-- send time code --
		if(Tx_Time_IR = false) then
			wait until Tx_Time_IR = true;
		end if;
		Tx_Time <= "10111100";							-- load timecode to send
		Tx_Time_OR <= true;								-- assert time code  OR
		report "sending time code : " & to_string(Tx_Time) severity note;
		wait for clk_period;
		Tx_Time_OR <= false;
		
		-- check for received time code
		report "waitng for Rx Timecode" severity note;
		wait until Rx_Time_OR_2 = true;
		report "got Rx Timecode" severity note;
		wait for clk_period/2;
		Rx_Time_IR_2 <= true;
		wait for clk_period;
		Rx_Time_IR_2 <= false;
		
		wait for 4.465 us;								-- wait for some time....
		
		-- Test Sending EOP  --
		report "sending EOP" severity note;
		if(Tx_IR = false) then
			wait until Tx_IR = true;
		end if;
		Tx_Data(8) <= '1';								-- set control bit
		Tx_Data(7 downto 0) <= x"02";					-- send Tx Data to EOP 
		Tx_OR <= true;									-- assert Tx_OR True (only when TX_IR == true)
		wait for clk_period;							-- wait for input to be valid
		Tx_OR <= false;
		
		-- receve EOP
		report "receiving EOP" severity note;
		wait until Rx_OR_2 = true;
		wait for clk_period/2;
		Rx_IR_2 <= true;
		wait for clk_period;
		Rx_IR_2 <= false;
		
		-- load Tx data to send --
		if(Tx_IR = false) then
			wait until Tx_IR = true;
		end if;
		wait for clk_period;
		Tx_Data  <= "001011110";						-- Load TX SpW Data port 
		Tx_OR <= true;									-- set Tx Data OR port
		wait for clk_period;							-- wait for data to be clocked in
		report "SpW Data Loaded : " & to_string(Tx_data) severity note;
		Tx_OR <= false;									-- de-assert TxOR
		
		-- wait for valid data to appear on SpW Rx output
		wait until Rx_OR_2 = true;
		wait for clk_period/2;							-- wait one clock cycle 
		Rx_IR_2 <= true;								-- assert IR true to read (one clock cycle)
		wait for clk_period;							
		Rx_IR_2 <= false;								-- de-assert IR
		
		-- Test Sending EEP  --
		report "sending EEP" severity note;
		if(Tx_IR = false) then
			wait until Tx_IR = true;
		end if;
		Tx_Data(8) <= '1';									-- set control bit
		Tx_Data(7 downto 0) <= x"01";						-- send Tx Data to EEP 
		Tx_OR <= true;										-- assert Tx_OR True (only when TX_IR == true)
		wait for clk_period;								-- wait for input to be valid
		Tx_OR <= false;										-- de-assert Tx OR
		
		-- receve EEP
		report "receiving EEP" severity note;
		wait until Rx_OR_2 = true;
		wait for clk_period/2;
		Rx_IR_2 <= true;
		wait for clk_period;
		Rx_IR_2 <= false;

	
		wait for 3.82 us;
		-- send 8 bytes of Tx Data
		v_tx_data := (others => '0');
		report "sending 8 bytes of data" severity note;
		for i in 0 to rx_data_buf'length-1 loop
			if(Tx_IR = false) then
				wait until Tx_IR = true;
			end if;
			wait until falling_edge(clock);
			Tx_data <= std_logic_vector(v_tx_data);
			v_tx_data(8) := '0';
			v_tx_data(7 downto 0) := v_tx_data(7 downto 0) + 1;
			Tx_OR 	<= true;
			wait until falling_edge(clock);
			Tx_OR 	<= false;
			
		end loop;
		
		wait for 3.43 us;	-- wait for data to be received in buffer on Rx side....
		
		report "getting Rx Data" severity note;
		
		rx_debug_loop: loop
			if(Rx_OR_2 = false) then										-- wait for new data	
				wait until Rx_OR_2 = true;	
			end if;	
			wait for clk_period/2;											-- wait for falling edge of clock
			Rx_IR_2 <= true;												-- assert IR
			
			wait until Rx_IR_2 and Rx_OR_2 = true;							-- wait for rising_edge where (Rx_OR_2 and Rx_IR_2) = true
			v_rx_data := Rx_data_2;											-- load in data
			wait for clk_period;											-- wait for clk_period. 
			Rx_IR_2 <= false;						
			
			rx_data_buf(rx_buf_addr) <= v_rx_data;							-- pass data to buffer
			
			
			if((v_rx_data(1 downto 0) & v_rx_data(8)) = c_SpW_EEP) then		-- was EOP or EEP ?
				rx_buf_addr := 0;											-- set buffer address to 0 for overwrite
				report "EEP detected" severity warning;	
			elsif((v_rx_data(1 downto 0) & v_rx_data(8)) = c_SpW_EOP) then	
				rx_buf_addr := 0;											-- set buffer address to 0 for overwrite
				report "EOP detected" severity warning;	
			else															-- was valid data ?
				exit rx_debug_loop when rx_buf_addr = (rx_data_buf'length-1);	-- exit loop once data has been loaded
				rx_buf_addr := (rx_buf_addr + 1) mod (rx_data_buf'length);	-- increment buffer address (with rollover)
			end if;
			
		end loop rx_debug_loop;
		
		wait for 1.46 us;													-- wait for signal assignment to be valid (simulation specific)
		
		v_tx_data := (others => '0');										-- reset comparator buffer
		report "8 bytes sent, checking data..." severity note;				-- send report...
		for i in 0 to rx_data_buf'length -1 loop							-- init comparator loop
			if(unsigned(rx_data_buf(i)) /= v_tx_data) then					-- check data buffer matches comparator value
				report "bit mismatch @ : " & to_string(v_tx_data) severity failure;	-- report any data mismatches
			end if;
			v_tx_data := v_tx_data + 1;										-- increment comparator value
		end loop;
		
		report "bits received OKAY" severity note;							-- notify if bits received okay
		
		wait for 1.54 us;
		
		Disable_2 <= true;
		wait for 1.245 us;
		Disable_2 <= false;
		
		wait until (Connected and Connected_2) = true;
		
		wait for 4.45 us;													-- wait for some time before calling finish

		
		report "stim finished OK @ time: " & to_string(now) severity failure; 		--  report sim finsihed and stop simulation
		wait;
	end process;
	

end bench;

