@echo off

rem check if the modelsim library work exists and if not create it
rem if it exists then clear it
echo "clean up library work"
if not exist work ( 
  vlib work 
  ) else (
  vdel -all
  vlib work
  )

rem Compile design 
call vsim -quiet -novopt -c -do vcom.do 

rem simulate design
call vsim -quiet -novopt -do vsim.do 
