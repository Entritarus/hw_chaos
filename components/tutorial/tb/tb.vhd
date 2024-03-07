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
    runner_cfg : string
  );
end entity;

architecture RTL of tb is
  --------------------------------------------------------------------------------
  -- DUT interfacing
  --------------------------------------------------------------------------------
  
  constant CLK_PERIOD : time := 10 ns;
  signal clk : sl := '1';
  signal rst : sl := '1';

  signal i_value : sfi(7 downto -8) := (others => '0');
  signal o_value : sfi(7 downto -8) := (others => '0');

begin
  clk <= not clk after CLK_PERIOD/2;
  rst <= '0' after CLK_PERIOD;
  
  --------------------------------------------------------------------------------
  -- DUT instantiation
  --------------------------------------------------------------------------------

  DUT: entity hw_chaos.test_compo
    port map(
      clk => clk,
      rst => rst,

      i_value => i_value,
      o_value => o_value
    );

  --------------------------------------------------------------------------------
  -- Test sequencer
  --------------------------------------------------------------------------------
  process
  begin
    test_runner_setup(runner, runner_cfg);
    
    while test_suite loop
      if run("Full_coverage") then
        wait for CLK_PERIOD;
        i_value <= to_sfixed(69.420, 7, -8);
        wait for 100 ns;

      end if;
    end loop;
    
    test_runner_cleanup(runner);
  end process;
end architecture;
