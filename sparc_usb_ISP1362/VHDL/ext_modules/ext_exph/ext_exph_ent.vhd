-------------------------------------------------------------------------------
-- Title      : Extention Module for Expansion header of DE2 board 
-- Project    : SCARTS - Scalable Processor for Embedded Applications in
--              Realtime Environment
-------------------------------------------------------------------------------
-- File       : ext_exph_ent.vhd
-- Author     : Ing. Stefan Simhandl
-- Company    : 
-- Created    : 2012-08-15
-- Last update: 
-- Platform   : CENTOS 5 
-------------------------------------------------------------------------------
-- Description:
--
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date      	  Version	  Author		  Description
-- 2012-08-15	  1.0    	  ssimhandl		Created
-------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- LIBRARY
--------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

USE work.scarts_pkg.all;
use work.pkg_exph.all;

----------------------------------------------------------------------------------
-- ENTITY
----------------------------------------------------------------------------------


entity ext_exph is
  port(
        clk         : IN  std_logic;
        extsel      : in std_ulogic;
        exti        : in  module_in_type;
        exto        : out module_out_type;
				PINS			: out std_logic_vector(2 downto 0)
  );
end ext_exph;

----------------------------------------------------------------------------------
-- END ENTITY
----------------------------------------------------------------------------------


