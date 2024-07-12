vsim -novopt tbench
add wave -noupdate -expand -group tbench /tbench/*
#do wave.do
run 100 us
WaveRestoreZoom {0 ns} {4500 ns}
