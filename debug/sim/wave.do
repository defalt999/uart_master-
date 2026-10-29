onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /uart_tb/DUT/clk_i
add wave -noupdate /uart_tb/DUT/rst_n
add wave -noupdate -divider -height 30 APB
add wave -noupdate /uart_tb/DUT/psel_i
add wave -noupdate /uart_tb/DUT/penable_i
add wave -noupdate /uart_tb/DUT/paddr_i
add wave -noupdate /uart_tb/DUT/pwrite_i
add wave -noupdate /uart_tb/DUT/pwdata_i
add wave -noupdate /uart_tb/DUT/pready_o
add wave -noupdate /uart_tb/DUT/pslverr_o
add wave -noupdate /uart_tb/DUT/state
add wave -noupdate /uart_tb/DUT/next_state
add wave -noupdate -divider -height 30 <NULL>
add wave -noupdate -divider -height 30 REGS
add wave -noupdate /uart_tb/DUT/ctrl_reg
add wave -noupdate /uart_tb/DUT/baud_reg
add wave -noupdate -divider -height 30 <NULL>
add wave -noupdate -divider -height 30 UART
add wave -noupdate /uart_tb/DUT/tx_busy
add wave -noupdate /uart_tb/DUT/tx_baud_tick
add wave -noupdate /uart_tb/DUT/tx_out
add wave -noupdate /uart_tb/DUT/uart_state
add wave -noupdate /uart_tb/DUT/data_reg
add wave -noupdate /uart_tb/DUT/bit_count
add wave -noupdate -divider -height 30 <NULL>
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 7} {1763 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 201
configure wave -valuecolwidth 88
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
WaveRestoreZoom {640 ps} {5451 ps}
