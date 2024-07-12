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
context work.rmap_context;

----------------------------------------------------------------------------------------------------------------------------------
-- Entity Declarations --
----------------------------------------------------------------------------------------------------------------------------------
entity rmap_initiator_tb is

end rmap_initiator_tb;


---------------------------------------------------------------------------------------------------------------------------------
-- Code Description & Developer Notes --
---------------------------------------------------------------------------------------------------------------------------------


architecture bench of rmap_initiator_tb is

	----------------------------------------------------------------------------------------------------------------------------
	-- Constant Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	constant c_clock_frequency 	: 		real      	:=  100_000_000.0;	-- clock frequency (in Hz)
	constant c_rx_fifo_size    	: 		integer   	:=  32;				-- number of SpW packets in RX fifo
	constant c_tx_fifo_size    	: 		integer   	:=  32;				-- number of SpW packets in TX fifo
	constant c_mode				: 		string 		:= "single";
	
--	constant c_mem_width		: 		natural := 8;
--	constant c_mem_addr_width	: 		natural := 12;
	
	constant clk_period			: 		time        := (1_000_000_000.0 / c_clock_frequency) * 1 ns;	-- clock period (ns)
	constant clk_num			: 		natural 	:= 1_000_000_000;								-- number of clock transitions, ignored...
	----------------------------------------------------------------------------------------------------------------------------
	-- Type Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Function Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Entity Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Component Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Signal Declarations --
	----------------------------------------------------------------------------------------------------------------------------

	signal	clock              		:   std_logic := '0';
	signal	clock_b			   		:  	std_logic := '1';
	signal	async_reset        		:   std_logic := '0';
	signal	reset              		:   std_logic := '0';
	
	signal	Rx_Time            		:  	t_byte := (others => '0');
	signal	Rx_Time_OR         		:  	std_logic := '0';
	signal	Rx_Time_IR         		:   std_logic := '0';
	
	signal	Tx_Time            		:   t_byte := (others => '0');
	signal	Tx_Time_OR         		:   std_logic := '0';
	signal	Tx_Time_IR         		:  	std_logic := '0';
	
	signal  tx_assert_char			:   std_logic := '0';
	signal	tx_header				: 	std_logic_vector(7 downto 0) := (others => '0');
	signal	tx_header_valid			: 	std_logic := '0';
	signal	tx_header_ready			: 	std_logic := '0';
	signal	tx_data					: 	std_logic_vector(7 downto 0) := (others => '0');
	signal	tx_data_valid			: 	std_logic := '0';
	signal	tx_data_ready			: 	std_logic := '0';
	
	signal  rx_assert_char			: 	std_logic := '0';
	signal	rx_header				: 	std_logic_vector(7 downto 0) := (others => '0');
	signal	rx_header_valid			: 	std_logic := '0';
	signal	rx_header_ready 		: 	std_logic := '0';
	
	signal	rx_data					: 	std_logic_vector(7 downto 0) := (others => '0');
	signal	rx_data_valid			: 	std_logic := '0';
	signal	rx_data_ready 			: 	std_logic := '0';
	
	signal	tx_error				:  	std_logic_vector(7 downto 0) := (others => '0');
	signal	tx_error_valid			:  	std_logic := '0';
	signal	tx_error_ready			: 	std_logic := '0';
	
	signal	rx_error				:  	std_logic_vector(7 downto 0) := (others => '0');
	signal	rx_error_valid			:  	std_logic := '0';
	signal	rx_error_ready			: 	std_logic := '0';
	
	signal	init_Rx_ESC_ESC      	:  	std_logic := '0';                                   
	signal	init_Rx_ESC_EOP      	:  	std_logic := '0';                                   
	signal	init_Rx_ESC_EEP      	:  	std_logic := '0';                                   
	signal	init_Rx_Parity_error 	:  	std_logic := '0';                                   
	signal	init_Rx_bits         	:   std_logic_vector(1 downto 0) := (others => '0');	
	signal	init_Rx_rate         	:  	std_logic_vector(15 downto 0) := (others => '0');     
	signal	init_Disable     		: 	std_logic := '0';                                   
	signal	init_Connected       	:   std_logic := '0';                                   
	signal	init_Error_select    	: 	std_logic_vector(3 downto 0) := (others => '0');    
	signal	init_Error_inject    	: 	std_logic := '0';                                   
	
	
	signal	Rx_ESC_ESC         	:  std_logic := '0';
	signal	Rx_ESC_EOP         	:  std_logic := '0';
	signal	Rx_ESC_EEP         	:  std_logic := '0';
	signal	Rx_Parity_error    	:  std_logic := '0';
	signal	Rx_bits            	:  	std_logic_vector(1 downto 0) := (others => '0');
	signal	Rx_rate            	:  	std_logic_vector(15 downto 0);
	
	-- Control		
	signal	Disable            	:   std_logic := '0';
	signal	Connected          	:  	std_logic := '0';
	signal	Error_select       	:   std_logic_vector(3 downto 0);
	signal	Error_inject       	:   std_logic := '0';
	
	-- DDR/SDR IO, only when "custom" mode is used
	-- when instantiating, if not used, you can ignore these ports. 
	signal	DDR_din_r			: 	std_logic := '0';
	signal	DDR_din_f           : 	std_logic := '0';
	signal	DDR_sin_r           : 	std_logic := '0';
	signal	DDR_sin_f           : 	std_logic := '0';
	signal	SDR_Dout			:  	std_logic := '0';
	signal	SDR_Sout			:  	std_logic := '0';
	
	-- SpW	
	signal	Din_p               :   std_logic := '0';
	signal	Din_n               :   std_logic := '0';
	signal	Sin_p               :   std_logic := '0';
	signal	Sin_n               :   std_logic := '0';
	signal	Dout_p              :  	std_logic := '0';
	signal	Dout_n              :  	std_logic := '0';
	signal	Sout_p              :  	std_logic := '0';
	signal	Sout_n              :  	std_logic := '0';
	
	-- Memory Interface
	signal	Address            	:  	std_logic_vector(39 downto 0)  := (others => '0');
	signal	Write              	:  	std_logic := '0';
	signal	Write_data         	:  	std_logic_vector( 7 downto 0)	 := (others => '0');
	signal	Bytes              	:  	std_logic_vector(23 downto 0)	 := (others => '0');
	signal	Read_data          	:  	std_logic_vector( 7 downto 0) := x"00";
	signal	Read_bytes         	:  	std_logic_vector(23 downto 0)	 := (others => '0');
	
	-- Bus handshake
	signal	RW_request         	:  	std_logic := '0';
	signal	RW_acknowledge     	:  	std_logic := '0';

	-- Control/Status 
	signal	Echo_required      	:   std_logic := '0';
	signal	Echo_port          	:   octet;
	
	signal	Logical_address    	:  	std_logic_vector(7 downto 0)	 := (others => '0');
	signal	Key                	:  	std_logic_vector(7 downto 0)	 := (others => '0');
	signal	Static_address     	:  	std_logic := '0';
	
	signal	Checksum_fail      	:  std_logic := '0';
	
	signal	Request            	:  	std_logic := '0';
	signal	Reject_target      	:  	std_logic := '0';
	signal	Reject_key         	:  	std_logic := '0';
	signal	Reject_request     	:  	std_logic := '0';
	signal	Accept_request     	:  	std_logic := '0';
	
	signal	Verify_overrun     	:   std_logic := '0';
	
	signal	OK                 	:   std_logic := '0';
	signal	Done               	:   std_logic := '0';
	
	signal tx_assert_path				: 	std_logic := '0';
	signal initiator_tx_time			: 	std_logic_vector(7 downto 0);
	signal initiator_tx_time_valid		: 	std_logic := '0';
	signal initiator_tx_time_ready		: 	std_logic := '0';
	
	signal initiator_rx_time			: 	std_logic_vector(7 downto 0);
	signal initiator_rx_time_valid		: 	std_logic := '0';
	signal initiator_rx_time_ready		: 	std_logic := '0';

	signal header_crc_mem 		: 	t_byte := (others => '0');
	signal data_crc_mem			: 	t_byte := (others => '0');

	constant tx_buf			: t_byte_array(0 to 4095) := gen_data(4096);	-- data_gen fills bytes with values 0x00 -> 0xFF 
	signal reply_buf 		: t_byte_array(0 to 4095);
	signal data_size		: natural;
	
	signal spw_init_link	: 	r_spw_debug_signals;	-- spacewire debug signals for Initiator output
	signal spw_target_link	: 	r_spw_debug_signals;	-- spacewire debug signals for Target output
	
	signal spw_init_clk		: std_logic := '0';
	signal spw_target_clk	: std_logic := '0';
	----------------------------------------------------------------------------------------------------------------------------
	-- Variable Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	shared variable v_rmap_frame						: 	t_rmap_frame;
