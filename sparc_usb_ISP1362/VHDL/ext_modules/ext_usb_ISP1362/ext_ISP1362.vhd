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
-- Title:			Extension Module for the USB chip ISP1362 on fpga board 
--						DE2-115 
-- Project:		SCARTS - Scalable Processor for Embedded Applications 
--            in Realtime Environment
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


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.scarts_pkg.all;
use work.pkg_ISP1362.all;

---------------------------------------------------------------------
-- architecture
---------------------------------------------------------------------
architecture behaviour of ext_ISP1362 is

---------------------------------------------------------------------
-- define type for extension module register set  
---------------------------------------------------------------------
subtype ext_register is std_logic_vector(7 downto 0);
type register_set is array (0 to 9) of ext_register;

---------------------------------------------------------------------
-- define constants 
---------------------------------------------------------------------
constant HIGH_IMPENDANT	: std_logic_vector := "ZZZZZZZZZZZZZZZZ";

-- DC control & status registers
constant STATUSREG_CUST		: integer	:= 2;
constant CONFIGREG_CUST		:	integer	:= 3;

-- DC data registers
constant DC_DATA_IN_LOW		: integer	:= 4;
constant DC_DATA_IN_HIGH	:	integer	:= 5;
constant DC_DATA_OUT_LOW	: integer	:= 6;
constant DC_DATA_OUT_HIGH	:	integer	:= 7;

-- indicies - flags of DC_CONTROL_REG 
constant avs_dc_address_iADDR				: integer := 0;
constant avs_dc_read_n_iRD_N				: integer := 1;
constant avs_dc_write_n_iWR_N				: integer := 2;
constant avs_dc_chipselect_n_iCS_N	: integer := 3;
constant avs_dc_reset_n_iRST_N			: integer := 4;
constant avs_dc_clk_iCLK						: integer := 5;
constant avs_dc_irq_n_oINT0_N				: integer := 6;


---------------------------------------------------------------------
-- define signals 
---------------------------------------------------------------------
signal r_next : register_set;
signal r : register_set := (others => (others => '0'));
   
signal rstint : std_ulogic;

begin -- behaviour
	------------------------------------------------------------------
  -- sync process
	------------------------------------------------------------------
  reg : process(clk, rstint)
  begin
    if rising_edge(clk) then 
      if rstint = RST_ACT then
        r <= (others => (others => '0'));
      else
        r(STATUSREG) <= r_next(STATUSREG);
				r(CONFIGREG) <= r_ext(CONFIGREG);
      end if;
    end if;
  end process;

	------------------------------------------------------------------
  -- extension module process
	------------------------------------------------------------------
  comb : process(r, exti, extsel, USB_DATA, USB_INT0, USB_INT1)
    variable v : register_set;
  begin
    v := r;
        
    -- write memory mapped addresses
		if ((extsel = '1') and (exti.write_en = '1')) then
      case exti.addr(4 downto 2) is
        when "000" =>
          if ((exti.byte_en(0) = '1') or (exti.byte_en(1) = '1')) then
            -- TODO which bits have to be written? 
            v(STATUSREG)(STA_INT) := '1';
            v(CONFIGREG)(CONF_INTA) :='0';
          else
            if ((exti.byte_en(2) = '1')) then
              v(STATUSREG_CUST) := exti.data(23 downto 16);
            end if;
            if ((exti.byte_en(3) = '1')) then
              v(CONFIGREG_CUST) := exti.data(31 downto 24);
            end if;
          end if;
        when "001" =>
          if ((exti.byte_en(0) = '1')) then
            v(DC_DATA_IN_LOW) := exti.data(7 downto 0);
          end if;
          if ((exti.byte_en(1) = '1')) then
            v(DC_DATA_IN_HIGH) := exti.data(15 downto 8);
          end if;
          if ((exti.byte_en(2) = '1')) then
            v(DC_DATA_OUT_LOW) := exti.data(23 downto 16);
          end if;
          if ((exti.byte_en(3) = '1')) then
            v(DC_DATA_OUT_HIGH) := exti.data(31 downto 24);
          end if;
        when others =>
          null;
      end case;
    end if;
    
    -- read memory mapped addresses
    exto.data <= (others => '0');
    if ((extsel = '1') and (exti.write_en = '0')) then
      case exti.addr(4 downto 2) is
        when "000" =>
          exto.data <= r.ifacereg(3) & r.ifacereg(2) & r.ifacereg(1) & r.ifacereg(0);
        when "001" =>
          if (r.ifacereg(CONFIGREG)(CONF_ID) = '1') then
            exto.data <= MODULE_VER & MODULE_ID;
          else
            exto.data <= r.ifacereg(7) & r.ifacereg(6) & r.ifacereg(5) & r.ifacereg(REG_BUTTONS);
          end if;
        when others =>
          null;
      end case;
    end if;
   
    -- compute status flags
    v.ifacereg(STATUSREG)(STA_LOOR) := r.ifacereg(CONFIGREG)(CONF_LOOW);
    v.ifacereg(STATUSREG)(STA_FSS) := '0';
    v.ifacereg(STATUSREG)(STA_RESH) := '0';
    v.ifacereg(STATUSREG)(STA_RESL) := '0';
    v.ifacereg(STATUSREG)(STA_BUSY) := '0';
    v.ifacereg(STATUSREG)(STA_ERR) := '0';
    v.ifacereg(STATUSREG)(STA_RDY) := '1';

    -- set output enabled (default)
    v.ifacereg(CONFIGREG)(CONF_OUTD) := '1';
     
    -- combine soft- and hard-reset
    rstint <= not RST_ACT;
    if exti.reset = RST_ACT or r.ifacereg(CONFIGREG)(CONF_SRES) = '1' then
      rstint <= RST_ACT;
    end if;

    -- reset interrupt
    if r.ifacereg(STATUSREG)(STA_INT) = '1' and r.ifacereg(CONFIGREG)(CONF_INTA) ='0' then
      v.ifacereg(STATUSREG)(STA_INT) := '0';
    end if; 

    --  set interrupt
    --if r.ifacereg(CONFIGREG)(CONF_INTA) ='1' then
    --  v.ifacereg(STATUSREG)(STA_INT) := '0';
    --  v.ifacereg(CONFIGREG)(CONF_INTA) := '0';
    --end if;

    -- write interupt flag
    exto.intreq <= r.ifacereg(STATUSREG)(STA_INT);

    -- module specific part
    for i in 1 to 3 loop
      v.ifacereg(REG_BUTTONS)(i) := buttons(i);
    end loop;  

    r_next <= v;
  end process;



end behaviour;
