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
-- Design Name:	 AHBMasterStatemachine_DPRAM_32
-- Module Name:	 AHBMasterStatemachine - Behavioral
-- Project Name:	AMBA4Scarts
-- Target Devices:
-- Tool versions:
-- Description:	 Statemachine that handels the AMBA-Protokoll
--
-- Dependencies: used in ext_AMBA_DPRAM_32
--
-- Revision:		 0.8 - ready for testing
-- Additional Comments:
--	todo: apply coding styles
--
--
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.scarts_core_pkg.all;
use work.scarts_amba_pkg.all;
use work.scarts_pkg.all;


entity AMBA_AHBMasterStatemachine is
  port(HRESET : in STD_LOGIC;
       HCLK : in STD_LOGIC;
       -- AHB Master Input
       AMBAI : in ahb_master_in_type;
       -- AHB Master Output
       AMBAO : out ahb_master_out_type;
       -- Bridge Signalflow SCARTS to AMBA
       BStA : in brg_scarts_to_amba_type;
       -- Bridge Signalflow AMBA to SCARTS
       BAtS : out brg_amba_to_scarts_type);
end AMBA_AHBMasterStatemachine;

architecture Behavioral of AMBA_AHBMasterStatemachine is

--constant hconfig : ahb_config_type := (
--	0 => ahb_device_reg(VENDOR_TEST, TEST_SCARTS, 0, SCARTS_VERSION, 0),
--	others => zero32);

type States is (IDLE, DEFAULTMASTER, HOLD, ACTIVE, ACTIVE_NEXT, ACTIVE_END);

type AMBA_Signals is record
  HBUSREQ : STD_LOGIC;
  HLOCK   : STD_LOGIC;
  HTRANS  : STD_LOGIC_VECTOR (1 downto 0);
  HADDR   : STD_LOGIC_VECTOR (31 downto 0); -- AMBA-Address of Data
  HWRITE  : STD_LOGIC;
  HSIZE   : STD_LOGIC_VECTOR (2 downto 0);
  HBURST  : STD_LOGIC_VECTOR (2 downto 0);
  HPROT   : STD_LOGIC_VECTOR (3 downto 0);
end record;

type Scarts_Signals is record
  MWRITE     : STD_LOGIC;
  ERROR      : STD_LOGIC;
  FINISHED   : STD_LOGIC;
  BusRequest : STD_LOGIC;
end record;

type Memory_Signals is record
  MADDR_read        : STD_LOGIC_VECTOR (31 downto 0);
  MADDR_write       : STD_LOGIC_VECTOR (31 downto 0);
  CountBurstDown    : STD_LOGIC_VECTOR (2 downto 0);
  Byte_Enable       : STD_LOGIC_VECTOR (3 downto 0);
  FirstTransfer     : STD_LOGIC;
end record;

type reg_type is record
  St : States;
  lR : std_ulogic;
  lB : std_ulogic;
  A  : AMBA_Signals;
  S  : Scarts_Signals;
  M  : Memory_Signals;
end record;

signal r, r_next : reg_type;

