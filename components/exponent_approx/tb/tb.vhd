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

  signal i_value : slv(WORD-1 downto 0) := (others => '0');
  signal i_valid : sl := '0';
  signal o_ready : sl := '1';

  signal o_result : slv(WORD-1 downto 0) := (others => '0');
  signal o_valid : sl := '0';
  signal i_ready : sl := '0';

  constant stream_master : axi_stream_master_t := new_axi_stream_master(
    data_length => WORD,
    stall_config => new_stall_config(0.0, 0, 10)
  );
  constant stream_slave : axi_stream_slave_t := new_axi_stream_slave(
    data_length => WORD,
    stall_config => new_stall_config(0.0, 0, 10)
  );
begin
  clk <= not clk after CLK_PERIOD/2;
  

  AXIS_MASTER: entity vunit_lib.axi_stream_master
    generic map (
      master => stream_master
    )
    port map (
      aclk => clk,
      tvalid => i_valid,
      tready => o_ready,
      tdata => i_value
    );
  AXIS_SLAVE: entity vunit_lib.axi_stream_slave
    generic map (
      slave => stream_slave
    )
    port map (
      aclk => clk,
      tvalid => o_valid,
      tready => i_ready,
      tdata => o_result
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

      i_value => i_value,
      i_valid => i_valid,

      o_result => o_result,
      o_valid => o_valid
    );

  --------------------------------------------------------------------------------
  -- Test sequencer
  --------------------------------------------------------------------------------
  process
    variable x_step : real := 0.0;
    variable x : real := 0.0;
    variable x_sfi : sfixed(i_value'range);
    variable x_slv : slv(WORD-1 downto 0);
    variable result : slv(o_result'range);
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
        
        for i in 0 to 100 loop
          pop_axi_stream(net, stream_slave, result, tlast);
        end loop;
      end if;
      
      
    end loop;
    
    test_runner_cleanup(runner);
  end process;
end architecture;
