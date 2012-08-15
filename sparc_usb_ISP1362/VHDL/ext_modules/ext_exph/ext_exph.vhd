-------------------------------------------------------------------------------
-- Title      : Extention Module for Expansion header of DE2 board 
-- Project    : SCARTS - Scalable Processor for Embedded Applications in
--              Realtime Environment
-------------------------------------------------------------------------------
-- File       : ext_exph.vhd
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.scarts_pkg.all;
use work.pkg_exph.all;

architecture behaviour of ext_exph is

subtype BYTE is std_logic_vector(7 downto 0);
type register_set is array (0 to 7) of BYTE;

constant STATUSREG_CUST : integer := 1;
constant CONFIGREG_CUST : integer := 3;

type reg_type is record
  ifacereg  : register_set;
end record;

signal r_next : reg_type;
signal r : reg_type := 
  (
    ifacereg => (others => (others => '0'))
  ); 
signal rstint : std_ulogic;

begin

  comb : process(r, exti, extsel)
  variable v : reg_type;
  begin
    v := r;
  
    --schreiben
    if ((extsel = '1') and (exti.write_en = '1')) then
      case exti.addr(4 downto 2) is
        when "000" =>
          if ((exti.byte_en(0) = '1') or (exti.byte_en(1) = '1')) then
            v.ifacereg(STATUSREG)(STA_INT) := '1';
            v.ifacereg(CONFIGREG)(CONF_INTA) :='0';
          else
            if ((exti.byte_en(2) = '1')) then
              v.ifacereg(2) := exti.data(23 downto 16);
            end if;
          end if;
				when others =>
          null;
      end case;
    end if;

    --auslesen
    exto.data <= (others => '0');
    if ((extsel = '1') and (exti.write_en = '0')) then
      case exti.addr(4 downto 2) is
        when "000" =>
          exto.data <= r.ifacereg(3) & r.ifacereg(2) & r.ifacereg(1) & r.ifacereg(0);
        when "001" =>
          if (r.ifacereg(CONFIGREG)(CONF_ID) = '1') then
            exto.data <= MODULE_VER & MODULE_ID;
          else
            exto.data <= r.ifacereg(7) & r.ifacereg(6) & r.ifacereg(5) & r.ifacereg(4);
          end if;
        when others =>
          null;
      end case;
    end if;
   
    
    --berechnen der neuen status flags
    v.ifacereg(STATUSREG)(STA_LOOR) := r.ifacereg(CONFIGREG)(CONF_LOOW);
    v.ifacereg(STATUSREG)(STA_FSS) := '0';
    v.ifacereg(STATUSREG)(STA_RESH) := '0';
    v.ifacereg(STATUSREG)(STA_RESL) := '0';
    v.ifacereg(STATUSREG)(STA_BUSY) := '0';
    v.ifacereg(STATUSREG)(STA_ERR) := '0';
    v.ifacereg(STATUSREG)(STA_RDY) := '1';

    -- Output soll Defaultmassig auf eingeschalten sie 
    v.ifacereg(CONFIGREG)(CONF_OUTD) := '1';
    
    
    --soft- und hard-reset vereinen
    rstint <= not RST_ACT;
    if exti.reset = RST_ACT or r.ifacereg(CONFIGREG)(CONF_SRES) = '1' then
      rstint <= RST_ACT;
    end if;
    
    -- Interrupt
    if r.ifacereg(STATUSREG)(STA_INT) = '1' and r.ifacereg(CONFIGREG)(CONF_INTA) ='0' then
      v.ifacereg(STATUSREG)(STA_INT) := '0';
    end if; 
    exto.intreq <= '0';

    -- module specific part
--		PINS(7 downto 0)	  <= r.ifacereg(3);
-- 		PINS(15 downto 8) 	<= r.ifacereg(4);
--		PINS(23 downto 16)  <= r.ifacereg(5);
--		PINS(31 downto 24)  <= r.ifacereg(6);
--		PINS(39 downto 32)  <= r.ifacereg(7);
		PINS <= r.ifacereg(3)(0);
    r_next <= v;
  end process;

  reg : process(clk)
  begin
    if rising_edge(clk) then 
      if rstint = RST_ACT then
        r.ifacereg <= (others => (others => '0'));
      else
        r <= r_next;
      end if;
    end if;
  end process;

end behaviour;
