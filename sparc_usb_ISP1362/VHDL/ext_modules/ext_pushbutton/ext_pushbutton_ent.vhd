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
-- Title      : Pushbuttons and switches for fpga board DE2-115 
-- Project    : SCARTS - Scalable Processor for Embedded Applications in
--              Realtime Environment
-----------------------------------------------------------------------
 
-----------------------------------------------------------------------
-- Description:
-- Entity
-----------------------------------------------------------------------
-- Copyright (c) 2012 
-----------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author    Description
-- 2012-07-11  1.0      ssimhandl	Created
-----------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE work.scarts_pkg.all;

use work.pkg_pushbutton.all;

-----------------------------------------------------------------------
-- ENTITY
-----------------------------------------------------------------------

entity ext_pushbutton is
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
    button1			: in std_logic;
	button2			: in std_logic;
	button3			: in std_logic
		
--		sw0 	  		: in std_logic;
--		sw1 	  		: in std_logic;
--		sw2 	  		: in std_logic;
--		sw3 	  		: in std_logic;
--		sw4 	  		: in std_logic;
--		sw5 	  		: in std_logic;
--		sw6 	  		: in std_logic;
--		sw7	    		: in std_logic;
--		sw8     		: in std_logic;
--		sw9		   	  	: in std_logic;
--		sw10	  		: in std_logic;
--		sw11	  		: in std_logic;
--		sw12	  		: in std_logic;
--		sw13	  		: in std_logic;
--		sw14	  		: in std_logic;
--		sw15	  		: in std_logic;
--		sw16	  		: in std_logic;
--		sw17	  		: in std_logic
  );

end entity ext_pushbutton;

---------------------------------------------------------------------
-- END ENTITY
-----------------------------------------------------------------


