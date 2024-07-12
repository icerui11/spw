----------------------------------------------------------------------------------------------------------------------------------
-- File Description  --
----------------------------------------------------------------------------------------------------------------------------------
-- @ File Name				:	spw_wrap_top_level_std.vhd
-- @ Engineer				:	James E Logan
-- @ Role					:	FPGA Engineer
-- @ Company				:	4Links ltd
-- @ Date					: 	dd/mm/yyyy

-- @ VHDL Version			:   2008
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
context work.rmap_context;
use work.all;
----------------------------------------------------------------------------------------------------------------------------------
-- Entity Declarations --
----------------------------------------------------------------------------------------------------------------------------------
entity spw_wrap_top_level_std is
	generic(
		g_clock_frequency   : real := 125000000.0;			-- clock frequency for SpaceWire IP (>2MHz)
		g_rx_fifo_size      : integer range 1 to 56 := 16; 	-- must be >8
		g_tx_fifo_size      : integer range 1 to 56 := 16; 	-- must be >8
		g_mode				: string := "diff"				-- valid options are "diff", "single" and "custom".
	);
	port( 
		clock                : in    std_logic := '0';
		clock_b              : in    std_logic := '0';
		reset                : in    std_logic := '0';
	
		-- Channels
		Tx_data              : in    	t_nonet;
		Tx_OR                : in    	std_logic := '0';
		Tx_IR                : out 		std_logic := '0';
		
		Rx_data              : out 		t_nonet;
		Rx_OR                : out 		std_logic := '0';
		Rx_IR                : in    	std_logic := '0';
		
		Rx_ESC_ESC           : out 		std_logic := '0';
		Rx_ESC_EOP           : out 		std_logic := '0';
		Rx_ESC_EEP           : out 		std_logic := '0';
		Rx_Parity_error      : out 		std_logic := '0';
		Rx_bits              : out 		std_logic_vector(1 downto 0) := (others => '0');--integer range 0 to 2;
		Rx_rate              : out 		std_logic_vector(15 downto 0) := (others => '0');
		
		Rx_Time              : out 		t_byte;
		Rx_Time_OR           : out 		std_logic := '0';
		Rx_Time_IR           : in    	std_logic := '0';
		
		Tx_Time              : in    	t_byte;
		Tx_Time_OR           : in    	std_logic := '0';
		Tx_Time_IR           : out 		std_logic := '0';
		
		-- prescalar load interface
		Tx_PSC					: in 	t_byte := (others => '0');
        Tx_PSC_valid			: in 	std_logic := '0';
		Tx_PSC_ready			: out 	std_logic := '0';
		
		-- Control	
		Disable              : in    	std_logic := '0';
		Connected            : out 		std_logic := '0';
		Error_select         : in    	std_logic_vector(3 downto 0) := (others => '0');
		Error_inject         : in    	std_logic := '0';
		
		-- DDR/SDR IO, only when "custom" mode is used
		-- when instantiating, if not used, you can ignore these ports. 
		DDR_din_r			: in 	std_logic := '0';
		DDR_din_f           : in 	std_logic := '0';
		DDR_sin_r           : in 	std_logic := '0';
		DDR_sin_f           : in 	std_logic := '0';
		SDR_Dout			: out 	std_logic := '0';
		SDR_Sout			: out 	std_logic := '0';
		
		-- SpW	
		Din_p                : in    	std_logic := '0';
		Din_n                : in    	std_logic := '0';
		Sin_p                : in    	std_logic := '0';
		Sin_n                : in    	std_logic := '0';
		Dout_p               : out 		std_logic := '0';
		Dout_n               : out 		std_logic := '0';
		Sout_p               : out 		std_logic := '0';
		Sout_n               : out 		std_logic := '0'
	);
end spw_wrap_top_level_std;


---------------------------------------------------------------------------------------------------------------------------------
-- Code Description & Developer Notes --
---------------------------------------------------------------------------------------------------------------------------------


