-------------------------------------------------------------------------------
-- Title      : 7 Segment Display Architecture
-- Project    : SPEAR - Scalable Processor for Embedded Applications in
--              Realtime Environment
-------------------------------------------------------------------------------
-- File       : ext_display7seg.vhd
-- Author     : Dipl. Ing. Martin Delvai
-- Company    : TU Wien - Institut fr Technische Informatik
-- Created    : 2002-04-16
-- Last update: 2011-04-01
-- Platform   : SUN Solaris
-------------------------------------------------------------------------------
-- Description:
-- Dieses Module kann zum Ansteuern eines vierstelligen 7 Segment Modules  verwendet
-- werden. Die vier Anzeigen werden gemultiplext angesteuer. 
-- Durch einen Prescaler kann man die Frequenz des weiterschaltens einsetellen.
-- Zus?zlich besitzt es noch einen 8 Bit Ausgang zum Ansteuern von z.B. LEDs 
-------------------------------------------------------------------------------
-- Copyright (c) 2002 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2002-04-16  1.0      delvai	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.spear_pkg.all;
use work.pkg_counter.all;

architecture behaviour of ext_counter is

subtype BYTE is std_logic_vector(7 downto 0);
type register_set is array (0 to 7) of BYTE;

constant STATUSREG_CUST : integer := 1;
constant CONFIGREG_CUST : integer := 3;

constant ZEROVALUE      : std_logic_vector(15 downto 0) := (others => '0');

constant COUNTER_BYTE0      : integer := 8;
constant COUNTER_BYTE1      : integer := 9;
constant COUNTER_BYTE2      : integer := 10;
constant COUNTER_BYTE3      : integer := 11;

type reg_type is record
  ifacereg  : register_set;
  counter   : std_logic_vector(31 downto 0);
  prescaler : std_logic_vector(7 downto 0);
end record;


signal r_next : reg_type;
signal r : reg_type := 
  (
    ifacereg => (others => (others => '0')),
--    ifacereg => (PRESCALER_REG => x"01", others => (others => '0')),
    counter => (others => '0'),
    --prescaler => x"01"
    prescaler => x"00"
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
            if ((exti.byte_en(3) = '1')) then
              v.ifacereg(3) := exti.data(31 downto 24);
            end if;
          end if;
        when "001" =>
          if ((exti.byte_en(0) = '1')) then
            v.ifacereg(4) := exti.data(7 downto 0);
          end if;
          if ((exti.byte_en(1) = '1')) then
            v.ifacereg(5) := exti.data(15 downto 8);
          end if;
          if ((exti.byte_en(2) = '1')) then
            v.ifacereg(6) := exti.data(23 downto 16);
          end if;
          if ((exti.byte_en(3) = '1')) then
            v.ifacereg(7) := exti.data(31 downto 24);
          end if;
        when "010" =>
          if ((exti.byte_en(0) = '1')) then
            v.counter(7 downto 0) := exti.data(7 downto 0);
          end if;
          if ((exti.byte_en(1) = '1')) then
            v.counter(15 downto 8) := exti.data(15 downto 8);
          end if;
          if ((exti.byte_en(2) = '1')) then
            v.counter(23 downto 16) := exti.data(23 downto 16);
          end if;
          if ((exti.byte_en(3) = '1')) then
            v.counter(31 downto 24) := exti.data(31 downto 24);
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
        when "010" =>
          exto.data <= r.counter;
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
    exto.intreq <= r.ifacereg(STATUSREG)(STA_INT);

    --module specific part
    v.counter := r.counter;
    
    if r.ifacereg(MY_CONFIGREG)(CMD_COUNT) = '1' then
      if r.prescaler = r.ifacereg(PRESCALER_REG) then
        v.counter := STD_LOGIC_VECTOR(UNSIGNED(r.counter) + 1);
        v.prescaler := (others => '0');
      else
        v.prescaler := STD_LOGIC_VECTOR(UNSIGNED(r.prescaler) + 1);        
      end if;

    elsif r.ifacereg(MY_CONFIGREG)(CMD_CLEAR) = '1' then
      v.counter := (others => '0');
      v.prescaler := (others => '0');
    end if;
    
    r_next <= v;
  end process;

  reg : process(clk)
  begin
    if rising_edge(clk) then 
      if rstint = RST_ACT then
        r.ifacereg <= (others => (others => '0'));
        --r.ifacereg(PRESCALER_REG) <= x"01";
        r.counter <= (others => '0');
        --r.prescaler <= x"01";
      else
        r <= r_next;
      end if;
    end if;
  end process;

end behaviour;
