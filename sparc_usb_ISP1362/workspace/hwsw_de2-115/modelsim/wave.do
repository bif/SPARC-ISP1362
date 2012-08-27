# start simulation
vsim -coverage work.top_tb

quietly WaveActivateNextPane {} 0
add wave -noupdate /top_tb/top_1/db_clk
add wave -noupdate /top_tb/top_1/clk
add wave -noupdate /top_tb/top_1/rst
add wave -noupdate /top_tb/top_1/LEDR(1)
add wave -noupdate /top_tb/top_1/LEDR(0)
add wave -noupdate /top_tb/top_1/LEDG(2)
add wave -noupdate /top_tb/top_1/LEDG(1)
add wave -noupdate /top_tb/top_1/LEDG(0)


