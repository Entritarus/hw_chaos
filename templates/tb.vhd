library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;
use ieee.fixed_float_types.all;

library hw_chaos;
use hw_chaos.data_types.all;
use hw_chaos.functions.all;

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.com_context;
context vunit_lib.data_types_context;
use vunit_lib.axi_stream_pkg.all;
use vunit_lib.stream_master_pkg.all;
use vunit_lib.stream_slave_pkg.all;

library osvvm;
use osvvm.RandomPkg.all;

entity tb is
  generic (

  );
end entity;

architecture RTL of tb is
  --------------------------------------------------------------------------------
  -- DUT interfacing
  --------------------------------------------------------------------------------
  
  constant CLK_PERIOD : time := 10 ns;
  signal clk : sl := '1';
  signal rst : sl := '1';


  constant stream_master : axi_stream_master_t := new_axi_stream_master(
    data_length => WORD,
    stall_config => new_stall_config(0.1, 0, 10)
  );
  constant stream_slave : axi_stream_slave_t := new_axi_stream_slave(
    data_length => WORD,
    stall_config => new_stall_config(0.1, 0, 10)
  );

begin
  clk <= not clk after CLK_PERIOD/2;
  

  AXIS_MASTER: entity vunit_lib.axi_stream_master
    generic map (
      master => stream_master
    )
    port map (

    );
  AXIS_SLAVE: entity vunit_lib.axi_stream_slave
    generic map (
      slave => stream_slave
    )
    port map (

    );
  --------------------------------------------------------------------------------
  -- DUT instantiation
  --------------------------------------------------------------------------------

  DUT: entity hw_chaos.
    generic map (
      
    )
    port map(
      
    );

  --------------------------------------------------------------------------------
  -- Test sequencer
  --------------------------------------------------------------------------------
  process
  begin
    test_runner_setup(runner, runner_cfg);
    
    while test_suite loop
    
    
      if run("Full_coverage") then

      end if;
      
      
    end loop;
    
    test_runner_cleanup(runner);
  end process;
end architecture;
