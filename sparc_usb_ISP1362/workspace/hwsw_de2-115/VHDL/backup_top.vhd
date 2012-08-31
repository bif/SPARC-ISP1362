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


library ieee;
use ieee.std_logic_1164.all;

use work.top_pkg.all;
use work.scarts_pkg.all;
use work.scarts_amba_pkg.all;
--use work.pkg_ISP1362.all;
use work.pkg_timer.all;
use work.pkg_but_sw_led.all;

library grlib;
use grlib.amba.all;

library techmap;
use techmap.gencomp.all;

library gaisler;
use gaisler.misc.all;
use gaisler.memctrl.all;

entity top is
  port(
    db_clk      : in  std_ulogic;
    rst         : in  std_ulogic;
    -- Debug Interface
    D_RxD : in std_logic;
    D_TxD : out std_logic;

    -- ISP1362 - usb controler
--		USB_DATA	: inout std_logic_vector (15 downto 0);
--		USB_ADDR	: out std_logic_vector (1 downto 0); 
--		USB_RD_N	: out std_logic;
--		USB_WR_N	: out std_logic;
--		USB_CS_N	: out std_logic;
--		USB_RST_N	: out std_logic;
--		USB_INT1	: in std_logic;

    -- but_sw_led
    KEY1        : in std_logic; 
    KEY2        : in std_logic;
    KEY3        : in std_logic;
		-- Switches
		SW 	  			: in std_logic_vector(17 downto 0);
		-- Leds
		LEDR				: out std_logic_vector(17 downto 0);
		LEDG				: out std_logic_vector(8 downto 0)	

  );
end top;

architecture behaviour of top is
  
  signal scarts_i    : scarts_in_type;
  signal scarts_o    : scarts_out_type;

  signal debugi_if : debug_if_in_type;
  signal debugo_if : debug_if_out_type;

  signal exti      : module_in_type;
  
  signal syncrst     : std_ulogic;
  signal sysrst      : std_ulogic;

  signal clk         : std_logic;

	-- timer
	signal timer_sel		: std_logic;
	signal timer_exto		: module_out_type;

	-- ISP1362 
--	signal usb_sel	: std_logic;
--  signal usb_exto	: module_out_type;

  -- but_sw_led
  signal but_sw_led_sel	: std_ulogic;
  signal but_sw_led_exto	: module_out_type;

  -- signals for AHB slaves and APB slaves
  signal ahbmi            : ahb_master_in_type;
  signal scarts_ahbmo     : ahb_master_out_type;

  signal vga_clk_int : std_logic;


  component altera_pll is
    port (
      areset		: in STD_LOGIC  := '0';
      inclk0		: in STD_LOGIC  := '0';
      c0	    	: out STD_LOGIC ;
      c1	    	: out STD_LOGIC;
      locked		: out STD_LOGIC 
    );
   end component;


begin
  
  altera_pll_inst : altera_pll 
    port map (
      areset	 => '0',
      inclk0	 => db_clk,
      c0	     => clk,
      c1	     => open,
      locked	 => open
    );

  scarts_unit: scarts
    generic map (
    CONF => (
      tech => work.scarts_pkg.ALTERA,
      word_size => 32,
      boot_rom_size => 12,
      instr_ram_size => 16,
      data_ram_size => 17,
      use_iram => true,
      use_amba => false,
      amba_shm_size => 8,
      amba_word_size => 32,
      gdb_mode => 0,
      bootrom_base_address => 29
    ))
    port map(
      clk    => clk,
      sysrst => sysrst,
      extrst => syncrst,
      scarts_i => scarts_i,
      scarts_o => scarts_o,
      ahbmi  => ahbmi,
      ahbmo  => scarts_ahbmo,
      debugi_if => debugi_if,
      debugo_if => debugo_if
    );
 
-----------------------------------------------------------------------------
  -- Scarts extension modules
-----------------------------------------------------------------------------

	timer_unit : ext_timer
  port map (
    clk				=> clk, 
    extsel		=> timer_sel,
    exti 			=> exti,
    exto			=> timer_exto
	);

  but_sw_led_unit: ext_but_sw_led
    port map(
      clk        => clk,
      extsel     => but_sw_led_sel,
      exti       => exti,
      exto       => but_sw_led_exto,
      button1    => KEY1,
      button2    => KEY2,
      button3    => KEY3,
			sw				 =>	SW,
			ledr			 => LEDR,
			ledg			 => LEDG
    );


--  ISP1362_usb_unit: ext_ISP1362
--	port map(
--   clk        => clk,
--    extsel     => usb_sel,
--    exti       => exti,
--    exto       => usb_exto,
--		-- ISP1362 Side
--		USB_DATA		=> USB_DATA, 	
--		USB_ADDR		=> USB_ADDR,
--		USB_RD_N		=> USB_RD_N,						
--		USB_WR_N		=> USB_WR_N,
--		USB_CS_N		=> USB_CS_N,
--		USB_RST_N		=> USB_RST_N,
--		USB_INT1		=> USB_INT1
--	); 

  
  comb : process(scarts_o, debugo_if, D_RxD, timer_exto, but_sw_led_exto) -- usb_exto)  --extend!
    variable extdata : std_logic_vector(31 downto 0);
  begin   
    exti.reset    <= scarts_o.reset;
    exti.write_en <= scarts_o.write_en;
    exti.data     <= scarts_o.data;
    exti.addr     <= scarts_o.addr;
    exti.byte_en  <= scarts_o.byte_en;

--    usb_sel <= '0';
		timer_sel <= '0';
    but_sw_led_sel <= '0';
   
		if scarts_o.extsel = '1' then
      case scarts_o.addr(14 downto 5) is
        when "1111110111" => -- (-288)
          -- select timer module
          timer_sel <= '1';
        when "1111110110" => -- (-320)              
          -- select button/switch/led module
          but_sw_led_sel <= '1';
        --when "1111110101" => -- (-352)              
          -- select uart module
          --aux_uart_sel <= '1';
        when others =>
          null;
      end case;
    end if;
   

    extdata := (others => '0');
    for i in extdata'left downto extdata'right loop
      extdata(i) := timer_exto.data(i) or but_sw_led_exto.data(i);  --or usb_exto.data(i);
    end loop;

    scarts_i.data <= (others => '0');
    scarts_i.data <= extdata;
    scarts_i.hold <= '0';
    scarts_i.interruptin <= (others => '0');
   
    -- Debug Interface
    D_TxD <= debugo_if.D_TxD;
    debugi_if.D_RxD <= D_RxD; 

 end process;

  reg : process(clk)
  begin
    if rising_edge(clk) then
      syncrst <= rst;
    end if;
  end process;


end behaviour;
