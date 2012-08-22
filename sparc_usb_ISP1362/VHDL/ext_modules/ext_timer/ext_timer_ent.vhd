-------------------------------------------------------------------------------
-- Title      : 7 Segment Display Architecture
-- Project    : SCARTS - Scalable Processor for Embedded Applications in
--              Realtime Environment
-------------------------------------------------------------------------------
-- File       : ext_sysctrl_ent.vhd
-- Author     : Dipl. Ing. Martin Delvai
-- Company    : TU Wien - Institut fr technische Informatik
-- Created    : 2002-02-11
-- Last update: 2011-10-20
-- Platform   : SUN Solaris 
-------------------------------------------------------------------------------
-- Description:
--
-------------------------------------------------------------------------------
-- Copyright (c) 2002 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2002-02-11  1.0      delvai	Created
-------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- LIBRARY
--------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

USE work.scarts_pkg.all;
use work.pkg_counter.all;

----------------------------------------------------------------------------------
-- ENTITY
----------------------------------------------------------------------------------


entity ext_counter is
  port(
        clk                     : IN  std_logic;
        extsel                  : in std_ulogic;
        exti                    : in  module_in_type;
        exto                    : out module_out_type
    );
end ext_counter;

----------------------------------------------------------------------------------
-- END ENTITY
----------------------------------------------------------------------------------


