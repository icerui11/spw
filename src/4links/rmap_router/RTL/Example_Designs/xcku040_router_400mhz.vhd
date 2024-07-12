---------------------------------------------------------------------------------------------------------------------------------
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

Library UNISIM;
use UNISIM.vcomponents.all;

----------------------------------------------------------------------------------------------------------------------------------
-- Package Declarations --
----------------------------------------------------------------------------------------------------------------------------------
-- use work.ip4l_data_types.all;
context work.router_context;	-- use router context 
----------------------------------------------------------------------------------------------------------------------------------
-- Entity Declarations --
----------------------------------------------------------------------------------------------------------------------------------
entity xcku040_router_400mhz is
	generic(
		g_clock_freq 	: real 					:= c_router_clk_freq;
		g_num_ports 	: integer range 1 to 32 := c_num_ports;
		g_is_fifo 		: t_dword				:= c_fifo_ports;
		g_priority      : string                := c_priority;
		g_ram_style 	: string				:= c_ram_style			-- style of RAM to use (Block, Auto, URAM etc), 
	);
	port( 
		
		-- standard register control signals --
		CLOCK_p		: in 	std_logic := '0';		-- clk input, rising edge trigger
		CLOCK_n		: in 	std_logic := '1';
		rst_in		: in 	std_logic := '0';		-- reset input, active high
		
		Din_p  		: in	std_logic_vector(1 to g_num_ports-1) := (others => '0');	
		Din_n   	: in	std_logic_vector(1 to g_num_ports-1) := (others => '1'); 
		Sin_p   	: in	std_logic_vector(1 to g_num_ports-1) := (others => '0'); 
		Sin_n   	: in	std_logic_vector(1 to g_num_ports-1) := (others => '1'); 
		Dout_p  	: out	std_logic_vector(1 to g_num_ports-1) := (others => '0'); 
		Dout_n  	: out	std_logic_vector(1 to g_num_ports-1) := (others => '1'); 
		Sout_p  	: out	std_logic_vector(1 to g_num_ports-1) := (others => '0'); 
		Sout_n  	: out	std_logic_vector(1 to g_num_ports-1) := (others => '1')
		
    );
end xcku040_router_400mhz;


---------------------------------------------------------------------------------------------------------------------------------
-- Code Description & Developer Notes --
---------------------------------------------------------------------------------------------------------------------------------


