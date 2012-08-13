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
-- Title      : button_switch_leds for fpga board DE2-115 
-- Project    : SCARTS - Scalable Processor for Embedded Applications in
--              Realtime Environment
-----------------------------------------------------------------------
 
-----------------------------------------------------------------------
-- Description:
-- Extension Module for the switches hbuttons & leds of the DE2-115 
-- Board 
-- Comment: Both are debounced by hardware so no debounce mechanism was
-- implemented in the module
-----------------------------------------------------------------------
-- Copyright (c) 2012 
-----------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author    Description
-- 2012-07-11  1.0      ssimhandl	Created
-----------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.scarts_pkg.all;
use work.pkg_but_sw_led.all;

architecture behaviour of ext_but_sw_led is

-- 48 pins = 6 byte fore
subtype byte is std_logic_vector(7 downto 0);
type register_set is array (0 to 9) of byte;

constant STATUSREG_CUST 	: integer := 1;
constant CONFIGREG_CUST 	: integer := 3;

constant REG_IO_0    	: integer := 4; -- buttons 1-3 / sw0 - sw4
constant REG_IO_1			: integer := 5;	-- sw5 - sw12
constant REG_IO_2			: integer := 6;	-- sw13- sw17 / red led0 - red led2
constant REG_IO_3			:	integer	:= 7; -- red led3 - red led10
constant REG_IO_4			: integer := 8;	-- red led11 - red led17 / green led0
constant REG_IO_5			:	integer	:= 9;	-- green led1 - green led8
	

type reg_type is record
  ifacereg   : register_set;
end record;


signal r_next : reg_type;
signal r : reg_type := 
  (
    ifacereg => (others => (others => '0'))
  ); 
signal rstint : std_ulogic;

-- signals for buttons
type buttons_type is array (0 to 2) of std_logic;
signal buttons : buttons_type;

-- signals for switches
type switches_type is array (0 to 17) of std_logic;
signal switches : switches_type;

-- signals for red leds
type red_leds_type is array (0 to 17) of std_logic;
signal red_leds : red_leds_type;

-- signals for green leds
type green_leds_type is array (0 to 8) of std_logic;
signal green_leds : green_leds_type;


begin -- behaviour

  -- extension module process
  comb : process(r, exti, extsel, button1, button2, button3, buttons, sw, switches, red_leds, green_leds)
    variable v : reg_type;
  begin
    v := r;
        
    -- write memory mapped addresses
    if ((extsel = '1') and (exti.write_en = '1')) then
      case exti.addr(4 downto 2) is
        when "000" =>
          if ((exti.byte_en(0) = '1') or (exti.byte_en(1) = '1')) then
            v.ifacereg(STATUSREG)(STA_INT) := '1';
            v.ifacereg(CONFIGREG)(CONF_INTA) :='0';
          else
            if ((exti.byte_en(2) = '1')) then
              v.ifacereg(STATUSREG_CUST) := exti.data(23 downto 16);
            end if;
            if ((exti.byte_en(3) = '1')) then
              v.ifacereg(CONFIGREG_CUST) := exti.data(31 downto 24);
            end if;
          end if;
        when "001" =>
          if ((exti.byte_en(0) = '1')) then
            v.ifacereg(REG_IO_0) := exti.data(7 downto 0);
          end if;
          if ((exti.byte_en(1) = '1')) then
            v.ifacereg(REG_IO_1) := exti.data(15 downto 8);
          end if;
          if ((exti.byte_en(2) = '1')) then
            v.ifacereg(REG_IO_2) := exti.data(23 downto 16);
          end if;
					if ((exti.byte_en(3) = '1')) then
            v.ifacereg(REG_IO_3) := exti.data(31 downto 24);
          end if;
				 when "010" =>
          if ((exti.byte_en(0) = '1')) then
            v.ifacereg(REG_IO_4) := exti.data(7 downto 0);
          end if;
          if ((exti.byte_en(1) = '1')) then
            v.ifacereg(REG_IO_5) := exti.data(15 downto 8);
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
          exto.data <= r.ifacereg(CONFIGREG_CUST) & r.ifacereg(STATUSREG_CUST) & r.ifacereg(CONFIGREG) & r.ifacereg(STATUSREG);
        when "001" =>
          if (r.ifacereg(CONFIGREG)(CONF_ID) = '1') then
            exto.data <= MODULE_VER & MODULE_ID;
          else
            exto.data <= r.ifacereg(REG_IO_3) & r.ifacereg(REG_IO_2) & r.ifacereg(REG_IO_1) & r.ifacereg(REG_IO_0);
          end if;
				when "010" =>
					exto.data <= "00000000" & "00000000" & r.ifacereg(REG_IO_5) & r.ifacereg(REG_IO_4);
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

    -- reset interrupt when acknowledged
    if r.ifacereg(STATUSREG)(STA_INT) = '1' and r.ifacereg(CONFIGREG)(CONF_INTA) ='0' then
      v.ifacereg(STATUSREG)(STA_INT) := '0';
    end if; 

    -- set interupt flag
    exto.intreq <= r.ifacereg(STATUSREG)(STA_INT);

    -- module specific part
			-- REG_IO_0: buttons 1-3 / sw0 - sw4
		for i in 0 to 7 loop
			if i < 3 then
      	v.ifacereg(REG_IO_0)(i) := buttons(i);
			else
				v.ifacereg(REG_IO_0)(i) := switches(i-3);
			end if;
  	end loop;
			-- REG_IO_1: sw5 - sw12
		for i in 0 to 7 loop
     	v.ifacereg(REG_IO_1)(i) := switches(i+5);
		end loop;
			-- REG_IO_2: sw13- sw17 / red led0 - red led2
		for i in 0 to 7 loop
			if i < 5 then
      	v.ifacereg(REG_IO_2)(i) := switches(i+13);
			else
	 			red_leds(i-5) <= v.ifacereg(REG_IO_2)(i);
			end if;
    end loop;
			-- REG_IO_3: red led3 - red led10
		for i in 0 to 7 loop
    	red_leds(i+3) <= v.ifacereg(REG_IO_3)(i);
		end loop;
			-- REG_IO_4: red led11 - red led17 / green led0
		for i in 0 to 7 loop
			if i < 7 then
      	red_leds(i+11) <= v.ifacereg(REG_IO_4)(i);
			else
				green_leds(i-7) <= v.ifacereg(REG_IO_4)(i);
			end if;
    end loop;
			-- REG_IO_5: green led1 - green led8
    for i in 0 to 7 loop
    	green_leds(i+1) <= 	v.ifacereg(REG_IO_5)(i);
    end loop;
    
    r_next <= v;
  end process;

  -- sync process
  reg : process(clk, rstint)
  begin
    if rising_edge(clk) then 
      if rstint = RST_ACT then
        r.ifacereg <= (others => (others => '0'));
        buttons <= (others => '1'); -- '1' because buttons low activ
				switches <= (others => '0');
				red_leds <= (others => '0');
      	green_leds <= (others => '0');
				ledr <= (others => '0');
				ledg <= (others => '0');
			else
        r <= r_next;
        buttons(0) <= button1;
        buttons(1) <= button2;
        buttons(2) <= button3;
				for i in 0 to 17 loop	
					switches(i) <= sw(i);
				end loop;
				for i in 0 to 17 loop	
					ledr(i) <= red_leds(i);
				end loop;
				for i in 0 to 8 loop	
					ledg(i) <= green_leds(i);
				end loop;
			end if;
    end if;
  end process;

end behaviour;
