----------------------------------------------------------------------------------------------------------------------------------
-- File Description  --
----------------------------------------------------------------------------------------------------------------------------------
-- @ File Name				:	
-- @ Engineer				:	James E Logan
-- @ Role					:	FPGA Engineer
-- @ Company				:	4Links ltd
-- @ Date					: 	05/07/2023

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
use work.all;

----------------------------------------------------------------------------------------------------------------------------------
-- Entity Signals --
----------------------------------------------------------------------------------------------------------------------------------
	c_clock_frequency   : 	real := 125_000_000.0;			-- clock frequency for SpaceWire IP (>2MHz)
	c_rx_fifo_size      : 	integer range 1 to 56 := 16; 	-- must be >8
	c_tx_fifo_size      : 	integer range 1 to 56 := 16; 	-- must be >8
	c_mode				: 	string := "diff";				-- valid options are "diff", "single" and "custom".
	

	clock               :	std_logic := '0'
	clock_b             :	std_logic := '1'
	reset               :	std_logic := '0';
	-- Channels
	Tx_data             :   std_logic_vector(8 downto 0);
	Tx_OR               :   boolean;
	Tx_IR               :  	boolean;
	
	Rx_data             :  	std_logic_vector(8 downto 0);
	Rx_OR               :  	boolean;
	Rx_IR               :   boolean;
	
	Rx_ESC_ESC          :  	boolean;
	Rx_ESC_EOP          :  	boolean;
	Rx_ESC_EEP          :  	boolean;
	Rx_Parity_error     :  	boolean;
	Rx_bits             :  	integer range 0 to 2;
	Rx_rate             :  	std_logic_vector(15 downto 0);
	
	Rx_Time             :  	std_logic_vector(7 downto 0);
	Rx_Time_OR          :  	boolean;
	Rx_Time_IR          :   boolean;
	
	Tx_Time             :   std_logic_vector(7 downto 0);
	Tx_Time_OR          :   boolean;
	Tx_Time_IR          :  	boolean;
	
	-- Control	
	Disable             :   boolean;
	Connected           :  	boolean;
	Error_select        :   std_logic_vector(3 downto 0);
	Error_inject        :   boolean;
	
	-- DDR/SDR IO, only when "custom" mode is used
	-- when instantiating, if not used, you can ignore these ports. 
	DDR_din_r			: 	std_logic := '0';
	DDR_din_f           : 	std_logic := '0';
	DDR_sin_r           : 	std_logic := '0';
	DDR_sin_f           : 	std_logic := '0';
	SDR_Dout			: 	std_logic := '0';
	SDR_Sout			: 	std_logic := '0';
	
	-- SpW	
	Din_p               :   std_logic := '0';
	Din_n               :   std_logic := '0';
	Sin_p               :   std_logic := '0';
	Sin_n               :   std_logic := '0';
	Dout_p              :  	std_logic := '0';
	Dout_n              :  	std_logic := '0';
	Sout_p              :  	std_logic := '0';
	Sout_n              :  	std_logic := '0';


----------------------------------------------------------------------------------------------------------------------------------
-- Entity Declaration --
----------------------------------------------------------------------------------------------------------------------------------

	-- copy into design entity architecture -- 
	spw_inst: entity spw_wrap_top_level(rtl) 
	generic map(
		g_clock_frequency   =>	125_000_000.0, 
		g_rx_fifo_size      =>  16,      
		g_tx_fifo_size      =>  16,      
		g_mode				=>  "diff"				
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
		
		-- DDR/SDR IO, only when "custom" mode is used
		-- when instantiating, if not used, you can ignore these ports. 
		DDR_din_r			=>	DDR_din_r,		-- Data in Rising Edge Input	
		DDR_din_f           =>  DDR_din_f, 		-- Data in Falling Edge Input  
		DDR_sin_r           =>  DDR_sin_r,   	-- Strobe in Rising Edge Input	
		DDR_sin_f           =>  DDR_sin_f,      -- Strobe in Falling Edge Input 
		SDR_Dout			=>  SDR_Dout,		-- Data Output (rising edge of Clock)
		SDR_Sout			=>  SDR_Sout,		-- Strobe output (rising edge of Clock)

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


---------------------------------------------------------------------------------------------------------------------------------
-- Code Description & Developer Notes --
---------------------------------------------------------------------------------------------------------------------------------


