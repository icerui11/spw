This folder contains Top-Level Entities to be instantiated in your design. The IP_Sub_Modules folder contains the HDL for all of the
different sub-entities which make up the SpaceWire IP. These are essential, without these in your project, you cannot instantiate the 4Links SpaceWire Codec IP. 

The IP_Wrapper directory contains pre-configured top-level wrappers for specific FPGA devices. Instantiation of DDR registers and IO buffers is technology specific. If no wrapper exists for your target technology you can make your own by modifying the "spw_wrap_top_level.vhd" file in the IP_Wrapper folder. Check to see if a wrapper for your device exists before doing this. 



The "spw_wrap_top_level.vhd" file contains the top-level entity "spw_wrap_top_level". This entity can be configured for Differential, Single-Ended and Custom IO operation. 
By default, the IP contains iDDR register and LVDS buffer models as processes. If using Differential or Single-Ended modes, 
these models should be replaced with device primitves as required by your FPGA technology and toolchain. The Custom Mode creates a direct path for IO signals In and Out of the entity. 
The Custom mode should be used if DDR registers and/or IO Buffers will be instantiated outside of the entity architecture. 

The Custom mode is useful when designing with Block diagrams and high-level synthesis tools, where you may not have direct access to entity architecure HDL. 

