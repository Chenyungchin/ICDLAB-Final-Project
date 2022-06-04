###############################################################
#  Generated by:      Cadence Innovus 20.10-p004_1
#  OS:                Linux x86_64(Host ID cad16)
#  Generated on:      Sat Jun  4 08:24:08 2022
#  Design:            CHIP
#  Command:           create_ccopt_clock_tree_spec -file ccopt.spec
###############################################################
#-------------------------------------------------------------------------------
# Clock tree setup script - dialect: Innovus
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

if { [get_ccopt_clock_trees] != {} } {
  error {Cannot run clock tree spec: clock trees are already defined.}
}

namespace eval ::ccopt {}
namespace eval ::ccopt::ilm {}
set ::ccopt::ilm::ccoptSpecRestoreData {}
# Start by checking for unflattened ILMs.
# Will flatten if so and then check the db sync.
if { [catch {ccopt_check_and_flatten_ilms_no_restore}] } {
  return -code error
}
# cache the value of the restore command output by the ILM flattening code
set ::ccopt::ilm::ccoptSpecRestoreData $::ccopt::ilm::ccoptRestoreILMState

# The following pins are clock sources
set_ccopt_property cts_is_sdc_clock_root -pin clk true

# Input pins determined constant across all timing configs.
set_ccopt_property case_analysis -pin ipad_clk_p_i/PD 0
set_ccopt_property case_analysis -pin ipad_clk_p_i/PU 0
set_ccopt_property case_analysis -pin ipad_clk_p_i/SMT 0

# Clocks present at pin clk
#   clk (period 10.000ns) in timing_config func_mode([/home/raid7_2/userb08/b08189/final/apr/apr_final/DBS/ultra/placement.dat/libs/mmmc/CHIP.sdc])
#   clk (period 10.000ns) in timing_config scan_mode([/home/raid7_2/userb08/b08189/final/apr/apr_final/DBS/ultra/placement.dat/libs/mmmc/CHIP.sdc])
create_ccopt_clock_tree -name clk -source clk -no_skew_group

# Clock period setting for source pin of clk
set_ccopt_property clock_period -pin clk 10

# Skew group to balance non generated clock:clk in timing_config:func_mode (sdc /home/raid7_2/userb08/b08189/final/apr/apr_final/DBS/ultra/placement.dat/libs/mmmc/CHIP.sdc)
create_ccopt_skew_group -name clk/func_mode -sources clk -auto_sinks
set_ccopt_property include_source_latency -skew_group clk/func_mode true
set_ccopt_property target_insertion_delay -skew_group clk/func_mode 0.500
set_ccopt_property extracted_from_clock_name -skew_group clk/func_mode clk
set_ccopt_property extracted_from_constraint_mode_name -skew_group clk/func_mode func_mode
set_ccopt_property extracted_from_delay_corners -skew_group clk/func_mode {DC_max DC_min}

# Skew group to balance non generated clock:clk in timing_config:scan_mode (sdc /home/raid7_2/userb08/b08189/final/apr/apr_final/DBS/ultra/placement.dat/libs/mmmc/CHIP.sdc)
create_ccopt_skew_group -name clk/scan_mode -sources clk -auto_sinks
set_ccopt_property include_source_latency -skew_group clk/scan_mode true
set_ccopt_property target_insertion_delay -skew_group clk/scan_mode 0.500
set_ccopt_property extracted_from_clock_name -skew_group clk/scan_mode clk
set_ccopt_property extracted_from_constraint_mode_name -skew_group clk/scan_mode scan_mode
set_ccopt_property extracted_from_delay_corners -skew_group clk/scan_mode {DC_max DC_min}


check_ccopt_clock_tree_convergence
# Restore the ILM status if possible
if { [get_ccopt_property auto_design_state_for_ilms] == 0 } {
  if {$::ccopt::ilm::ccoptSpecRestoreData != {} } {
    eval $::ccopt::ilm::ccoptSpecRestoreData
  }
}
