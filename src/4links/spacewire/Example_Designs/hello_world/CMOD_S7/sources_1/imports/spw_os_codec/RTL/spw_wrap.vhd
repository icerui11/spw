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
use work.ip4l_data_types.all;
use work.spw_codes.all;
use work.all;

----------------------------------------------------------------------------------------------------------------------------------
-- Entity Declarations --
----------------------------------------------------------------------------------------------------------------------------------
entity spw_wrap is
	generic(
		constant CLOCK_FREQUENCY      : real := 125000000.0;
		constant RX_FIFO_SIZE         : integer range 1 to 56 := 16; -- must be >8
		constant TX_FIFO_SIZE         : integer range 1 to 56 := 16  -- must be >8
	);
	port( 
		clock                : in    std_logic;
		clock_b              : in    std_logic;
		reset                : in    std_logic;
	
		-- Channels
		Tx_data              : in    	nonet;
		Tx_OR                : in    	boolean;
		Tx_IR                : out 		boolean;
		
		Rx_data              : out 		nonet;
		Rx_OR                : out 		boolean;
		Rx_IR                : in    	boolean;
		
		Rx_ESC_ESC           : out 		boolean;
		Rx_ESC_EOP           : out 		boolean;
		Rx_ESC_EEP           : out 		boolean;
		Rx_Parity_error      : out 		boolean;
		Rx_bits              : out 		integer range 0 to 2;
		Rx_rate              : out 		std_logic_vector(15 downto 0);
		
		Rx_Time              : out 		octet;
		Rx_Time_OR           : out 		boolean;
		Rx_Time_IR           : in    	boolean;
		
		Tx_Time              : in    	octet;
		Tx_Time_OR           : in    	boolean;
		Tx_Time_IR           : out 		boolean;
		
		-- Control	
		Disable              : in    	boolean;
		Connected            : out 		boolean;
		Error_select         : in    	std_logic_vector(3 downto 0);
		Error_inject         : in    	boolean;
		
		-- SpW	
		Din_p                : in    	std_logic;
		Din_n                : in    	std_logic;
		Sin_p                : in    	std_logic;
		Sin_n                : in    	std_logic;
		Dout_p               : out 		std_logic;
		Dout_n               : out 		std_logic;
		Sout_p               : out 		std_logic;
		Sout_n               : out 		std_logic
	);
end spw_wrap;


---------------------------------------------------------------------------------------------------------------------------------
-- Code Description & Developer Notes --
---------------------------------------------------------------------------------------------------------------------------------


