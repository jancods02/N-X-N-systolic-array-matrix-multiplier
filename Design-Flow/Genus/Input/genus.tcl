read_libs /linuxeda_new/c2scadence/FOUNDRY/digital/90nm/dig/lib/fast.lib
read_hdl systolic_array_top.v synch_FIFO.v PE.v controller.v

# 2. Build Design Hierarchy
elaborate
current_design systolic_array_top

# 3. Apply Constraints (AFTER elaborate)
read_sdc input_constraints.sdc

# Ensure the driving cell "BUFX2" actually exists in slow.lib
set_driving_cell -lib_cell BUFX2 [all_inputs]
set_load 0.05 [all_outputs]
set_db [get_db modules PE] .preserve_hierarchy true
set_db / .syn_generic_eff medium
set_db / .syn_map_eff high
set_db / .syn_opt_eff high
syn_generic
syn_map
syn_opt

# 5. Reports & Export
check_design
report_clocks
report_timing > netlist_no_dft/sys_timing_slow.rpt
report_power  > netlist_no_dft/sys_power_slow.rpt
report_area   > netlist_no_dft/sys_area_slow.rpt
report_gates  > netlist_no_dft/sys_gates_slow.rpt

write_hdl > netlist_no_dft/sysnetlist_slow.v
write_sdc > netlist_no_dft/outputconstraints_slow.sdc

# Launch GUI to see the schematic
gui_show
