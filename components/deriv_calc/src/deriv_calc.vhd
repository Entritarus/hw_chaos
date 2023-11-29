library ieee;
library hw_chaos;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;
use ieee.fixed_float_types.all;
use ieee.math_real.all;
use hw_chaos.data_types.all;
use hw_chaos.functions.all;

entity deriv_calc is
  generic (
    a : real;
    b : real;
    c : real;
    e : real;

    INT_PART : natural := 16;
    FRAC_PART : natural := 16;
    WORD : natural := INT_PART + FRAC_PART
  );
  port (
    clk       : in  sl;
    rst       : in  sl;

    i_tvalid  : in  sl;
    o_tready  : out sl;
    i_tdata   : in  aslv;
    i_tlast   : in  sl;

    o_tvalid  : out sl;
    i_tready  : in  sl;
    o_tdata   : out aslv;
    o_tlast   : out sl
  );
end entity;

architecture RTL of exponent_approx is
  constant DELAY_COUNT : natural := 5;

  signal int_en : sl := '0';

  signal x_value_sfi : sfixed(INT_PART-1 downto -FRAC_PART) := (others => '0');
  signal y_value_sfi : sfixed(INT_PART-1 downto -FRAC_PART) := (others => '0');
  signal z_value_sfi : sfixed(INT_PART-1 downto -FRAC_PART) := (others => '0');

  signal valid_reg, valid_next : slv(DELAY_COUNT-1 downto 0) := (others => '0');

  
  
begin
  
  x_value_sfi <= to_sfixed(i_tdata(0), INT_PART-1, -FRAC_PART);
  y_value_sfi <= to_sfixed(i_tdata(1), INT_PART-1, -FRAC_PART);
  z_value_sfi <= to_sfixed(i_tdata(2), INT_PART-1, -FRAC_PART);

  -- reg-state logic
  process(clk, rst)
  begin
    if rst = '1' then
      
    elsif int_en = '1' then
      if rising_edge(clk) then
        
      end if;
    end if;
  end process;
  
  -- next-state logic

  -- outputs

end architecture;
