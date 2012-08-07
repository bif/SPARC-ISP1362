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


-------------------------------------------------------------------------------
-- Company:		  Institut für Technische Informatik - Abteilung ECS
-- Engineer:		 Josef MOSSER, 0126655
--
-- Create Date:	 
-- Design Name:	 ext_ambadram
-- Module Name:	 AMBA shared memory - Behavioral
-- Project Name: AMBA4Scarts
-- Target Devices:
-- Tool versions:
-- Description:	 shared memory for data transport Scarts <-> AMBA
--
-- Dependencies: used in top entity and interface to ext_AMBA_DPRAM_32
--
-- Revision:		 0.8 - ready for testing
-- Additional Comments:
--	todo: 
--
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.scarts_core_pkg.all;
use work.scarts_pkg.all;

entity ext_AMBA_sharedmem is
  generic (
    CONF : scarts_conf_type);
  port (
    clk          : in  std_ulogic;
    rst          : in  std_ulogic;
    --ren          : in  std_ulogic;
    ambadramsel  : in  std_ulogic;
    ambadramlock : in  std_ulogic;
    exti         : in  module_in_type;
    exto         : out module_out_type;

    adrami_write_en  : in  std_ulogic;
    adrami_byte_en   : in  std_logic_vector(3 downto 0);
    adrami_data_in   : in  std_logic_vector(CONF.word_size-1 downto 0);
    adrami_addr      : in  std_logic_vector(CONF.amba_shm_size-1 downto CONF.amba_word_size/16);
    adramo_data_out  : out std_logic_vector(CONF.word_size-1 downto 0)  
    );
end ext_AMBA_sharedmem;

architecture behaviour of ext_AMBA_sharedmem is

signal dramsel : std_ulogic;

signal drami_write_en  : std_ulogic;
signal drami_byte_en   : std_logic_vector(3 downto 0);
signal drami_data_in   : std_logic_vector(CONF.word_size-1 downto 0);
signal drami_addr      : std_logic_vector(CONF.amba_shm_size-1 downto CONF.amba_word_size/16);
signal dramo_data_out  : std_logic_vector(CONF.word_size-1 downto 0);

signal olddata : std_logic_vector(31 downto 0);
signal newren  : std_ulogic;

begin

-- if AMBA uses dram --> dram always active
-- if AMBA doesn't use dram --> check if Scarts needs it else dataout is zero
dramsel <= ambadramsel when ambadramlock = '0' else '1';

--drami_addr(31 downto 8) <= (others => '0');
drami_addr(CONF.amba_shm_size-1 downto CONF.amba_word_size/16) <= exti.addr(CONF.amba_shm_size-1 downto CONF.amba_word_size/16) when ambadramlock = '0'
                                                                  else adrami_addr(CONF.amba_shm_size-1 downto CONF.amba_word_size/16);
drami_data_in(31 downto 0) <= exti.data(31 downto 0) when ambadramlock = '0' else adrami_data_in(31 downto 0);
drami_write_en <= (exti.write_en and ambadramsel) when ambadramlock = '0' else adrami_write_en;
drami_byte_en(3 downto 0) <= exti.byte_en(3 downto 0) when ambadramlock = '0' else adrami_byte_en(3 downto 0);

exto.data(31 downto 0) <= dramo_data_out(31 downto 0) when ambadramlock = '0' else (others => '0');
adramo_data_out(31 downto 0) <= dramo_data_out(31 downto 0);
exto.intreq <= '1' when (ambadramlock = '1' and ambadramsel = '1') else '0';

dram_unit: AMBA_sharedmem_dram
  generic map(CONF => CONF)
  port map(
    clk     => clk,
    dramsel => dramsel,
    write_en => drami_write_en,
    byte_en  => drami_byte_en,
    data_in  => drami_data_in,
    addr     => drami_addr,
    data_out => dramo_data_out
  );


end behaviour;
