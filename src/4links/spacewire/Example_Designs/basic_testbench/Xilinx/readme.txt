To build the project from "build_project.tcl":

Move project folders & .tcl script to desired working directory. 

Windows: 
	- Run Vivado
	- Tools -> Run TCL Script -> /* select select build_project.tcl */
	
Linux 
	- open terminal in desired working directory.
	- source vivado
	- run vivado GUI ($ vivado&)
	- Tools -> Run TCL Script -> /* select select build_project.tcl */

project should begin building. Once built, run "Behavioural Simulation"	to see example run.

project designed in Vivado 2023.1. Tested in Vivado 2022.2 for Ubuntu & Windows. 

project should not be used for Synthesis, only for behavioural simulation. 
No constraints are included with this example design. 