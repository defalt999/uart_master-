vlib work
vmap work work

vlog -sv ../hdl/ck_rst_tb.v
vlog -sv ../hdl/apb_interface.sv
vlog -sv ../hdl/apb_driver.sv
vlog -sv ../../hdl/uart_master.v
vlog -sv ../hdl/uart_tb.sv

vsim work.uart_tb
do wave.do
add log -r /*
run -all