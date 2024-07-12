rmap_router\RTL\IP_Sub_Modules\legacy contains previous revisions of submodules. If required, replace the
file in the IP_Sub_Modules folder with the legacy version. 


Use router_pckg.vhd from common_packages directory to configure the router parameters. 

Add all /common_packages/ subdirectories and context cluases as required. 
Add SpaceWire CoDec, RMAP Initiator & RMAP Targets to your project before adding the router IP. 

change log:

18/10/2023 :	Added FiFo based priority arbitration method to RMAP router. 
		Mode selection is set using generic g_priority. 
		Setting to string "FiFo" will use "FiFo" based priority. 
		Setting to any other value will use round-robin based priority. 

26/10/2023: 	Added configurable router fabric bus width and seperate router clock domain. 
