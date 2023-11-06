library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library hw_chaos;
use hw_chaos.data_types.all;
use hw_chaos.functions.all;

entity test_component is
  port (
    input : in slv(log2c(255)-1 downto 0);
    output : out slv(log2c(255)-1 downto 0)
  );
end entity;

architecture RTL of test_component is
  
begin
  output <= not input;
end architecture;