----------------------------------------------------------------------------------------------------------------------------------
-- File Description  --
----------------------------------------------------------------------------------------------------------------------------------
-- @ File Name				:	rmap_command_controller_parallel_interface.vhd
-- @ Engineer				:	James E Logan
-- @ Role					:	FPGA Engineer
-- @ Company				:	4Links ltd
-- @ Date					: 	26/06/2023

-- @ VHDL Version			:   2008
-- @ Supported Toolchain	:	Xilinx Vivado IDE
-- @ Target Device			: 	Xilinx US+ Family

-- @ Revision #				:	2

-- File Description         : 	4Links RMAP initiator IP Top-Level File 

-- Document Number			: 	xxx-xxxx-xxx
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
use work.all;
context work.rmap_context;
----------------------------------------------------------------------------------------------------------------------------------
-- Entity Declarations --
----------------------------------------------------------------------------------------------------------------------------------
entity rmap_command_controller_parallel_interface is
	port( 
		-- standard register control signals --
		clock					: in 	std_logic := '0';		-- clk logic_input, rising edge trigger
		rst_in					: in 	std_logic := '0';		-- reset logic_input, active high
		enable  				: in 	std_logic := '0';		-- enable logic_input, asserted high. 
		
		tx_logical_address		: in 	t_byte := (others => '0');
		tx_protocol_id			: in 	t_byte := (others => '0');
		tx_instruction			: in 	t_byte := (others => '0');
		tx_Key	    			: in 	t_byte := (others => '0');
		tx_reply_addresses		: in 	t_byte_array(0 to 11) := (others => (others => '0'));
		tx_init_log_addr	    : in 	t_byte := (others => '0');
		tx_Tranaction_ID		: in 	std_logic_vector(15 downto 0) := (others => '0');
		tx_Address   			: in 	std_logic_vector(39 downto 0) := (others => '0');
		tx_Data_Length     		: in 	std_logic_vector(23 downto 0) := (others => '0');
		
		tx_header_ready			: out	std_logic := '0';
		tx_header_valid 		: in 	std_logic := '0';
		
		tx_data					: in  	t_byte := (others => '0');
		tx_data_valid			: in  	std_logic := '0';
		tx_data_ready			: out 	std_logic := '0';
		
		tx_error				: out 	t_byte := (others => '0');
		tx_error_valid			: out 	std_logic := '0';
		tx_error_ready			: in 	std_logic := '0';
		
		spw_in					: in 	r_cmd_controller_spw_in;
		spw_out					: out 	r_cmd_controller_spw_out
	
    );
end rmap_command_controller_parallel_interface;


---------------------------------------------------------------------------------------------------------------------------------
-- Code Description & Developer Notes --
---------------------------------------------------------------------------------------------------------------------------------