architecture rtl of spw_wrap is

	----------------------------------------------------------------------------------------------------------------------------
	-- Constant Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Type Declarations --
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
	signal legacy                : boolean;
	
	signal din                   : std_logic;
	signal sin                   : std_logic;
	signal dout                  : std_logic;
	signal sout                  : std_logic;
	
	signal i_doutp               : std_logic;
	signal i_doutn               : std_logic;
	signal i_soutp               : std_logic;
	signal i_soutn               : std_logic;
	signal dout_b                : std_logic;
	signal sout_b                : std_logic;
	
	signal din_r                 : std_logic;
	signal din_f                 : std_logic;
	signal sin_r                 : std_logic;
	signal sin_f                 : std_logic;
	
	signal timetagged_timecode   : long;
	
	signal link_disable          : boolean;
	signal forced_link_fail      : boolean;
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
	u_spw: entity spw
    generic map(
		CLOCK_FREQUENCY      => CLOCK_FREQUENCY,
		RX_FIFO_SIZE         => RX_FIFO_SIZE,
		TX_FIFO_SIZE         => TX_FIFO_SIZE
        )
    port map(
		clock           => clock,
		clock_b         => clock_b,
		reset           => reset,
		
		-- Control
		Disable         => link_disable,
		Legacy          => Legacy,
		Error_select    => Error_select,
		Error_inject    => Error_inject,
		Force_timeout_error   => false,       
		-- Status
		Out_Stalled     => open,
		Connected       => Connected,
		
		-- SpW DS	Interface			  
		RxD_r           => din_r,
		RxD_f           => din_f,
		RxS_r           => sin_r,
		RxS_f           => sin_f,
		TxD             => dout,
		TxS             => sout,
		
		-- Received Data Out
		Rx_data         => Rx_data,
		Rx_Data_OR      => Rx_OR,
		Rx_Data_IR      => Rx_IR,
		
		Rx_ESC_ESC      => Rx_ESC_ESC,
		Rx_ESC_EOP      => Rx_ESC_EOP,
		Rx_ESC_EEP      => Rx_ESC_EEP,
		Rx_Parity_error => Rx_Parity_error,
		Rx_bits         => Rx_bits,
		Rx_rate         => Rx_rate,

		-- Time
		Rx_Time         => Rx_Time,
		Rx_Time_OR      => Rx_Time_OR,
		Rx_Time_IR      => Rx_Time_IR,
		
		Tx_Time         => Tx_Time,
		Tx_Time_OR      => Tx_Time_OR,
		Tx_Time_IR      => Tx_Time_IR,
		
		-- Transmit Data In               
		Tx_data         => Tx_data,
		Tx_Data_OR      => Tx_OR,
		Tx_Data_IR      => Tx_IR
    );
	----------------------------------------------------------------------------------------------------------------------------
	-- Component Instantiations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Asynchronous Signal Assignments --
	----------------------------------------------------------------------------------------------------------------------------
	dout_b <= not dout;
	sout_b <= not sout;
	
	-- Use LVDS input buffers
    Dout_p <= i_doutp;
    Dout_n <= i_doutn;
    Sout_p <= i_soutp;
    Sout_n <= i_soutn;
	
	link_disable <= Disable or forced_link_fail;
	-- Link Auto Start when True
	legacy             <= False;
	----------------------------------------------------------------------------------------------------------------------------
	-- Synchronous Processes --
	----------------------------------------------------------------------------------------------------------------------------
		-------------------------------------------------------------------------------
		-- Technology specific instantiation
		-------------------------------------------------------------------------------
	-- DDR Register input model
	p_iddr_model: process(reset, clock/* clock_b*/)
    begin
		if reset = '1' then
			din_r <= '0';
		--	din_f <= '0';
			sin_r <= '0';
		--	sin_f <= '0';
		elsif rising_edge(clock) then
			din_r <= Din_p and not Din_n;
			sin_r <= Sin_p and not Sin_n;
	/*	elsif rising_edge(clock_b) then
			din_f <= Din_p and not Din_n;
			sin_f <= Sin_p and not Sin_n; */
		end if ;
    end process p_iddr_model;
	
    n_iddr_model: process(reset, clock_b)
	begin
		if(reset = '1') then
			din_f <= '0';
			sin_f <= '0';
		elsif(rising_edge(clock_b)) then
			din_f <= Din_p and not Din_n;
			sin_f <= Sin_p and not Sin_n;
		end if;
	end process n_iddr_model;
	
	-- SDR Register output model
    p_osdr_model: process(clock, reset)
    begin
		if (reset = '1') then
			i_doutp <= '0';
			i_doutn <= '1';
			i_soutp <= '0';
			i_soutn <= '1';
		elsif rising_edge(clock)  then
			i_doutp <= dout;
			i_doutn <= dout_b;
			i_soutp <= sout;
			i_soutn <= sout_b;
		end if;
    end process p_osdr_model;
	
	-------------------------------------------------------------------------------
	-- Body of top level
	-------------------------------------------------------------------------------
	
	p_link_fail: process ( clock, reset )
    begin
		if (reset = '1') then
			forced_link_fail <= false;
		elsif rising_edge( clock ) then
			if Error_inject then
				case Error_select is
					when force_link_fail => 
						forced_link_fail <= true;
						
					when unforce_link_fail => 	
						forced_link_fail <= false;
						
					when others  => 
						null;
				end case;
			end if;
		end if;
    end process p_link_fail;
	----------------------------------------------------------------------------------------------------------------------------
	-- Asynchronous Processes --
	----------------------------------------------------------------------------------------------------------------------------


end rtl;