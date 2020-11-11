################################################################################
# Genus logic synthesis script
################################################################################
#
# This script is meant to be executed with the following directory structure
#
# project_top_folder
# |
# |- db: store output data like mapped designs or physical files like GDSII
# |
# |- phy: physical synthesis material (scripts, pins, etc)
# |
# |- rtl: contains rtl code for the design, it should also contain a
# |       hierarchy.txt file with the all the files that compose the design
# |
# |- syn: logic synthesis material (this script, SDC constraints, etc)
# |
# |- sim: simulation stuff like waveforms, reports, coverage etc.
# |
# |- tb: testbenches for the rtl code
#
#
# The standard way of executing the is from the project_top_folder
# with the following command
#
# $ genus -files ./syn/genus_synthesis.tcl
#
# Additionally it should be possible to do
#
# $ make syn
#
# If the standard Makefile is present in the project directory
################################################################################



# Technology variables
set LIB_NAME tcbn28hpcbwp30p140ssg0p81v125c
#set LIB_SEARCH_PATH "/mnt/storage3/stdc_libs/28LP/stdclib/9-track/30p140/nvt/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28lpbwp30p140_142b"
set LIB_SEARCH_PATH "/mnt/d/stdc_libs/28HPC/stclib/9-track/30p140/nvt/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hpcbwp30p140_100a"
set OP_CONDS ssg0p81v125c


# Directories for output material
set REPORT_DIR  ./syn/rpt;      # synthesis reports: timing, area, etc.
set OUT_DIR ./db;               # output files: netlist, sdf sdc etc.
set SOURCE_DIR ./rtl;           # rtl code that should be synthesised
set SYN_DIR ./syn;              # synthesis directory, synthesis scripts constraints etc.


# Design specific variables
set TOP_NAME serial_FIR


# Synthesis controls


################################################################################
# Synthesis process
# From this point the script should not require to be modified 
################################################################################

# Set up libraries
set_db lib_search_path $LIB_SEARCH_PATH
set_db library "${LIB_NAME}.lib"

# General settings
set_db / .information_level 9
set_db / .hdl_track_filename_row_col 1
set_db / .source_verbose true
set_db / .hdl_error_on_blackbox false
set_db / .hdl_error_on_latch true
set_db / .hdl_vhdl_read_version 2008

# Read files
set hierarchy_files [split [read [open ${SOURCE_DIR}/${TOP_NAME}_hierarchy.txt r]] "\n"]
close ${SOURCE_DIR}/${TOP_NAME}_hierarchy.txt

# assume .vhd extensions are VHDL and others are Verilog netlist
# skip the last element since tcl reads {} for the last line
foreach filename [lrange ${hierarchy_files} 0 end-1] {
    # puts "${filename}"
    if {[string equal [file extension $filename] ".vhd"]} {
        read_hdl -vhdl "${SOURCE_DIR}/${filename}"
    } else {
        read_hdl -netlist "${SOURCE_DIR}/${filename}"
    }
}

# Enable clock gating
set_db lp_insert_clock_gating true
set_db lp_clock_gating_hierarchical true

elaborate ${TOP_NAME}
current_design ${TOP_NAME}

source ${SYN_DIR}/constraints.sdc

set_db syn_generic_effort high
add_assign_buffer_options -verbose
set_db remove_assigns true
set_db use_tiehilo_for_const duplicate
syn_generic
syn_map
syn_opt
syn_opt

write_hdl > ${OUT_DIR}/${TOP_NAME}.v
