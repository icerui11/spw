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
context work.router_context;
use work.all;

----------------------------------------------------------------------------------------------------------------------------------
-- Entity Signals --
----------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------------
-- Entity Declaration --
----------------------------------------------------------------------------------------------------------------------------------
router_inst: entity work.router_top_level(rtl)
generic map(
	g_clock_freq	=>  c_spw_clk_freq	,		-- these are located in router_pckg.vhd
    g_num_ports 	=>  c_num_ports		,      	-- these are located in router_pckg.vhd
	g_mode			=>  c_port_mode		,      	-- these are located in router_pckg.vhd
	g_is_fifo		=>  c_fifo_ports	,       -- these are located in router_pckg.vhd
	g_priority		=>  c_priority		,      	-- these are located in router_pckg.vhd
	g_ram_style 	=>  c_ram_style				-- style of RAM to use (Block, Auto, URAM etc), 
)
port map( 

	-- standard register control signals --
	spw_clk_p				=>	spw_clk_p		,
	spw_clk_n				=>	spw_clk_n		,
	router_clk				=>	router_clk		,
	rst_in  				=>	rst_in			,
	
	-- use these IO if using custom IO mode 
	DDR_din_r				=>	DDR_din_r		,	
	DDR_din_f   			=>  DDR_din_f   	,
	DDR_sin_r   			=>  DDR_sin_r   	,
	DDR_sin_f   			=>  DDR_sin_f   	,
	SDR_Dout				=>  SDR_Dout		,
	SDR_Sout				=>  SDR_Sout		,
	
	-- use these IO if using Single/Diff IO modes
	Din_p  					=>	Din_p 			, 			
	Din_n                   =>	Din_n           ,
	Sin_p                   =>	Sin_p           ,
	Sin_n                   =>	Sin_n           ,
	Dout_p                  =>	Dout_p          ,
	Dout_n                  =>	Dout_n          ,
	Sout_p                  =>	Sout_p          ,
	Sout_n                  =>	Sout_n          ,

	spw_fifo_in				=>	spw_fifo_in		,
	spw_fifo_out			=>	spw_fifo_out	


);


---------------------------------------------------------------------------------------------------------------------------------
-- Code Description & Developer Notes --
---------------------------------------------------------------------------------------------------------------------------------