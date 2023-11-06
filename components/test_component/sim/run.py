#!/usr/bin/env python3
from vunit import VUnit

# Create VUnit instance by parsing command line arguments
prj = VUnit.from_argv()

prj.add_osvvm()
prj.add_verification_components()
prj.add_random()

# Create main library
hw_chaos = prj.add_library("hw_chaos")
# Create library for fixed pkg
ieee_proposed = prj.add_library("ieee_proposed")


# Add source files relative to sim directory
hw_chaos.add_source_file("../src/test_component.vhd")



ieee_proposed.add_source_file("../../../pkg/fixed_float_types_c.vhdl")
ieee_proposed.add_source_file("../../../pkg/fixed_pkg_c.vhdl")
hw_chaos.add_source_file("../../../pkg/data_types.vhd")
hw_chaos.add_source_file("../../../pkg/functions.vhd")
hw_chaos.add_source_file("../tb/tb.vhd")


# Run testbench
prj.main()