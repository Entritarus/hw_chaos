# hw_chaos
The repository for the RTR803 course work

## Before you start working, you need to fulfill these requirements:
1. Install latest Quartus Prime Lite Edition 
2. Install Questa and activate by following this [tutorial](https://www.youtube.com/watch?v=F6FvXga4f1A)
3. Install VUnit with pip
   ```
   pip install vunit-hdl
   ```

## Description of directories

### components
Here we keep all of our VHDL components. The recommended structure of a component is as follows:

+ **component_name**
   - _sim_\
   &nbsp; &nbsp; run.py
   - _src_\
   &nbsp; &nbsp; component_name.vhd
   - _tb_\
   &nbsp; &nbsp; tb.vhd\
   &nbsp; &nbsp; other testbench files...

### matlab
Here we keep scripts for modeling systems

### pkg
This directory contains VHDL packages

### templates
This directory contains templates for VHDL components and Python VUnit simulation template
