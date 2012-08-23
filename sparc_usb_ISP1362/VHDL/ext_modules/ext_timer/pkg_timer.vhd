-------------------------------------------------------------------------------
-- Title      : 32 Bit Timer Architecture
-- Project    : SCARTS - Scalable Processor for Embedded Applications in
--              Realtime Environment
-------------------------------------------------------------------------------
-- File       : ext_timer.vhd
-- Author     : Ing. Stefan Simhandl
-- Company    : 
-- Created    : 2012-08-22
-- Last update: 
-- Platform   : CentOS 5
-------------------------------------------------------------------------------
-- Description:
-- Impelementation of 32 bit timer with 8 bit preescaler and option to set
-- a timer max/match value based on the extension counter module
-- (ext_counter.vhd)
-- TODO_: implement PWM mode
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author      Description
-- 2002-04-16  1.0      ssimhandl	  Created
-------------------------------------------------------------------------------

library ieee;;
use ieee.std_logic_1164.all;
use work.scarts_pkg.all;

-------------------------------------------------------------------------------
-- PACKAGE
-------------------------------------------------------------------------------

package pkg_timer is

-------------------------------------------------------------------------------
--                             COMPONENT
-------------------------------------------------------------------------------
    component ext_timer
      port (
        clk        : in   std_logic;
        extsel     : in   std_ulogic;
        exti       : in   module_in_type;
        exto       : out  module_out_type);
    end component;
-------------------------------------------------------------------------------
--                           END COMPONENT
-------------------------------------------------------------------------------

end pkg_timer;
-------------------------------------------------------------------------------
--                             END PACKAGE
-------------------------------------------------------------------------------

