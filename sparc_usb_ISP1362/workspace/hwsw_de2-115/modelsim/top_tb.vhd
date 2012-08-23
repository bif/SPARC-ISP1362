library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.scarts_pkg.all;
use work.pkg_timer.all;

entity top_tb is
  port (
      -- buttons
      button1        : out std_logic; 
      button2        : out std_logic;
      button3        : out std_logic;
      -- Switches
      sw 	  			: out std_logic_vector(17 downto 0);
      -- Leds
      ledr				: in std_logic_vector(17 downto 0);
      ledg				: in std_logic_vector(8 downto 0);	
    );
  
end top_tb;

architecture behaviour of top_tb is

  --constant  cc    : TIME := 20 ns;
  --constant  bittime    : integer := 434; --8.681 us / 20 ns ;
  constant  cc    : TIME := 33 ns; -- 1/50 MHz

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


  component top
    port (
      db_clk      : in    std_ulogic;
      rst         : in    std_ulogic;
      
      -- buttons
      KEY1        : in std_logic; 
      KEY2        : in std_logic;
      KEY3        : in std_logic;
      -- Switches
      SW 	  			: in std_logic_vector(17 downto 0);
      -- Leds
      LEDR				: out std_logic_vector(17 downto 0);
      LEDG				: out std_logic_vector(8 downto 0);	
    );    
  end component;


begin

  top_1: top
    port map (
      db_clk         => clk,
      rst            => rst,
   
    
    );

  clkgen : process
  begin
    clk <= '1';
    wait for cc/2;
    clk <= '0'; 
    wait for cc/2;
  end process clkgen;
  
  test: process
  begin

    rst <= RST_ACT;
    D_Rxd <= '1';
    aux_uart_rx <= '1';
    icwait(100);
    rst <= not RST_ACT;

    -- run forever
    wait;
  end process test;

end behaviour; 

