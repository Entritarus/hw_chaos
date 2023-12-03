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
    runner_cfg : string;
    INT_PART : integer := 16;
    FRAC_PART : integer := 16;
    WORD : integer := INT_PART + FRAC_PART
  );
end entity;

architecture RTL of tb is
  --------------------------------------------------------------------------------
  -- DUT interfacing
  --------------------------------------------------------------------------------
  
  constant CLK_PERIOD : time := 10 ns;
  signal clk : sl := '1';
  signal rst : sl := '1';

  signal i_tvalid : sl := '0';
  signal o_tready : sl := '0';
  signal i_tdata : aslv(0 to 3-1)(WORD-1 downto 0) := (others => (others => '0'));

  signal o_tvalid : sl := '0';
  signal i_tready : sl := '1';
  signal o_tdata : aslv(0 to 3-1)(WORD-1 downto 0) := (others => (others => '0'));

  signal o_tdata_sfi : asfi(0 to 3-1)(INT_PART-1 downto -FRAC_PART) := (others => (others => '0'));

begin
  clk <= not clk after CLK_PERIOD/2;
  rst <= '0' after CLK_PERIOD;
  
  --------------------------------------------------------------------------------
  -- DUT instantiation
  --------------------------------------------------------------------------------

  DUT: entity hw_chaos.deriv_calc
    generic map (
      a => 1.0,
      b => 1.0,
      c => 1.0,
      e => 1.0,

      INT_PART => 16,
      FRAC_PART => 16,
      WORD => 32
    )
    port map (
      clk => clk,
      rst => rst,

      i_tvalid => i_tvalid,
      o_tready => o_tready,
      i_tdata => i_tdata,

      o_tvalid => o_tvalid,
      i_tready => i_tready,
      o_tdata => o_tdata
    );


  o_tdata_sfi(X_POS) <= to_sfixed(o_tdata(X_POS), INT_PART-1, -FRAC_PART);
  o_tdata_sfi(Y_POS) <= to_sfixed(o_tdata(Y_POS), INT_PART-1, -FRAC_PART);
  o_tdata_sfi(Z_POS) <= to_sfixed(o_tdata(Z_POS), INT_PART-1, -FRAC_PART);

  --------------------------------------------------------------------------------
  -- Test sequencer
  --------------------------------------------------------------------------------
  process
    variable input_data : slv(3*WORD-1 downto 0);
  begin
    test_runner_setup(runner, runner_cfg);
    
    while test_suite loop
    
    
      if run("Full_coverage") then

        i_tvalid <= '1';
        i_tdata(X_POS) <= to_slv(to_sfixed(1000, INT_PART-1, -FRAC_PART));
        i_tdata(Y_POS) <= to_slv(to_sfixed(1000, INT_PART-1, -FRAC_PART));
        i_tdata(Z_POS) <= to_slv(to_sfixed(10, INT_PART-1, -FRAC_PART));
        wait for 100 ns;
      end if;
      
      
    end loop;
    
    test_runner_cleanup(runner);
  end process;
end architecture;
