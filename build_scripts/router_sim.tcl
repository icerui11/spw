set origin_dir "."

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
  set origin_dir $::origin_dir_loc
}

set path [file dirname $origin_dir]

open_project $path/../tcl/router_example/router_example.xpr

set sim_fileset sim_1
  
launch_simulation -simset [get_filesets $sim_fileset]
close_sim

cd  $path/../tcl/router_example
set test [exec pwd]
puts "$test"
  
# Look for assertion failures in the simulation log
set log_file [glob *sim/$sim_fileset/behav/xsim/simulate.log]
set fp [open $log_file]
set file_data [read $fp]
exit [regex "Failure:" $file_data]