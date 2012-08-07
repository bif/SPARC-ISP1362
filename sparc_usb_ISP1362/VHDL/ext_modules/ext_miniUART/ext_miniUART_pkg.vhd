library ieee;
use ieee.std_logic_1164.all;
use work.scarts_pkg.all;

package ext_miniUART_pkg is

  component ext_miniUART IS
    PORT(
      ---------------------------------------------------------------
      -- Generic Ports
      ---------------------------------------------------------------
      clk           : IN  std_logic;  
      extsel        : in  std_logic;
      Exti          : in module_in_type;
      Exto          : out module_out_type;
      
      ---------------------------------------------------------------
      -- Module Specific Ports
      ---------------------------------------------------------------
      RxD           : IN std_logic;  -- Empfangsleitung
      TxD           : OUT std_logic  -- Sendeleitung
      );
  end component;  

end ext_miniUART_pkg;



