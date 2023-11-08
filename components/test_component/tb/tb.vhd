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


entity tb is
  generic (
    runner_cfg : string
  );
end entity;

architecture RTL of tb is
  signal input : slv(log2c(255)-1 downto 0) := (others => '0');
  signal output : slv(log2c(255)-1 downto 0) := (others => '0');
  signal in_sf1 : sfixed(7 downto -8) := (others => '0');
  signal in_sf2 : sfixed(7 downto -8) := (others => '0');
  signal out_sf : sfixed(8 downto -8) := (others => '0');
begin

  DUT: entity hw_chaos.test_component
    port map (
      input => input,
      output => output,
      in_sf1 => in_sf1,
      in_sf2 => in_sf2,
      out_sf => out_sf
    );

  main: process
  begin
    test_runner_setup(runner, runner_cfg);
    
    while test_suite loop
    
    
      if run("test1") then
        in_sf1 <= (others => '1');
        in_sf2 <= (others => '1');
        input <= "11111111";
        wait for 5 ns;
        check(output = "00000000", "Inverter didnt invert!");
      end if;
      
      
    end loop;
    
    test_runner_cleanup(runner);
  end process;
  output <= not input;
end architecture;
