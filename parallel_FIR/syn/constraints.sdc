create_clock -name "clk" -period 5 -waveform {0 2.5} [get_ports clk]
set_false_path -from [get_port n_rst]
set_load 1.5 -pin_load [get_ports -filter "direction==out"]