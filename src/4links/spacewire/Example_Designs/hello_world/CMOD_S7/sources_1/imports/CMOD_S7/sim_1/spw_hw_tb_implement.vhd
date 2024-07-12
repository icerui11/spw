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

library UNISIM;
use UNISIM.Vcomponents.all;


----------------------------------------------------------------------------------------------------------------------------------
-- Entity Declarations --
----------------------------------------------------------------------------------------------------------------------------------
entity spw_hw_tb is
    constant c_spw_clk_freq			: real := 100_000_000.0;
    constant c_sys_clk_freq			: real := 300_000_000.0;

    constant c_spw_clk_period		: time := (1_000_000_000.0/c_spw_clk_freq) * 1 ns;
    constant c_sys_clk_period		: time := (1_000_000_000.0/c_sys_clk_freq) * 1 ns;

    constant c_clk_num				: natural := 1_000_000_000;
end spw_hw_tb;

architecture implement of spw_hw_tb is 
	
	
	signal sys_clk_p	: std_logic := '0';
	signal sys_clk_n	: std_logic := '1';
	signal rst_in		: std_logic := '1';
	
	signal spw_Din_p 	: std_logic := '0';
	signal spw_Din_n    : std_logic := '1';
	signal spw_Sin_p    : std_logic := '0';
	signal spw_Sin_n    : std_logic := '1';


	signal spw_Dout_p   : std_logic := '0';
	signal spw_Dout_n   : std_logic := '1';
	signal spw_Sout_p   : std_logic := '0';
	signal spw_Sout_n   : std_logic := '1';

	signal spw_error	: std_logic := '0';
	

begin

	u_hw_wrap_tx: entity spw_hello_world_wrapper
	port map( 
	
		-- standard register control signals --
		mmcm_clk_in1_p 	=> sys_clk_p,										-- clock_in (p) 	-- 300MHz
		mmcm_clk_in1_n	=> sys_clk_n,										-- clock_out (n) 	-- 300MHz
		rst_in			=> rst_in,											-- reset input, active high
		
		-- SpW Rx IO
		spw_Din_p 		=>	spw_Din_p 	,	
		spw_Din_n       =>  spw_Din_n   , 
		spw_Sin_p       =>  spw_Sin_p   , 
		spw_Sin_n       =>  spw_Sin_n   , 
	
		-- SpW Tx IO                    
		spw_Dout_p      =>  spw_Dout_p  , 
		spw_Dout_n      =>  spw_Dout_n  , 
		spw_Sout_p      =>  spw_Sout_p  , 
		spw_Sout_n      =>  spw_Sout_n  , 

		spw_error		=>  spw_error		
    );
	
	u_hw_wrap_rx: entity spw_hello_world_wrapper
	port map( 
	
		-- standard register control signals --
		mmcm_clk_in1_p 	=> sys_clk_p,										-- clock_in (p) 	-- 300MHz
		mmcm_clk_in1_n	=> sys_clk_n,										-- clock_out (n) 	-- 300MHz
		rst_in			=> rst_in,										-- reset input, active high
		
		-- SpW Rx IO
		spw_Din_p 		=>	spw_Dout_p 	,	
		spw_Din_n       =>  spw_Dout_n   , 
		spw_Sin_p       =>  spw_Sout_p   , 
		spw_Sin_n       =>  spw_Sout_n   , 
	
		-- SpW Tx IO                    
		spw_Dout_p      =>  spw_Din_p   , 
		spw_Dout_n      =>  spw_Din_n   , 
		spw_Sout_p      =>  spw_Sin_p   , 
		spw_Sout_n      =>  spw_Sin_n   , 

		spw_error		=>  open		
    );
	
	
	p_sys_clk_gen: process		-- generate positive system clock
	begin
		clock_gen(sys_clk_p, c_clk_num, c_sys_clk_period);
	end process;
	
	n_sys_clk_gen: process		-- generate negative system clock 
	begin
		clock_gen(sys_clk_n, c_clk_num, c_sys_clk_period);
	end process;
	
	stim_gen: process
	begin
		report "starting stimulus @ : " & to_string(now) severity note;
		rst_in <= '1';
		report "waiting for MMCM output LOCKED : " & to_string(now) severity note;
		report "MMCM output LOCKED @ : " & to_string(now) severity note;
		wait for 1.245 us;
		report "de-asserting reset @ : " & to_string(now) severity note;
		rst_in <= '0';
		wait for c_spw_clk_period;

		wait for 100.56 us;
		report "stim finished @ : " & to_string(now) severity failure;			-- stimulus finished, stop simulation. 
		wait;
	end process;
	
	
	
	
end implement;