architecture rtl of xcku040_router_400mhz is

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
	-- Component Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	component clk_wiz_0
	port(
		-- Clock out ports
		clk_out_p          	: out    std_logic;
		clk_out_n          	: out    std_logic;
		clk_out3            : out    std_logic;
		-- Status and control signals
		reset             	: in     std_logic;
		locked            	: out    std_logic;
		-- Clock in ports
		clk_in1           	: in     std_logic
	);
	end component;
	----------------------------------------------------------------------------------------------------------------------------
	-- Signal Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	signal	DDR_din_r				: 	std_logic_vector(1 to g_num_ports-1)	:= (others => '0');	-- DDR in Signals 
	signal	DDR_din_f   			: 	std_logic_vector(1 to g_num_ports-1)     := (others => '0');	-- DDR in Signals 
	signal	DDR_sin_r   			: 	std_logic_vector(1 to g_num_ports-1)     := (others => '0');	-- DDR in Signals 
	signal	DDR_sin_f   			: 	std_logic_vector(1 to g_num_ports-1)     := (others => '0');	-- DDR in Signals 
	signal	SDR_Dout				: 	std_logic_vector(1 to g_num_ports-1)     := (others => '0');	-- SDR out Signals 
	signal	SDR_Sout				: 	std_logic_vector(1 to g_num_ports-1)     := (others => '0');	-- SDR out Signals 
	
	signal 	Din						: 	std_logic_vector(1 to g_num_ports-1) := (others => '0');
	signal 	Sin						: 	std_logic_vector(1 to g_num_ports-1) := (others => '0');
	
	signal pll_clk_p				: 	std_logic 	:= '0';		-- Positive clock-out signal (PLL)
	signal pll_clk_n	            : 	std_logic 	:= '1';		-- Negateive clock-out signal (PLL)
	signal router_clk              : std_logic := '0';
	signal rst_in_sync	            : 	std_logic 	:= '0';		-- Reset (active high), Synchronous to Positive PLL clock 
	
	
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
	IO_gen:	for i in 1 to g_num_ports-1 generate	-- generate Differential / IO Buffers & DDR Registers
		
		D_in_buf : IBUFDS
		port map (
			O 	=> Din(i),   						-- 1-bit output: Buffer output
			I 	=> Din_p(i),   						-- 1-bit input: Diff_p buffer input (connect directly to top-level port)
			IB 	=> Din_n(i) 						-- 1-bit input: Diff_n buffer input (connect directly to top-level port)
		);
		
		S_in_buf : IBUFDS
		port map (
			O 	=> Sin(i),   						-- 1-bit output: Buffer output
			I 	=> Sin_p(i),   						-- 1-bit input: Diff_p buffer input (connect directly to top-level port)
			IB 	=> Sin_n(i)  						-- 1-bit input: Diff_n buffer input (connect directly to top-level port)
		);
			
		D_in_DDR : IDDRE1
		generic map(
			DDR_CLK_EDGE 	=> "OPPOSITE_EDGE", 	-- IDDRE1 mode (OPPOSITE_EDGE, SAME_EDGE, SAME_EDGE_PIPELINED)
			IS_CB_INVERTED 	=> '1',          	 	-- Optional inversion for CB
			IS_C_INVERTED 	=> '0'             		-- Optional inversion for C
		)
		port map(
			Q1 	=> DDR_din_r(i),					-- 1-bit output: Registered parallel output 1
			Q2 	=> DDR_din_f(i), 					-- 1-bit output: Registered parallel output 2
			C 	=> pll_clk_p,  				 		-- 1-bit input: High-speed clock
			CB 	=> pll_clk_p,						-- 1-bit input: Inversion of High-speed clock C
			D 	=> Din(i),   						-- 1-bit input: Serial Data Input
			R 	=> '0'    							-- 1-bit input: Active-High Async Reset
		);
		
		S_in_DDR : IDDRE1
		generic map(
			DDR_CLK_EDGE 	=> "OPPOSITE_EDGE", 	-- IDDRE1 mode (OPPOSITE_EDGE, SAME_EDGE, SAME_EDGE_PIPELINED)
			IS_CB_INVERTED 	=> '1',           		-- Optional inversion for CB
			IS_C_INVERTED 	=> '0'            		-- Optional inversion for C
		)
		port map(
			Q1 	=> DDR_sin_r(i), 					-- 1-bit output: Registered parallel output 1
			Q2 	=> DDR_sin_f(i), 					-- 1-bit output: Registered parallel output 2
			C 	=> pll_clk_p,   					-- 1-bit input: High-speed clock
			CB 	=> pll_clk_p, 						-- 1-bit input: Inversion of High-speed clock C
			D 	=> Sin(i),   						-- 1-bit input: Serial Data Input
			R 	=> '0'   							-- 1-bit input: Active-High Async Reset
		);
		
		D_out_buf : OBUFDS
		port map(
			O 	=> Dout_p(i),   					-- 1-bit output: Diff_p output (connect directly to top-level port)
			OB 	=> Dout_n(i), 						-- 1-bit output: Diff_n output (connect directly to top-level port)
			I 	=> SDR_Dout(i)    					-- 1-bit input: Buffer input
		);
		
		S_out_buf : OBUFDS
		port map(
			O 	=> Sout_p(i),   					-- 1-bit output: Diff_p output (connect directly to top-level port)
			OB 	=> Sout_n(i), 						-- 1-bit output: Diff_n output (connect directly to top-level port)
			I 	=> SDR_Sout(i)    					-- 1-bit input: Buffer input
		);
	
	
	end generate IO_gen;
	
	
	router_inst: entity work.router_top_level(rtl)	-- instantiate SpaceWire Router 
	generic map(
		g_clock_freq => g_clock_freq,
		g_num_ports => g_num_ports,
		g_is_fifo 	=> g_is_fifo,
		g_mode		=> "custom",					-- custom mode, we're instantiating SpaceWire in this top-level architecture
		g_priority => g_priority,
		g_ram_style => g_ram_style
	)
	port map( 
	
		-- standard register control signals --
		spw_clk_p				=>	pll_clk_p		,	
		spw_clk_n				=>  pll_clk_n		,
		router_clk              =>  router_clk      ,
		rst_in					=>  rst_in		    ,	
		enable  				=>  '1'				,  
	
		DDR_din_r				=> 	DDR_din_r		,	
		DDR_din_f   			=> 	DDR_din_f   	,  
		DDR_sin_r   			=> 	DDR_sin_r   	,  
		DDR_sin_f   			=> 	DDR_sin_f   	,  
		SDR_Dout				=> 	SDR_Dout		,
		SDR_Sout				=> 	SDR_Sout		,
		
		Din_p               	=>	open			, 
		Din_n               	=>  open			, 
		Sin_p               	=>  open			, 
		Sin_n               	=>  open			, 
		Dout_p              	=>  open			, 
		Dout_n              	=>  open			, 
		Sout_p              	=>  open			, 
		Sout_n              	=>  open			,  

		spw_fifo_in				=>	open			,		
		spw_fifo_out			=>	open				

	--	tc_master_mask			=>	g_tc_mask		

	);
	----------------------------------------------------------------------------------------------------------------------------
	-- Component Instantiations --
	----------------------------------------------------------------------------------------------------------------------------
	pll_clk : clk_wiz_0
	port map( 
		-- Clock out ports  
		clk_out_p 	=> pll_clk_p,
		clk_out_n 	=> pll_clk_n,
		clk_out3    => router_clk,
		-- Status and control signals                
		reset 		=> '0',
		locked 		=> open,
		-- Clock in ports
		clk_in1	    => CLOCK_p
	);
	----------------------------------------------------------------------------------------------------------------------------
	-- Asynchronous Signal Assignments --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Synchronous Processes --
	----------------------------------------------------------------------------------------------------------------------------



end rtl;