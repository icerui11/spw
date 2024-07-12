----------------------------------------------------------------------------------------------------------------------------------
-- File Description  --
----------------------------------------------------------------------------------------------------------------------------------
-- @ File Name				:	spw_wrap_top_level_proASIC_3.vhd
-- @ Engineer				:	James E Logan
-- @ Role					:	FPGA Engineer
-- @ Company				:	4Links ltd
-- @ Date					: 	dd/mm/yyyy

-- @ VHDL Version			:   2008
-- @ Supported Toolchain	:	Xilinx Vivado IDE
-- @ Target Device			: 	Xilinx US+ Family

-- @ Revision #				:	1

-- File Description         : 	top-level wrapper file for 4Links SpaceWire Codec IP on MicroSemi ProASIC3 devices

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

-- Library For ProAsic_3 technology specific Primitives
library proasic3; 
use proasic3.all;
----------------------------------------------------------------------------------------------------------------------------------
-- Package Declarations --
----------------------------------------------------------------------------------------------------------------------------------
context work.spw_context;
use work.all;

----------------------------------------------------------------------------------------------------------------------------------
-- Entity Declarations --
----------------------------------------------------------------------------------------------------------------------------------
entity spw_wrap_top_level_proASIC_3 is
	generic(
		g_clock_frequency   : real := 125_000_000.0;			-- clock frequency for SpaceWire IP (>2MHz)
		g_rx_fifo_size      : integer range 1 to 56 := 16; 	-- must be >8
		g_tx_fifo_size      : integer range 1 to 56 := 16; 	-- must be >8
		g_mode				: string := "single"			-- valid options are "diff", "single" and "custom"
	);
	port( 
		clock               : in    std_logic;
		clock_b             : in    std_logic;
		reset               : in    std_logic;
	
		-- Channels
		Tx_data             : in    	nonet;
		Tx_OR               : in    	boolean;
		Tx_IR               : out 		boolean;
		
		Rx_data             : out 		nonet;
		Rx_OR               : out 		boolean;
		Rx_IR               : in    	boolean;
		
		Rx_ESC_ESC          : out 		boolean;
		Rx_ESC_EOP          : out 		boolean;
		Rx_ESC_EEP          : out 		boolean;
		Rx_Parity_error     : out 		boolean;
		Rx_bits             : out 		integer range 0 to 2;
		Rx_rate             : out 		std_logic_vector(15 downto 0);
		
		Rx_Time             : out 		octet;
		Rx_Time_OR          : out 		boolean;
		Rx_Time_IR          : in    	boolean;
		
		Tx_Time             : in    	octet;
		Tx_Time_OR          : in    	boolean;
		Tx_Time_IR          : out 		boolean;
		
		-- Control	
		Disable             : in    	boolean;
		Connected           : out 		boolean;
		Error_select        : in    	std_logic_vector(3 downto 0);
		Error_inject        : in    	boolean;
		
		-- DDR/SDR IO, only when "custom" mode is used
		-- when instantiating, if not used, you can ignore these ports. 
		DDR_din_r			: in 		std_logic := '0';
		DDR_din_f           : in 		std_logic := '0';
		DDR_sin_r           : in 		std_logic := '0';
		DDR_sin_f           : in 		std_logic := '0';
		SDR_Dout			: out 		std_logic := '0';
		SDR_Sout			: out 		std_logic := '0';
		
		-- SpW	_p signals used for single-ended mode 
		Din_p               : in    	std_logic := '0';
		Din_n               : in    	std_logic := '0';
		Sin_p               : in    	std_logic := '0';
		Sin_n               : in    	std_logic := '0';
		Dout_p              : out 		std_logic := '0';
		Dout_n              : out 		std_logic := '0';
		Sout_p              : out 		std_logic := '0';
		Sout_n              : out 		std_logic := '0'
	);
end spw_wrap_top_level_proASIC_3;


---------------------------------------------------------------------------------------------------------------------------------
-- Code Description & Developer Notes --
---------------------------------------------------------------------------------------------------------------------------------


