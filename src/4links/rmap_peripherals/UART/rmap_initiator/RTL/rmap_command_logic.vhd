----------------------------------------------------------------------------------------------------------------------------------
-- File Description  --
----------------------------------------------------------------------------------------------------------------------------------
-- @ File Name				:	rmap_command_logic
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
use work.all;
----------------------------------------------------------------------------------------------------------------------------------
-- Package Declarations --
----------------------------------------------------------------------------------------------------------------------------------
context work.rmap_context;

----------------------------------------------------------------------------------------------------------------------------------
-- Entity Declarations --
----------------------------------------------------------------------------------------------------------------------------------
entity rmap_command_logic is
	port( 
		
		-- standard register control signals --
		clk_in						: 	in 		std_logic 						:= '0';		-- clk input, rising edge trigger
		rst_in						: 	in 		std_logic 						:= '0';		-- reset input, active high
		
		-- UART Data & Control Ports --
		UART_in						: 	in 		t_byte 							:= (others => '0');
		UART_in_valid				:	in 		std_logic 						:= '0';
		UART_in_ready				:	out 	std_logic 						:= '0';
		
		
		-- Initiator TimeCode Ports -- 
		INIT_tx_time				: 	out 	t_byte 							:= (others => '0');	
		INIT_tx_time_valid	    	: 	out		std_logic 						:= '0';
		INIT_tx_time_ready	    	: 	in		std_logic 						:= '0';

		-- Initiator Tx Header Set-up Ports --
		INIT_tx_logical_address		: 	out 	t_byte 							:= (others => '0');
		INIT_tx_protocol_id		    : 	out 	t_byte 							:= (others => '0');
		INIT_tx_instruction		    : 	out 	t_byte 							:= (others => '0');
		INIT_tx_Key	    		    : 	out 	t_byte 							:= (others => '0');
		INIT_tx_reply_addresses	    : 	out 	t_byte_array(0 to 11) 			:= (others => (others => '0'));
		INIT_tx_init_log_addr	    : 	out 	t_byte							:= (others => '0');
		INIT_tx_Tranaction_ID	    : 	out 	std_logic_vector(15 downto 0) 	:= (others => '0');
		INIT_tx_Address   		    : 	out 	std_logic_vector(39 downto 0) 	:= (others => '0');
		INIT_tx_Data_Length         : 	out 	std_logic_vector(23 downto 0) 	:= (others => '0');

		INIT_tx_header_valid   		: 	out		std_logic 						:= '0';
		INIT_tx_header_ready		: 	in		std_logic 						:= '0';
		
		--Initiator Data Tx Ports --
		INIT_tx_data				: 	out		t_byte 							:= (others => '0');
		INIT_tx_data_valid	    	: 	out		std_logic 						:= '0';
		INIT_tx_data_ready	    	: 	in		std_logic 						:= '0'
		
		
    );
	
end rmap_command_logic;


---------------------------------------------------------------------------------------------------------------------------------
-- Code Description & Developer Notes --
---------------------------------------------------------------------------------------------------------------------------------


architecture rtl of rmap_command_logic is

	----------------------------------------------------------------------------------------------------------------------------
	-- Constant Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	constant c_protocol_id 			:   t_byte			 				:= x"01";
	constant c_instruction		    : 	t_byte 							:= b"0110_1000";
	constant c_Key	    		    : 	t_byte 							:= x"00";
	constant c_reply_addresses	    : 	t_byte_array(0 to 11) 			:= (others => (others => '0'));
	constant c_init_log_addr	    : 	t_byte							:= x"F3";
	constant c_Tranaction_ID	    : 	std_logic_vector(15 downto 0) 	:= x"0123";
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Type Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	type t_state is (
		idle				,
		get_addr_byte		,
		get_mem_addr_byte	,
		get_instruction		,
		get_payload_size	,
		set_rmap_header		,
		get_data_byte		,
		send_rmap_data	
	);
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Function Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Component Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Signal Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	signal state 			: t_state 			:= idle;
	signal tx_byte_reg 		: t_byte 			:= (others => '0');
	signal addr_set			: std_logic 		:= '0';
	
	signal log_addr_reg		: t_byte 						:= (others => '0');	-- logical address register 
	signal mem_addr_reg		: t_byte						:= (others => '0');	-- memory address byte 
	signal instruction_reg	: t_byte						:= (others => '0');	-- instruction register
	signal data_length_reg	: unsigned(7 downto 0) 			:= (others => '0');	-- data length register
	signal data_count_reg	: unsigned(7 downto 0) 			:= (others => '0');

	signal FIFO_rd_data		: t_byte 			:= (others => '0');
	signal FIFO_rd_valid	: std_logic 		:= '0';
    signal FIFO_rd_ready	: std_logic 		:= '0';
	signal FIFO_full 		: std_logic 		:= '0';
	signal FIFO_empty		: std_logic 		:= '0';
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Variable Declarations --
	----------------------------------------------------------------------------------------------------------------------------

	
	----------------------------------------------------------------------------------------------------------------------------
	-- Attribute Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