--	shared variable rmap_frame							: 	t_rmap_command;
--	shared variable rmap_reply							:   t_rmap_reply_pattern;
	
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Alias Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	-- rename signals for ease of use 
--	alias cmd_tx_header 		: t_nonet		is cmd_channel_in.tx_frame.rdata;
--	alias cmd_tx_header_valid	: std_logic		is cmd_channel_in.tx_frame.rvalid;
--	alias cmd_tx_header_ready	: std_logic 	is cmd_channel_out.tx_frame.rready;
--	
--	alias cmd_tx_data 			: t_nonet 		is cmd_channel_in.tx_data.rdata;
--	alias cmd_tx_valid			: std_logic 	is cmd_channel_in.tx_data.rvalid;
--	alias cmd_tx_ready			: std_logic 	is cmd_channel_out.tx_data.rready;
--	
--	alias reply_rx_header		: t_nonet		is reply_channel_out.rx_header.rdata;
--	alias reply_rx_header_valid	: std_logic 	is reply_channel_out.rx_header.rvalid;
--	alias reply_rx_header_ready : std_logic		is reply_channel_in.rx_header.rready;
--	
--	alias reply_rx_data  		: t_nonet 		is reply_channel_out.rx_data.rdata;
--	alias reply_rx_valid 		: std_logic 	is reply_channel_out.rx_data.rvalid;
--	alias reply_rx_ready 		: std_logic 	is reply_channel_in.rx_data.rready;
	
	
/*	-- internal signal breakout --
	alias cmd_crc_reg 	is  << signal rmap_initiator_tb.u_initiator_inst.u_rmap_tx_controller.crc_out : t_nonet >>;			-- live value of Tx CRC calculation 	
	alias reply_crc_reg is  << signal rmap_initiator_tb.u_initiator_inst.u_rmap_rx_controller.crc_out : t_nonet >>;			-- live value of Rx CRC check 
--	alias a_spw_connected is  << signal rmap_initiator_tb.u_initiator_inst.spw_inst.Connected  : boolean >>;	-- asserted when spacewire connected 
	alias a_tx_cmd_FSM	is  << signal rmap_initiator_tb.u_initiator_inst.u_rmap_tx_controller.tx_state  : tx_initiator >>;		-- breakout Tx Controller FSM
	alias a_rx_reply_FSM  is 	<< signal rmap_initiator_tb.u_initiator_inst.u_rmap_rx_controller.rx_state  : rx_initiator >>;		-- breakout Rx Controller FSM 
	*/
	
	alias a_target_mem is << signal rmap_initiator_tb.target_mem_inst.s_ram : t_byte_array(0 to 4095)>>;
	----------------------------------------------------------------------------------------------------------------------------
	-- Attribute Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