architecture rtl of spw_wrap_top_level_proASIC_3 is

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
	-- Component Declarations for ProASIC3 Primitives -------------------
	-- instantiate DDR registers -- 
	component DDR_REG
	port(
		D	: in  std_logic := 'U';  
		CLK	: in  std_logic := 'U'; 
		CLR : in  std_logic := 'U'; 
		QR	: out std_logic := 'U'; 
		QF  : out std_logic := 'U'
	);
	end component;
	
	-- 3.3V LVCMOS IO Buffers (change as required) for single-ended
	component INBUF_LVCMOS33
	port(
		PAD : in 	std_logic := 'U';
		Y 	: out 	std_logic := 'U'
	);
	end component;
	
	component OUTBUF_LVCMOS33
	port(
		D 	: in 	std_logic := 'U';
		PAD : out 	std_logic := 'U'
	);
	end component;
	
	-- Differential IO Buffers (Differential Mode)
	component INBUF_LVDS
	port(
		PADP	: in 	std_logic;
		PADN	: in 	std_logic;
		Y 		: out 	std_logic
	);
	end component;
	
	component OUTBUF_LVDS
	port(
		D		: in  std_logic;
		PADP	: out std_logic;
		PADN	: out std_logic	
	);
	end component;
	
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Signal Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	signal legacy                : boolean;
	
	signal Din                   : std_logic;
	signal Sin                   : std_logic;
	signal Dout                  : std_logic;
	signal Sout                  : std_logic;
	
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
	u_spw: entity work.spw
    generic map(
		CLOCK_FREQUENCY      => g_clock_frequency,
		RX_FIFO_SIZE         => g_rx_fifo_size,
		TX_FIFO_SIZE         => g_tx_fifo_size
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
		TxD             => Dout,
		TxS             => Sout,
		
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

	link_disable <= Disable or forced_link_fail;
	-- Link Auto Start when True
	legacy             <= False;
	----------------------------------------------------------------------------------------------------------------------------
	-- Synchronous Processes --
	----------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	-- Technology specific instantiation for DE Signals 
	-------------------------------------------------------------------------------
	g_mode_select: if(g_mode = "diff") generate
	----------------------------------------------------------------------------------	
	-- Modify this section to use technology specific primitives 					-- 
	----------------------------------------------------------------------------------
		
		-- LVDS Input Buffers 
		u_Din_LVDS : INBUF_LVDS
		port map(
			PADP	=> Din_p,
			PADN	=> Din_n, 
			Y 		=> Din
		);
		
		u_Sin_LVDS : INBUF_LVDS
		port map(
			PADP	=> Sin_p,
			PADN	=> Sin_n, 
			Y 		=> Sin
		);
	
		-- DDR Register inputs for proasic3
		u_Din_iDDR: DDR_REG
		port map(
			D	=> Din,
			CLK	=> clock,
			CLR => reset,
			QR	=> din_r,
			QF  => din_f
		);
		
		u_Sin_iDDR: DDR_REG
		port map(
			D	=> Sin,
			CLK	=> clock,
			CLR => reset,
			QR	=> sin_r,
			QF  => sin_f
		);
		
		-- LVDS Output Buffers 
		u_Dout_LVDS : OUTBUF_LVDS
		port map(
			D 		=> Dout,
			PADP 	=> Dout_p,
			PADN 	=> Dout_n
		);
		
		u_Sout_LVDS : OUTBUF_LVDS
		port map(
			D 		=> Sout,
			PADP 	=> Sout_p,
			PADN 	=> Sout_n
		);
	
	elsif(g_mode = "single") generate	-- generate for single-ended signaling 
	----------------------------------------------------------------------------------	
	-- Modify this section to use technology specific primitives 					-- 
	----------------------------------------------------------------------------------
	
		u_Din_buf: INBUF_LVCMOS33
		port map(
			PAD => Din_p,
			Y  	=> Din	
		);
		
		u_Sin_buf: INBUF_LVCMOS33
		port map(
			PAD => Sin_p,
			Y  	=> Sin	
		);
		
		u_Dout_buf: OUTBUF_LVCMOS33
		port map(
			D   => Dout,
			PAD => Dout_p
		);
		
		u_Sout_buf: OUTBUF_LVCMOS33
		port map(
			D   => Sout,
			PAD => Sout_p
		);
		
		-- DDR Register inputs for proasic3
		u_Din_iDDR: DDR_REG
		port map(
			D	=> Din,
			CLK	=> clock,
			CLR => reset,
			QR	=> din_r,
			QF  => din_f
		);
		
		u_Sin_iDDR: DDR_REG
		port map(
			D	=> Sin,
			CLK	=> clock,
			CLR => reset,
			QR	=> sin_r,
			QF  => sin_f
		);
		
	elsif(g_mode = "custom") generate		-- custom bypass for use with Block diagram DDR Primitives 
	-- use custom if you are including primitves outside of this architecture --
	-- do not modify this section --
		din_r		<= DDR_din_r;
		din_f   	<= DDR_din_f;
		sin_r   	<= DDR_sin_r;
		sin_f   	<= DDR_sin_f;
		SDR_Dout 	<= dout;
		SDR_Sout 	<= sout;

	else generate 					-- default to single-ended IO Mode using process models 

		p_iddr_model: process(reset, clock)
		begin
			if reset = '1' then
				din_r <= '0';
				sin_r <= '0';
			elsif rising_edge(clock) then
				din_r <= Din_p;
				sin_r <= Sin_p;
			end if ;
		end process p_iddr_model;
		
		n_iddr_model: process(reset, clock_b)
		begin
			if(reset = '1') then
				din_f <= '0';
				sin_f <= '0';
			elsif(rising_edge(clock_b)) then
				din_f <= Din_p;
				sin_f <= Sin_p;
			end if;
		end process n_iddr_model;
		
		-- SDR Register output model
		p_osdr_model: process(clock, reset)
		begin
			if (reset = '1') then
				Dout_p <= '0';
				Sout_p <= '0';
			elsif rising_edge(clock)  then
				Dout_p <= dout;
				Sout_p <= sout;
			end if;
		end process p_osdr_model;
	end generate g_mode_select;
	
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