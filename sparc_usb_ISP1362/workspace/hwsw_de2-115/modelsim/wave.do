onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_tb/clk
add wave -noupdate /top_tb/top_1/db_clk
add wave -noupdate /top_tb/top_1/clk
add wave -noupdate /top_tb/rst
add wave -noupdate /top_tb/top_1/rst
add wave -noupdate /top_tb/ledg(0)
add wave -noupdate /top_tb/ledg(1)
add wave -noupdate /top_tb/ledr(0)
add wave -noupdate /top_tb/ledr(1)
add wave -noupdate /top_tb/ledr(2)
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3184 ns} 0}
configure wave -namecolwidth 150
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
WaveRestoreZoom {800 ns} {5568 ns}
