###############################################################
#  Generated by:      Cadence Innovus 20.10-p004_1
#  OS:                Linux x86_64(Host ID cad16)
#  Generated on:      Sat Jun  4 08:47:05 2022
#  Design:            CHIP
#  Command:           routeDesign -globalDetail -viaOpt -wireOpt
###############################################################
current_design CHIP
create_clock [get_ports {clk}]  -name clk -period 10.000000 -waveform {0.000000 5.000000}
set_propagated_clock  [get_ports {clk}]
set_drive 1  [get_ports {clk}]
set_drive 1  [get_ports {rst_n}]
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
set_load -pin_load -max  1  [get_ports {valid}]
set_load -pin_load -min  1  [get_ports {valid}]
set_load -pin_load -max  1  [get_ports {out[11]}]
set_load -pin_load -min  1  [get_ports {out[11]}]
set_load -pin_load -max  1  [get_ports {out[10]}]
set_load -pin_load -min  1  [get_ports {out[10]}]
set_load -pin_load -max  1  [get_ports {out[9]}]
set_load -pin_load -min  1  [get_ports {out[9]}]
set_load -pin_load -max  1  [get_ports {out[8]}]
set_load -pin_load -min  1  [get_ports {out[8]}]
set_load -pin_load -max  1  [get_ports {out[7]}]
set_load -pin_load -min  1  [get_ports {out[7]}]
set_load -pin_load -max  1  [get_ports {out[6]}]
set_load -pin_load -min  1  [get_ports {out[6]}]
set_load -pin_load -max  1  [get_ports {out[5]}]
set_load -pin_load -min  1  [get_ports {out[5]}]
set_load -pin_load -max  1  [get_ports {out[4]}]
set_load -pin_load -min  1  [get_ports {out[4]}]
set_load -pin_load -max  1  [get_ports {out[3]}]
set_load -pin_load -min  1  [get_ports {out[3]}]
set_load -pin_load -max  1  [get_ports {out[2]}]
set_load -pin_load -min  1  [get_ports {out[2]}]
set_load -pin_load -max  1  [get_ports {out[1]}]
set_load -pin_load -min  1  [get_ports {out[1]}]
set_load -pin_load -max  1  [get_ports {out[0]}]
set_load -pin_load -min  1  [get_ports {out[0]}]
set_load -pin_load -max  1  [get_ports {resend}]
set_load -pin_load -min  1  [get_ports {resend}]
set_max_fanout 6  [get_designs {CHIP}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk}] [get_ports {in[6]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk}] [get_ports {rst_n}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk}] [get_ports {in[4]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk}] [get_ports {in[10]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk}] [get_ports {in[2]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk}] [get_ports {in[0]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk}] [get_ports {state[1]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk}] [get_ports {in[9]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk}] [get_ports {in[7]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk}] [get_ports {in[5]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk}] [get_ports {in[11]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk}] [get_ports {in[3]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk}] [get_ports {in[1]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk}] [get_ports {state[0]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk}] [get_ports {in[8]}]
set_output_delay -add_delay 0.5 -min -clock [get_clocks {clk}] [get_ports {out[4]}]
set_output_delay -add_delay 0.5 -min -clock [get_clocks {clk}] [get_ports {resend}]
set_output_delay -add_delay 0.5 -min -clock [get_clocks {clk}] [get_ports {out[2]}]
set_output_delay -add_delay 0.5 -min -clock [get_clocks {clk}] [get_ports {out[0]}]
set_output_delay -add_delay 0.5 -min -clock [get_clocks {clk}] [get_ports {valid}]
set_output_delay -add_delay 0.5 -min -clock [get_clocks {clk}] [get_ports {out[9]}]
set_output_delay -add_delay 0.5 -min -clock [get_clocks {clk}] [get_ports {out[11]}]
set_output_delay -add_delay 0.5 -min -clock [get_clocks {clk}] [get_ports {out[7]}]
set_output_delay -add_delay 0.5 -min -clock [get_clocks {clk}] [get_ports {out[5]}]
set_output_delay -add_delay 0.5 -min -clock [get_clocks {clk}] [get_ports {out[3]}]
set_output_delay -add_delay 0.5 -min -clock [get_clocks {clk}] [get_ports {out[1]}]
set_output_delay -add_delay 0.5 -min -clock [get_clocks {clk}] [get_ports {out[8]}]
set_output_delay -add_delay 0.5 -min -clock [get_clocks {clk}] [get_ports {out[10]}]
set_output_delay -add_delay 0.5 -min -clock [get_clocks {clk}] [get_ports {out[6]}]
set_clock_uncertainty 0.1 [get_clocks {clk}]