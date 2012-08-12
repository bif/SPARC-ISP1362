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
use work.pkg_button_switch_led.all;

architecture behaviour of ext_button_switch_led is

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
type buttons_type is array (1 to 3) of std_logic;
signal buttons : buttons_type;

-- signals for switches
type switches_type is array (0 to 17) od std_logic;
signal switches : switches_type;

-- signals for red leds
type red_leds_type is array (0 to 17) od std_logic;
signal red_leds : red_leds_type;

-- signals for green leds
type green_leds_type is array (0 to 8) od std_logic;
signal green_leds : green_leds_type;


begin -- behaviour

  -- extension module process
  comb : process(r, exti, extsel, button1, button2, button2, buttons, sw0, sw1, sw2, sw3, sw4, sw5, sw6, sw7, sw8, sw9, sw10, sw11, sw12, sw13, sw14, sw15, sw16, sw17, red_leds, green_leds)
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
            exto.data <= r.ifacereg(REG_IO_3) & r.ifacereg(REG_IO_2);
          end if;
				when "010" =>
					exto.data <= r.ifacereg(REG_IO_5) & r.ifacereg(REG_IO_4);
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
      	v.ifacereg(REG_IO_0)(i) := buttons(i+1);
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
				v.ifacereg(REG_IO_2)(i) := red_leds(i-5);
			end if;
    end loop;
			-- REG_IO_3: red led3 - red led10
		for i in 0 to 7 loop
     	v.ifacereg(REG_IO_3)(i) := red_leds(i+3);
		end loop;
			-- REG_IO_4: red led11 - red led17 / green led0
		for i in 0 to 7 loop
			if i < 7 then
      	v.ifacereg(REG_IO_4)(i) := red_leds(i+11);
			else
				v.ifacereg(REG_IO_4)(i) := green_leds(i-7);
			end if;
    end loop;
			-- REG_IO_5: green led1 - green led8
    for i in 0 to 7 loop
     	v.ifacereg(REG_IO_5)(i) := green_leds(i+1);
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
			else
        r <= r_next;
        buttons(1) <= button1;
        buttons(2) <= button2;
        buttons(3) <= button3;

				switches(0) <= sw0;
				switches(1) <= sw1;
				switches(2) <= sw2;
				switches(3) <= sw3;
				switches(4) <= sw4;
				switches(5) <= sw5;
				switches(6) <= sw6;
				switches(7) <= sw7;
				switches(8) <= sw8;
				switches(9) <= sw9;
				switches(10) <= sw10;
				switches(11) <= sw11;
				switches(12) <= sw12;
				switches(13) <= sw13;
				switches(14) <= sw14;
				switches(15) <= sw15;
				switches(16) <= sw16;
				switches(17) <= sw17;	

				red_leds(0) <= ledr_0;
  			red_leds(1) <= ledr_1;
   			red_leds(2) <= ledr_2;
  			red_leds(3) <= ledr_3;
   			red_leds(4) <= ledr_4;
   			red_leds(5) <= ledr_5;
  			red_leds(6) <= ledr_6;
  			red_leds(7) <= ledr_7;
  			red_leds(8) <= ledr_8;
  			red_leds(9) <= ledr_9;
				red_leds(10) <= ledr_10;
  			red_leds(11) <= ledr_11;
  			red_leds(12) <= ledr_12;
  			red_leds(13) <= ledr_13;
  			red_leds(14) <= ledr_14;
  			red_leds(15) <= ledr_15;
  			red_leds(16) <= ledr_16;
  			red_leds(17) <= ledr_17;
  			
				green_leds(0) <= ledg_0;
				green_leds(1) <= ledg_1;
				green_leds(2) <= ledg_2;
				green_leds(3) <= ledg_3;
				green_leds(4) <= ledg_4;
				green_leds(5) <= ledg_5;
				green_leds(6) <= ledg_6;
				green_leds(7) <= ledg_7;
				green_leds(8) <= ledg_8;

			end if;
    end if;
  end process;

end behaviour;