architecture rtl of rmap_command_controller_parallel_interface is

	----------------------------------------------------------------------------------------------------------------------------
	-- Constant Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	constant c_num_paths_max			: integer 	:= 16;
	
	constant c_header_bytes_max			: positive 	:= 17;	-- number of header byte elements (path address count as +1)
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Type Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	/*type tx_initiator is( 	
		init, 
		ready, 
		get_header_byte, 
		check_header_byte,
		send_header_byte,
		abort_frame,
		send_header_crc,
		add_eop, 
		get_data, 
		send_data,
		send_data_crc,
		error_handle
	); */
	
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
	
	signal tx_state 			: 		tx_initiator 			:= init; -- state machine for Tx-Side logic 
	
	-- bytes & byte arrays --
	
	signal tx_header_crc		: 		t_nonet := (others => '0');
	signal tx_data_crc			: 		t_nonet := (others => '0');
	signal tx_data_buf			: 		t_nonet := (others => '0');

	signal tx_reply_mem			: 		t_nonet_array(0 to 11);
	--signal tx_frame_memory		:		t_nonet_array(0 to 16);
	
	signal	tx_logical_address_reg		: t_byte := (others => '0');
	signal	tx_protocol_id_reg			: t_byte := (others => '0');
	signal	tx_instruction_reg			: t_byte := (others => '0');
	signal	tx_Key_reg	    			: t_byte := (others => '0');
	signal	tx_reply_addresses_reg		: t_byte_array(0 to 11) := (others => (others => '0'));
	signal	tx_init_log_addr_reg	    : t_byte := (others => '0');
	signal	tx_Tranaction_ID_reg		: std_logic_vector(15 downto 0) := (others => '0');
	signal	tx_Address_reg   			: std_logic_vector(39 downto 0) := (others => '0');
	signal	tx_Data_Length_reg     		: std_logic_vector(23 downto 0) := (others => '0');
	
	-- How data is sent from "tx_frame_memory" 
	/*
	tx_frame_memory(0) 		=>  logical address
	tx_frame_memory(1) 		=>	protocol identifier (not used)
	tx_frame_memory(2)		=>  instruction 
	tx_frame_memory(3)      =>	Key
	tx_frame_memory(4)   	=>	reply address(s), sent using this buffer. 
	tx_frame_memory(5)      =>  initiator logical address
	tx_frame_memory(6)      =>	Transaction Identifier (MSByte)
	tx_frame_memory(7)      =>	Transaction Identifier (LSByte)
	tx_frame_memory(8)      =>	Extended Address Field
	tx_frame_memory(9)      =>  Address(31 downto 24)
	tx_frame_memory(10)     =>  Address(23 downto 16)
	tx_frame_memory(11)     =>  Address(15 downto 8)
	tx_frame_memory(12)     =>	Address(7 downto 0)
	tx_frame_memory(13)     =>	Data_Length(24 downto 16)
	tx_frame_memory(14)     =>	Data_Length(15 downto 8)
	tx_frame_memory(15)     =>	Data-lenfth(7 downto 0)
	tx_frame_memory(16)		=>  Frame Header CRC 
	*/
	
	-- integers & naturals --
	signal tx_num_replies		: 		integer range 0 to 11 := 0;
	signal tx_num_replies_max	: 		integer range 0 to 12 := 0;
	signal tx_byte_counter		: 		integer range 0 to c_header_bytes_max := 0;
	signal tx_data_len			: 		integer range 0 to 2**24 - 1 := 0;
	signal tx_data_counter		: 		integer range 0 to 2**24 - 1 := 0;
