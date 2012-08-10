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
	constant EXT_DFLT_ADDR	:std_logic_vector (14 downto 0) := "000000000000000";
	
	signal clk_sig			: std_logic;
  signal extsel_sig		: std_ulogic;
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
	
			procedure icwait(cycles: Natural) is
			begin
				for i in 1 to cycles loop
					wait until clk = '0' and clk'event;
				end loop;
			end icwait; 
		
			procedure en_mdoule(config: boolean) is
				if config = true then
					exti_sig.addr <= EXT_DFLT_ADDR;	
					--exti_sig.byte_en <= "0011";
					extsel_sig <= '1';
					icwait(2);
				else
					extsel_sig <= '0';
					exti.byte_en <= "0000";
					icwait(2);
				end if;
			end en_module;

			procedure set_addr(bits : std_logic_vector (2 downto 0)) is
				exti_sig_addr (4 downto 2) <= bits;
			end set_addr;

		begin

		-- reset module
		exti_sig.reset <= RST_ACT;
		icwait(5);
		exti_sig.reset <= not RST_ACT;

		

		


		end process test;

end architecture beh;
