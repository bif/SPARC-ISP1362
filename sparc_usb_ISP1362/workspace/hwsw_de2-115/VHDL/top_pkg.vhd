-----------------------------------------------------------------------
-- This file is part of SCARTS.
-- 
-- SCARTS is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- SCARTS is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with SCARTS.  If not, see <http://www.gnu.org/licenses/>.
-----------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

--library grlib;
--use grlib.amba.all;

package top_pkg is

  constant CLK_FREQ : integer range 1 to integer'high := 50000000;

  --constant AHB_SLAVE_COUNT : natural := 2;
  --constant APB_SLAVE_COUNT : natural := 1;

  --constant VENDOR_TEST     : amba_vendor_type := 16#FF#;
  --constant TEST_SCARTS     : amba_device_type := 16#000#;
  --constant SCARTS_VERSION  : amba_version_type := 16#00#;
  --constant AMBA_MASTER_CONFIG : ahb_config_type := (
  --  0 => ahb_device_reg(VENDOR_TEST, TEST_SCARTS, 0, SCARTS_VERSION, 0),
  --  others => (others => '0'));
  
end top_pkg;
