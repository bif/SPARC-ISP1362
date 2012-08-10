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
type register_set is array (0 to 7) of ext_register;

---------------------------------------------------------------------
-- define constants 
---------------------------------------------------------------------
constant HIGH_IMPENDANT	: std_logic_vector := "ZZZZZZZZ";

-- DC control & status registers
constant STATUSREG_CUST		: integer	:= 2;
constant CONFIGREG_CUST		:	integer	:= 3;

-- DC data registers
constant DC_READ_DATA_LOW		: integer	:= 4;
constant DC_READ_DATA_HIGH	:	integer	:= 5;
constant DC_WRITE_DATA_LOW	: integer	:= 6;
constant DC_WRITE_DATA_HIGH	:	integer	:= 7;

-- indicies - flags of DC_CONTROL_REG 
constant avs_dc_address_iADDR				: integer := 0;
constant avs_dc_read_n_iRD_N				: integer := 1;
constant avs_dc_write_n_iWR_N				: integer := 2;
constant avs_dc_chipselect_n_iCS_N	: integer := 3;
constant avs_dc_reset_n_iRST_N			: integer := 4;
constant avs_dc_clk_iCLK						: integer := 5;
constant avs_dc_irq_n_oINT1_N				: integer := 6;


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
				r(CONFIGREG) <= r_next(CONFIGREG);
      end if;
    end if;
  end process;

	------------------------------------------------------------------
  -- extension module process
	------------------------------------------------------------------
  comb : process(r, exti, extsel, USB_DATA, USB_INT1)
    variable v : register_set;
  begin
    v := r;
    ----------------------------------------------------------------    
    -- write memory mapped registers (SPARC to EXT_MOD) 
		----------------------------------------------------------------
		if ((extsel = '1') and (exti.write_en = '1')) then
      case exti.addr(4 downto 2) is
        when "000" =>
					-- get control & configuration flags
          if ((exti.byte_en(0) = '1') or (exti.byte_en(1) = '1')) then
            -- TODO which bits have to be written? 
            v(STATUSREG)(STA_INT) := '1';
            v(CONFIGREG)(CONF_INTA) :='0';
          else
						-- used for status flags
            if ((exti.byte_en(2) = '1')) then
              v(STATUSREG_CUST) := exti.data(23 downto 16);
            end if;
						-- not used (only interrupt?)
            if ((exti.byte_en(3) = '1')) then
              v(CONFIGREG_CUST) := exti.data(31 downto 24);
            end if;
          end if;
        when "001" =>
          -- get data from SPARC - to transmit to host
					if ((exti.byte_en(0) = '1')) then
            v(DC_WRITE_DATA_LOW) := exti.data(7 downto 0);
          end if;
          if ((exti.byte_en(1) = '1')) then
            v(DC_WRITE_DATA_HIGH) := exti.data(15 downto 8);
          end if;
        when others =>
          null;
      end case;
    end if;
   
		----------------------------------------------------------------
		-- module specific part
		----------------------------------------------------------------
		-- data to transmit to host
		-- assign	USB_DATA		=	avs_dc_chipselect_n_iCS_N ? (avs_hc_write_n_iWR_N	?	16'hzzzz	:	avs_hc_writedata_iDATA) :  (avs_dc_write_n_iWR_N	?	16'hzzzz	:	avs_dc_writedata_iDATA) ;
		if r(STATUSREG_CUST)(avs_dc_chipselect_n_iCS_N) = '0' then
			if v(STATUSREG_CUST)(avs_dc_write_n_iWR_N)	= '1' then
				USB_DATA <= HIGH_IMPENDANT & HIGH_IMPENDANT;
			else
				USB_DATA <= r(DC_WRITE_DATA_HIGH) & v(DC_WRITE_DATA_LOW);
			end if;
		end if;

		--assign	avs_dc_readdata_oDATA		=	avs_dc_read_n_iRD_N	?	16'hzzzz	:	USB_DATA;
		-- data received from host
		if r(STATUSREG_CUST)(avs_dc_read_n_iRD_N) = '1' then
			v(DC_READ_DATA_HIGH)	:= HIGH_IMPENDANT;
			v(DC_READ_DATA_LOW)	:= HIGH_IMPENDANT;
		else
			v(DC_READ_DATA_HIGH)	:= USB_DATA(15 downto 8);
			v(DC_READ_DATA_LOW)	:= USB_DATA(7 downto 0);
		end if;

		--assign	USB_ADDR		=	avs_dc_chipselect_n_iCS_N? {1'b0,avs_hc_address_iADDR} : {1'b1,avs_dc_address_iADDR};
		-- set usb address
		if r(STATUSREG_CUST)(avs_dc_chipselect_n_iCS_N) = '0' then
			USB_ADDR <= ('1', v(STATUSREG_CUST)(avs_dc_address_iADDR));
		end if; 

		--assign	USB_CS_N		=	avs_hc_chipselect_n_iCS_N & avs_dc_chipselect_n_iCS_N;
		-- set chipselect for device
		USB_CS_N <= v(STATUSREG_CUST)(avs_dc_chipselect_n_iCS_N); 

		--assign	USB_WR_N		=	avs_dc_chipselect_n_iCS_N? avs_hc_write_n_iWR_N : avs_dc_write_n_iWR_N;
		if r(STATUSREG_CUST)(avs_dc_chipselect_n_iCS_N) = '0' then	
			USB_WR_N <= v(STATUSREG_CUST)(avs_dc_write_n_iWR_N);
		end if;

		--assign	USB_RD_N		=	avs_dc_chipselect_n_iCS_N? avs_hc_read_n_iRD_N  : avs_dc_read_n_iRD_N;
		if r(STATUSREG_CUST)(avs_dc_chipselect_n_iCS_N) = '0' then
			USB_RD_N <= v(STATUSREG_CUST)(avs_dc_read_n_iRD_N);
		end if; 

		--assign	USB_RST_N		=	avs_dc_chipselect_n_iCS_N? avs_hc_reset_n_iRST_N: avs_dc_reset_n_iRST_N;
		if r(STATUSREG_CUST)(avs_dc_chipselect_n_iCS_N) = '0' then
			USB_RST_N <= v(STATUSREG_CUST)(avs_dc_reset_n_iRST_N);
		end if;

		--assign	avs_dc_irq_n_oINT1_N		=	USB_INT1;
		-- forward interrupt to SPARC
