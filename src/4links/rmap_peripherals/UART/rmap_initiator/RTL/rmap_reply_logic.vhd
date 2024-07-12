----------------------------------------------------------------------------------------------------------------------------------
-- File Description  --
----------------------------------------------------------------------------------------------------------------------------------
-- @ File Name				:	rmap_reply_logic
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
-- use work.ip4l_data_types.all;
context work.rmap_context;
----------------------------------------------------------------------------------------------------------------------------------
-- Entity Declarations --
----------------------------------------------------------------------------------------------------------------------------------
entity rmap_reply_logic is
	port( 
		
		-- standard register control signals --
		clk_in						: in 	std_logic 	:= '0';		-- clk input, rising edge trigger
		rst_in						: in 	std_logic 	:= '0';		-- reset input, active high

		UART_out  					: out 	t_byte 		:= (others => '0');
		UART_valid					: out 	std_logic 	:= '0';
		UART_ready					: in 	std_logic 	:= '0';
		
		INIT_rx_enable				: out 	std_logic 	:= '0';
		INIT_rx_error				: in 	std_logic_vector(7 downto 0) := (others => '0');
		INIT_rx_error_valid			: in 	std_logic 	:= '0';
		INIT_rx_error_ready			: out 	std_logic 	:= '0';

		INIT_rx_time				: in 	t_byte 		:= (others => '0');
		INIT_rx_time_valid 			: in 	std_logic 	:= '0';
		INIT_rx_time_ready			: out	std_logic 	:= '0';
		
		INIT_rx_data				: in 	t_byte 		:= (others => '0');
		INIT_rx_data_valid			: in 	std_logic	:= '0';
		INIT_rx_data_ready 			: out	std_logic 	:= '0';
		
		INIT_rx_init_log_addr	    : in 	t_byte := (others => '0');
		INIT_rx_protocol_id			: in 	t_byte := (others => '0');
		INIT_rx_instruction			: in 	t_byte := (others => '0');
		INIT_rx_Status	    		: in 	t_byte := (others => '0');
		INIT_rx_target_log_addr		: in 	t_byte := (others => '0');
		INIT_rx_Tranaction_ID		: in 	std_logic_vector(15 downto 0) := (others => '0');
		INIT_rx_Data_Length     	: in 	std_logic_vector(23 downto 0) := (others => '0');
		
		INIT_rx_header_valid		: in 	std_logic := '0';
		INIT_rx_header_ready 		: out 	std_logic := '0';
	
		INIT_crc_good				: in 	std_logic := '1'
		
		
    );
end rmap_reply_logic;


---------------------------------------------------------------------------------------------------------------------------------
-- Code Description & Developer Notes --
---------------------------------------------------------------------------------------------------------------------------------


architecture rtl of rmap_reply_logic is

	----------------------------------------------------------------------------------------------------------------------------
	-- Constant Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Type Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	type t_state is(
		idle			, 
		send_address	,
		send_data_len	,
		get_data_byte	,
		send_data_byte	
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
	signal state : t_state := idle;
	
	signal data_count 		: unsigned(7 downto 0) := (others => '0');
	signal FIFO_full 		: std_logic 		:= '0';
	signal FIFO_empty		: std_logic 		:= '0';
	
	signal reply_data  		: t_byte 			:= (others => '0');
	signal reply_data_valid	: std_logic			:= '0';
	signal reply_data_ready : std_logic         := '0';
	signal clr				: std_logic 		:= '0';
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
	reply_fifo: entity work.dp_fifo_buffer(rtl)
	generic map(
		g_data_width	=> 	8,
		g_addr_width	=> 	10
	)
	port map( 
		
		-- standard register control signals --
		wr_clk_in		=>	clk_in				,		-- write clk input, rising edge trigger
		rd_clk_in		=>	clk_in				,		-- read clk input, rising edge trigger
		wr_rst_in		=>	(rst_in	or clr)		,		-- reset input, active high
		rd_rst_in		=>	(rst_in	or clr)		,		-- reset input, active high
		
		-- FiFO buffer Wr/Rd Interface --
		FIFO_wr_data	=>	INIT_rx_data		,			
		FIFO_wr_valid	=>	INIT_rx_data_valid	,	
		FIFO_wr_ready	=>	INIT_rx_data_ready 	,		-- only asserted when fifo is NOT full
		
		FIFO_rd_data	=>	reply_data  		,
		FIFO_rd_valid	=>	reply_data_valid	,		-- only asserted when fifo is NOT empty
		FIFO_rd_ready	=>	reply_data_ready	,

		full			=>	FIFO_full			, 		-- asserted when Fifo is Full (Write Clock Domain)
		empty			=>	FIFO_empty					-- asserted when Fifo is Empty (Read Clock Domain)
		
    );
	----------------------------------------------------------------------------------------------------------------------------
	-- Component Instantiations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Asynchronous Signal Assignments --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Synchronous Processes --
	----------------------------------------------------------------------------------------------------------------------------
	process(clk_in)
	begin
		if(rising_edge(clk_in)) then
			clr <= '0';	-- used to "clear" the FIFO on error
			INIT_rx_enable <= '0';
			if(rst_in = '1') then
				INIT_rx_header_ready <= '0';
				UART_valid 	<= '0';
				reply_data_ready <= '0';
				state <= idle;
			else
				case state is
					when idle =>
						INIT_rx_enable <= '1';
						INIT_rx_header_ready <= '1';
						if(INIT_rx_header_valid and INIT_rx_header_ready) then
							INIT_rx_header_ready <= '0';
						end if;
					
						data_count <= (others => '0');
						if(FIFO_empty = '0') then
							state <= send_address;
						end if;
						
					when send_address =>
						UART_out	<= INIT_rx_target_log_addr;
						UART_valid 	<= '1';
						
						if(UART_ready and UART_valid) then
							UART_valid 	<= '0';
							state <= send_data_len;
						end if;
						
					when send_data_len =>
					
						UART_out 		<= 	INIT_rx_Data_Length(7 downto 0);
						UART_valid 		<= '1';
						
						if(UART_ready and UART_valid) then
							UART_valid 	<= '0';
							state <= get_data_byte;
							if(INIT_rx_Data_Length(7 downto 0) = x"00") then
								state <= idle;
								clr <= '1';
							end if;
						end if;
					
					when get_data_byte =>
					
						UART_out 			<= reply_data;
						reply_data_ready 	<= '1';
						
						if(reply_data_ready and reply_data_valid) then
							reply_data_ready <= '0';
							data_count <= data_count + 1;
							state <= send_data_byte;
						end if;
						
					
					when send_data_byte =>
					
						UART_valid <= '1';
						if(UART_ready and UART_valid) then
							UART_valid <= '0';
							state <= get_data_byte;
							if(data_count = unsigned(INIT_rx_Data_Length)) then
								state <= idle;
							end if;
						end if;
				
				end case;
				

			
				
				-- Take care of errors, we don't care about them but need to make
				-- they are acknowledged to prevent IP lock ups
				if(INIT_rx_error_valid = '1') then
					INIT_rx_error_ready <= '1';
				end if;
				
				if(INIT_rx_error_ready and INIT_rx_error_valid) then
					INIT_rx_error_ready <= '0';
					clr <= '1';
					state <= idle;	-- force idle state when error acknowledged
				end if;
			
			end if;
		end if;
	end process;


end rtl;