architecture rtl of spw_wrap_top_level_std is

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
	
	signal din                   : std_logic := '0';
	signal sin                   : std_logic := '0';
	signal dout                  : std_logic := '0';
	signal sout                  : std_logic := '0';
	
	signal i_doutp               : std_logic := '0';
	signal i_doutn               : std_logic := '0';
	signal i_soutp               : std_logic := '0';
	signal i_soutn               : std_logic := '0';
	signal dout_b                : std_logic := '0';
	signal sout_b                : std_logic := '0';
	
	signal din_r                 : std_logic := '0';
	signal din_f                 : std_logic := '0';
	signal sin_r                 : std_logic := '0';
	signal sin_f                 : std_logic := '0';
	
	signal timetagged_timecode   : long;
	
	signal link_disable          : boolean;
	signal forced_link_fail      : boolean;
	
	signal  Rx_bits_int			: 	integer range 0 to 2 := 0;
	signal 	Rx_ESC_ESC_bool  		:	boolean;  
	signal 	Rx_ESC_EOP_bool         :	boolean;
	signal 	Rx_ESC_EEP_bool         :	boolean;
	signal 	Rx_Parity_error_bool    :	boolean;
	
	signal 	Rx_Time_OR_bool  	:	boolean;
	signal 	Tx_Time_IR_bool  	:	boolean;
	signal 	Connected_bool		:	boolean;
	
	signal Tx_IR_bool          : boolean;
	signal Rx_OR_bool          : boolean;
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
		Error_inject    => to_bool(Error_inject),
		Force_timeout_error   => false,       
		-- Status
		Out_Stalled     => open,
		Connected       => Connected_bool,
		
		-- SpW DS	Interface			  
		RxD_r           => din_r,
		RxD_f           => din_f,
		RxS_r           => sin_r,
		RxS_f           => sin_f,
		TxD             => dout,
		TxS             => sout,
		
		-- Received Data Out
		Rx_data         => Rx_data,
		Rx_Data_OR      => Rx_OR_bool,
		Rx_Data_IR      => to_bool(Rx_IR),
		
		Rx_ESC_ESC      => Rx_ESC_ESC_bool,      
		Rx_ESC_EOP      => Rx_ESC_EOP_bool,      
		Rx_ESC_EEP      => Rx_ESC_EEP_bool,      
		Rx_Parity_error => Rx_Parity_error_bool, 
		Rx_bits         => Rx_bits_int,         
		Rx_rate         => Rx_rate,         
                           
		-- Time            
		Rx_Time         => Rx_Time,         
		Rx_Time_OR      => Rx_Time_OR_bool,      
		Rx_Time_IR      => to_bool(Rx_Time_IR),     
		                   
		Tx_Time         => Tx_Time,         
		Tx_Time_OR      => to_bool(Tx_Time_OR),     
		Tx_Time_IR      => Tx_Time_IR_bool,     

		-- prescalar load interface
		Tx_PSC			=> Tx_PSC,			
        Tx_PSC_valid	=> Tx_PSC_valid,
		Tx_PSC_ready	=> Tx_PSC_ready,			
		
		-- Transmit Data In               
		Tx_data         => Tx_data,
		Tx_Data_OR      => to_bool(Tx_OR),
		Tx_Data_IR      => Tx_IR_bool
		
		
    );
	----------------------------------------------------------------------------------------------------------------------------
	-- Component Instantiations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Asynchronous Signal Assignments --
	----------------------------------------------------------------------------------------------------------------------------
	Rx_ESC_ESC		<= to_std(Rx_ESC_ESC_bool);  	     
	Rx_ESC_EOP      <= to_std(Rx_ESC_EOP_bool);      
	Rx_ESC_EEP      <= to_std(Rx_ESC_EEP_bool);      
	Rx_Parity_error <= to_std(Rx_Parity_error_bool); 
	
	
	Rx_Time_OR	<= to_std( Rx_Time_OR_bool 	);
	Tx_Time_IR  <= to_std( Tx_Time_IR_bool 	);
	Connected   <= to_std( Connected_bool	);
	
	Rx_OR <= to_std(Rx_OR_bool);
	Tx_IR <= to_std(Tx_IR_bool);

	Rx_bits <= std_logic_vector(to_unsigned(Rx_bits_int, Rx_bits'length));

	link_disable <= to_bool(Disable) or forced_link_fail;
	-- Link Auto Start when True
	legacy             <= False;
	----------------------------------------------------------------------------------------------------------------------------
	-- Synchronous Processes --
	----------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	-- Technology specific instantiation for DE Signals 
	-------------------------------------------------------------------------------
	g_mode_select: if(g_mode = "diff") generate	-- generate for differential signaling 
	----------------------------------------------------------------------------------	
	-- Modify this section to use technology specific primitives 					-- 
	----------------------------------------------------------------------------------
		dout_b <= not dout;
		sout_b <= not sout;
		
		-- Use LVDS input buffers
		Dout_p <= i_doutp;
		Dout_n <= i_doutn;
		Sout_p <= i_soutp;
		Sout_n <= i_soutn;

		p_iddr_model: process(reset, clock)
		begin
			if reset = '1' then
				din_r <= '0';
				sin_r <= '0';
			elsif rising_edge(clock) then
				din_r <= Din_p and not Din_n;
				sin_r <= Sin_p and not Sin_n;
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

	elsif(g_mode = "single") generate	-- single-ended most 
	----------------------------------------------------------------------------------	
	-- Modify this section to use technology specific primitives 					-- 
	----------------------------------------------------------------------------------
		-- Use TTL input buffers
		Dout_p <= i_doutp;
		Sout_p <= i_soutp;
		-- DDR Register input model
		p_iddr_model: process(reset, clock/* clock_b*/)
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
				i_doutp <= '0';
				i_soutp <= '0';
			elsif rising_edge(clock)  then
				i_doutp <= dout;
				i_soutp <= sout;
			end if;
		end process p_osdr_model;
	
	elsif(g_mode = "custom") generate		-- custom bypass for use with Block diagram DDR Primitives 
	-- use custom if you are including primitves outside of this architecture --
	-- do not modify this section --
		din_r		<= DDR_din_r;
		din_f   	<= DDR_din_f;
		sin_r   	<= DDR_sin_r;
		sin_f   	<= DDR_sin_f;
		SDR_Dout 	<= dout;
		SDR_Sout 	<= sout;

	else generate 		-- default generate behaviour is standard differential IO modelling. 				
		dout_b <= not dout;
		sout_b <= not sout;
		
		-- Use LVDS input buffers
		Dout_p <= i_doutp;
		Dout_n <= i_doutn;
		Sout_p <= i_soutp;
		Sout_n <= i_soutn;

		p_iddr_model: process(reset, clock/* clock_b*/)
		begin
			if reset = '1' then
				din_r <= '0';
				sin_r <= '0';
			elsif rising_edge(clock) then
				din_r <= Din_p and not Din_n;
				sin_r <= Sin_p and not Sin_n;
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