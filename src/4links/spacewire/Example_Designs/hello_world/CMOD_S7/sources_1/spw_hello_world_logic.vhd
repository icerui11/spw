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

-- @ Revision #				:	1

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
----------------------------------------------------------------------------------------------------------------------------------
-- Entity Declarations --
----------------------------------------------------------------------------------------------------------------------------------
entity spw_hello_world_logic is
	generic(
		g_clock_freq	: real 		:= 125_000_000.0;
		g_tx_fifo_depth	: integer 	:= 16;
		g_rx_fifo_depth	: integer 	:= 16;
		g_ram_str		: string 	:= "HELLO_WORLD";
		g_mode			: string  	:= "diff"  -- DE or SE are valid arguments. 
	);
	port( 
		-- standard register control signals --
		mmcm_clk_in1_p 	: in 	std_logic := '0';										-- clock_in (p) 	-- 300MHz
		mmcm_clk_in1_n	: in 	std_logic := '1';										-- clock_out (n) 	-- 300MHz
		rst_in			: in 	std_logic := '0';										-- reset input, active high
		enable  		: in 	std_logic := '0';										-- enable input, asserted high. 
		
		rx_cmd_out		: out 	std_logic_vector(2 downto 0)	:= (others => '0');		-- control char output bits
		rx_cmd_valid	: out 	std_logic;												-- asserted when valid command to output
		rx_cmd_ready	: in 	std_logic;												-- assert to receive rx command. 
		
		rx_data_out		: out 	std_logic_vector(7 downto 0)	:= (others => '0');		-- received spacewire data output
		rx_data_valid	: out 	std_logic := '0';										-- valid rx data on output
		rx_data_ready	: in 	std_logic := '1';										-- assert to receive rx data
		
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
		
		spw_error       : out     std_logic := '0'
    );
end spw_hello_world_logic;


---------------------------------------------------------------------------------------------------------------------------------
-- Code Description & Developer Notes --
---------------------------------------------------------------------------------------------------------------------------------




