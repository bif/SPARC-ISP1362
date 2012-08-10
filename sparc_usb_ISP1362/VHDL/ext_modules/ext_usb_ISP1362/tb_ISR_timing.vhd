library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.scarts_pkg.all;
use work.pkg_ISP1362.all;

entity tb_ISR_timing is
end entity tb_ISR_timing;

architecture beh  of ext_usb_ISP1362 is
  component ext_ISP1362 is
	 port (
    ------------------------------------------------------------------
    -- Generic Ports
    ------------------------------------------------------------------
    clk        : in  std_logic;
    extsel     : in  std_ulogic;
    exti       : in  module_in_type;
    exto       : out module_out_type;
    ------------------------------------------------------------------
    -- Module Specific Ports
    ------------------------------------------------------------------
		USB_DATA	: inout std_logic_vector (15 downto 0);
		USB_ADDR	: out std_logic_vector (1 downto 0); 
		USB_RD_N	: out std_logic;
		USB_WR_N	: out std_logic;
		USB_CS_N	: out std_logic;
		USB_RST_N	: out std_logic;
		USB_INT1	: in std_logic
  );
  end component ext_ISP1362;

	constant cc	: TIME := 20 ns;
	constant bittime	: integer := 434; -- 8.681 us / 20 ns	

	signal clk_sig			: std_logic;
  signal extsel_wig		: std_ulogic;
  signal exti_sig			: module_in_type;
  signal exto_sig			: module_out_type;
	signal usb_data_sig	: std_logic_vector (15 downto 0);
	signal usb_addr_sig	: std_logic_vector (1 downto 0); 
	signal usb_rd_sig		:	std_logic;
	signal usb_wr_sig		: std_logic;
	signal usb_cs_sig		: std_logic;
	signal usb_rst_sig	: std_logic;
	signal usb_int1_sig	: std_logic;


	-- begin testbench
	begin
		ISR_timing : ext_ISP1362
		port map (
			clk => clk_sig,
			extsel => extsel_sig,
			exti => exti_sig,
			exto => exto_sig,
			USB_DATA => usb_data_sig,
			USB_ADDR 	=> usb_addr_sig
			USB_RD_N => usb_rd_sig,
			USB_WR_N => usb_wr_sig,
			USB_CS_N => usb_cs_sig,
			USB_RST_N => usb_rst_sig,
			USB_INT1 => usb_int1_sig
		);
					
		clk_gen : process
		begin
			clk_sig <= '1';
			wait for cc/2;
			clk_sig <= '0';
			wait for cc/2;
		end process clk_gen;
		
  test : process
  begin
		-- TODO: simulate beh of ISR  



  end process test;
end architecture beh;
