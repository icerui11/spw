onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider tbench
add wave -noupdate -expand -group tbench /tbench/*
add wave -noupdate -divider Other
TreeUpdate [SetDefaultTree]
quietly wave cursor active 1
configure wave -namecolwidth 206
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 us} {100 us}
