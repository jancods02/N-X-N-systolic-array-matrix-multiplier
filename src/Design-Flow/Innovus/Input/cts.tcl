#defIn netlist/fifo_asynchronous.scandef
# source this script as: source cts.tcl
#post placement 
checkPlace timingReports/post_place/check_place.rpt
reportCongestion -hotspot > timingReports/post_place/congestion.rpt
timeDesign -preCTS -reportOnly -pathReports -drvReports -outDir timingReports/post_place
set_analysis_view -setup {worst} -hold {best}
add_ndr -name clock_rule -width {Metal3 0.4 Metal4 0.4} -spacing {Metal3 0.4 Metal4 0.4}
create_route_type -name trunk_route -non_default_rule clock_rule
create_route_type -name leaf_route

# 1. Clear the environment to start fresh
delete_ccopt_clock_tree_spec

set_ccopt_property buffer_cells {CLKBUFX2 CLKBUFX3 CLKBUFX4 CLKBUFX6 CLKBUFX8 CLKBUFX12 CLKBUFX16 CLKBUFX20}
set_ccopt_property inverter_cells {CLKINVX1 CLKINVX2 CLKINVX3 CLKINVX4 CLKINVX6 CLKINVX8 CLKINVX12 CLKINVX16 CLKINVX20}

# 3. Create the specification
# This analyzes your SDC and maps the clocks to the cells defined above
create_ccopt_clock_tree_spec
set_ccopt_property target_max_trans 0.300
set_ccopt_property target_skew 0.050;
set_ccopt_property route_type trunk_route -net_type trunk
set_ccopt_property route_type leaf_route -net_type leaf

# 5. Run the Clock Tree Synthesis
ccopt_design -cts
set_interactive_constraint_modes [all_constraint_modes -active]
set_propagated_clock [all_clocks]

#Post CTS
setAnalysisMode -analysisType onChipVariation
setAnalysisMode -cppr both
report_ccopt_skew_groups > timingReports/post_cts/clock_skew.rpt
report_ccopt_worst_chain > timingReports/post_cts/clock_chain.rpt
timeDesign -postCTS -prefix timingReports/post_unoptimized_cts_setup
timeDesign -postCTS -hold -prefix timingReports/post_unoptimized_cts_hold
optDesign -postCTS

# Run Post-CTS Hold Optimization (Crucial Step)
optDesign -postCTS -hold
setOptMode -fixHoldAllowSetupTnsDegrade false
timeDesign -postCTS -prefix timingReports/post_optimized/post_cts_setup
timeDesign -postCTS -hold -prefix timingReports/post_optimized/post_cts_hold