begin

	-- AMBA-Signals on Bus
	AMBAO.HBUSREQ <= r_next.A.HBUSREQ;
	AMBAO.HLOCK <= r_next.A.HLOCK;
	AMBAO.HTRANS <= r_next.A.HTRANS;
	AMBAO.HADDR <= r_next.A.HADDR;
	AMBAO.HWRITE <= r_next.A.HWRITE;
	AMBAO.HSIZE <= r_next.A.HSIZE;
	AMBAO.HBURST <= r_next.A.HBURST;
	AMBAO.HPROT <= r_next.A.HPROT;
	AMBAO.HWDATA <= BStA.sMRDATA;
	--AMBAO.hconfig <= hconfig;
	--AMBAO.hirq <= (others => '0');
	-- Scarts-Signals on Bus
	BAtS.sMWRITE <= r_next.S.MWRITE;
	BAtS.sERROR <= r_next.S.ERROR;
	BAtS.sFINISHED <= r_next.S.FINISHED;
	BAtS.sBusRequest <= r_next.S.BusRequest;
	BAtS.sMWDATA <= AMBAI.HRDATA;
	BAtS.sByteEn <= r_next.M.Byte_Enable;
	BAtS.sMADDR <= r_next.M.MADDR_read when BStA.sHWRITE = '1' else r_next.M.MADDR_write;
	BAtS.sIRQ(7 downto 0) <= AMBAI.hirq(7 downto 0);


	ClockedProcess: process (HCLK, HRESET)
	begin
    if rising_edge(HCLK) then
	    if HRESET = RST_ACT then
				-- init States
				r.St <= IDLE;
				r.lR <= '0';
				-- init current AMBA-Signals
				r.A.HBUSREQ <= '0';
				r.A.HLOCK <= '0';
				r.A.HTRANS <= (others => '0');
				r.A.HADDR <= (others => '0');
				r.A.HWRITE <= '0';
				r.A.HSIZE <= (others => '0');
				r.A.HBURST <= (others => '0');
				r.A.HPROT <= (others => '0');
				-- init current Scarts-Signals
				r.S.MWRITE <= '0';
				r.S.ERROR <= '0';
				r.S.FINISHED <= '0';
				r.S.BusRequest <= '0';
				-- init current Memory-Signals
				r.M.MADDR_read <= (others => '0');
				r.M.MADDR_write <= (others => '0');
				r.M.CountBurstDown <= (others => '0');
				r.M.Byte_Enable <= (others => '0');
				r.M.FirstTransfer <= '0';
			else
				r <= r_next;
			end if;
		end if;
	end process ClockedProcess;


	Statemachine: process (AMBAI, BStA, r)

  variable v : reg_type;
  

	begin
	-- default: use old value --> no latches ;)
	v := r;
	v.lR := AMBAI.HREADY;
	v.lB := BStA.sWAIT;
	-- Statemachine
	case r.St is
		when IDLE =>
			v.S.ERROR := '0';
			v.S.Finished := '0';
			v.M.Byte_Enable := (others => '0');
			if (BStA.sHBUSREQ = '1') then
				v.A.HBUSREQ := '1';
				v.St := HOLD;
--				v.S.BusRequest := '1';
			else
				if (AMBAI.HGRANT = '1') then
					v.St := DEFAULTMASTER;
				else
					v.St := IDLE;
				end if;
			end if;
		when DEFAULTMASTER =>
			v.A.HTRANS := HTRANS_IDLE;
			v.A.HADDR := (others => '0');
			if (AMBAI.HRESP = HRESP_OKAY) then
				v.St := IDLE;
			else
				v.St := DEFAULTMASTER;
			end if;
		when HOLD =>
			v.S.BusRequest := '1';
			if (AMBAI.HGRANT = '1') then
				v.St := ACTIVE;
                                -- removed assignment to htrans to remove comb
                                -- loop (jl)
				--v.A.HTRANS := HTRANS_IDLE;
                                
