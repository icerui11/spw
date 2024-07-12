All RTL & Simulation files for the SpW_os_CoDec must use VHDL 2008+ for proper functionality. 
Please consult your toolchain documentation if required. 

/RTL/Submodules -> Contains the submodules which make up the IP Architecture. These are required in youyr project.
/RTL/IP_Wrappers -> Check this section to see if it contains a pre-configured IP Wrapper file for your target FPGA device
/RTL/Instantiation_Templates -> Contains Language instantiation templates for the IP. 
/RTL/Legacy -> Old top-level wrapper files which may still be used.

files in /Lib/ should be brought into your project a long with the IP Submodules and one or more top_level wrapper files. 

files in /Sim/ contain the example design testbench environment. These are not required for your project, only the example
testbench design. 

/Example_Designs/ contains example designs for the SpaceWire CoDec. Check to see if an example exists for your target device.





Alternatively, get in touch and we will provide guidance where neccessary. 

