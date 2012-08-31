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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.scarts_pkg.all;

architecture behaviour of ext_timer is

-- byte 0 t0 3  ... config & status registers
-- byte 4 to 7  ... counter mach value
-- byte 8       ... preescaler match value
subtype BYTE is std_logic_vector(7 downto 0);
type register_set is array (0 to 8) of BYTE;

constant STATUSREG_CUST : integer := 1; 
constant CONFIGREG_CUST : integer := 3;  

constant BASE_COUNTER_MATCH     : integer := 4;
constant PRESCALER_MATCH        : integer := 8;

constant START_C    :integer := 0;
constant STOP_C     :integer := 1;

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
--          if ((exti.byte_en(0) = '1') or (exti.byte_en(1) = '1')) then
--            v.ifacereg(STATUSREG)(STA_INT) := '1';
--            v.ifacereg(CONFIGREG)(CONF_INTA) :='0';
--          else
--            if ((exti.byte_en(2) = '1')) then
--              v.ifacereg(2) := exti.data(23 downto 16);
--            end if;
--            if ((exti.byte_en(3) = '1')) then
--             v.ifacereg(3) := exti.data(31 downto 24);
--            end if;
          if ((exti.byte_en(0) = '1')) then
            v.ifacereg(STATUSREG) := exti.data(7 downto 0);
          end if;
          if ((exti.byte_en(1) = '1')) then
            v.ifacereg(STATUSREG_CUST) := exti.data(15 downto 8);
          end if; 
          if ((exti.byte_en(2) = '1')) then
             v.ifacereg(CONFIGREG) := exti.data(23 downto 16);
          end if;
          if ((exti.byte_en(3) = '1')) then
            v.ifacereg(CONFIGREG_CUST) := exti.data(31 downto 24);
          end if;
        when "001" =>
          if ((exti.byte_en(0) = '1')) then
            v.ifacereg(BASE_COUNTER_MATCH) := exti.data(7 downto 0);
          end if;
          if ((exti.byte_en(1) = '1')) then
            v.ifacereg(BASE_COUNTER_MATCH+1) := exti.data(15 downto 8);
          end if;
          if ((exti.byte_en(2) = '1')) then
            v.ifacereg(BASE_COUNTER_MATCH+2) := exti.data(23 downto 16);
          end if;
          if ((exti.byte_en(3) = '1')) then
            v.ifacereg(BASE_COUNTER_MATCH+3) := exti.data(31 downto 24);
          end if;
        when "010" =>
          if ((exti.byte_en(0) = '1')) then
            v.ifacereg(PRESCALER_MATCH) := exti.data(7 downto 0);
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
          exto.data <= r.ifacereg(CONFIGREG_CUST) & r.ifacereg(CONFIGREG) & r.ifacereg(STATUSREG_CUST) & r.ifacereg(STATUSREG);
        when "001" =>
          if (r.ifacereg(CONFIGREG)(CONF_ID) = '1') then
            exto.data <= MODULE_VER & MODULE_ID;
          else
            exto.data <= r.ifacereg(BASE_COUNTER_MATCH+3) & r.ifacereg(BASE_COUNTER_MATCH+2) & r.ifacereg(BASE_COUNTER_MATCH+1) & r.ifacereg(BASE_COUNTER_MATCH);
          end if;
        when "010" =>
          exto.data <= "00000000" & "00000000" & "00000000" & r.ifacereg(PRESCALER_MATCH);
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
    --if r.ifacereg(STATUSREG)(STA_INT) = '1' and r.ifacereg(CONFIGREG)(CONF_INTA) ='0' then
    --  v.ifacereg(STATUSREG)(STA_INT) := '0';
    --end if; 
    --exto.intreq <= r.ifacereg(STATUSREG)(STA_INT);
  
    -- Interrupt
    if r.ifacereg(CONFIGREG)(CONF_INTA) ='1' then
      v.ifacereg(STATUSREG)(STA_INT) := '0';
      v.ifacereg(CONFIGREG)(CONF_INTA) := '0';
    end if; 
    exto.intreq <= r.ifacereg(STATUSREG)(STA_INT);


    --module specific part
    v.counter := r.counter;
    
    if r.ifacereg(CONFIGREG_CUST)(START_C) = '1' then
      if r.counter = (r.ifacereg(BASE_COUNTER_MATCH+3) & r.ifacereg(BASE_COUNTER_MATCH+2) & r.ifacereg(BASE_COUNTER_MATCH+1) & r.ifacereg(BASE_COUNTER_MATCH)) then
        v.ifacereg(STATUSREG)(STA_INT) := '1';  -- activate interrupt
      else
        if r.prescaler = r.ifacereg(PRESCALER_MATCH) then
          v.counter := STD_LOGIC_VECTOR(UNSIGNED(r.counter) + 1);
          v.prescaler := (others => '0');
        else
          v.prescaler := STD_LOGIC_VECTOR(UNSIGNED(r.prescaler) + 1);        
        end if;
      end if;
    elsif r.ifacereg(CONFIGREG_CUST)(STOP_C) = '1' then
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
        r.counter <= (others => '0');
        r.prescaler <= (others => '0');
      else
        r <= r_next;
      end if;
    end if;
  end process;

end behaviour;
