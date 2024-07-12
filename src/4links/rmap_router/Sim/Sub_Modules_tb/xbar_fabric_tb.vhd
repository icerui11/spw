----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.08.2023 19:45:58
-- Design Name: 
-- Module Name: xbar_fabric_tb - bench
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

context work.router_context;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity xbar_fabric_tb is
--  Port ( );
end xbar_fabric_tb;

architecture bench of xbar_fabric_tb is

    constant clk_period 	: 	time := 10 ns;
  
	signal	clk_in			:  	std_logic := '0';		-- clk input, rising edge trigger
	signal 	rst_in			: 	std_logic := '0';
	signal 	enable			: 	std_logic := '0';
	
--	signal	target_addr_32	:  	t_ports_array(0 to 31)	:= (others => (others => '0'));
--	signal	addr_valid		:  	std_logic 				:= '0';
--	signal	addr_ready		:  	std_logic 				:= '0';
--	
--	signal	tar_port_ready	:  	t_ports 				:= (others => '0');
--	signal	req_port_valid  :  	t_ports 				:= (others => '0');
--	signal	req_port_data	:  	t_nonet_array(0 to 31)	:= (others => (others => '0'));
--
--	signal	req_port_ready	: 	t_ports 				:= (others => '0');
--	signal	tar_port_valid  :  	t_ports 				:= (others => '0');
--	signal	tar_port_data	:  	t_nonet_array(0 to 31)	:= (others => (others => '0'));
	impure function port_byte_gen return t_byte_array is
	    variable port_buf : t_byte_array(0 to c_num_ports -1);
		variable port_bits : unsigned(7 downto 0) := (others => '0');
	begin
		for i in 0 to c_num_ports-1 loop
			port_bits := to_unsigned(i, port_bits'length);
			port_buf(i) := std_logic_vector(port_bits);
		end loop;
		return port_buf;
	end function port_byte_gen;
	
	impure function req_port_data_gen return t_nonet_array is
		variable data_buf : t_nonet_array(0 to c_num_ports-1);
	begin
		for i in 0 to c_num_ports-1 loop
			data_buf(i) := std_logic_vector(to_unsigned((255-i), 9));
		end loop;
		return data_buf;
	end function req_port_data_gen;
	
	
	signal	addr_byte_in		:  	t_byte_array(0 to c_num_ports-1) 	:= (others => (others => '0'));
	signal	addr_byte_valid		:  	t_ports 							:= (others => '0');	-- req in 
	signal	addr_byte_ready		:  	t_ports 							:= (others => '0'); -- grant out 
	signal	mem_wr				:  	std_logic 							:= '0';	
	signal	mem_wr_addr  		:  	t_byte								:= (others => '0');
	signal	mem_wr_data  		:  	t_dword 							:= (others => '0');
	signal	tar_port_ready		:  	t_ports 							:= (others => '0');
	signal	req_port_valid  	:  	t_ports 							:= (others => '0');
	signal	req_port_data		:  	t_nonet_array(0 to c_num_ports-1)	:=  req_port_data_gen;--(others => (others => '0'));
	signal	req_port_ready		:  	t_ports 							:= (others => '0');
	signal	tar_port_valid  	:  	t_ports 							:= (others => '0');
	signal	tar_port_data		:  	t_nonet_array(0 to c_num_ports-1)	:= (others => (others => '0'));
	signal	req_active			:  	t_ports		 						:= (others => '1');


begin

    clk_gen: process
    begin
        clk_in <= '1';
        wait for clk_period/2;
        clk_in <= '0';
        wait for clk_period/2;
    end process;
    
    stim_gen :process
    begin
		rst_in <= '1';
		enable <= '1';
		mem_wr <= '0';
        wait for 102.3 ns;
		rst_in <= '0';
		req_port_valid <= (others => '1');
		addr_byte_in <= port_byte_gen;
		wait for 10.6 ns;
		for i in 0 to 31 loop
		  addr_byte_valid(i) <= '1';
		  if(addr_byte_ready(i) = '0') then
		      wait until addr_byte_ready(i) = '1';
		  end if;
		  wait for clk_period;
		  addr_byte_valid(i) <= '0';
		end loop;
		wait for clk_period;
		wait for 142.6 ns;
		req_active(3 downto 0) <= (others => '0');
		wait for clk_period*2;
		--req_activereq_active(3 downto 0)
		
		wait for 10.134 us;
		report "stim finished @ :" & to_string(now) severity failure;
    end process;
    
    reply_gen:for i in 0 to c_num_ports-1 generate
        process(tar_port_valid)
        begin
            if(tar_port_valid(i) = '1') then
                tar_port_ready(i) <= '1';
            else
                tar_port_ready(i) <= '0';
            end if;
        end process;
    
    end generate reply_gen;
	
	router_inst:entity work.router_top_level(rtl)
    generic map(
        g_num_ports => c_num_ports
    )
	port map( 
	
		-- standard register control signals --
		clk_in				=> clk_in,
		rst_in				=> rst_in,
		enable  			=> enable,
		
		addr_byte_in		=> addr_byte_in,		
		addr_byte_valid		=> addr_byte_valid,		
		addr_byte_ready		=> addr_byte_ready,		

		mem_wr				=> mem_wr,				
		mem_wr_addr  		=> mem_wr_addr,  		
		mem_wr_data  		=> mem_wr_data,  		

		tar_port_ready		=> tar_port_ready,		
		req_port_valid  	=> req_port_valid,  	
		req_port_data		=> req_port_data,		

		req_port_ready		=> req_port_ready,		
		tar_port_valid  	=> tar_port_valid,  	
		tar_port_data		=> tar_port_data,		
	
		req_active			=> req_active			
		
    );


 /* 
	-- uncomment for Behaviour Simulation
	fabric :entity work.router_xbar_switch_fabric(rtl)
	port map( 
		
		-- standard register control signals --
		clk_in			=> clk_in,

		target_addr_32	=> target_addr_32,
		addr_valid		=> addr_valid,
		addr_ready		=> addr_ready,
		
		tar_port_ready  => tar_port_ready,
		req_port_valid  => req_port_valid,
		req_port_data	=> req_port_data,

		req_port_ready	=> req_port_ready,
		tar_port_valid  => tar_port_valid,
		tar_port_data	=> tar_port_data
    );
	*/
/*	
	-- uncomment for post-synthesis Simulation 
	fabric_synth:entity work.router_xbar_switch_fabric(STRUCTURE)
	port map (
		clk_in					=> clk_in,
		\target_addr_32[0]\ 	=> target_addr_32(0),
		\target_addr_32[1]\ 	=> target_addr_32(1),
		\target_addr_32[2]\ 	=> target_addr_32(2),
		\target_addr_32[3]\ 	=> target_addr_32(3),
		\target_addr_32[4]\ 	=> target_addr_32(4),
		\target_addr_32[5]\ 	=> target_addr_32(5),
		\target_addr_32[6]\ 	=> target_addr_32(6),
		\target_addr_32[7]\ 	=> target_addr_32(7),
		\target_addr_32[8]\ 	=> target_addr_32(8),
		\target_addr_32[9]\ 	=> target_addr_32(9),
		\target_addr_32[10]\ 	=> target_addr_32(10),
		\target_addr_32[11]\ 	=> target_addr_32(11),
		\target_addr_32[12]\ 	=> target_addr_32(12),
		\target_addr_32[13]\ 	=> target_addr_32(13),
		\target_addr_32[14]\ 	=> target_addr_32(14),
		\target_addr_32[15]\ 	=> target_addr_32(15),
		\target_addr_32[16]\ 	=> target_addr_32(16),
		\target_addr_32[17]\ 	=> target_addr_32(17),
		\target_addr_32[18]\ 	=> target_addr_32(18),
		\target_addr_32[19]\ 	=> target_addr_32(19),
		\target_addr_32[20]\ 	=> target_addr_32(20),
		\target_addr_32[21]\ 	=> target_addr_32(21),
		\target_addr_32[22]\ 	=> target_addr_32(22),
		\target_addr_32[23]\ 	=> target_addr_32(23),
		\target_addr_32[24]\ 	=> target_addr_32(24),
		\target_addr_32[25]\ 	=> target_addr_32(25),
		\target_addr_32[26]\ 	=> target_addr_32(26),
		\target_addr_32[27]\ 	=> target_addr_32(27),
		\target_addr_32[28]\ 	=> target_addr_32(28),
		\target_addr_32[29]\ 	=> target_addr_32(29),
		\target_addr_32[30]\ 	=> target_addr_32(30),
		\target_addr_32[31]\ 	=> target_addr_32(31),
		addr_valid 				=> addr_valid,
		addr_ready				=> addr_ready,
		req_port_valid 			=> req_port_valid,
		req_port_ready			=> req_port_ready,
		\req_port_data[0]\ 	=> req_port_data(0),
		\req_port_data[1]\ 	=> req_port_data(1),
		\req_port_data[2]\ 	=> req_port_data(2),
		\req_port_data[3]\ 	=> req_port_data(3),
		\req_port_data[4]\ 	=> req_port_data(4),
		\req_port_data[5]\ 	=> req_port_data(5),
		\req_port_data[6]\ 	=> req_port_data(6),
		\req_port_data[7]\ 	=> req_port_data(7),
		\req_port_data[8]\ 	=> req_port_data(8),
		\req_port_data[9]\ 	=> req_port_data(9),
		\req_port_data[10]\ => req_port_data(10),
		\req_port_data[11]\ => req_port_data(11),
		\req_port_data[12]\ => req_port_data(12),
		\req_port_data[13]\ => req_port_data(13),
		\req_port_data[14]\ => req_port_data(14),
		\req_port_data[15]\ => req_port_data(15),
		\req_port_data[16]\ => req_port_data(16),
		\req_port_data[17]\ => req_port_data(17),
		\req_port_data[18]\ => req_port_data(18),
		\req_port_data[19]\ => req_port_data(19),
		\req_port_data[20]\ => req_port_data(20),
		\req_port_data[21]\ => req_port_data(21),
		\req_port_data[22]\ => req_port_data(22),
		\req_port_data[23]\ => req_port_data(23),
		\req_port_data[24]\ => req_port_data(24),
		\req_port_data[25]\ => req_port_data(25),
		\req_port_data[26]\ => req_port_data(26),
		\req_port_data[27]\ => req_port_data(27),
		\req_port_data[28]\ => req_port_data(28),
		\req_port_data[29]\ => req_port_data(29),
		\req_port_data[30]\ => req_port_data(30),
		\req_port_data[31]\ => req_port_data(31),
		tar_port_valid 		=> tar_port_valid,
		tar_port_ready		=> tar_port_ready,
		\tar_port_data[0]\ 	=> tar_port_data(0),
		\tar_port_data[1]\ 	=> tar_port_data(1),
		\tar_port_data[2]\ 	=> tar_port_data(2),
		\tar_port_data[3]\ 	=> tar_port_data(3),
		\tar_port_data[4]\ 	=> tar_port_data(4),
		\tar_port_data[5]\ 	=> tar_port_data(5),
		\tar_port_data[6]\ 	=> tar_port_data(6),
		\tar_port_data[7]\ 	=> tar_port_data(7),
		\tar_port_data[8]\ 	=> tar_port_data(8),
		\tar_port_data[9]\ 	=> tar_port_data(9),
		\tar_port_data[10]\ => tar_port_data(10),
		\tar_port_data[11]\ => tar_port_data(11),
		\tar_port_data[12]\ => tar_port_data(12),
		\tar_port_data[13]\ => tar_port_data(13),
		\tar_port_data[14]\ => tar_port_data(14),
		\tar_port_data[15]\ => tar_port_data(15),
		\tar_port_data[16]\ => tar_port_data(16),
		\tar_port_data[17]\ => tar_port_data(17),
		\tar_port_data[18]\ => tar_port_data(18),
		\tar_port_data[19]\ => tar_port_data(19),
		\tar_port_data[20]\ => tar_port_data(20),
		\tar_port_data[21]\ => tar_port_data(21),
		\tar_port_data[22]\ => tar_port_data(22),
		\tar_port_data[23]\ => tar_port_data(23),
		\tar_port_data[24]\ => tar_port_data(24),
		\tar_port_data[25]\ => tar_port_data(25),
		\tar_port_data[26]\ => tar_port_data(26),
		\tar_port_data[27]\ => tar_port_data(27),
		\tar_port_data[28]\ => tar_port_data(28),
		\tar_port_data[29]\ => tar_port_data(29),
		\tar_port_data[30]\ => tar_port_data(30),
		\tar_port_data[31]\ => tar_port_data(31)
	);
	
*/

end bench;