begin

	----------------------------------------------------------------------------------------------------------------------------
	-- Entity Instantiations --
	----------------------------------------------------------------------------------------------------------------------------
	cmd_fifo: entity dp_fifo_buffer(rtl)
	generic map(
		g_data_width	=> 	8,
		g_addr_width	=> 	10
	)
	port map( 
		
		-- standard register control signals --
		wr_clk_in		=>	clk_in			,		-- write clk input, rising edge trigger
		rd_clk_in		=>	clk_in			,		-- read clk input, rising edge trigger
		wr_rst_in		=>	rst_in			,		-- reset input, active high
		rd_rst_in		=>	rst_in			,		-- reset input, active high
		
		-- FiFO buffer Wr/Rd Interface --
		FIFO_wr_data	=>	UART_in			,			
		FIFO_wr_valid	=>	UART_in_valid   ,	
		FIFO_wr_ready	=>	UART_in_ready	,		-- only asserted when fifo is NOT full
		
		FIFO_rd_data	=>	FIFO_rd_data	,
		FIFO_rd_valid	=>	FIFO_rd_valid	,		-- only asserted when fifo is NOT empty
		FIFO_rd_ready	=>	FIFO_rd_ready	,

		full			=>	FIFO_full		, 		-- asserted when Fifo is Full (Write Clock Domain)
		empty			=>	FIFO_empty				-- asserted when Fifo is Empty (Read Clock Domain)
		
    );
	----------------------------------------------------------------------------------------------------------------------------
	-- Component Instantiations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Asynchronous Signal Assignments --
	----------------------------------------------------------------------------------------------------------------------------
	INIT_tx_protocol_id		<= c_protocol_id;
	INIT_tx_Key	    		<= c_Key;
	INIT_tx_reply_addresses	<= c_reply_addresses;
	INIT_tx_init_log_addr	<= c_init_log_addr;
	INIT_tx_Tranaction_ID	<= c_Tranaction_ID;
	

	----------------------------------------------------------------------------------------------------------------------------
	-- Synchronous Processes --
	----------------------------------------------------------------------------------------------------------------------------
	-- FSM for Tranmitting UART data across RMAP Initiator IP (Parallel Interface mode) 
	process(clk_in) 
	begin
		if(rising_edge(clk_in)) then
			if(rst_in = '1') then
				state <= idle;
			else
				case state is 
					when idle =>	-- default idle state when fifo is empty 
					
						data_length_reg <= (others => '0');
						data_count_reg <= (others => '0');
						if(FIFO_empty = '0') then
							state <= get_addr_byte;
						end if;
						
					when get_addr_byte =>		-- get first byte of command (address byte)
					
						FIFO_rd_ready <= '1';
						log_addr_reg <= FIFO_rd_data;
						
						if(FIFO_rd_valid and FIFO_rd_ready) then
							FIFO_rd_ready <= '0';
							state <= get_mem_addr_byte;
						end if;
					
					when get_mem_addr_byte =>
					
						FIFO_rd_ready <= '1';
						mem_addr_reg <= FIFO_rd_data;
						
						if(FIFO_rd_valid and FIFO_rd_ready) then
							FIFO_rd_ready <= '0';
							state <= get_instruction;
						end if;
					
					when get_instruction =>
					
						FIFO_rd_ready <= '1';
						instruction_reg <= FIFO_rd_data;
						
						if(FIFO_rd_valid and FIFO_rd_ready) then
							FIFO_rd_ready <= '0';
							state <= get_payload_size;
						end if;
						
					when get_payload_size =>	-- 
						
						FIFO_rd_ready <= '1';
						data_length_reg <= unsigned(FIFO_rd_data);
						
						if(FIFO_rd_valid and FIFO_rd_ready) then
							FIFO_rd_ready <= '0';
							state <= set_rmap_header;
						end if;
					
					when set_rmap_header => 
					
						INIT_tx_logical_address <= log_addr_reg;							-- set address field bits
						INIT_tx_Data_Length(7 downto 0) <= std_logic_vector(data_length_reg);	-- set data payload length
						INIT_tx_instruction <= b"01" & instruction_reg(0) & b"0_1" & instruction_reg(1) & b"00";
						INIT_tx_header_valid <= '1';
						INIT_tx_Address(7 downto 0) <= mem_addr_reg;
						
						if(INIT_tx_header_valid and INIT_tx_header_ready) then
							INIT_tx_header_valid <= '0';
							state <= get_data_byte;
							if(instruction_reg(0) = '0') then
								state <= idle;
							end if;
						end if;
					
					when get_data_byte =>	-- retreive data from fifo
					
						FIFO_rd_ready <= '1';
						INIT_tx_data <= FIFO_rd_data;
						
						if(FIFO_rd_valid and FIFO_rd_ready) then
							FIFO_rd_ready <= '0';
							data_count_reg <= data_count_reg + 1;
							state <= send_rmap_data;
						end if;
					
					when send_rmap_data =>	-- send data from fifo to the Initiator IP data interface
					
						INIT_tx_data_valid <= '1';
						
						if(INIT_tx_data_valid and INIT_tx_data_ready) then	-- handshake complete ?
							INIT_tx_data_valid <= '0';						-- de-assert valid
							state <= get_data_byte;							-- get next data byte 
							if(data_count_reg = data_length_reg) then		-- data sent ?
								state <= idle;								-- return to idle state 
							end if;
						end if;
						
				end case;
			
			end if;
		end if;
	end process;


end rtl;