-- QUESTION: wie lange bleibt INT1 auf 1? 
		if	USB_INT1 = '1' then
    	v(STATUSREG)(STA_INT) := '1';
		end if;

		-----------------------------------------------------------------
		-- read memory mapped addresses (EXT_MOD to SPARC)
		-----------------------------------------------------------------
    exto.data <= (others => '0');
    if ((extsel = '1') and (exti.write_en = '0')) then
      case exti.addr(4 downto 2) is
        when "000" =>
          -- write control & configuration flags
					exto.data <= r(CONFIGREG_CUST) & r(STATUSREG_CUST) & r(CONFIGREG) & r(STATUSREG);
        when "001" =>
          if (r(CONFIGREG)(CONF_ID) = '1') then
            -- to read manufacture & version nbr of the module
						exto.data <= MODULE_VER & MODULE_ID;
          else
						-- transfer data to SPARC - received from host
            exto.data <= "00000000" & "00000000" & r(DC_READ_DATA_HIGH
) & r(DC_READ_DATA_LOW);
          end if;
        when others =>
          null;
      end case;
    end if;

		-----------------------------------------------------------------
    -- compute status flags
		-----------------------------------------------------------------
    v(STATUSREG)(STA_LOOR) := r(CONFIGREG)(CONF_LOOW);
    v(STATUSREG)(STA_FSS) := '0';
    v(STATUSREG)(STA_RESH) := '0';
    v(STATUSREG)(STA_RESL) := '0';
    v(STATUSREG)(STA_BUSY) := '0';
    v(STATUSREG)(STA_ERR) := '0';
    v(STATUSREG)(STA_RDY) := '1';

		-----------------------------------------------------------------
    -- set output enabled (default)
		-----------------------------------------------------------------
    v(CONFIGREG)(CONF_OUTD) := '1';

		-----------------------------------------------------------------
    -- combine soft- and hard-reset
		-----------------------------------------------------------------
    rstint <= not RST_ACT;
    if exti.reset = RST_ACT or r(CONFIGREG)(CONF_SRES) = '1' then
      rstint <= RST_ACT;
    end if;

		-----------------------------------------------------------------
    -- interrupts
		-----------------------------------------------------------------
    -- reset interrupt next time cycle it this cycle occours an 
		-- interrupt
		if r(STATUSREG)(STA_INT) = '1' and r(CONFIGREG)(CONF_INTA) ='0' then
      v(STATUSREG)(STA_INT) := '0';
    end if; 

    -- write interupt flag
    exto.intreq <= r(STATUSREG)(STA_INT);

    ----------------------------------------------------------------
		-- prepare register for handover to next clock cycle
		----------------------------------------------------------------
    r_next <= v;
  end process;



end behaviour;
