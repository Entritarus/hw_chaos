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
    tb_path : string;
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

  signal i_sync_select : slv(3-1 downto 0) := (others => '0');

  signal i_tvalid : sl := '0';
  signal o_tready : sl := '0';
  signal i_tdata : aslv(0 to 3-1)(WORD-1 downto 0) := (others => (others => '0'));

  signal o_tvalid : sl := '0';
  signal i_tready : sl := '1';
  signal o_tdata : aslv(0 to 3-1)(WORD-1 downto 0) := (others => (others => '0'));

  signal o_tdata_slv : slv(3*WORD-1 downto 0) := (others => '0');

  signal o_tdata_sfi : asfi(0 to 3-1)(INT_PART-1 downto -FRAC_PART) := (others => (others => '0'));

  constant stream_slave : axi_stream_slave_t := new_axi_stream_slave(
    data_length => 3*WORD,
    stall_config => new_stall_config(0.0, 0, 10)
  );

  constant POINT_COUNT : natural := 1000000;
  constant MEM_OUT_X : integer_array_t := new_1d(
    length => POINT_COUNT
  );
  constant MEM_OUT_Y : integer_array_t := new_1d(
    length => POINT_COUNT
  );
  constant MEM_OUT_Z : integer_array_t := new_1d(
    length => POINT_COUNT
  );
begin
  clk <= not clk after CLK_PERIOD/2;
  rst <= '0' after CLK_PERIOD;

  o_tdata_slv <= o_tdata(Z_POS) & o_tdata(Y_POS) & o_tdata(X_POS);
  
  AXIS_SLAVE: entity vunit_lib.axi_stream_slave
    generic map (
      slave => stream_slave
    )
    port map (
      aclk => clk,
      tvalid => o_tvalid,
      tready => i_tready,
      tdata => o_tdata_slv
    );
  --------------------------------------------------------------------------------
  -- DUT instantiation
  --------------------------------------------------------------------------------

  DUT: entity hw_chaos.vilnius_oscillator
    generic map (
      a => 0.600,
      b => 19.323671,
      c => 0.002318840,
      e => 0.150, 

      dt => 0.001,

      INT_PART => 16,
      FRAC_PART => 16,
      WORD => 32
    )
    port map (
      clk => clk,
      rst => rst,

      i_sync_select => i_sync_select,

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
    variable output_data : slv(3*WORD-1 downto 0);
    variable tlast : sl;
  begin
    test_runner_setup(runner, runner_cfg);
    
    while test_suite loop
    
    
      if run("Full_coverage") then

        i_tvalid <= '1';
        -- i_tdata(X_POS) <= to_slv(to_sfixed(1, INT_PART-1, -FRAC_PART));
        -- i_tdata(Y_POS) <= to_slv(to_sfixed(1, INT_PART-1, -FRAC_PART));
        -- i_tdata(Z_POS) <= to_slv(to_sfixed(1, INT_PART-1, -FRAC_PART));
        for i in 0 to POINT_COUNT-1 loop
          pop_axi_stream(net, stream_slave, output_data, tlast);
          set(MEM_OUT_X, i, to_integer(signed(output_data(WORD-1 downto 0))));
          set(MEM_OUT_Y, i, to_integer(signed(output_data(2*WORD-1 downto WORD))));
          set(MEM_OUT_Z, i, to_integer(signed(output_data(3*WORD-1 downto 2*WORD))));
        end loop;

        save_csv(MEM_OUT_X, tb_path & "../sim/test_out_x.csv");
        save_csv(MEM_OUT_Y, tb_path & "../sim/test_out_y.csv");
        save_csv(MEM_OUT_Z, tb_path & "../sim/test_out_z.csv");

      end if;
      
      
    end loop;
    
    test_runner_cleanup(runner);
  end process;
end architecture;
