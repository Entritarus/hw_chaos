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
    i_tdata   : in  aslv(0 to 3-1)(WORD-1 downto 0);

    o_tvalid  : out sl;
    i_tready  : in  sl;
    o_tdata   : out aslv(0 to 3-1)(WORD-1 downto 0)
  );
end entity;

architecture RTL of deriv_calc is
  signal int_en : sl := '0';

  signal x_sfi : sfi(INT_PART-1 downto -FRAC_PART) := (others => '0');
  signal y_sfi : sfi(INT_PART-1 downto -FRAC_PART) := (others => '0');
  signal z_sfi : sfi(INT_PART-1 downto -FRAC_PART) := (others => '0');
  signal z_slv : slv(WORD-1 downto 0) := (others => '0');

  signal valid_reg, valid_next : slv(3-1 downto 0) := (others => '0');
  
  -- dx registers
  signal dx_reg, dx_next : asfi(0 to 5-1)(INT_PART-1 downto -FRAC_PART) := (others => (others => '0'));


  -- dy registers
  constant DY1_HIGH : integer := sfixed_high(INT_PART-1, -FRAC_PART, '*', INT_PART-1, -FRAC_PART);
  constant DY1_LOW : integer := sfixed_low(INT_PART-1, -FRAC_PART, '*', INT_PART-1, -FRAC_PART);
  signal dy1_reg, dy1_next : sfi(DY1_HIGH downto DY1_LOW) := (others => '0');

  constant DY2_HIGH : integer := sfixed_high(DY1_HIGH, DY1_LOW, '-', INT_PART-1, -FRAC_PART);
  constant DY2_LOW : integer := sfixed_low(DY1_HIGH, DY1_LOW, '-', INT_PART-1, -FRAC_PART);
  signal dy2_reg, dy2_next : sfi(DY2_HIGH downto DY2_LOW) := (others => '0');

  constant DY3_HIGH : integer := sfixed_high(DY2_HIGH, DY2_LOW, '-', INT_PART-1, -FRAC_PART);
  constant DY3_LOW : integer := sfixed_low(DY2_HIGH, DY2_LOW, '-', INT_PART-1, -FRAC_PART);
  signal dy3_reg, dy3_next : sfi(DY3_HIGH downto DY3_LOW) := (others => '0');

  constant DY4_HIGH : integer := INT_PART-1;
  constant DY4_LOW : integer := -FRAC_PART;
  signal dy4_reg, dy4_next : sfi(DY4_HIGH downto DY4_LOW) := (others => '0');
  
  constant DY5_HIGH : integer := INT_PART-1;
  constant DY5_LOW : integer := -FRAC_PART;
  signal dy5_reg, dy5_next : sfi(DY5_HIGH downto DY5_LOW) := (others => '0');

  -- dz registers
  signal exp_z : sfi(INT_PART-1 downto -FRAC_PART) := (others => '0');
  signal exp_z_slv : slv(WORD-1 downto 0) := (others => '0');

  constant DZ1_HIGH : integer := sfixed_high(INT_PART-1, -FRAC_PART, '+', INT_PART-1, -FRAC_PART);
  constant DZ1_LOW : integer := sfixed_low(INT_PART-1, -FRAC_PART, '+', INT_PART-1, -FRAC_PART);
  signal dz1_reg, dz1_next : sfi(DZ1_HIGH downto DZ1_LOW) := (others => '0');

  constant DZ2_HIGH : integer := sfixed_high(INT_PART-1, -FRAC_PART, '-', INT_PART-1, -FRAC_PART);
  constant DZ2_LOW : integer := sfixed_low(INT_PART-1, -FRAC_PART, '-', INT_PART-1, -FRAC_PART);
  signal dz2_reg, dz2_next : sfi(DZ2_HIGH downto DZ2_LOW) := (others => '0');

  constant DZ3_HIGH : integer := sfixed_high(DZ2_HIGH, DZ2_LOW, '*', INT_PART-1, -FRAC_PART);
  constant DZ3_LOW : integer := sfixed_low(DZ2_HIGH, DZ2_LOW, '*', INT_PART-1, -FRAC_PART);
  signal dz3_reg, dz3_next : sfi(DZ3_HIGH downto DZ3_LOW) := (others => '0');
  
  constant DZ4_HIGH : integer := sfixed_high(DZ3_HIGH, DZ3_LOW, '+', DZ1_HIGH, DZ1_LOW);
  constant DZ4_LOW : integer := sfixed_low(DZ3_HIGH, DZ3_LOW, '+', DZ1_HIGH, DZ1_LOW);
  signal dz4_reg, dz4_next : sfi(DZ4_HIGH downto DZ4_LOW) := (others => '0');
