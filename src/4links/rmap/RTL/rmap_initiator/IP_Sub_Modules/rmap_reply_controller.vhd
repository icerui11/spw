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
entity rmap_reply_controller is
	port( 
		-- standard register control signals --
		clk_in				: in 	std_logic := '0';				-- clk input, rising edge trigger
		rst_in				: in 	std_logic := '0';				-- reset input, active high
		
		rx_enable  			: in 	std_logic := '0';				-- enable input, asserted high. 
		
		logic_in			: in 	r_reply_controller_logic_in := c_reply_logic_in_init;
		logic_out			: out 	r_reply_controller_logic_out := c_reply_logic_out_init;
		
		spw_in				: in 	r_reply_controller_spw_in := c_reply_spw_in_init;
		spw_out				: out 	r_reply_controller_spw_out := c_reply_spw_out_init
	
    );
end rmap_reply_controller;


---------------------------------------------------------------------------------------------------------------------------------
-- Code Description & Developer Notes --
---------------------------------------------------------------------------------------------------------------------------------


architecture rtl of rmap_reply_controller is

	----------------------------------------------------------------------------------------------------------------------------
	-- Constant Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	-- reply controller error codes --
	constant c_rx_early_EOP 		: t_byte := x"01";
	constant c_rx_data_error 		: t_byte := x"02";
	constant c_rx_status_error		: t_byte := x"03";
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Type Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	/*type rx_initiator is (
		idle, 				-- default state, returns to on reset asserted  
		read_byte,			-- read valid byte from SpW IP
		get_header,			-- get header infor for the SpW Reply
		post_header,		-- post header to controller interface
		rx_abort, 			-- EEP detected ? Discard received data in frame
		status_error,
		get_data,			-- get reply data (if any)
		post_data,			-- post rx data to IP interface 
		data_crc,
		get_EOP				-- receive EOP, check for correct termination
	); */
	
	type header_mem is array (natural range <>) of t_nonet;
	
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
	
	signal rx_state : rx_initiator := idle;	-- rx reply initiator state machine
	
	signal header_buf : header_mem(0 to 12) := (others => (others => '0'));	-- frame header buffer 
	
	signal header_count		: integer range 0 to 12 := 0;
	signal path_addr_count	: integer range 0 to 11 := 0;			-- counts reply path addresses received in reply header 
	signal reply_count		: integer range 0 to 15 := 0;			-- counts bytes received in reply header
	signal data_count		: integer range 0 to (2**24)-1 := 0;
