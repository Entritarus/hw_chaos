library ieee;
library hw_chaos;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;
use ieee.fixed_float_types.all;
use ieee.math_real.all;
use hw_chaos.data_types.all;
use hw_chaos.functions.all;

entity exponent_approx is
  generic (
    LINE_COUNT : natural := 3;
    X_MIN : real := -10.0;
    X_MAX : real := 10.0;

    INT_PART : natural := 16;
    FRAC_PART : natural := 16;
    WORD : natural := INT_PART + FRAC_PART
  );
  port (
    clk : in sl;
    rst : in sl;

    i_tvalid : in sl;
    o_tready : out sl;
    i_tdata : in slv(WORD-1 downto 0);

    o_tvalid : out sl;
    i_tready : in sl;
    o_tdata : out slv(WORD-1 downto 0)
  );
end entity;

architecture RTL of exponent_approx is
  signal i_value_sfi : sfixed(INT_PART-1 downto -FRAC_PART) := (others => '0');
  signal valid_reg, valid_next : sl := '0';
  signal valid_reg_reg, valid_reg_next : sl := '0';

  constant B_SEL_HIGH : integer := INT_PART-1;
  constant B_SEL_LOW : integer := -FRAC_PART;
  signal b_sel_reg, b_sel_next : sfixed(B_SEL_HIGH downto B_SEL_LOW) := (others => '0');

  constant A_SEL_HIGH : integer := INT_PART-1;
  constant A_SEL_LOW : integer := -FRAC_PART;
  signal a_sel : sfixed(A_SEL_HIGH downto A_SEL_LOW) := (others => '0');

  -- y = a*x + b
  constant MUL_REG_HIGH : integer := sfixed_high(INT_PART-1, -FRAC_PART, '*', A_SEL_HIGH, A_SEL_LOW);
  constant MUL_REG_LOW : integer := sfixed_low(INT_PART-1, -FRAC_PART, '*', A_SEL_HIGH, A_SEL_LOW);
  signal mul_reg, mul_next : sfixed(MUL_REG_HIGH downto MUL_REG_LOW) := (others => '0');

  constant SUM_REG_HIGH : integer := sfixed_high(MUL_REG_HIGH, MUL_REG_LOW, '+', B_SEL_HIGH, B_SEL_LOW);
  constant SUM_REG_LOW : integer := sfixed_low(MUL_REG_HIGH, MUL_REG_LOW, '+', B_SEL_HIGH, B_SEL_LOW);
  signal sum_reg, sum_next : ufixed(SUM_REG_HIGH downto SUM_REG_LOW) := (others => '0');

begin

  i_value_sfi <= to_sfixed(i_tdata, INT_PART-1, -FRAC_PART);

  -- reg-state logic
  process(clk, rst)
  begin
    if rst = '1' then
      valid_reg <= '0';
      valid_reg_reg <= '0';
      mul_reg <= (others => '0');
      sum_reg <= (others => '0');
      b_sel_reg <= (others => '0');
    elsif i_tready = '1' then
      if rising_edge(clk) then
        valid_reg <= valid_next;
        valid_reg_reg <= valid_reg_next;
        mul_reg <= mul_next;
        sum_reg <= sum_next;
        b_sel_reg <= b_sel_next;
      end if;
    end if;
  end process;
  
  -- next-state logic

  -- valid propagation
  valid_next <= i_tvalid;
  valid_reg_next <= valid_reg;

  -- a and b selection process
  A_B_SEL_PROC: process(all)
    variable x_step : real := 0.0;
    variable x1 : real := 0.0;
    variable x2 : real := 0.0;
    variable y1 : real := 0.0;
    variable y2 : real := 0.0;
    variable a : real := 0.0;
    variable b : real := 0.0;
  begin
    -- calculate breakpoints
    a := 0.0;
    b := 0.0;

    x_step := (X_MAX - X_MIN)/real(LINE_COUNT);
    for i in 0 to LINE_COUNT-1 loop
      x1 := X_MIN + real(i)*x_step;
      x2 := x1 + x_step;

      if i_value_sfi >= to_sfixed(x1, INT_PART-1, -FRAC_PART) then
        y1 := exp(x1);
        y2 := exp(x2);

        a := (y2-y1)/(x2-x1);
        b := y1 - x1*(y2-y1)/(x2-x1);
      end if;
    end loop;

    a_sel <= to_sfixed(a, A_SEL_HIGH, A_SEL_LOW);
    b_sel_next <= to_sfixed(b, B_SEL_HIGH, B_SEL_LOW);
  end process;

  -- multiplication a*x
  mul_next <= a_sel * i_value_sfi;

  -- adding a*x + b
  sum_next <= to_ufixed(to_slv(mul_reg + b_sel_reg), SUM_REG_HIGH, SUM_REG_LOW);

  -- outputs
  o_tvalid <= valid_reg_reg;
  o_tdata <= to_slv(sum_reg(INT_PART-1 downto -FRAC_PART));
  o_tready <= i_tready;

end architecture;
