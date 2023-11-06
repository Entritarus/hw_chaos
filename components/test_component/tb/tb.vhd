library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hw_chaos;
use hw_chaos.data_types.all;
use hw_chaos.functions.all;

library vunit_lib;
context vunit_lib.vunit_context;


entity tb is
  generic (
    runner_cfg : string
  );
end entity;

architecture RTL of tb is
  signal input : slv(log2c(255)-1 downto 0) := (others => '0');
  signal output : slv(log2c(255)-1 downto 0) := (others => '0');
begin

  DUT: entity hw_chaos.test_component
    port map (
      input => input,
      output => output
    );

  main: process
  begin
    test_runner_setup(runner, runner_cfg);
    
    while test_suite loop
    
    
      if run("test1") then
        input <= "11111111";
        wait for 5 ns;
        check(output = "00000000", "Inverter didnt invert!");
      end if;
      
      
    end loop;
    
    test_runner_cleanup(runner);
  end process;
  output <= not input;
end architecture;