--				v.S.BusRequest := '0';
			else
				v.St := HOLD;
			end if;
		when ACTIVE =>
			v.S.BusRequest := '0';
			-- AMBAInitialization;
			v.A.HADDR := BStA.sHADDR;
			v.A.HWRITE := BStA.sHWRITE;
			v.S.MWrite := not BStA.sHWRITE;
			v.M.MADDR_read := BStA.sBADDR;
			v.M.Byte_Enable := (others => '0');
			case BStA.sHSIZE is
				when HSIZE_DWORD =>
					v.A.HSIZE := HSIZE_WORD;
					v.A.HBURST := HBURST_INCR;
					v.M.CountBurstDown := "001";
					v.St := ACTIVE_NEXT;
				when HSIZE_4WORD =>
					v.A.HSIZE := HSIZE_WORD;
					v.A.HBURST := HBURST_INCR4;
					v.M.CountBurstDown := "011";
					v.St := ACTIVE_NEXT;
				when HSIZE_8WORD =>
					v.A.HSIZE := HSIZE_WORD;
					v.A.HBURST := HBURST_INCR8;
					v.M.CountBurstDown := "111";
					v.St := ACTIVE_NEXT;
				when HSIZE_16WORD =>
				when HSIZE_32WORD =>
				when others =>
					v.A.HSIZE := BStA.sHSIZE;
					v.A.HBURST := HBURST_SINGLE;
					v.M.CountBurstDown := "000";
					v.St := ACTIVE_END;
			end case;
			v.A.HPROT := "0001"; -- Non cachable, non bufferable, non privileged data access
			v.A.HTRANS := HTRANS_NONSEQ;
		when ACTIVE_NEXT =>
			if (BStA.sWAIT = '1') then
				v.A.HTRANS := HTRANS_BUSY;
			else
				v.A.HTRANS := HTRANS_SEQ;
			end if;
			case AMBAI.HRESP is
				when HRESP_OKAY =>
					if (r.M.CountBurstDown /= "000") then
						v.St := ACTIVE_NEXT;
						if (AMBAI.HREADY = '1') then
							if (r.lB = '0') then
								if (r.lR = '1') then
									v.A.HADDR := r.A.HADDR + 4;
									v.M.CountBurstDown := r.M.CountBurstDown - 1;
									if (v.M.CountBurstDown = "000") then
										v.St := ACTIVE_END;
									end if;
								end if;
								v.M.MADDR_read := r.M.MADDR_read + 4;
								v.M.MADDR_write := r.M.MADDR_read;
								if (r.A.HWRITE = '0') then
									v.M.Byte_Enable := (others => '1');
								else
									v.M.Byte_Enable := (others => '0');
								end if;
							else
								v.M.Byte_Enable := (others => '0');
							end if;
						else
							v.M.Byte_Enable := (others => '0');
							if (r.lR = '1') then
								v.A.HADDR := r.A.HADDR + 4;
								v.M.CountBurstDown := r.M.CountBurstDown - 1;
								--if (v.M.CountBurstDown = "000") then
								--	v.St := ACTIVE_END;
								--end if;
							end if;
						end if;
					else
						if (AMBAI.HREADY = '1') then
							v.M.MADDR_write := r.M.MADDR_read;
							v.M.MADDR_read := r.M.MADDR_read + 4;
							v.St := ACTIVE_END;
							if (r.A.HWRITE = '0') then
								v.M.Byte_Enable := (others => '1');
							else
								v.M.Byte_Enable := (others => '0');
							end if;
						else
							v.St := ACTIVE_NEXT;
							v.M.Byte_Enable := (others => '0');
						end if;
					end if;
				when HRESP_RETRY =>
					v.A.HADDR := r.A.HADDR + 4;
                                        -- state change to hold => set
                                        -- htrans_idle (added by jl)
                                        v.A.HTRANS := HTRANS_IDLE; 
					v.St := HOLD;
				when HRESP_ERROR =>
					v.A.HADDR := (others => '0');
					v.A.HTRANS := HTRANS_IDLE;
					v.M.Byte_Enable := (others => '0');
					v.S.ERROR := '1';
					v.A.HBUSREQ := '0';
					v.St := IDLE;
				when others =>
					v.A.HADDR := (others => '0');
					v.A.HTRANS := HTRANS_IDLE;
					v.M.Byte_Enable := (others => '0');
					v.A.HBUSREQ := '0';
					v.St := IDLE;
			end case;
		when ACTIVE_END =>
			if (AMBAI.HREADY = '1') then
				v.M.MADDR_write := r.M.MADDR_read;
				if (r.A.HWRITE = '0') then
					case r.A.HSIZE is
						when HSIZE_BYTE =>
							case r.A.HADDR(1 downto 0) is
								when "00" =>
									v.M.Byte_Enable := "0001";
								when "01" =>
									v.M.Byte_Enable := "0010";
								when "10" =>
									v.M.Byte_Enable := "0100";
								when "11" =>
									v.M.Byte_Enable := "1000";
								when others =>
									v.M.Byte_Enable := "0000";
							end case;
						when HSIZE_HWORD =>
							if (r.A.HADDR(1) = '0') then
								v.M.Byte_Enable := "0011";
							else
								v.M.Byte_Enable := "1100";
							end if;
						when others =>
							v.M.Byte_Enable := (others => '1');
					end case;
				else
					v.M.Byte_Enable := (others => '0');
				end if;
				v.A.HADDR := (others => '0');
				v.A.HTRANS := HTRANS_IDLE;
				v.A.HBUSREQ := '0';
				v.St := IDLE;
				v.S.Finished := '1';
			else
				v.M.Byte_Enable := (others => '0');
				if (AMBAI.HRESP = HRESP_ERROR) then
					v.A.HADDR := (others => '0');
					v.A.HTRANS := HTRANS_IDLE;
					v.S.ERROR := '1';
					v.A.HBUSREQ := '0';
					v.St := IDLE;
				else
					v.St := ACTIVE_END;
				end if;
			end if;
	end case;
	
	r_next <= v;
	
	end process Statemachine;


end Behavioral;

