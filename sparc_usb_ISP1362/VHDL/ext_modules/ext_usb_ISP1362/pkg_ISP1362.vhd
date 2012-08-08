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


-----------------------------------------------------------------------
-- Title      : Extension Module for the USB chip ISP1362 on fpga board 
--				DE2-115 
-- Project    : SCARTS - Scalable Processor for Embedded Applications 
--              in Realtime Environment
-----------------------------------------------------------------------
 
-----------------------------------------------------------------------
-- Description:
-- Entity
-----------------------------------------------------------------------
-- Copyright (c) 2012 
-----------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author    Description
-- 2012-08-04  1.0      ssimhandl	Created
-----------------------------------------------------------------------


LIBRARY IEEE;
use IEEE.std_logic_1164.all;

use work.scarts_pkg.all;


----------------------------------------------------------------------
-- PACKAGE
----------------------------------------------------------------------

package pkg_ISP1362 is
  
  component ext_ISP1362
		port (
			------------------------------------------------------------------
			-- Generic Ports
			------------------------------------------------------------------
			clk        : in  std_logic;
			extsel     : in  std_ulogic;
			exti       : in  module_in_type;
			exto       : out module_out_type;
			------------------------------------------------------------------
			-- Module Specific Ports
			------------------------------------------------------------------
			USB_DATA	: inout std_logic_vector (15 downto 0);
			USB_ADDR	: out std_logic_vector (1 downto 0); 
			USB_RD_N	: out std_logic;
			USB_WR_N	: out std_logic;
			USB_CS_N	: out std_logic;
			USB_RST_N	: out std_logic;
			USB_INT0	: in std_logic;
			USB_INT1	: in std_logic
		);
end component;

end pkg_ISP1362;

---------------------------------------------------------------------
-- END PACKAGE
--------------------------------------------------------------------- 
