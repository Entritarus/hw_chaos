library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;
use ieee.fixed_float_types.all;
use ieee.math_real.all;

package data_types is

  alias sl is std_logic;
  alias slv is std_logic_vector;
  type aslv is array(integer range <>) of std_logic_vector;

  alias sfi is sfixed;

  type asfi is array(integer range <>) of sfixed;


  constant X_POS : natural := 0;
  constant Y_POS : natural := 1;
  constant Z_POS : natural := 2;
  
end package;


package body data_types is
  
  
end package body;
