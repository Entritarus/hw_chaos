library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;
use ieee.fixed_float_types.all;

library hw_chaos;
use hw_chaos.data_types.all;
use hw_chaos.functions.all;

entity test_compo is
    port (
        clk : in sl;
        rst : in sl;
        
        i_value : in sfi(7 downto -8);
        o_value : out sfi(7 downto -8)
    );
end entity;


architecture RTL of test_compo is
    signal value_reg, value_next : sfi(7 downto -8) := (others => '0');
begin

    process(clk, rst) is
    begin
        if rst = '1' then
            value_reg <= (others => '0');
        elsif rising_edge(clk) then
            value_reg <= value_next;
        end if;
    end process;


    value_next <= i_value;

    o_value <= value_reg; 
    
end architecture;
