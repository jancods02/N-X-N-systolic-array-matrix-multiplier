# Period = 10ns (100MHz)
create_clock -name sys_clk -period 10 [get_ports clk]
set_clock_uncertainty 0.1 [get_clocks sys_clk]
set_input_delay -clock sys_clk 2.0 [get_ports rst]
set_input_delay -clock sys_clk 2.0 [get_ports start]
set_output_delay -clock sys_clk 2.0 [get_ports done]