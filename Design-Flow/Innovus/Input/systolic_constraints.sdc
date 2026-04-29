# ####################################################################

#  Created by Genus(TM) Synthesis Solution 20.11-s111_1 on Sat Apr 11 00:42:32 IST 2026

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design systolic_array_top

create_clock -name "sys_clk" -period 10.0 -waveform {0.0 5.0} [get_ports clk]
set_clock_gating_check -setup 0.0 
set_input_delay -clock [get_clocks sys_clk] -add_delay 2.0 [get_ports rst]
set_input_delay -clock [get_clocks sys_clk] -add_delay 2.0 [get_ports start]
set_output_delay -clock [get_clocks sys_clk] -add_delay 2.0 [get_ports done]
set_wire_load_mode "enclosed"
set_clock_uncertainty -setup 0.1 [get_clocks sys_clk]
set_clock_uncertainty -hold 0.1 [get_clocks sys_clk]
