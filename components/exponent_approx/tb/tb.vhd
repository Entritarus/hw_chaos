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

    LINE_COUNT : natural := 3;
    X_MIN : real := -10.0;
    X_MAX : real := 10.0;

    INT_PART : natural := 32;
    FRAC_PART : natural := 32;
    WORD : natural := INT_PART + FRAC_PART
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
  signal i_tdata : slv(WORD-1 downto 0) := (others => '0');
  signal i_tlast : sl := '0';

  signal o_tvalid : sl := '0';
  signal i_tready : sl := '0';
  signal o_tdata : slv(WORD-1 downto 0) := (others => '0');
  signal o_tlast : sl := '0';

  constant stream_master : axi_stream_master_t := new_axi_stream_master(
    data_length => WORD,
    stall_config => new_stall_config(0.1, 0, 10)
  );
  constant stream_slave : axi_stream_slave_t := new_axi_stream_slave(
    data_length => WORD,
    stall_config => new_stall_config(0.1, 0, 10)
  );
begin
  clk <= not clk after CLK_PERIOD/2;
  

  AXIS_MASTER: entity vunit_lib.axi_stream_master
    generic map (
      master => stream_master
    )
    port map (
      aclk => clk,
      tvalid => i_tvalid,
      tready => o_tready,
      tdata => i_tdata,
      tlast => i_tlast
    );
  AXIS_SLAVE: entity vunit_lib.axi_stream_slave
    generic map (
      slave => stream_slave
    )
    port map (
      aclk => clk,
      tvalid => o_tvalid,
      tready => i_tready,
      tdata => o_tdata,
      tlast => o_tlast
    );
  --------------------------------------------------------------------------------
  -- DUT instantiation
  --------------------------------------------------------------------------------

  DUT: entity hw_chaos.exponent_approx
    generic map (
      LINE_COUNT => LINE_COUNT,
      X_MIN => X_MIN,
      X_MAX => X_MAX,

      INT_PART => INT_PART,
      FRAC_PART => FRAC_PART
    )
    port map(
      clk => clk,
      rst => rst,

      i_tvalid => i_tvalid,
      o_tready => o_tready,
      i_tdata => i_tdata,
      i_tlast => i_tlast,

      o_tvalid => o_tvalid,
      i_tready => i_tready,
      o_tdata => o_tdata,
      o_tlast => o_tlast
    );

  --------------------------------------------------------------------------------
  -- Test sequencer
  --------------------------------------------------------------------------------
  process
    variable x_step : real := 0.0;
    variable x : real := 0.0;
    variable x_sfi : sfixed(i_tdata'range);
    variable x_slv : slv(WORD-1 downto 0);
    variable result : slv(o_tdata'range);
    variable tlast : sl := '0';
  begin
    test_runner_setup(runner, runner_cfg);
    
    while test_suite loop
    
    
      if run("Full_coverage") then
        wait for CLK_PERIOD; 
        rst <= '0';
        
        x_step := (X_MAX-X_MIN)/200.0;
        info("x_step: =" & to_string(x_step));

        for i in -100 to 100 loop
          x := real(i)*x_step;
          x_sfi := to_sfixed(x, INT_PART-1, -FRAC_PART);
          x_slv := to_slv(x_sfi);
          push_axi_stream(net, stream_master, x_slv, '0');
        end loop;
        
        for i in 0 to 200 loop
          pop_axi_stream(net, stream_slave, result, tlast);
        end loop;
      end if;
      
      
    end loop;
    
    test_runner_cleanup(runner);
  end process;
end architecture;
