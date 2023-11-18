#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2022.1 (64-bit)
#
# Filename    : compile.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for compiling the simulation design source files
#
# Generated by Vivado on Wed Oct 11 18:02:34 PDT 2023
# SW Build 3526262 on Mon Apr 18 15:47:01 MDT 2022
#
# IP Build 3524634 on Mon Apr 18 20:55:01 MDT 2022
#
# usage: compile.sh
#
# ****************************************************************************
set -Eeuo pipefail
# compile Verilog/System Verilog design sources
echo "xvlog --incr --relax -prj testbench_vlog.prj"
xvlog --incr --relax -prj testbench_vlog.prj 2>&1 | tee compile.log

# compile VHDL design sources
echo "xvhdl --incr --relax -prj testbench_vhdl.prj"
xvhdl --incr --relax -prj testbench_vhdl.prj 2>&1 | tee -a compile.log

echo "Waiting for jobs to finish..."
echo "No pending jobs, compilation finished."
