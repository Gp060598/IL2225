# set global libraries
source synopsys_dc.setup

set REPORT_DIR  ./rpt;      # synthesis reports: timing, area, etc.
set OUT_DIR ./db;           # output files: netlist, sdf sdc etc.
set SOURCE_DIR ./rtl;       # rtl code that should be synthesised
set SYN_DIR ./syn;          # synthesis directory, synthesis scripts constraints etc.

# Design specific variables
set TOP_NAME serial_FIR

# Read files
set hierarchy_files [split [read [open ${SOURCE_DIR}/${TOP_NAME}_hierarchy.txt r]] "\n"]

# read design files
foreach filename [lrange ${hierarchy_files} 0 end-1] {
    puts "${filename}"
    analyze -format VHDL -lib WORK "${SOURCE_DIR}/${filename}"
}

elaborate ${TOP_NAME}

set_wireload_mode segmented
set_wireload_model TSMC8K_Lowk_Conservative
set_operating_condition NCCOM

create_clock -name "clk" -period 5 -waveform {0 2.5} { clk }
set_false_path -from [get_port n_rst]

compile -map_effort medium

report_constraints > ${REPORT_DIR}/${TOP_NAME}_constratints.txt
report_area > ${REPORT_DIR}/${TOP_NAME}_area.txt
report_cell > ${REPORT_DIR}/${TOP_NAME}_cells.txt
report_timing > ${REPORT_DIR}/${TOP_NAME}_timing.txt
report_power > ${REPORT_DIR}/${TOP_NAME}_power.txt


# Export netlist
write -hierarchy -format ddc -output ${OUT_DIR}/${TOP_NAME}.ddc
write -hierarchy -format verilog -output ${OUT_DIR}/${TOP_NAME}.v
