
Directory Organisation
**********************
build_scripts/
	Contains TCL scripts used in Jenkins CI pipeline. Can be ignored by the end user.
	
tcl/
	Contains TCL scripts for building example projects. Make sure Vivado/Toolchain root directory contains the opensource directory. 
	Vivado target version is 2023.1. Older versions should still work.

	For Windows:
		Default Xilinx Build Directory is %APPDATA%\Xilinx\Vivado. Opensource directory would be placed in %APPDATA%\Xilinx.
	For Linux:
		Place opensource directory into project directory. Open Terminal and Run Vivado from project directory.

	Using Vivado GUI: "Tools > Run TCL" and select the desired example project TCL script to build.
	Check the Vivado TCL Console for any errors/warnings on import. If successful, no errors will be deisplayed and the project window
	should contain the project IP files. 
	Running a behavioural simulation can be used to check the IP has imported correctly and the project settings are correct. 
	

src/4Links/common
	legacy libraries, do not use unless required

src/4Links/common_packages
	common project packages for VHDL libraries. See directory readme for details. 
	Bring these into your project as instructed before porting in any 4Links IP.

src/4Links/rmap
	Contains 4Links RMAP Initiator and RMAP Target IP files. RMAP Router & Peripherals depend on this IP. 
	Bring these files into your project as required. 

src/4Links/rmap_peripherals
	Basic RMAP peripheral interfaces (will be expanded). for bridging common interfaces (i.e Serial UART) to RMAP over
	SpaceWire. 

src/4Links/rmap_router
	4Links RMAP Router IP. Requires 4Links RMAP Target IP. Configurable up to 32 ports (31+1).
	Router configured using router_pckg.vhd in common_packages/router

src/4links/spacewire
    This directory contains the core spacewire transmit and receive code for bringing up a spacewire link.
	This IP is required by ALL 4Links OpenSource IP cores unless stated otherwise. 
	
src/4links/spacewire_highspeed
	High-Speed version of 4Links SpaceWire codec IP core. Currently WIP and shelved until future requirements/interest. 
	Aimed at providing >400 MHz line rate using RTL.
	

Each IP directory contains a /Docs, /RTL and /Sim sub folder. 
	/Docs contains user documentation for the IP. 
	/RTL contains HDL code for building the IP. 
	/Sim contains testbench environments for testing the IP.

readme's are places in several directories to explain specific properties or file locations as required. 	

Building
********
Manually building the IP example projects is covered in the respective IP user guides. See src/4Links/IP_NAME/docs sub-directories. 
Instuctions on Building IP Example projects using TCL scripts is detailed above. 


LICENSING
*********
This source is licensed under the terms of the license held in the file LICENSE.txt
If you require commercial support for this source please contact sales@4links.co.uk


SUPPORT
*******
If you require support for this source please contact support@4links.co.uk

- James E Logan