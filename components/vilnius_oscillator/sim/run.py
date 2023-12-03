#!/usr/bin/env python3
from vunit import VUnit

# Create VUnit instance by parsing command line arguments
prj = VUnit.from_argv()

prj.add_osvvm()
prj.add_vhdl_builtins()
prj.add_com()
prj.add_verification_components()
prj.add_random()

# Create main library
hw_chaos = prj.add_library("hw_chaos")


# Add source files relative to sim directory
hw_chaos.add_source_file("../../exponent_approx/src/exponent_approx.vhd")
hw_chaos.add_source_file("../../deriv_calc/src/deriv_calc.vhd")
hw_chaos.add_source_file("../src/vilnius_oscillator.vhd")

hw_chaos.add_source_file("../../../pkg/data_types.vhd")
hw_chaos.add_source_file("../../../pkg/functions.vhd")
hw_chaos.add_source_file("../tb/tb.vhd")


# Run testbench
prj.main()
