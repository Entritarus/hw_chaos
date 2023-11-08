# hw_chaos
The repository for the RTR803 course work

## Before you start working, you need to fulfill these requirements:
1. Install latest [Quartus Prime Lite Edition](https://www.intel.com/content/www/us/en/products/details/fpga/development-tools/quartus-prime/resource.html)\
   On Windows it's just running an .exe file\
   <br>
   On Linux: 
   1. Change ownership of /opt/:
      ```
      sudo chown -R <username> /opt
      ```
   2. Unpack .tar archive
      ```
      tar -xvzf Quartus-lite-22.1std.2.922-linux.tar
      ```
   3. Run install script and choose `/opt/intelFPGA_lite/22.1/` as target directory
      ```
      ./QuartusLiteSetup-22.1std.2.922-linux.run
      ```
   4. Modify .bashrc
      ```
      export PATH=$PATH:/opt/intelFPGA_lite/22.1/quartus/bin
      export PATH=$PATH:/opt/intelFPGA_lite/22.1/questa_fse/bin
      ```
3. Install Questa and activate by following this [tutorial](https://www.youtube.com/watch?v=F6FvXga4f1A)\
   On Linux you will need to add a new variable into .bashrc:
   ```
   export LM_LICENSE_FILE=/opt/intelFPGA_lite/22.1/questa_fse/LR-xxxxxx_License.dat
   ```
5. Install VUnit with pip
   ```
   pip install vunit-hdl
   ```

By now you should have Quartus, Questa and VUnit installed.\
Try running run.py of a test_component:
```
cd components/test_component/sim
python3 run.py
```
It will compile a bunch of libraries and then will start the test.\
If the test passes, then you are ready to go. Congratulations!

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
