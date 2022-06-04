if {![namespace exists ::IMEX]} { namespace eval ::IMEX {} }
set ::IMEX::dataVar [file dirname [file normalize [info script]]]
set ::IMEX::libVar ${::IMEX::dataVar}/libs

create_library_set -name lib_typ\
   -timing\
    [list ${::IMEX::libVar}/mmmc/fsa0m_a_generic_core_tt1p8v25c.lib\
    ${::IMEX::libVar}/mmmc/fsa0m_a_t33_generic_io_tt1p8v25c.lib]\
   -si\
    [list ${::IMEX::libVar}/mmmc/u18_tt.cdb]
create_library_set -name lib_min\
   -timing\
    [list ${::IMEX::libVar}/mmmc/fsa0m_a_generic_core_ff1p98vm40c.lib\
    ${::IMEX::libVar}/mmmc/fsa0m_a_t33_generic_io_ff1p98vm40c.lib]\
   -si\
    [list ${::IMEX::libVar}/mmmc/u18_ff.cdb]
create_library_set -name lib_max\
   -timing\
    [list ${::IMEX::libVar}/mmmc/fsa0m_a_generic_core_ss1p62v125c.lib\
    ${::IMEX::libVar}/mmmc/fsa0m_a_t33_generic_io_ss1p62v125c.lib]\
   -si\
    [list ${::IMEX::libVar}/mmmc/u18_ss.cdb]
create_rc_corner -name RC_typ\
   -cap_table ${::IMEX::libVar}/mmmc/u18_Faraday.CapTbl\
   -preRoute_res 1\
   -postRoute_res 1\
   -preRoute_cap 1\
   -postRoute_cap 1\
   -postRoute_xcap 1\
   -preRoute_clkres 0\
   -preRoute_clkcap 0\
   -qx_tech_file ${::IMEX::libVar}/mmmc/RC_typ/icecaps.tch
create_rc_corner -name RC_best\
   -cap_table ${::IMEX::libVar}/mmmc/u18_Faraday.CapTbl\
   -preRoute_res 1\
   -postRoute_res 1\
   -preRoute_cap 1\
   -postRoute_cap 1\
   -postRoute_xcap 1\
   -preRoute_clkres 0\
   -preRoute_clkcap 0\
   -qx_tech_file ${::IMEX::libVar}/mmmc/RC_typ/icecaps.tch
create_rc_corner -name RC_worst\
   -cap_table ${::IMEX::libVar}/mmmc/u18_Faraday.CapTbl\
   -preRoute_res 1\
   -postRoute_res 1\
   -preRoute_cap 1\
   -postRoute_cap 1\
   -postRoute_xcap 1\
   -preRoute_clkres 0\
   -preRoute_clkcap 0\
   -qx_tech_file ${::IMEX::libVar}/mmmc/RC_typ/icecaps.tch
create_delay_corner -name DC_typ\
   -library_set lib_typ\
   -rc_corner RC_typ
create_delay_corner -name DC_min\
   -library_set lib_min\
   -rc_corner RC_best
create_delay_corner -name DC_max\
   -library_set lib_max\
   -rc_corner RC_worst
create_constraint_mode -name func_mode\
   -sdc_files\
    [list ${::IMEX::dataVar}/mmmc/modes/func_mode/func_mode.sdc]
create_constraint_mode -name scan_mode\
   -sdc_files\
    [list ${::IMEX::dataVar}/mmmc/modes/scan_mode/scan_mode.sdc]
create_analysis_view -name av_func_mode_max -constraint_mode func_mode -delay_corner DC_max -latency_file ${::IMEX::dataVar}/mmmc/views/av_func_mode_max/latency.sdc
create_analysis_view -name av_func_mode_min -constraint_mode func_mode -delay_corner DC_min -latency_file ${::IMEX::dataVar}/mmmc/views/av_func_mode_min/latency.sdc
create_analysis_view -name av_scan_mode_max -constraint_mode scan_mode -delay_corner DC_max -latency_file ${::IMEX::dataVar}/mmmc/views/av_scan_mode_max/latency.sdc
create_analysis_view -name av_scan_mode_min -constraint_mode scan_mode -delay_corner DC_min -latency_file ${::IMEX::dataVar}/mmmc/views/av_scan_mode_min/latency.sdc
set_analysis_view -setup [list av_func_mode_max av_scan_mode_max] -hold [list av_func_mode_min av_scan_mode_min]