begin
  
  x_sfi <= to_sfixed(i_tdata(X_POS), INT_PART-1, -FRAC_PART);
  y_sfi <= to_sfixed(i_tdata(Y_POS), INT_PART-1, -FRAC_PART);
  z_sfi <= to_sfixed(i_tdata(Z_POS), INT_PART-1, -FRAC_PART);
  z_slv <= to_slv(z_sfi);

  EXP_APPROX : entity hw_chaos.exponent_approx
    generic map (
      LINE_COUNT => 3,
      X_MIN => -10.0,
      X_MAX => 10.0,

      INT_PART => 16,
      FRAC_PART => 16,
      WORD => 32
    )
    port map (
      clk => clk,
      rst => rst,

      i_tvalid => i_tvalid,
      o_tready => open,
      i_tdata => z_slv,

      o_tvalid => valid_next(0),
      i_tready => i_tready,
      o_tdata => exp_z_slv
    );
  -- reg-state logic
  process(clk, rst)
  begin
    if rst = '1' then
      valid_reg <= (others => '0');
      dx_reg <= (others => (others => '0'));
      dy1_reg <= (others => '0');
      dy2_reg <= (others => '0');
      dy3_reg <= (others => '0');
      dy4_reg <= (others => '0');
      dy5_reg <= (others => '0');
      dz1_reg <= (others => '0');
      dz2_reg <= (others => '0');
      dz3_reg <= (others => '0');
      dz4_reg <= (others => '0');
    elsif i_tready = '1' then
      if rising_edge(clk) then
        valid_reg <= valid_next;
        dx_reg <= dx_next;
        dy1_reg <= dy1_next;
        dy2_reg <= dy2_next;
        dy3_reg <= dy3_next;
        dy4_reg <= dy4_next;
        dy5_reg <= dy5_next;
        dz1_reg <= dz1_next;
        dz2_reg <= dz2_next;
        dz3_reg <= dz3_next;
        dz4_reg <= dz4_next;
      end if;
    end if;
  end process;
  
  -- next-state logic
  dx_next(0) <= y_sfi;
  dx_next(1 to 5-1) <= dx_reg(0 to 4-1);

  dy1_next <= to_sfixed(a, INT_PART-1, -FRAC_PART) * y_sfi;
  dy2_next <= dy1_reg - x_sfi;
  dy3_next <= dy2_reg - z_sfi;
  dy4_next <= dy3_reg(INT_PART-1 downto -FRAC_PART);
  dy5_next <= dy4_reg;

  exp_z <= to_sfixed(exp_z_slv, INT_PART-1, -FRAC_PART);
  dz1_next <= to_sfixed(b, INT_PART-1, -FRAC_PART) + y_sfi;
  dz2_next <= exp_z - to_sfixed(1.0, INT_PART-1, -FRAC_PART);
  dz3_next <= to_sfixed(-c, INT_PART-1, -FRAC_PART) * dz2_reg;
  dz4_next <= dz3_reg + dz1_reg;

  valid_next(2 downto 1) <= valid_reg(1 downto 0);
  -- outputs

  o_tready <= i_tready;

  o_tdata(X_POS) <= to_slv(dx_reg(4));
  o_tdata(Y_POS) <= to_slv(dy5_reg);
  o_tdata(Z_POS) <= to_slv(dz4_reg(INT_PART-1 downto -FRAC_PART));
  
  o_tvalid <= valid_reg(2);
end architecture;
