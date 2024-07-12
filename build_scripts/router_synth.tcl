
#get current build_scripts directory
set origin_dir "."	

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
  set origin_dir $::origin_dir_loc
}

# go to parent directory, since projects built in orig/tcl and we are currently in orig/build_scripts
set path [file dirname $origin_dir]

# path to to the project from the origin directory
open_project $path/../tcl/router_example/router_example.xpr
  
set run_name synth_1
set cpu_count 4
  
reset_runs $run_name
launch_runs $run_name -jobs $cpu_count
wait_on_run $run_name
  
set status [get_property STATUS [get_runs $run_name]]
if {$status != "synth_design Complete!"} {
  exit 1
}
exit 0