--	signal data_len			: integer range 0 to (2**24)-1 := 0;
	signal data_len 		: unsigned(23 downto 0) := (others => '0');
	
	signal crc_data_valid	: std_logic := '0';
	signal crc_data_ready	: std_logic := '0';
	signal crc_OKAY			: std_logic := '0';
	signal crc_OKAY_buf			: std_logic := '0';
	signal crc_valid		: std_logic := '0';
	signal increment_header	: std_logic := '0';
	signal has_payload		: std_logic := '0';
	signal crc_good			: std_logic := '0';
	
	signal data_buf			: t_nonet := (others => '0');
	signal crc_buf			: t_nonet := (others => '0');
	signal crc_data_out		: t_nonet := (others => '0');
	signal crc_out			: t_nonet := (others => '0');
	-- IO Port Map Signals --
	signal rx_header		: t_nonet	:= (others => '0');
	signal rx_header_valid  : std_logic := '0';
	signal rx_header_ready  : std_logic := '0';
	signal rx_data          : t_nonet	:= (others => '0');
	signal rx_data_valid    : std_logic	:= '0';
	signal rx_data_ready    : std_logic	:= '0';
	signal rx_error         : t_byte	:= (others => '0');
	signal rx_error_valid   : std_logic := '0';
	signal rx_error_ready   : std_logic := '0';
	signal spw_rx_data		: t_nonet	:= (others => '0');
	signal spw_rx_valid		: std_logic := '0';
	signal spw_rx_ready		: std_logic := '0';
	signal spw_Connected    : std_logic := '0';
	signal spw_Connected_old    : std_logic := '0';
	signal rx_link_active   : std_logic := '0';
	
	signal has_paths 		: std_logic := '0';
	
	

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
	u_rx_crc_calc: entity rmap_crc_checker(rtl)	-- calculates CRC on-the-fly 
	port map(
		clk_in			=> clk_in,			
	    rst_in			=> rst_in,		
	    enable  		=> rx_enable,	
		
		-- Rx Data from 4Links IP Core
		spw_rx_data		=>	 spw_in.spw_rx.rdata,
		spw_rx_OR		=>	 spw_in.spw_rx.rvalid,
		spw_rx_IR		=>	 spw_out.spw_rx.rready ,
		
		-- Rx data (output) ports to RMAP reply controller logic
		rx_data			=>	crc_data_out,
		rx_valid	    =>	crc_data_valid,
		rx_ready	    =>	crc_data_ready,
		
		-- CRC output ports to RMAP reply controller logic --
		crc_OKAY		=>	crc_OKAY,
		crc_out		    =>	crc_out,
		crc_valid 	    =>	crc_valid
	);
	----------------------------------------------------------------------------------------------------------------------------
	-- Component Instantiations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Asynchronous Signal Assignments --
	----------------------------------------------------------------------------------------------------------------------------
	-- Map IO Records Onto Arch Signal List -- 
	logic_out.rx_header.rdata 	<= rx_header;	
	logic_out.rx_header.rvalid 	<= rx_header_valid;
	rx_header_ready 			<= logic_in.rx_header.rready;
	
	logic_out.rx_data.rdata 	<= rx_data;
	logic_out.rx_data.rvalid 	<= rx_data_valid;
	rx_data_ready 				<= logic_in.rx_data.rready;
	
	logic_out.rx_error.rdata	<= rx_error;
	logic_out.rx_error.rvalid 	<= rx_error_valid;
	rx_error_ready 				<= logic_in.rx_error.rready;
	
	logic_out.crc_error 		<= not crc_good;
	
	spw_Connected 				<= spw_in.link_connected;
	logic_out.rx_link_active 	<= rx_link_active;
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Synchronous Processes --
	----------------------------------------------------------------------------------------------------------------------------
	rx_fsm: process(clk_in)
	begin
		if(rising_edge(clk_in)) then 
			data_len(23 downto 16)  <= unsigned(header_buf(8)(7 downto 0)); 
			data_len(15 downto 8)   <= unsigned(header_buf(9)(7 downto 0));
			data_len(7 downto 0)	<= unsigned(header_buf(10)(7 downto 0));
			if(rst_in = '1') then
				rx_data_valid 		<= '0';
				crc_data_ready		<= '0';
				rx_error_valid 		<= '0';
				rx_header_valid 	<= '0';
				rx_error 			<= (others => '0');
			--	data_count			<= 0; 
				rx_state 			<= idle;
			else
				case rx_state is 
					when idle =>
						has_paths <= '0';
						crc_good <= '1';
						header_count <= 0;
						data_count	<= 0;
						increment_header <= '0';
						crc_data_ready <= '0';
						has_payload <= '0';
						if(rx_enable = '1') then
							rx_state <= read_byte;
						end if;
						
					when read_byte =>

						crc_data_ready <= '1';

						if(crc_data_ready = '1' and crc_data_valid = '1') then
							crc_data_ready <= '0';
							header_buf(header_count) <= crc_data_out;
							rx_state <= get_header;
							-- abort frame is eaely EOP/EEP detected, leave to error handler. 
							if(crc_data_out = c_spw_EOP or crc_data_out= c_spw_EEP) then
								rx_error <= c_early_eop_eep;
								rx_state <= status_error;
							end if;
							
						end if;
						
					when get_header =>
						
						rx_header_valid <= '1';
						increment_header <= '1';
						rx_header <= header_buf(header_count);
						
						case header_count is 
						
							when 0 =>		-- path addresses + logical address
								
								if(header_buf(0)(7 downto 5) = "000") then	-- is path address ?
									increment_header <= '0';
									has_paths <= '1';
								end if;
								
								if(has_paths = '1' and header_buf(0)(7 downto 0) /= x"FE") then
									increment_header <= '0';
								end if;
								
								rx_state <= post_header;
								
							when 1 =>		-- protocol identifier
							
								rx_state <= post_header;
								
							when 2 =>		-- instruction 
								
								case header_buf(header_count)(5 downto 2) is 
									when "0010" | "0011"  =>						-- is read instruction ?
										has_payload <= '1';
									when "1000" | "1001" | "1010" | "1011" |
										 "1100" | "1101" | "1110" | "1111" 	=> 		-- is write instrution ?
										
									when "0111" =>									-- is read modify-write instruction ?
										has_payload <= '1';
										
									when others =>									-- is invalid instruciton ?
										null;
								end case;
								
								rx_state <= post_header;
							
							when 3 =>		-- status
								
								rx_state <= post_header;	-- no errors ? post header...
								
								rx_error <= header_buf(3)(7 downto 0);
								if(header_buf(3)(7 downto 0) /= x"00") then	-- returns non zero ? status error
									rx_state <= discard;
									rx_header_valid <= '0';
								end if;

							when 4 to 6 =>		-- target Logical Address, Trans ID MSB and LSB.
								
								rx_state <= post_header;
								
							when 7 =>
								
								header_count <= header_count + 1;
								rx_state <= read_byte;					-- skip to data length bits
								rx_header_valid <= '0';								
								if(has_payload = '0') then					-- is write reply ?
									rx_header_valid <= '1';
									rx_state <= get_header_crc;
									rx_header_valid <= '0';
								end if; 
								
								
							when 8 to 9 => -- Data length (Read/Read_Mod_Write)
							
							
								rx_state <= post_header;	-- output data length bits
								
							when 10 =>
							
							
								rx_state <= post_header;	-- output data length bits
								
							when 11 =>		-- CRC on Read/Read_Mod_Write

						
								rx_state <= get_header_crc;		
								rx_header_valid <= '0';									
								
							when others =>
								rx_state <= idle;

						end case;
						
					
					when post_header =>	-- post header data to controller interface 
						
					--	rx_header <= header_buf(header_count);
					--	rx_header_valid <= '1';
						
						if(rx_header_valid = '1' and rx_header_ready = '1' ) then
							rx_header_valid <= '0';
							if(increment_header = '1') then
								header_count <= header_count + 1 mod 12;
							end if;
							rx_state <= read_byte;
						end if;
					
					when get_header_crc =>
					
						if(crc_OKAY = '1') then
							if(has_payload = '0') then
								rx_state <= get_EOP;
								crc_good <= '1';
							else
								rx_state <= get_data;
							end if;
						else
							rx_error <= c_reply_crc_error;
							rx_state <= discard;
							crc_good <= '0';
						end if;
					
					when discard => 
						crc_data_ready <= '1';		-- assert ready when valid is asserted 
						
						if(crc_data_ready = '1' and crc_data_valid = '1') then	-- data handshake accepted ?
							crc_data_ready <= '0';								-- de-assert data ready
							if(crc_data_out = c_spw_EOP or crc_data_out = c_spw_EEP) then	
								rx_state <= status_error;
							end if;
						end if;
	
					when status_error =>	-- output error code to interface. 
					-- error code should be loaded in previous state. 
					-- this state forces the user application to acknowledge the error
					-- befor continuing.... on acknowledge, state goes back to idle....
						rx_error_valid <= '1';
						if(rx_error_ready = '1' and  rx_error_valid = '1') then
							rx_error_valid	<= '0';
							rx_error 	<= (others => '0');
							rx_state <= idle;
						end if;
					
					
					when get_data =>					-- get data bytes from SpW (through CRC Checker)
					
						crc_data_ready <= '1';		-- assert ready when valid is asserted 
						
						if(crc_data_ready = '1' and crc_data_valid = '1') then	-- data handshake accepted ?
							crc_data_ready <= '0';					-- de-assert data ready
							data_count <= data_count + 1;			-- increment data counter 
							rx_data <= crc_data_out;				-- load data into data buffer
							rx_state <= post_data;					-- set RX state to post data 
							if(crc_data_out = c_spw_EOP or crc_data_out= c_spw_EEP) then
								rx_error <= c_early_eop_eep;
								rx_state <= discard;
							end if;
						end if;
						
						if(data_count = data_len) then			-- all data got from interface ?
							rx_data_valid   <= '0';
							rx_state 		<= data_crc;				-- perform data CRC validation 
						--	data_count 		<= 0;						-- reset data counter 
						end if;
							
					when post_data =>								-- post data bytes to interface 
					
						rx_data_valid	<= '1';						-- assert rx data is valid 
						
						if(rx_data_valid = '1' and rx_data_ready = '1') then	-- rx data handshake ?
							rx_data_valid 	<= '0';								-- de-assert data valid
							rx_state <= get_data;					-- go to get data state 
						end if;
						
					when data_crc =>	-- get data CRC status and output to interface 
						
		
						crc_data_ready <= '1';		-- assert ready when valid is asserted 

						if(crc_data_ready = '1' and crc_data_valid = '1') then	-- handshake to read CRC byte (we don't care about its value) 
							crc_data_ready <= '0';								-- de-assert data ready
							if(crc_OKAY = '1') then								-- did CRC reduce to 0 ?
								rx_state <= get_EOP;
								crc_good <= '1';
							else
								rx_state <= discard;
								rx_error <= c_reply_crc_error;
								crc_good <= '0';
							end if;
						end if;
						
					when get_EOP =>		-- receive EOP (after data or Header) at a valid point in frame...
					
						crc_data_ready <= '1';		-- assert ready when valid is asserted 
						
						if(crc_data_ready = '1' and crc_data_valid = '1') then	-- data handshake accepted ?
							crc_data_ready <= '0';					-- de-assert data ready
							if(crc_data_out /= c_spw_EOP) then		-- load status register, output error
								rx_state <= discard;
							else
								rx_state <= idle;					-- EOP is correct, go to idle start for next RX frame 
							end if;
						end if;
						
					when others =>
						rx_state <= idle;
					
				end case;
			
			end if;
			
			spw_Connected_old <= spw_Connected;
			if(spw_Connected_old = '1' and spw_Connected = '0') then
				rx_error <= x"FF";
				rx_state <= status_error;
			end if;
		end if;
		
	end process;


end rtl;