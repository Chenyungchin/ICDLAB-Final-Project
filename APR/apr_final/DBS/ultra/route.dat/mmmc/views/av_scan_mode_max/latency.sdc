set_clock_latency 0.5  [get_clocks {clk}]
set_clock_latency -source -early -max -rise  -1.13109 [get_ports {clk}] -clock clk 
set_clock_latency -source -early -max -fall  -0.88366 [get_ports {clk}] -clock clk 
set_clock_latency -source -late -max -rise  -1.13109 [get_ports {clk}] -clock clk 
set_clock_latency -source -late -max -fall  -0.88366 [get_ports {clk}] -clock clk 
