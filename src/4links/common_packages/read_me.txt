Common packages to be used with the 4Links OpenSource IP are saved here. 
Load these into your project before attempting to add any RTL code.

Note that the sub-folder name is the required library name. for example packages located in /spw should be 
added to a library called spw. The library should be created as part of the synthesis tool design flow. 

The "_context" files are used within the IP submodules to group required libraries together.
Context declarations are part of VHDL 2008 onwards. Please make sure your toolchain supports Context Declarations. 
 
once all libraries have been added, add the top-level context file "ip4l_context.vhd". 
This should be included as part of your "work" library. 

It is best practice to add all libraries within the common_packages sub folder to your project. 