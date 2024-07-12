# Clean up the work area
#vdel -all
#vlib work

# Compile common code
vcom -work work -2002 -explicit -vopt ../../hdl/ip4l_data_types.vhd
vcom -work work -2002 -explicit -vopt ../../hdl/spw_codes.vhd

# Compile the top level and testbench
vcom -work work -2008 -explicit -vopt ../../tb/ip4l_beh_models.vhd
vcom -work work -2002 -explicit -vopt ../../tb/tbench.vhd

quit
