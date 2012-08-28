onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_tb/top_1/db_clk
add wave -noupdate /top_tb/top_1/clk
add wave -noupdate /top_tb/top_1/syncrst
add wave -noupdate /top_tb/top_1/sysrst
add wave -noupdate /top_tb/top_1/timer_sel
add wave -noupdate /top_tb/top_1/timer_exto.intreq
add wave -noupdate -radix decimal /top_tb/top_1/timer_unit/r.counter
add wave -noupdate /top_tb/top_1/timer_unit/r.prescaler
add wave -noupdate /top_tb/top_1/timer_unit/r.ifacereg(0)(0)
add wave -noupdate /top_tb/top_1/but_sw_led_unit/ledr(2)
add wave -noupdate /top_tb/top_1/but_sw_led_unit/ledr(1)
add wave -noupdate /top_tb/top_1/but_sw_led_unit/ledr(0)
add wave -noupdate /top_tb/top_1/but_sw_led_unit/ledg(1)
add wave -noupdate /top_tb/top_1/but_sw_led_unit/ledg(0)
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 3} {3300000 ps} 0}
configure wave -namecolwidth 128
configure wave -valuecolwidth 58
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {2933325 ps} {3666675 ps}
