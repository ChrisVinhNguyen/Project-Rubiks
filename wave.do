# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog ProjectRubiks.v

#load simulation using mux as the top level simulation module
vsim ProjectRubiks

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

force {KEY[1]} 0
run 10 ns

force {KEY[1]} 1
run 10 ns
