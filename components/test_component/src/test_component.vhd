library ieee;
library hw_chaos;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;
use ieee.fixed_float_types.all;
use hw_chaos.data_types.all;
use hw_chaos.functions.all;

entity test_component is
  port (
    input : in slv(log2c(255)-1 downto 0);
    output : out slv(log2c(255)-1 downto 0);

    in_sf1 : in sfixed(7 downto -8);
    in_sf2 : in sfixed(7 downto -8);
    out_sf : out sfixed(8 downto -8)
  );
end entity;

architecture RTL of test_component is
  
begin
  output <= not input;
  out_sf <= in_sf1 + in_sf2;
end architecture;