begin
	

	----------------------------------------------------------------------------------------------------------------------------
	-- Asynchronous Signal Assignments --
	----------------------------------------------------------------------------------------------------------------------------
	Accept_request <= '1';
	RW_acknowledge <= '1';
	spw_init_clk <= Dout_p xor Sout_p;
	spw_target_clk <= Din_p xor Sin_p;
	----------------------------------------------------------------------------------------------------------------------------
	-- Synchronous Processes --
	----------------------------------------------------------------------------------------------------------------------------

	-- generate stimulus 
	stim_gen: process
		variable target_mem_debug : t_byte_array(0 to 4095) := (others =>(others => '0'));
	begin
	-- initialize Tx and Rx Header/Data interface signals 
		reset <= '1';
	--	rx_header_ready <= '1';
		report "stimulus starting @ time " & to_string(now) severity note;
		wait for 1.567 us;
		reset <= '0';
		wait for clk_period;
		report "reset de-asserted, waiting for SPW Uplink";
		wait for 25 us;					-- wait 50 us to establish spacewire uplink. 
		if(Connected = '1') then	-- Was SpW Connection Established ?
			report "SpW Connection Okay" severity note;
		else							-- SpW Connection Uplink Failed ? 
			report "SpW Connection failed" severity failure;
		end if;
		rx_header_ready <= '1';
		report "sending Command with Test Pattern 1" severity note;
		
		v_rmap_frame.has_path_addr(false);                               	-- are path bytes to be used ?
		v_rmap_frame.set_logical_addr(254);                             	-- set logical address (254 is path bytes used)
		v_rmap_frame.set_pid(1);                                       	 	-- set Protocol ID
		v_rmap_frame.set_instruction("write", false, false, true, "00"); 	-- set Instruction Byte (RD/WR, Verify ?, Reply Required ? Increment Address ? Reply Address Field length ?
		v_rmap_frame.set_key(1);                                        	-- set Key 
		v_rmap_frame.set_init_address(67);                               	-- set Initiator Address
		v_rmap_frame.set_trans_id(98);                                 		-- set Transaction ID
		v_rmap_frame.set_mem_address(0);                             		-- set Memory Address (32-bit)
		v_rmap_frame.set_data_length(16);                                	-- set length of Data field (if required)
		v_rmap_frame.set_data_bytes(c_data_test_pattern_1);                 -- set data bytes (if required)
		
		send_rmap_frame(
			tx_header(7 downto 0),
			tx_header_valid,
			tx_header_ready,
			tx_data(7 downto 0),
			tx_data_valid,
			tx_data_ready,
			v_rmap_frame
		);
		
		
		
		
	/*	
		
		-- set header and data to RMAP test pattern 1
		rmap_frame.set_header_bytes(c_header_test_pattern_1);	-- load header test pattern 1
		rmap_frame.set_data_bytes(c_data_test_pattern_1);		-- load data test pattern 1 
		rmap_frame.set_path_bytes(c_path_addr_1);				-- load path address pattern 1
		rmap_frame.set_paths(false);							-- set use path address 
		-- load header and data CRCs for verifcation 
		header_crc_mem  <=  rmap_frame.get_header_crc;
		data_crc_mem	<=  rmap_frame.get_data_crc;
		
	--	wait for 1.34 us;
		wait for 10.2 ns;
		wait until falling_edge(clock);
		rx_header_ready <= '1';
		rx_data_ready <= '1';
		-- send test pattern 1 (write 16 bytes of data to target)
		send_header_bytes(		-- find this procedure in SpaceWire_Sim_lib
			tx_assert_path,
			tx_header(7 downto 0),
			tx_header_valid,
			tx_header_ready,
			rmap_frame
		);
		
		send_data_bytes(	-- data bytes to write  -- find this procedure in SpaceWire_Sim_lib
			tx_data(7 downto 0),
			tx_data_valid,
			tx_data_ready,
			rmap_frame
		);
		*/
		-- check target received bytes OKAY -- 
		report "data bytes finished" severity note;
		report "checking target memory contents" severity note;
		wait for 5 us;
		target_mem_debug := a_target_mem;
	--	wait for 5 us;
		for i in 0 to (c_data_test_pattern_1'length)-1 loop
			if(target_mem_debug(i) /= c_data_test_pattern_1(i)) then
				report "data mismatch in target memory @: " & to_string(i) severity failure;
			end if;
		end loop;
		
		report "TARGET MEM OKAY" severity note;
		
		
		wait for 2.5 us;
		
		report "sending BIG test pattern" severity note;
		
		v_rmap_frame.has_path_addr(false);                               	-- are path bytes to be used ?
		v_rmap_frame.set_logical_addr(254);                             	-- set logical address (254 is path bytes used)
		v_rmap_frame.set_pid(1);                                       	 	-- set Protocol ID
		v_rmap_frame.set_instruction("write", false, false, true, "00"); 	-- set Instruction Byte (RD/WR, Verify ?, Reply Required ? Increment Address ? Reply Address Field length ?
		v_rmap_frame.set_key(1);                                        	-- set Key 
		v_rmap_frame.set_init_address(67);                               	-- set Initiator Address
		v_rmap_frame.set_trans_id(98);                                 		-- set Transaction ID
		v_rmap_frame.set_mem_address(0);                             		-- set Memory Address (32-bit)
		v_rmap_frame.set_data_length(4096);                        			-- set length of Data field (if required)
		v_rmap_frame.set_data_bytes(tx_buf);                			 	-- set data bytes (if required)
		
		send_rmap_frame(
			tx_header(7 downto 0),
			tx_header_valid,
			tx_header_ready,
			tx_data(7 downto 0),
			tx_data_valid,
			tx_data_ready,
			v_rmap_frame
		);
		
		wait for 5.0 us;
		
		report "reading BIG test pattern" severity note;
		
		
		v_rmap_frame.has_path_addr(false);                               	-- are path bytes to be used ?
		v_rmap_frame.set_logical_addr(254);                             	-- set logical address (254 is path bytes used)
		v_rmap_frame.set_pid(1);                                       	 	-- set Protocol ID
		v_rmap_frame.set_instruction("read", false, true, true, "00"); 	-- set Instruction Byte (RD/WR, Verify ?, Reply Required ? Increment Address ? Reply Address Field length ?
		v_rmap_frame.set_key(1);                                        	-- set Key 
		v_rmap_frame.set_init_address(67);                               	-- set Initiator Address
		v_rmap_frame.set_trans_id(98);                                 		-- set Transaction ID
		v_rmap_frame.set_mem_address(0);                             		-- set Memory Address (32-bit)
		v_rmap_frame.set_data_length(4096);                        -- set length of Data field (if required)
		v_rmap_frame.set_data_bytes(tx_buf);                			 	-- set data bytes (if required)
		
		send_rmap_frame(
			tx_header(7 downto 0),
			tx_header_valid,
			tx_header_ready,
			tx_data(7 downto 0),
			tx_data_valid,
			tx_data_ready,
			v_rmap_frame
		);
		
		report "sent read command" severity note;
		
		
		-- for Reply data for 4096 bytes 
		for i in 0 to 4095 loop
			if(rx_data_valid = '0') then
				wait until rx_data_valid = '1';
			end if;
			rx_data_ready <= '1';
			reply_buf(i) <= rx_data(7 downto 0);
			wait for clk_period;
			rx_data_ready <= '0';
			wait for clk_period;
		end loop;
		
		for i in 0 to reply_buf'length-1 loop
			if(tx_buf(i) /= reply_buf(i)) then
				report "failure in reply buffer : " & to_string(i) severity failure;
			end if;
		end loop;
		
		wait for 10 us;
		
		report "Stim Finished: OKAY @ time: " & to_string(now) severity warning;
		finish;
		wait;
	end process;
	
	-- timeout process to stop sim with failure. 
	timeout_proc: process
	begin
		wait for 2500 us;
		report "Sim time-out" severity failure;
		wait;
	end process;
	
	
	-- generate positive system clock
	clock_p_gen: process
	begin
        clock_gen(clock, clk_period); 
	end process;
	
	--generate negative system clock
	clock_n_gen: process
	begin
	   clock_gen(clock_b, clk_period); 
	end process;
	
	-- debug spacewire output from RMAP initiator 
	spw_initiator_debug: process
	begin
	--	wait until Connected = true;
		wait until reset = '0';
		debug_loop: loop	
			spw_get_poll(		-- debug procedure in SpaceWire_Sim_lib
				spw_init_link,	-- variable of protected type containing SpaceWire data buffers
				Dout_p,			-- Data Signal to Debug
				Sout_p,			-- Strobe Signal to Debug
				1				-- Polling timestep (ns)
			);
		end loop debug_loop;
		wait;
	end process;
	
	-- debug spacewire output from RMAP target 
	spw_target_debug: process
	begin
	--	wait until Connected = true;
		wait until reset = '0';
		debug_loop: loop		
			spw_get_poll(			-- debug procedure in SpaceWire_Sim_lib
				spw_target_link,	-- variable of protected type containing SpaceWire data buffers
				Din_p,
				Sin_p,
				1
			);
		end loop debug_loop;
		wait;
	end process;

	
	----------------------------------------------------------------------------------------------------------------------------
	-- Entity Instantiations --
	----------------------------------------------------------------------------------------------------------------------------
	u_target_inst : entity rmap_target_full(rtl)
	generic map(
		g_freq 				=> 	c_clock_frequency,
		g_fifo_depth 		=>  c_rx_fifo_size,
		g_mode				=>  c_mode
	)
	port map( 
		
		clock              => clock          ,  	
		clock_b			   => clock_b		 ,
		async_reset        => async_reset    ,
		reset              => reset          ,

		Rx_Time            => Rx_Time        ,
		Rx_Time_OR         => Rx_Time_OR     ,
		Rx_Time_IR         => Rx_Time_IR     ,

		Tx_Time            => Tx_Time        ,
		Tx_Time_OR         => Tx_Time_OR     ,
		Tx_Time_IR         => Tx_Time_IR     ,

		Rx_ESC_ESC         => Rx_ESC_ESC     ,
		Rx_ESC_EOP         => Rx_ESC_EOP     ,
		Rx_ESC_EEP         => Rx_ESC_EEP     ,
		Rx_Parity_error    => Rx_Parity_error,
		Rx_bits            => Rx_bits        ,
		Rx_rate            => Rx_rate        ,

		-- Control	                         
		Disable            => Disable        ,
		Connected          => Connected      ,
		Error_select       => Error_select   ,
		Error_inject       => Error_inject   ,
		
		-- DDR/SDR IO, only when "custom" mode is used
		-- when instantiating, if not used, you can ignore these ports. 
	--	DDR_din_r			: in 	std_logic := '0';
	--	DDR_din_f           : in 	std_logic := '0';
	--	DDR_sin_r           : in 	std_logic := '0';
	--	DDR_sin_f           : in 	std_logic := '0';
	--	SDR_Dout			: out 	std_logic := '0';
	--	SDR_Sout			: out 	std_logic := '0'; 
	
		-- SpW	
		Din_p               =>	Dout_p		,
		Din_n               =>  Dout_n      ,
		Sin_p               =>	Sout_p      ,
		Sin_n               =>	Sout_n      ,
		Dout_p              =>	Din_p       ,
		Dout_n              =>  Din_n       ,
		Sout_p              =>  Sin_p       ,
		Sout_n              =>  Sin_n       ,

		-- Memory Interface
		Address     		=> Address   	,       
		wr_en               => Write        ,
		Write_data          => Write_data   ,
		Bytes               => Read_bytes   ,
		Read_data           => Read_data    ,
		Read_bytes          => Read_bytes   ,

		-- Bus handshake
		RW_request         => RW_request ,   
		RW_acknowledge     => RW_acknowledge,

		-- Control/Status 
		Echo_required      => Echo_required,
		Echo_port          => Echo_port,    

		Logical_address    => Logical_address ,
		Key                => Key ,            
		Static_address     => Static_address  ,

		Checksum_fail      => Checksum_fail,
		
		Request    			=> Request ,               
		Reject_target   	=> Reject_target , 
		Reject_key      	=> Reject_key ,    
		Reject_request  	=> Reject_request ,
		Accept_request 		=> Accept_request ,    

		Verify_overrun    => Verify_overrun,

		OK                 => OK,
		Done               => Done
		
    );
	
	u_init_inst: entity work.rmap_initiator_top_level(rtl)
	generic map(
		g_clock_freq		=>	c_clock_frequency,
		g_tx_fifo_size		=>	c_tx_fifo_size,
		g_rx_fifo_size		=>	c_rx_fifo_size,
		g_tx_fifo_interface	=> 	true,
		g_rx_fifo_interface	=> 	true,
		g_mode			 	=>	c_mode
	
	)
	port map( 
		-- Standard Register Channels --
		clock				=> 	clock,
		clock_b				=> 	clock_b,
		rst_in				=> 	reset,
		enable  			=> 	'1',
		----------------------------------------------------------------------------------
		-- Time Code Channels --
		tx_time				=>	initiator_tx_time,			
		tx_time_valid		=>	initiator_tx_time_valid,	
		tx_time_ready		=>	initiator_tx_time_ready,	
	
		rx_time				=>	initiator_rx_time,			
		rx_time_valid		=>	initiator_rx_time_valid,	
		rx_time_ready		=>	initiator_rx_time_ready,	
		----------------------------------------------------------------------------------
		-- Tx Command Channels --
		tx_assert_char		=>  tx_assert_char,
		tx_assert_path		=> 	tx_assert_path,
		tx_header			=>	tx_header,			
		tx_header_valid		=>  tx_header_valid,		
		tx_header_ready		=>  tx_header_ready,		

		tx_data				=>  tx_data,			
		tx_data_valid		=>  tx_data_valid,		
		tx_data_ready		=>  tx_data_ready,		
		----------------------------------------------------------------------------------
		-- Rx Reply Channels --
		rx_assert_char		=> 	rx_assert_char,
		rx_header			=>	rx_header,			
		rx_header_valid		=>  rx_header_valid,		
		rx_header_ready 	=>  rx_header_ready, 	
      
		rx_data				=>  rx_data,				
		rx_data_valid		=>  rx_data_valid,		
		rx_data_ready 		=>  rx_data_ready, 		
		----------------------------------------------------------------------------------
		tx_error			=>	tx_error,		
		tx_error_valid		=>  tx_error_valid,	
		tx_error_ready		=>  tx_error_ready,	

		rx_error			=>  rx_error,		
		rx_error_valid		=>  rx_error_valid,	
		rx_error_ready		=>  rx_error_ready,	
		
		
		spw_Rx_ESC_ESC      => init_Rx_ESC_ESC,     
		spw_Rx_ESC_EOP      => init_Rx_ESC_EOP,     
		spw_Rx_ESC_EEP      => init_Rx_ESC_EEP,     
		spw_Rx_Parity_error => init_Rx_Parity_error,
		spw_Rx_bits         => init_Rx_bits,        
		spw_Rx_rate         => init_Rx_rate,        
		spw_Disable     	=> init_Disable,     	
		spw_Connected       => init_Connected,      
		spw_Error_select    => init_Error_select,   
		spw_Error_inject    => init_Error_inject,   
		
	--	DDR_din_r			: in 	std_logic := '0';
	--	DDR_din_f           : in	std_logic := '0';
	--	DDR_sin_r           : in	std_logic := '0';
	--	DDR_sin_f           : in	std_logic := '0';
	--	SDR_Dout			: out	std_logic := '0';
	--	SDR_Sout			: out	std_logic := '0';
	
		-- SpW IO (diff & single)
		Din_p				=> Din_p,	
		Din_n               => Din_n,  
		Sin_p               => Sin_p,   
		Sin_n               => Sin_n,   
		Dout_p              => Dout_p,  
		Dout_n              => Dout_n, 
		Sout_p              => Sout_p,  
		Sout_n              => Sout_n  
		
    );

	target_mem_inst: entity xilinx_single_port_single_clock_ram(rtl)
	generic map(
		ram_type	=>  "auto",			-- ram type to infer (auto, distributed, block, register, ultra)
		data_width	=> 	8,	-- bit-width of ram element
		addr_width	=>  12,				-- address width of RAM
		ram_str		=> "HELLO_WORLD"		
	)
	port map(
		-- standard register control signals --
		clk_in 		=> clock,												-- clock in (rising_edge)
		enable_in 	=> '1',													-- enable input (active high)
		
		wr_en		=> Write,										-- write enable (asserted high)
		addr		=> Address(11 downto 0),
		wr_data     => Write_data,
		rd_data		=> Read_data
		
	);

end bench;