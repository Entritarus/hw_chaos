library ieee;
library hw_chaos;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;
use ieee.fixed_float_types.all;
use ieee.math_real.all;
use hw_chaos.data_types.all;
use hw_chaos.functions.all;

entity vilnius_oscillator is
  generic (
    a : real;
    b : real;
    c : real;
    e : real;

    dt : real;

    INT_PART : natural := 16;
    FRAC_PART : natural := 16;
    WORD : natural := INT_PART + FRAC_PART
  );
  port (
    clk       : in  sl;
    rst       : in  sl;

    i_sync_select : in slv;

    i_tvalid  : in  sl;
    o_tready  : out sl;
    i_tdata   : in  aslv(0 to 3-1)(WORD-1 downto 0);

    o_tvalid  : out sl;
    i_tready  : in  sl;
    o_tdata   : out aslv(0 to 3-1)(WORD-1 downto 0)
  );
end entity;

architecture RTL of vilnius_oscillator is
  signal valid_reg, valid_next : slv(2-1 downto 0) := (others => '0');

  signal der_input : aslv(0 to 3-1)(WORD-1 downto 0) := (others => (others => '0'));
  
  signal derivatives_aslv : aslv(0 to 3-1)(WORD-1 downto 0) := (others => (others => '0'));
  signal derx : sfi(INT_PART-1 downto -FRAC_PART) := (others => '0');
  signal dery : sfi(INT_PART-1 downto -FRAC_PART) := (others => '0');
  signal derz : sfi(INT_PART-1 downto -FRAC_PART) := (others => '0');

  constant MUL_HIGH : integer := sfixed_high(INT_PART-1, -FRAC_PART, '*', INT_PART-1, -FRAC_PART);
  constant MUL_LOW : integer := sfixed_low(INT_PART-1, -FRAC_PART, '*', INT_PART-1, -FRAC_PART);
  signal mul_reg, mul_next : asfi(0 to 3-1)(MUL_HIGH downto MUL_LOW) := (others => (others => '0'));

  signal dx : sfi(INT_PART-1 downto -FRAC_PART) := (others => '0');
  signal dy : sfi(INT_PART-1 downto -FRAC_PART) := (others => '0');
  signal dz : sfi(INT_PART-1 downto -FRAC_PART) := (others => '0');

  constant SUM_HIGH : integer := sfixed_high(INT_PART-1, -FRAC_PART, '+', INT_PART-1, -FRAC_PART);
  constant SUM_LOW : integer := sfixed_low(INT_PART-1, -FRAC_PART, '+', INT_PART-1, -FRAC_PART);
  signal x_plus_dx : sfi(SUM_HIGH downto SUM_LOW) := (others => '0');
  signal y_plus_dy : sfi(SUM_HIGH downto SUM_LOW) := (others => '0');
  signal z_plus_dz : sfi(SUM_HIGH downto SUM_LOW) := (others => '0');

  signal var_reg, var_next : aslv(0 to 3-1)(WORD-1 downto 0) := (others => (others => '0'));
begin
  
  DERIV_CALC : entity hw_chaos.deriv_calc
    generic map (
      a => a,
      b => b,
      c => c,
      e => e,

      INT_PART => 16,
      FRAC_PART => 16,
      WORD => 32
    )
    port map (
      clk => clk,
      rst => rst,

      i_tvalid => i_tvalid,
      o_tready => o_tready,
      i_tdata => der_input,

      o_tvalid => valid_next(valid_next'low),
      i_tready => i_tready,
      o_tdata => derivatives_aslv
    );

  -- reg-state logic
  process(clk, rst)
  begin
    if rst = '1' then
      valid_reg <= (others => '0');
      mul_reg <= (others => (others => '0'));
      var_reg <= (others => (others => '0'));

    elsif i_tready = '1' then
      if rising_edge(clk) then
        valid_reg <= valid_next;
        mul_reg <= mul_next;
        var_reg <= var_next;

      end if;
    end if;
  end process;
  

  valid_next(valid_next'high downto valid_next'low+1) <= valid_reg(valid_reg'high-1 downto valid_reg'low);

  der_input(X_POS) <= i_tdata(X_POS) when i_sync_select(X_POS) = '1' else
                      var_reg(X_POS);
  der_input(Y_POS) <= i_tdata(Y_POS) when i_sync_select(Y_POS) = '1' else
                      var_reg(Y_POS);
  der_input(Z_POS) <= i_tdata(Z_POS) when i_sync_select(Z_POS) = '1' else
                      var_reg(Z_POS);

  derx <= to_sfixed(derivatives_aslv(X_POS), INT_PART-1, -FRAC_PART);
  dery <= to_sfixed(derivatives_aslv(Y_POS), INT_PART-1, -FRAC_PART);
  derz <= to_sfixed(derivatives_aslv(Z_POS), INT_PART-1, -FRAC_PART);

  mul_next(X_POS) <= derx * to_sfixed(dt, INT_PART-1, -FRAC_PART);
  mul_next(Y_POS) <= dery * to_sfixed(dt, INT_PART-1, -FRAC_PART);
  mul_next(Z_POS) <= derz * to_sfixed(dt, INT_PART-1, -FRAC_PART);

  dx <= mul_reg(X_POS)(INT_PART-1 downto -FRAC_PART);
  dy <= mul_reg(Y_POS)(INT_PART-1 downto -FRAC_PART);
  dz <= mul_reg(Z_POS)(INT_PART-1 downto -FRAC_PART);

  x_plus_dx <= to_sfixed(var_reg(X_POS), INT_PART-1, -FRAC_PART) + dx;
  y_plus_dy <= to_sfixed(var_reg(Y_POS), INT_PART-1, -FRAC_PART) + dy;
  z_plus_dz <= to_sfixed(var_reg(Z_POS), INT_PART-1, -FRAC_PART) + dz;

  var_next(X_POS) <= to_slv(x_plus_dx(INT_PART-1 downto -FRAC_PART));
  var_next(Y_POS) <= to_slv(y_plus_dy(INT_PART-1 downto -FRAC_PART));
  var_next(Z_POS) <= to_slv(z_plus_dz(INT_PART-1 downto -FRAC_PART));

  -- outputs

  o_tready <= i_tready;

  o_tdata <= var_reg;
  
  o_tvalid <= valid_reg(valid_reg'high);
end architecture;
