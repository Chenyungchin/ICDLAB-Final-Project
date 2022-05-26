###################################################################

# Created by write_sdc on Thu May 26 13:46:22 2022

###################################################################
set sdc_version 2.1

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
set_operating_conditions -max WCCOM -max_library                               \
fsa0m_a_generic_core_ss1p62v125c\
                         -min BCCOM -min_library                               \
fsa0m_a_generic_core_ff1p98vm40c
set_wire_load_model -name G200K -library fsa0m_a_generic_core_tt1p8v25c
set_max_fanout 6 [current_design]
set_max_area 0
set_load -pin_load 1 [get_ports valid]
set_load -pin_load 1 [get_ports {out[11]}]
set_load -pin_load 1 [get_ports {out[10]}]
set_load -pin_load 1 [get_ports {out[9]}]
set_load -pin_load 1 [get_ports {out[8]}]
set_load -pin_load 1 [get_ports {out[7]}]
set_load -pin_load 1 [get_ports {out[6]}]
set_load -pin_load 1 [get_ports {out[5]}]
set_load -pin_load 1 [get_ports {out[4]}]
set_load -pin_load 1 [get_ports {out[3]}]
set_load -pin_load 1 [get_ports {out[2]}]
set_load -pin_load 1 [get_ports {out[1]}]
set_load -pin_load 1 [get_ports {out[0]}]
set_load -pin_load 1 [get_ports resend]
create_clock [get_ports clk]  -period 10  -waveform {0 5}
set_clock_latency 0.5  [get_clocks clk]
set_clock_uncertainty 0.1  [get_clocks clk]
set_input_delay -clock clk  -max 1  [get_ports clk]
set_input_delay -clock clk  -max 1  [get_ports rst_n]
set_input_delay -clock clk  -max 1  [get_ports {state[1]}]
set_input_delay -clock clk  -max 1  [get_ports {state[0]}]
set_input_delay -clock clk  -max 1  [get_ports {in[11]}]
set_input_delay -clock clk  -max 1  [get_ports {in[10]}]
set_input_delay -clock clk  -max 1  [get_ports {in[9]}]
set_input_delay -clock clk  -max 1  [get_ports {in[8]}]
set_input_delay -clock clk  -max 1  [get_ports {in[7]}]
set_input_delay -clock clk  -max 1  [get_ports {in[6]}]
set_input_delay -clock clk  -max 1  [get_ports {in[5]}]
set_input_delay -clock clk  -max 1  [get_ports {in[4]}]
set_input_delay -clock clk  -max 1  [get_ports {in[3]}]
set_input_delay -clock clk  -max 1  [get_ports {in[2]}]
set_input_delay -clock clk  -max 1  [get_ports {in[1]}]
set_input_delay -clock clk  -max 1  [get_ports {in[0]}]
set_output_delay -clock clk  -min 0.5  [get_ports valid]
set_output_delay -clock clk  -min 0.5  [get_ports {out[11]}]
set_output_delay -clock clk  -min 0.5  [get_ports {out[10]}]
set_output_delay -clock clk  -min 0.5  [get_ports {out[9]}]
set_output_delay -clock clk  -min 0.5  [get_ports {out[8]}]
set_output_delay -clock clk  -min 0.5  [get_ports {out[7]}]
set_output_delay -clock clk  -min 0.5  [get_ports {out[6]}]
set_output_delay -clock clk  -min 0.5  [get_ports {out[5]}]
set_output_delay -clock clk  -min 0.5  [get_ports {out[4]}]
set_output_delay -clock clk  -min 0.5  [get_ports {out[3]}]
set_output_delay -clock clk  -min 0.5  [get_ports {out[2]}]
set_output_delay -clock clk  -min 0.5  [get_ports {out[1]}]
set_output_delay -clock clk  -min 0.5  [get_ports {out[0]}]
set_output_delay -clock clk  -min 0.5  [get_ports resend]
set_drive 1  [get_ports clk]
set_drive 1  [get_ports rst_n]
set_drive 1  [get_ports {state[1]}]
set_drive 1  [get_ports {state[0]}]
set_drive 1  [get_ports {in[11]}]
set_drive 1  [get_ports {in[10]}]
set_drive 1  [get_ports {in[9]}]
set_drive 1  [get_ports {in[8]}]
set_drive 1  [get_ports {in[7]}]
set_drive 1  [get_ports {in[6]}]
set_drive 1  [get_ports {in[5]}]
set_drive 1  [get_ports {in[4]}]
set_drive 1  [get_ports {in[3]}]
set_drive 1  [get_ports {in[2]}]
set_drive 1  [get_ports {in[1]}]
set_drive 1  [get_ports {in[0]}]