architecture rtl of spw_hello_world_logic is

	----------------------------------------------------------------------------------------------------------------------------
	-- Constant Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	constant c_ram_data_width	: natural 	:= 8;
	constant c_clock_delays		: natural  	:= 256;
	----------------------------------------------------------------------------------------------------------------------------
	-- Type Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Function Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	impure function to_std(bool : boolean) return std_logic is		-- convert boolean ports to std_logic
		variable std	: std_logic;
	begin
		if(bool = true) then
			std := '1';
		else
			std := '0';
		end if;
		return std;
	end;
	
	impure function to_bool(std	: std_logic) return boolean is		-- convert std_logic ports to boolean 
		variable bool 	: boolean;
	begin
		if(std = '1' or std = 'H') then
			bool := true;
		else
			bool := false;
		end if;
		return bool;
	end;

	----------------------------------------------------------------------------------------------------------------------------
	-- Entity Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Component Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	
	component clk_wiz_S7
	port(	-- Clock in ports
		-- Clock out ports
		clk_out1          : out    std_logic;
		clk_out2          : out    std_logic;
		-- Status and control signals
		reset             : in     std_logic;
		locked            : out    std_logic;
		clk_in1           : in     std_logic
	);
	end component;
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Signal Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------
	-- spw_wrap signals --															--
	----------------------------------------------------------------------------------
	signal clock                	:    	std_logic;								--
	signal clock_b              	:    	std_logic;                              --
	-- Channels                                                                 	--
	signal spw_Tx_data              :    	nonet;                                  --
	signal spw_Tx_OR                :    	std_logic := '0';                       -- converted to std_logic for use in entity/component outputs...
	signal spw_Tx_IR                :  		boolean;                                --
	signal spw_Rx_data              :  		nonet;                                  --
	signal spw_Rx_OR                :  		boolean;                                --
	signal spw_Rx_IR                :    	std_logic := '0';                       --
	signal spw_Rx_ESC_ESC           :  		boolean;                                --
	signal spw_Rx_ESC_EOP           :  		boolean;                                --
	signal spw_Rx_ESC_EEP           :  		boolean;                                --
	signal spw_Rx_Parity_error      :  		boolean;                                --
	signal spw_Rx_bits              :  		integer range 0 to 2;                   --
	signal spw_Rx_rate              :  		std_logic_vector(15 downto 0);          --
	signal spw_Connected            : 		boolean;                                --
	----------------------------------------------------------------------------------
	
	--------------------------------------------------------------------------------------------------
	-- RAM signals --																				--
	--------------------------------------------------------------------------------------------------
	signal ram_enable 			: 			std_logic;												--
	signal ram_wr_en			:			std_logic;                                      		--
	signal ram_addr	            :			std_logic_vector(log2(g_ram_str'length)-1 downto 0);	--
	signal ram_wr_data	        :			std_logic_vector(c_ram_data_width-1 downto 0);			--
	signal ascii_data	        :			std_logic_vector(c_ram_data_width-1 downto 0);			--
	--------------------------------------------------------------------------------------------------
	
	signal mmcm_locked			: 			std_logic := '0';
	signal reset				: 			std_logic := '0';
	
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
	-- SpW CoDeC --
		u_spw_wrap: entity spw_wrap_top_level_xilinx(rtl)
		generic map(
			g_clock_frequency 	=>	 	g_clock_freq,   
			g_rx_fifo_size      =>		g_rx_fifo_depth,   
			g_tx_fifo_size      =>	  	g_tx_fifo_depth,   
			g_mode              =>      g_mode
		)
		port map( 
			clock  				=>  clock,          
			clock_b             => 	clock_b,
			reset               => 	reset,
			
			-- Channels         	-- Channels      	  
			Tx_data             =>  spw_Tx_data        	   	,
			Tx_OR               =>  to_bool(spw_Tx_OR)     	,
			Tx_IR               =>  spw_Tx_IR              	,
			
			Rx_data             =>  spw_Rx_data            	,
			Rx_OR               =>  spw_Rx_OR              	,
			Rx_IR               =>  to_bool(spw_Rx_IR)     	,
			
			Rx_ESC_ESC          =>  spw_Rx_ESC_ESC        	,
			Rx_ESC_EOP          =>  spw_Rx_ESC_EOP         	,
			Rx_ESC_EEP          =>  spw_Rx_ESC_EEP         	,
			Rx_Parity_error     =>  spw_Rx_Parity_error   	,
			Rx_bits             =>  open          			,
			Rx_rate             =>  open            		,
			
			Rx_Time             =>  open            		,
			Rx_Time_OR          =>  open         			,
			Rx_Time_IR          =>  false         			,

			Tx_Time             =>  (others => '0')         ,
			Tx_Time_OR          =>  false         			,
			Tx_Time_IR          =>  open     				,

			-- Control              -- Control         
			Disable             =>  false            	    ,
			Connected           =>  spw_Connected          	,
			Error_select        =>  (others => '0')       	,
			Error_inject        =>  false       			,
			
			-- SpW                  -- SpW             
			Din_p               =>  spw_Din_p              	,
			Din_n               =>  spw_Din_n              	,
			Sin_p               =>  spw_Sin_p              	,
			Sin_n               =>  spw_Sin_n              	,
			Dout_p              =>  spw_Dout_p             	,
			Dout_n              =>  spw_Dout_n             	,
			Sout_p              =>  spw_Sout_p             	,
			Sout_n              =>  spw_Sout_n             
		);
	
	
	-- RAM to store Characters (used as ROM) --
	u_ram: entity xilinx_single_port_single_clock_ram(rtl)
	generic map(
		ram_type	=>	"auto",						    -- ram type to infer (auto, distributed, block, register, ultra)
		data_width	=> 	c_ram_data_width,				-- bit-width of ram element
		addr_width	=> 	log2(g_ram_str'length),				-- address width of RAM
		ram_str		=>  g_ram_str					
	)
	port map(
		-- standard register control signals --
		clk_in 		=> clock,							-- clock in (rising_edge)
		enable_in 	=> ram_enable,						-- enable input (active high)
		
		wr_en		=> '0',								-- write enable (asserted high)
		addr		=> ram_addr,						-- write address
		wr_data     => open,							-- write data
		rd_data		=> ascii_data						-- read data
	
	);
	
	-- Hello World Memory Controller --
	u_controller: entity spw_hello_world_controller(rtl)
	generic map(
		g_addr_width		=>	log2(g_ram_str'length),		-- address width of connecting RAM
		g_count_max 		=> 	c_clock_delays,  			-- count period between character reads
		g_num_chars			=> 	g_ram_str'length 		 	-- number of characters to send from RAM "HELLO_WORLD" = 11
	)
	port map( 

		-- standard register control signals --
		clk_in				=> 	clock,						-- clk input, rising edge trigger
		rst_in				=>	reset,						-- reset input, active high
		enable  			=>	mmcm_locked and enable,		-- enable input, asserted high. 
		
		-- RAM signals
		ram_enable			=> 	ram_enable,					-- ram enable
		ram_data_in			=> 	ascii_data,					-- ram read data
		ram_addr_out		=> 	ram_addr,					-- address to read ram data
		
		-- SpW Data Signals
		spw_Tx_data			=> 	spw_Tx_data(7 downto 0),	-- SpW Tx Data
		spw_Tx_Con			=> 	spw_Tx_data(8),				-- SpW Control Char Bit
		spw_Tx_OR			=> 	spw_Tx_OR,					-- SpW Tx Output Ready signal
		spw_Tx_IR			=> 	to_std(spw_Tx_IR),			-- SpW Tx Input Ready signal
		
		spw_Rx_data			=>	spw_Rx_data(7 downto 0),
		spw_Rx_Con		    =>	spw_Rx_data(8),
		spw_Rx_OR		    =>  to_std(spw_Rx_OR),
		spw_Rx_IR		    =>  spw_Rx_IR,
	
		rx_cmd_out		    =>	rx_cmd_out,
		rx_cmd_valid	    =>	rx_cmd_valid,
		rx_cmd_ready	    =>  rx_cmd_ready,
	
		rx_data_out		    =>	rx_data_out,
		rx_data_valid	    =>	rx_data_valid,
		rx_data_ready	    =>	rx_data_ready,
		
		-- SpW Control Signals
		spw_Connected	 	=> 	to_std(spw_Connected),			-- asserted when SpW Link is Connected
		spw_Rx_ESC_ESC	 	=> 	to_std(spw_Rx_ESC_ESC),     	-- SpW ESC_ESC error 
		spw_ESC_EOP 	 	=> 	to_std(spw_Rx_ESC_EOP),   		-- SpW ESC_EOP error 
		spw_ESC_EEP      	=> 	to_std(spw_Rx_ESC_EEP),     	-- SpW ESC_EEP error 
		spw_Parity_error 	=> 	to_std(spw_Rx_Parity_error),    -- SpW Parity error
		
		error_out			=> 	spw_error						-- assert when error
    );

	
	----------------------------------------------------------------------------------------------------------------------------
	-- Component Instantiations --
	----------------------------------------------------------------------------------------------------------------------------
	u_mmcm : clk_wiz_S7	-- component instantiation of MMCM 
	port map ( 
		-- Clock out ports  
		clk_out1 	=> clock,			-- 100MHz P clock output
		clk_out2 	=> clock_b,			-- 100MHz N clock output
		-- Status and control signals                
		reset 		=> '0',
		locked 		=> mmcm_locked,		-- asserted high when clock output is valid. 
		clk_in1 	=> mmcm_clk_in1_p	-- 300MHz P clock input
	);
	

	----------------------------------------------------------------------------------------------------------------------------
	-- Asynchronous Signal Assignments --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Synchronous Processes --
	----------------------------------------------------------------------------------------------------------------------------
	reset_sync: process(clock)
	begin
		if(rising_edge(clock)) then
			reset <= rst_in;
		end if;
	end process;
	----------------------------------------------------------------------------------------------------------------------------
	-- Asynchronous Processes --
	----------------------------------------------------------------------------------------------------------------------------


end rtl;


