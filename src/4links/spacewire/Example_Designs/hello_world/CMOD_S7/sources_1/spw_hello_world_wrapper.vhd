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

----------------------------------------------------------------------------------------------------------------------------------
-- Entity Declarations --
----------------------------------------------------------------------------------------------------------------------------------
entity spw_hello_world_wrapper is
	generic(
		g_clock_freq	: real 		:= 100_000_000.0;
		g_tx_fifo_depth	: integer 	:= 16;
		g_rx_fifo_depth	: integer 	:= 16;
		g_ram_str		: string	:= "HELLO_WORLD";
		g_mode			: string 	:= "diff"
	);
	port( 
		-- standard register control signals --
		mmcm_clk_in1_p 	: in 	std_logic := '0';										-- clock_in (p) 	-- 300MHz
		mmcm_clk_in1_n	: in 	std_logic := '1';										-- clock_out (n) 	-- 300MHz
		rst_in			: in 	std_logic := '0';										-- reset input, active high
		
		-- SpW Rx IO
		spw_Din_p 		: in	std_logic := '0';
		spw_Din_n       : in    std_logic := '1';
		spw_Sin_p       : in    std_logic := '0';
		spw_Sin_n       : in    std_logic := '1'; 
		
		-- SpW Tx IO
		spw_Dout_p      : out   std_logic := '0';
		spw_Dout_n      : out   std_logic := '1';
		spw_Sout_p      : out   std_logic := '0';
		spw_Sout_n      : out   std_logic := '1';
		
		spw_error		: out 	std_logic := '0'
		
    );
end spw_hello_world_wrapper;


---------------------------------------------------------------------------------------------------------------------------------
-- Code Description & Developer Notes --
---------------------------------------------------------------------------------------------------------------------------------


architecture rtl of spw_hello_world_wrapper is

	----------------------------------------------------------------------------------------------------------------------------
	-- Constant Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
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
	u_spw_hw: entity spw_hello_world_logic(rtl)
	generic map(
		g_clock_freq	=> 	g_clock_freq,
		g_tx_fifo_depth	=>	g_tx_fifo_depth,
		g_rx_fifo_depth	=> 	g_rx_fifo_depth,
		g_ram_str		=>  g_ram_str,
		g_mode			=>  g_mode
	)
	port map(
		-- standard register control signals --
		mmcm_clk_in1_p 	=> 	mmcm_clk_in1_p,		
		mmcm_clk_in1_n	=> 	mmcm_clk_in1_n,
		rst_in			=> 	rst_in, 		
		enable  		=> 	'1',
		
		rx_cmd_out		=>  open,		
		rx_cmd_valid	=>  open,
		rx_cmd_ready	=>  '1',	
		
		rx_data_out		=>  open,	
		rx_data_valid	=>  open,	
		rx_data_ready	=>	'1',	

		-- SpW Rx IO   
		spw_Din_p 		=> 	spw_Din_p,
		spw_Din_n       => 	spw_Din_n,
		spw_Sin_p       => 	spw_Sin_p,
		spw_Sin_n       => 	spw_Sin_n,

		-- SpW Tx IO   
		spw_Dout_p      => 	spw_Dout_p,
		spw_Dout_n      => 	spw_Dout_n,
		spw_Sout_p      => 	spw_Sout_p,
		spw_Sout_n      => 	spw_Sout_n,
		
		spw_error		=> spw_error 
	);
	----------------------------------------------------------------------------------------------------------------------------
	-- Component Instantiations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Asynchronous Signal Assignments --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Synchronous Processes --
	-------------------------------------------------------------------------------
	
	
	end rtl;