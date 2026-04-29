
file mkdir netlist_dft/reports


set_db init_lib_search_path /linuxeda_new/c2scadence/FOUNDRY/digital/90nm/dig/lib
set_db library fast.lib

# -------------------------------------------------
# Read RTL
# -------------------------------------------------
read_hdl systolic_array_top.v synch_FIFO.v PE.v controller.v
elaborate 
current_design systolic_array_top
read_sdc input_constraints.sdc

report clocks > netlist_dft/reports/clocks.rpt

# -------------------------------------------------

# -------------------------------------------------
# DFT Setup
# -------------------------------------------------
set_db dft_scan_style muxed_scan

define_shift_enable -name scan_en -active high -create_port scan_en

check_dft_rules

# -------------------------------------------------
# Synthesis
# -------------------------------------------------
syn_generic
syn_map

# Map logic that is not yet scan compatible
map_dft_unmapped_logic systolic_array_top
convert_to_scan
syn_opt

# -------------------------------------------------
# Final DFT Checks
# -------------------------------------------------
check_dft_rules

# -------------------------------------------------
# Define Scan Chain
# -------------------------------------------------
define_scan_chain \
-name systolic_scan_chain \
-sdi scan_in \
-sdo scan_out \
-create_ports

# Automatically connect chains
connect_scan_chains -auto_create_chains
write_scandef systolic_array_top > netlist_dft/reports/systolic.scandef
  #Scandef file is required and need to be imported in innovus
# -------------------------------------------------
# Write outputs
# -------------------------------------------------

# Now write the netlist
write_hdl > netlist_dft/reports/systolic_dft_netlist_flat.v
write_sdc > netlist_dft/reports/systolic_constraints.sdc
write_sdf > netlist_dft/reports/systolic_timing.sdf

write_dft_atpg \
-library /linuxeda_new/c2scadence/FOUNDRY/digital/90nm/dig/vlog/slow.v

# -------------------------------------------------
# Reports
# -------------------------------------------------
report_timing > netlist_dft/reports/timing.rpt
report_power > netlist_dft/reports/power.rpt
report_area > netlist_dft/reports/area.rpt
report_gates > netlist_dft/reports/gates.rpt
#report clock_gating > reports/clock_gating.rpt
report_scan_setup > netlist_dft/reports/dft_setup.rpt
report_scan_chains > netlist_dft/reports/scan_chains.rpt
gui_show