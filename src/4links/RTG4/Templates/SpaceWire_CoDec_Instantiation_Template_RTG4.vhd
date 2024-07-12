	
	
	-- add the context clause to pull in required packages/libs
	context work.spw_context;
	
	-- Signal List for SpaceWire CoDec Interface
	signal	clock               :    	std_logic := '0';
	signal	reset               :    	std_logic := '0';
	
	signal	Tx_data             :    	t_nonet;
	signal	Tx_OR               :    	std_logic := '0';
	signal	Tx_IR               :  		std_logic := '0';
	
	signal	Rx_data             :  		t_nonet;
	signal	Rx_OR               :  		std_logic := '0';
	signal	Rx_IR               :    	std_logic := '0';
	
	signal	Rx_ESC_ESC          :  		std_logic := '0';
	signal	Rx_ESC_EOP          :  		std_logic := '0';
	signal	Rx_ESC_EEP          :  		std_logic := '0';
	signal	Rx_Parity_error     :  		std_logic := '0';
	signal	Rx_bits             :  		std_logic_vector(1 downto 0) := (others => '0');--integer range 0 to 2;
	signal	Rx_rate             :  		std_logic_vector(15 downto 0) := (others => '0');
	
	signal	Rx_Time             :  		t_byte;
	signal	Rx_Time_OR          :  		std_logic := '0';
	signal	Rx_Time_IR          :    	std_logic := '0';
	
	signal	Tx_Time             :    	t_byte;
	signal	Tx_Time_OR          :    	std_logic := '0';
	signal	Tx_Time_IR          :  		std_logic := '0';
	
	signal	Tx_PSC				: 		t_byte := (others => '0');
    signal	Tx_PSC_valid		: 		std_logic := '0';
	signal	Tx_PSC_ready		:  		std_logic := '0';
	
	signal	Disable             :    	std_logic := '0';
	signal	Connected           :  		std_logic := '0';
	signal	Error_select        :    	std_logic_vector(3 downto 0) := (others => '0');
	signal	Error_inject        :    	std_logic := '0';
	
	-- External Port List for SpaceWire CoDec 
	port	Din_p               : in    std_logic := '0';
	port	Din_n               : in    std_logic := '0';
	port	Sin_p               : in    std_logic := '0';
	port	Sin_n               : in    std_logic := '0';
	port	Dout_p              : out 	std_logic := '0';
	port	Dout_n              : out 	std_logic := '0';
	port	Sout_p              : out 	std_logic := '0';
	port	Sout_n              : out 	std_logic := '0';
	
	-- SpaceWire CoDec Instantiation Template 
	spw_codec_inst:	entity work.spw_wrap_top_level_RTG4(rtl)
	generic map(
		g_clock_frequency  	=> 125000000.0			,		-- clock frequency for SpaceWire IP (>2MHz)
		g_rx_fifo_size     	=> 56 					,		-- must be >8
		g_tx_fifo_size     	=> 56 					,		-- must be >8
		g_mode				=> "diff"						-- valid options are "diff", "single" and "custom".
	)
	port map( 
		clock  				=>   clock  			,			           
		reset               =>   reset              , 
		
		Tx_data             =>   Tx_data            , 
		Tx_OR               =>   Tx_OR              , 
		Tx_IR               =>   Tx_IR              , 
		
		Rx_data             =>   Rx_data            , 
		Rx_OR               =>   Rx_OR              , 
		Rx_IR               =>   Rx_IR              , 
		
		Rx_ESC_ESC          =>   Rx_ESC_ESC         , 
		Rx_ESC_EOP          =>   Rx_ESC_EOP         , 
		Rx_ESC_EEP          =>   Rx_ESC_EEP         , 
		Rx_Parity_error     =>   Rx_Parity_error    , 
		Rx_bits             =>   Rx_bits            , 
		Rx_rate             =>   Rx_rate            , 
		
		Rx_Time             =>   Rx_Time            , 
		Rx_Time_OR          =>   Rx_Time_OR         , 
		Rx_Time_IR          =>   Rx_Time_IR         , 
		
		Tx_Time             =>   Tx_Time            , 
		Tx_Time_OR          =>   Tx_Time_OR         , 
		Tx_Time_IR          =>   Tx_Time_IR         , 
		
		Tx_PSC				=>   Tx_PSC				,
        Tx_PSC_valid		=>   Tx_PSC_valid		,
		Tx_PSC_ready		=>	 Tx_PSC_ready		,
		
		Disable             =>   Disable            , 
		Connected           =>   Connected          , 
		Error_select        =>   Error_select       , 
		Error_inject        =>   Error_inject       , 
		
		Din_p               =>   Din_p              , 
		Din_n               =>   Din_n              , 
		Sin_p               =>   Sin_p              , 
		Sin_n               =>   Sin_n              , 
		Dout_p              =>   Dout_p             , 
		Dout_n              =>   Dout_n             , 
		Sout_p              =>   Sout_p             , 
		Sout_n              =>   Sout_n              
	);