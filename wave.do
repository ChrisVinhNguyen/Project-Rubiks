# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog rubikscube.v

#load simulation using mux as the top level simulation module
vsim rubikscube

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


#{KEY[0]} : RESET
#{KEY[1]} : DO MOVE
#{SW[3:0]}: Choose Move

force CLOCK_50 1'b0
force {SW[3:0]} 4'b0000
force {KEY[0]} 1'b1
force {KEY[1]} 1'b0
run 10 ns

force CLOCK_50 1'b1
run 10 ns
#START

#!
force CLOCK_50 1'b0
force {SW[3:0]} 4'b0001
force {KEY[0]} 1'b0
force {KEY[1]} 1'b1
run 10 ns

force CLOCK_50 1'b1
run 10 ns

force {KEY[1]} 1'b0
force CLOCK_50 1'b0
run 10ns

force CLOCK_50 1'b1
run 10 ns

#!
force CLOCK_50 1'b0
force {SW[3:0]} 4'b0010
force {KEY[0]} 1'b0
force {KEY[1]} 1'b1
run 10 ns

force CLOCK_50 1'b1
run 10 ns

force {KEY[1]} 1'b0
force CLOCK_50 1'b0
run 10ns

force CLOCK_50 1'b1
run 10 ns

#!
force CLOCK_50 1'b0
force {SW[3:0]} 4'b0011
force {KEY[0]} 1'b0
force {KEY[1]} 1'b1
run 10 ns

force CLOCK_50 1'b1
run 10 ns

force {KEY[1]} 1'b0
force CLOCK_50 1'b0
run 10ns

force CLOCK_50 1'b1
run 10 ns

#!
force CLOCK_50 1'b0
force {SW[3:0]} 4'b0100
force {KEY[0]} 1'b0
force {KEY[1]} 1'b1
run 10 ns

force CLOCK_50 1'b1
run 10 ns

force {KEY[1]} 1'b0
force CLOCK_50 1'b0
run 10ns

force CLOCK_50 1'b1
run 10 ns

#!
force CLOCK_50 1'b0
force {SW[3:0]} 4'b0101
force {KEY[0]} 1'b0
force {KEY[1]} 1'b1
run 10 ns

force CLOCK_50 1'b1
run 10 ns

force {KEY[1]} 1'b0
force CLOCK_50 1'b0
run 10ns

force CLOCK_50 1'b1
run 10 ns

#!
force CLOCK_50 1'b0
force {SW[3:0]} 4'b0110
force {KEY[0]} 1'b0
force {KEY[1]} 1'b1
run 10 ns

force CLOCK_50 1'b1
run 10 ns

force {KEY[1]} 1'b0
force CLOCK_50 1'b0
run 10ns

force CLOCK_50 1'b1
run 10 ns

#!
force CLOCK_50 1'b0
force {SW[3:0]} 4'b0111
force {KEY[0]} 1'b0
force {KEY[1]} 1'b1
run 10 ns

force CLOCK_50 1'b1
run 10 ns

force {KEY[1]} 1'b0
force CLOCK_50 1'b0
run 10ns

force CLOCK_50 1'b1
run 10 ns

#!
force CLOCK_50 1'b0
force {SW[3:0]} 4'b1000
force {KEY[0]} 1'b0
force {KEY[1]} 1'b1
run 10 ns

force CLOCK_50 1'b1
run 10 ns

force {KEY[1]} 1'b0
force CLOCK_50 1'b0
run 10ns

force CLOCK_50 1'b1
run 10 ns

#!
force CLOCK_50 1'b0
force {SW[3:0]} 4'b1001
force {KEY[0]} 1'b0
force {KEY[1]} 1'b1
run 10 ns

force CLOCK_50 1'b1
run 10 ns

force {KEY[1]} 1'b0
force CLOCK_50 1'b0
run 10ns

force CLOCK_50 1'b1
run 10 ns

#!
force CLOCK_50 1'b0
force {SW[3:0]} 4'b1010
force {KEY[0]} 1'b0
force {KEY[1]} 1'b1
run 10 ns

force CLOCK_50 1'b1
run 10 ns

force {KEY[1]} 1'b0
force CLOCK_50 1'b0
run 10ns

force CLOCK_50 1'b1
run 10 ns

#!
force CLOCK_50 1'b0
force {SW[3:0]} 4'b1011
force {KEY[0]} 1'b0
force {KEY[1]} 1'b1
run 10 ns

force CLOCK_50 1'b1
run 10 ns

force {KEY[1]} 1'b0
force CLOCK_50 1'b0
run 10ns

force CLOCK_50 1'b1
run 10 ns


#!
force CLOCK_50 1'b0
force {SW[3:0]} 4'b1100
force {KEY[0]} 1'b0
force {KEY[1]} 1'b1
run 10 ns

force CLOCK_50 1'b1
run 10 ns

force {KEY[1]} 1'b0
force CLOCK_50 1'b0
run 10ns

force CLOCK_50 1'b1
run 10 ns