--	signal tx_frame_counter		: 		integer range 0 to 16 := 0;
	
	-- std_logics --
	signal assert_path_addr 	: 	 	std_logic := '0';
	signal has_path_addr		: 		std_logic := '0';
	signal has_payload			: 		std_logic := '0';
	signal tx_header_crc_read	: 		std_logic := '0';
	signal tx_data_crc_read		: 		std_logic := '0';
	signal increment_addr		: 		std_logic := '0'; --when asserted, header address will increment 
	
	--------------------------------------------------------------------------
	-- Tx CRC Signals --------------------------------------------------------
	--------------------------------------------------------------------------
	signal crc_tx_data				: t_nonet 	:= (others => '0');			--
	signal crc_tx_valid			    : std_logic := '0';						--
	signal crc_tx_ready			    : std_logic := '0';                     --
	--------------------------------------------------------------------------
	signal crc_ignore              : std_logic := '0';
	signal crc_clear               : std_logic := '0';
	signal crc_out                 : t_nonet   := (others => '0');
	signal crc_out_valid           : std_logic := '0';
	signal crc_reg                 : t_nonet := (others => '0');
	signal tx_link_active   :	std_logic   := '0';
	signal spw_tx_data      :	t_nonet		:= (others => '0');	
	signal spw_tx_ready     :	std_logic   := '0';
	signal spw_tx_valid     :	std_logic   := '0';
	signal spw_Connected    :   std_logic	:= '0';
	signal spw_Connected_old    :   std_logic	:= '0';
	
	---------------------------------------------------------------------------------------------------------------------------
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
	
	-- RMAP calculator for Tx Logic
	u_tx_crc_calc: entity rmap_crc_calculator
	port map(
		clk_in				=> clock,			
	    rst_in				=> rst_in,		
	    enable  			=> enable,	
	    
	    -- data logic_input
	    spw_data			=>	crc_tx_data(8 downto 0)		,
	    spw_data_valid		=>	crc_tx_valid				,
	    spw_data_ready		=>	crc_tx_ready				,
	
	    -- CRC bypass logic_input				
	    crc_ignore			=>	crc_ignore					,
	
	    -- crc byte out 
	    crc_clear           =>  crc_clear                   ,  				
	    crc_data 			=>	crc_out						,
	    crc_data_valid		=>	crc_out_valid				,
		
		-- data logic_output (to SpW IP)
	    output_con			=>	spw_tx_data(8)				,	-- 9th but of SpW Tx_Data used for control characters
	    output_data			=>	spw_tx_data(7 downto 0)		,	-- lower byte of SpW Tx_data logic_input, used for data 
	    output_valid		=>	spw_tx_valid					,	-- SpW IP Handshake logic_output Ready
	    output_ready		=>	spw_tx_ready						-- SpW IP Handshake logic_input Ready 
	
	);
	----------------------------------------------------------------------------------------------------------------------------
	-- Component Instantiations --
	----------------------------------------------------------------------------------------------------------------------------
	
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Asynchronous Signal Assignments --
	----------------------------------------------------------------------------------------------------------------------------
	-- logic_input_assignements (
	
	-- might want to register tx_data_len for some synthesizers ??
--	tx_data_len <= to_integer(unsigned(tx_frame_memory(13)) 
--	               & unsigned(tx_frame_memory(14)) 
--	               & unsigned(tx_frame_memory(15)));						-- get data length of data / data+mask payload. 
	-- Map record IO to Signal Declarations.... 			   
	
	
	spw_out.spw_tx.wdata  	<= spw_tx_data;
	spw_out.spw_tx.wvalid 	<= spw_tx_valid;
	spw_tx_ready 			<= spw_in.spw_tx.wready;
	spw_Connected           <= spw_in.link_connected;
--	assert_target_addr      <= logic_in.assert_target;
	----------------------------------------------------------------------------------------------------------------------------
	-- Synchronous Processes --
	----------------------------------------------------------------------------------------------------------------------------
	-- fsm process to handle sending RMAP commands 
	tx_fsm: process(clock)	-- handles sending RMAP frames & data 
	begin
		if(rising_edge(clock)) then
			if(rst_in = '1') then
				tx_state <= init;
				spw_Connected_old 	<= '0';
				tx_header_ready 	<= '0';
				tx_data_ready 		<= '0';
				tx_link_active		<= '0';

			else
				case tx_state is 
				
					when init =>
						crc_clear 		<= '1';
						if(enable = '1' and spw_Connected = '1') then	-- is enabled and SpW IP is connected ?
							tx_state <= ready;
							crc_clear 		<= '0';
						end if;
					
					when ready =>
					--	crc_clear 		<= '1';
						crc_ignore		<= '0';
						has_path_addr 	<= '0';
						tx_byte_counter	<= 0;
						tx_data_counter <= 0;
						tx_link_active  <= '0';						-- de-assert link active when in ready state 
						tx_state 		<= get_header_byte;
					--------------------------------------------------------------------------------------------	
					when get_header_byte =>		-- get frame info from ready/valid handshake
					
						tx_logical_address_reg	<= tx_logical_address;	
						tx_protocol_id_reg		<= tx_protocol_id;				
						tx_instruction_reg		<= tx_instruction;		
						tx_Key_reg	    		<= tx_Key;	    		
						tx_reply_addresses_reg	<= tx_reply_addresses;	
						tx_init_log_addr_reg	<= tx_init_log_addr;
						tx_Tranaction_ID_reg	<= tx_Tranaction_ID;
						tx_Address_reg   		<= tx_Address;   		
						tx_Data_Length_reg     	<= tx_Data_Length;    	
						
						tx_header_ready 		<= '1';
						if(tx_header_valid = '1' and tx_header_ready = '1') then
							tx_link_active 	    <= '1';								-- will assert link valid on first byte read 
							tx_header_ready 	<= '0';
							tx_state <= check_header_byte;
						end if;
					--------------------------------------------------------------------------------------------
					when check_header_byte	=> 
						increment_addr  <= '1';
						crc_ignore <= '0';
						case tx_byte_counter is 										-- buffer pointer is ?
							
							when 0 => 													-- get path/logical address
							
								crc_tx_data 		<= '0'& tx_logical_address_reg;
								if(tx_logical_address_reg(7 downto 5) = "000" or assert_path_addr = '1') then			-- is path address ?
									crc_ignore 		<= '1';								-- set CRC logic to ignore 
									has_path_addr	<= '1';								-- assert has path address for this frame
									increment_addr  <= '0';
								end if;
								
								if(has_path_addr = '1' and tx_logical_address_reg(7 downto 0) /= x"FE") then	-- has path address, not logical address yet ?
									increment_addr  <= '0';
									crc_ignore 		<= '1';
								end if;
								
								tx_state <= send_header_byte;	
								
							when 1 =>													-- insert protocol indentifier for RMAP
							
								crc_tx_data <= '0'& tx_protocol_id_reg;
								tx_state <= send_header_byte;	
							
							when 2 =>													-- get instruction data 
								
								crc_tx_data <= '0'& tx_instruction_reg;
								if(tx_instruction_reg(7 downto 6) = "01") then			-- if valid command ?
									case tx_instruction_reg(5 downto 2) is 
										when "0010" | "0011"  =>						-- is read instruction ?
											has_payload <= '0';
										when "1000" | "1001" | "1010" | "1011" |
											 "1100" | "1101" | "1110" | "1111" 	=> 		-- is write instrution ?
											has_payload <= '1';
										when "0111" =>									-- is read modify-write instruction ?
											has_payload <= '1';
											
										when others =>									-- is invalid instruciton ?
										
									end case;
									
									case tx_instruction_reg(1 downto 0) is				-- set number of replies (0, 4, 8, 12 bytes)
										when "00" =>
											tx_num_replies_max <= 0;
										when "01" =>
											tx_num_replies_max <= 4;	
										when "10" =>
											tx_num_replies_max <= 8;
										when "11" =>
											tx_num_replies_max <= 12;
										when others =>
											tx_num_replies_max <= 0;					-- default to 0 replies. 
										
									end case;
								else													-- if invalid command data 
									tx_state <= abort_frame;							-- abort frame...add to error handler later. 
				
								end if;
								
							
								tx_state <= send_header_byte;	
							
							when 3 =>			-- get key data 
								
								crc_tx_data  <= '0'& tx_Key_reg;
								if(tx_num_replies_max = 0 /*or has_path_addr = '0'*/) then				-- no reply address or using logical addressing 
									tx_byte_counter <= tx_byte_counter + 1;
								end if;
								tx_state 		<= send_header_byte;
								
							when 4 =>			-- get reply addresses (up to 12 bytes) in buffer
								
								crc_tx_data <=  '0'& tx_reply_addresses_reg(tx_num_replies);
								tx_num_replies <= tx_num_replies + 1;
								increment_addr  <= '0';
								if(tx_num_replies = tx_num_replies_max - 1) then
									tx_num_replies 	<= 0;
									increment_addr  <= '1';
								end if;
								tx_state 		<= send_header_byte;
							
							when 5 =>					-- get rest of frame, see comments in constants section for data byte order
								crc_tx_data 	<= '0'& tx_init_log_addr_reg;
								tx_state 		<= send_header_byte;
							when 6 =>
								crc_tx_data 	<= '0'& tx_Tranaction_ID_reg(15 downto 8);
								tx_state 		<= send_header_byte;
							
							when 7 =>
								crc_tx_data 	<= '0'& tx_Tranaction_ID_reg(7 downto 0);
								tx_state 		<= send_header_byte;
								
							when 8 =>
								crc_tx_data 	<= '0'& tx_Address_reg(39 downto 32);
								tx_state 		<= send_header_byte;

							when 9 =>
								crc_tx_data 	<= '0'& tx_Address_reg(31 downto 24);
								tx_state 		<= send_header_byte;
							
							when 10 =>
								crc_tx_data 	<= '0'& tx_Address_reg(23 downto 16);
								tx_state 		<= send_header_byte;
							
							when 11 =>
								crc_tx_data 	<= '0'& tx_Address_reg(15 downto 8);
								tx_state 		<= send_header_byte;
							
							when 12 =>
								crc_tx_data 	<= '0'& tx_Address_reg(7 downto 0);
								tx_state 		<= send_header_byte;
							
							when 13 =>
								crc_tx_data 	<= '0'& tx_Data_Length_reg(23 downto 16);
								tx_state 		<= send_header_byte;
							
							when 14 =>
								crc_tx_data 	<= '0'& tx_Data_Length_reg(15 downto 8);
								tx_state 		<= send_header_byte;
							
							when 15 =>
								crc_tx_data 	<= '0'& tx_Data_Length_reg(7 downto 0);
								tx_state 		<= send_header_byte;
							
							when others =>						-- invalid value ?
							
								tx_byte_counter <= 0;			-- abort current frame 
						
						end case;
						
						-- catches early EEP/EOP in data stream 
				--		if((tx_frame_memory(tx_byte_counter) = c_spw_EEP) or (tx_frame_memory(tx_byte_counter) = c_spw_EOP)) then
				--			tx_state <= abort_frame;
				--		end if;
					
					---------------------------------------------------------------------------------------------
					when send_header_byte =>												-- used to stream spacewire data 
					
						crc_tx_valid 	<= '1';
						
						if(crc_tx_valid = '1' and crc_tx_ready = '1') then
							crc_tx_valid <= '0';
							
							if(increment_addr = '1') then
							    tx_byte_counter <= (tx_byte_counter + 1) mod c_header_bytes_max;
							end if;
							
							if(increment_addr = '0' and tx_byte_counter = 0) then	-- was a path address ?
								tx_state <= get_header_byte;
							end if;
							
							if(tx_byte_counter = 15) then	-- last header  byte sent ?
								tx_state <= get_header_crc;	-- get CRC 
							else							-- still header bytes remaining ?			
								tx_state <= check_header_byte;	-- get header bytes...
							end if;
						end if;
					
					when abort_frame =>	-- abort frame here...
					
						tx_error 	<= c_early_eop_eep;
						crc_tx_valid <= '1';
						
						if(crc_tx_valid = '1' and crc_tx_ready = '1') then
							crc_tx_valid <= '0';
							tx_error_valid 	<= '1';
							tx_state <= error_handle;								-- aborts the current frame with idle 
						end if;

					
					when get_header_crc =>
					
							-- wait until a valid CRC to read...
							if(crc_out_valid = '1') then	-- valid CRC to read ?
								crc_reg <= crc_out;	-- store CRC data
								crc_tx_data		<= crc_out;
								tx_state 		<= send_header_crc; 				-- logic_output CRC data 
							end if;
						
					when send_header_crc =>
				
						crc_tx_data 	<= crc_reg;
						crc_tx_valid 	<= '1';

						if(crc_tx_ready = '1' and crc_tx_valid = '1') then			-- crc handshake valid ?
							crc_tx_valid <= '0';
							if(has_payload = '1') then								-- command had data payload ?
								crc_ignore <= '0';									-- de-assert crc ignore
								tx_state <= get_data;								-- go to get_data.	
							else													-- no data payload in command ?
								tx_state <= add_eop;								-- go to add EOP
							end if;
						end if;
					
					when add_eop =>										-- send EOP, returns interface to ready state
						
						crc_ignore		<= '1';
						crc_tx_data		<= c_spw_EOP;			-- EOP is b"1_0000_0010"
						crc_tx_valid	<= '1';

						if(crc_tx_ready = '1' and crc_tx_valid = '1') then
							crc_tx_valid <= '0';
							crc_tx_data		<= (others => '0');
							tx_state 	<= ready;		--complete, go back to ready state 
						end if;
					
					when get_data =>				-- get data on data interface
					
						crc_ignore	 	<= '0';
						crc_tx_data		<= '0'& tx_data;
						tx_data_ready 	<= '1';
						
						if(tx_data_ready = '1' and tx_data_valid = '1') then
							tx_data_ready	<= '0';
							tx_state <= send_data;
							tx_data_counter <= tx_data_counter + 1;
						end if;
						

					when send_data =>				-- send data to spacewire IP (through CRC calculator)
						
						crc_tx_valid <= '1';
						
						if(crc_tx_valid = '1' and crc_tx_ready = '1') then
							crc_tx_valid <= '0';
							if(tx_data_counter = to_integer(unsigned(tx_Data_Length_reg))) then
								tx_state <= send_data_crc;
							else
								tx_state <= get_data;
							end if;
						end if;

					
					when send_data_crc =>				-- send pre-calculated data CRC
						
						crc_tx_valid 	<= '1';
						crc_tx_data 	<= crc_out;
						
						
						if(crc_tx_ready = '1' and crc_tx_valid = '1') then			-- crc handshake valid ?
							crc_tx_valid <= '0';
							tx_state <= add_eop;							-- go to add EOP
						end if;
						
					when error_handle =>	-- error handle for tx, do no exit until error is acknowledged
					
						tx_error_valid <= '1';
						if(tx_error_ready = '1' and tx_error_valid = '1') then
							tx_error_valid <= '0';
							tx_state <= ready;
						end if;
					
					when others =>		-- leave commented for debug to make sure all states are covered. 
						tx_state <= init;
				
				end case;
			end if;
			
			spw_Connected_old <= spw_Connected;
			if(spw_Connected_old = '1' and spw_Connected = '0') then
				tx_error <= x"FF";
				tx_state <= error_handle;
			end if;
			
		end if;
	end process;
	


end rtl;