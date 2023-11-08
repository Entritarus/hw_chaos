#!/usr/bin/env python3
from vunit import VUnit

# Create VUnit instance by parsing command line arguments
prj = VUnit.from_argv()

prj.add_osvvm()
prj.add_verification_components()
prj.add_random()

# Create main library
hw_chaos = prj.add_library("hw_chaos")


### Add source files relative to sim directory

hw_chaos.add_source_file("../src/test_component.vhd")

### The rest should be kept untouched

hw_chaos.add_source_file("../../../pkg/data_types.vhd")
hw_chaos.add_source_file("../../../pkg/functions.vhd")
hw_chaos.add_source_file("../tb/tb.vhd")

prj.set_compile_option("modelsim.vcom_flags", ["-2008"]);

# Run testbench
prj.main()
