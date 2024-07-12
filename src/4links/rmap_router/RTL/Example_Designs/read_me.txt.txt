This directory contains scripts and files for building the RMAP router example design.

Before building the project set router_pckg.vhd constants:
	c_router_clk_freq to 400_000_000.0 (400MHz)
	c_num_ports to 13 (12+1).
	c_port_mode to "custom". 

Project will build for Xilinx Kintex UltraScale FPGA (XCKU040) in SFVA784 Package.

Constaints file sets IO mapping but ommits IO delay. As Asynchronous False paths can be used for D/S IO; however care must be taken that D and S are synchronous to each other for low speed designs skew may not be a problem, but for high-speed designs D/S Skew must be taken into consideration. 



