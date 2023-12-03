vlib work
vlog fsm.v
vsim fsm

log {/*}
add wave {/*}


force {Clk} 0 0ns, 1 2ns -r 4ns

#reset
force {reset} 0
force {mouseClick} 1
force {keyPressed} 0
force {accurate} 0
force {noMoreLives} 0
force {finishSong} 0

run 5ns



#TEST 1 -----------------

force {reset} 1
force {mouseClick} 0
run 10ns



#state: mainMenu_wait
force {mouseClick} 1
run 10ns



#state: selectDiff
force {mouseClick} 0
run 10ns



#state: selectDiff_wait
force {mouseClick} 1
run 10ns


#state: loadLevel
force {mouseClick} 0
run 10ns



#state: loadLevel_wait
force {mouseClick} 1
run 10ns




#state: idle (4'b0110) -> hit -> idle -> miss
force {mouseClick} 0
run 10ns


force {keyPressed} 1
force {accurate} 1
run 10ns



force {keyPressed} 0
run 10ns


force {keyPressed} 1
force {accurate} 0
run 10ns


#state: idle -> finishsong -> win 
force {keyPressed} 0
run 10ns

force {finishSong} 1
run 10ns

force {mouseClick} 1
run 10ns
force {mouseClick} 0
run 10ns




##state: idle -> hit -> miss --> lose
#force {keyPressed} 0
#run 10ns
#
#
#force {keyPressed} 1
#force {accurate} 1
#run 10ns
#
#force {accurate} 0
#force {noMoreLives} 1 
#run 10ns
#
#
#force {mouseClick} 1
#run 10ns
#force {mouseClick} 0
#run 10ns





