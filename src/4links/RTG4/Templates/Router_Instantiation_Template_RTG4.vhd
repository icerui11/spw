
/*
	This file contains and instantiation template for the RTG4 SpaceWire Router. 
	This code is non synthesizable and should be used as a guideline for instantiating 
	the router within your own RTL design. 
	
	The signals listed as "port" are physical IO pins which should be in your top-level port list. 
	The syntax you see below is NOT a valid way of declaring ports within your design. 
	

*/
	-- add the context clause to pull in required packages/libs
	context work.router_context;

	-- signals/ports required for instantiation. 
	signal	router_clk		: 		std_logic := '0';		-- router clock input 
	signal	rst_in			: 		std_logic := '0';		-- reset input, active high	
	
	-- these are your external ports to IO pins. 
	port	Din_p  			: in	std_logic_vector(1 to c_num_ports-1)	:= (others => '0');	-- IO used for "single" and "diff" io modes
	port	Din_n           : in	std_logic_vector(1 to c_num_ports-1)	:= (others => '0'); -- IO used for "single" and "diff" io modes
	port	Sin_p           : in	std_logic_vector(1 to c_num_ports-1)	:= (others => '0'); -- IO used for "single" and "diff" io modes
	port	Sin_n           : in	std_logic_vector(1 to c_num_ports-1)	:= (others => '0'); -- IO used for "single" and "diff" io modes
	port	Dout_p          : out	std_logic_vector(1 to c_num_ports-1)	:= (others => '0'); -- IO used for "single" and "diff" io modes
	port	Dout_n          : out	std_logic_vector(1 to c_num_ports-1)	:= (others => '0'); -- IO used for "single" and "diff" io modes
	port	Sout_p          : out	std_logic_vector(1 to c_num_ports-1)	:= (others => '0'); -- IO used for "single" and "diff" io modes
	port	Sout_n          : out	std_logic_vector(1 to c_num_ports-1)	:= (others => '0'); -- IO used for "single" and "diff" io modes
	
	signal	spw_fifo_in		:	r_fifo_master_array(1 to c_num_ports-1) := (others => c_fifo_master);
	signal	spw_fifo_out	: 	r_fifo_slave_array(1 to c_num_ports-1)	:= (others => c_fifo_slave);
	signal	Port_Connected	: 	std_logic_vector(31 downto 1) := (others => '0');	-- High when "connected" May want to map these to LEDs


	-- Router instantiation Template 
	spw_router_inst: entity work.router_top_level_RTG4(rtl)
	generic map(
		g_clock_freq	=>  c_spw_clk_freq	,		-- these are located in router_pckg.vhd
		g_num_ports 	=>  c_num_ports     ,    	-- these are located in router_pckg.vhd
		g_mode			=>  c_port_mode     ,    	-- these are located in router_pckg.vhd
		g_is_fifo		=>  c_fifo_ports    ,   	-- these are located in router_pckg.vhd
		g_priority		=>  c_priority      ,    	-- these are located in router_pckg.vhd
		g_ram_style 	=>  c_ram_style				-- style of RAM to use (Block, Auto, URAM etc), 
	)
	port map( 
	
		-- standard register control signals --
		router_clk		=>	router_clk		,	
		rst_in			=>  rst_in			,
	
		-- SpW IO Pins                    
		Din_p  			=>  Din_p  			,
		Din_n           =>  Din_n           ,
		Sin_p           =>  Sin_p           ,
		Sin_n           =>  Sin_n           ,
		Dout_p          =>  Dout_p          ,
		Dout_n          =>  Dout_n          ,
		Sout_p          =>  Sout_p          ,
		Sout_n          =>  Sout_n          ,
	
		-- SpW Router FiFo Interface        
		spw_fifo_in		=>  spw_fifo_in		,
		spw_fifo_out	=>  spw_fifo_out	,
		
		-- Port Status LEDs 
		Port_Connected	=>  Port_Connected	
	
	);