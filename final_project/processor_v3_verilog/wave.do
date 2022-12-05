onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /multicycle_tb/reset
add wave -noupdate /multicycle_tb/clock
add wave -noupdate -divider {Hex Display}
add wave -noupdate -divider {multicycle.v inputs}
add wave -noupdate /multicycle_tb/KEY
add wave -noupdate /multicycle_tb/SW
add wave -noupdate -divider {multicycle.v outputs}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2500 ns} 0}
configure wave -namecolwidth 227
configure wave -valuecolwidth 57
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1000
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {2500 ns}

add wave -position end  sim:/multicycle_tb/DUT/Control/cycle_counter
add wave -position end  sim:/multicycle_tb/DUT/Control/reset
add wave -position end  sim:/multicycle_tb/DUT/Control/state
add wave -position end  sim:/multicycle_tb/DUT/Control/instr
add wave -position end  sim:/multicycle_tb/DUT/RF_block/k0
add wave -position end  sim:/multicycle_tb/DUT/RF_block/k1
add wave -position end  sim:/multicycle_tb/DUT/RF_block/k2
add wave -position end  sim:/multicycle_tb/DUT/RF_block/k3
add wave -position 2  sim:/multicycle_tb/DUT/ALUOut

add wave -position end  sim:/multicycle_tb/DUT/VRFwrite
add wave -position end  sim:/multicycle_tb/DUT/R2Sel
add wave -position end  sim:/multicycle_tb/DUT/T0Wire
add wave -position end  sim:/multicycle_tb/DUT/T1Wire
add wave -position end  sim:/multicycle_tb/DUT/T2Wire
add wave -position end  sim:/multicycle_tb/DUT/T3Wire
add wave -position end  sim:/multicycle_tb/DUT/vdataw
add wave -position end  sim:/multicycle_tb/DUT/MemMuxWire
add wave -position end  sim:/multicycle_tb/DUT/vreg0
add wave -position end  sim:/multicycle_tb/DUT/vreg1
add wave -position end  sim:/multicycle_tb/DUT/vreg2
add wave -position end  sim:/multicycle_tb/DUT/vreg3
add wave -position end  sim:/multicycle_tb/DUT/V1Wire
add wave -position end  sim:/multicycle_tb/DUT/V2Wire

add wave -position end  sim:/multicycle_tb/DUT/T0/q
add wave -position end  sim:/multicycle_tb/DUT/T1/q
add wave -position end  sim:/multicycle_tb/DUT/T2/q
add wave -position end  sim:/multicycle_tb/DUT/T3/q

add wave -position end  sim:/multicycle_tb/DUT/VRF_block/k0
add wave -position end  sim:/multicycle_tb/DUT/VRF_block/k1
add wave -position end  sim:/multicycle_tb/DUT/VRF_block/k2
add wave -position end  sim:/multicycle_tb/DUT/VRF_block/k3
add wave -position end  sim:/multicycle_tb/DUT/VRF_block/vdata1
add wave -position end  sim:/multicycle_tb/DUT/VRF_block/vdata2

add wave -position end sim:/multicycle_tb/DUT/X1/*
add wave -position end sim:/multicycle_tb/DUT/X2/*