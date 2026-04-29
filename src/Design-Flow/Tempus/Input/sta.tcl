extractRC
rcOut -spef tempusfiles/sta/sys_final.spef
# 1. Save the final Routed Netlist
saveNetlist -phys -includePowerGround tempusfiles/sta/routed_design.v

# 2. Save the Constraints (SDC)
write_sdc tempusfiles/sta/sys_final.sdc
#tempus
tempus -eco
read_lib -max {/linuxeda_new/c2scadence/FOUNDRY/digital/90nm/dig/lib/slow.lib} -min {/linuxeda_new/c2scadence/FOUNDRY/digital/90nm/dig/lib/fast.lib}
read_verilog tempusfiles/sta/routed_design.v

# Set the top module
set_top_module systolic_array_top


# 2. Load the Physical Data (Parasitics)
# This is the SPEF file you generated with 'rcOut'
read_spef netlist/sta/carfsm_final.spef
read_sdc netlist/sta/carfsm_final.sdc
 current_design systolic_array_top
 check_timing
 set_analysis_mode -analysisType single
setAnalysisMode -analysisType onChipVariation
set_analysis_mode -analysisType single -checkType setup -skew true
 set_eco_opt_mode -save_eco_opt_db mySignOffTGDir
 write_eco_opt_db
set_distribute_host -local
set_multi_cpu_usage -localCpu 8 -remoteHost 2 -cpuPerRemoteHost 4
 eco_opt_design -hold
# eco_opt_design -setup
 update_timing
 report_timing -late > tempusfiles/sta/setup.txt
 report_timing -early > tempusfiles/sta/hold.txt
report_annotated_parasitics
