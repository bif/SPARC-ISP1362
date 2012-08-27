library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.scarts_pkg.all;
use work.pkg_dis7seg.all;

use std.textio.all;

entity top_tb is
end top_tb;

architecture behaviour of top_tb is

  constant  cc    : TIME := 20 ns;
  constant  bittime    : integer := 434; --8.681 us / 20 ns ;

  type parity_type is (none, even, odd);

  signal clk      : std_ulogic;
  signal rst      : std_ulogic;
  signal D_RxD    : std_logic;
  signal D_TxD    : std_logic;
  signal digits   : digit_vector_t(7 downto 0);
  -- SDRAM Interface (AMBA)
  signal sdcke    : std_logic;
  signal sdcsn    : std_logic;
  signal sdwen    : std_logic;
  signal sdrasn   : std_logic;
  signal sdcasn   : std_logic;
  signal sddqm    : std_logic_vector(3 downto 0);
  signal sdclk    : std_logic;
  signal sa       : std_logic_vector(14 downto 0);
  signal sd       : std_logic_vector(31 downto 0);
  -- LCD (AMBA)
  signal ltm_hd      : std_logic;
  signal ltm_vd      : std_logic;
  signal ltm_r       : std_logic_vector(7 downto 0);
  signal ltm_g       : std_logic_vector(7 downto 0);
  signal ltm_b       : std_logic_vector(7 downto 0);
  signal ltm_nclk    : std_logic;
  signal ltm_den     : std_logic;
  signal ltm_grest   : std_logic;
  -- AUX UART
  signal aux_uart_rx : std_logic;
  signal aux_uart_tx : std_logic;
  
  file appFile : text  open read_mode is "app.srec";

  component top
    port (
      db_clk      : in    std_ulogic;
      rst      : in    std_ulogic;
      D_RxD    : in    std_logic;
      D_TxD    : out   std_logic;
      -- 7Segment Anzeige
      digits      : out digit_vector_t(7 downto 0);
      -- SDRAM Controller Interface (AMBA)
      sdcke       : out std_logic;
      sdcsn       : out std_logic;
      sdwen       : out std_logic;
      sdrasn      : out std_logic;
      sdcasn      : out std_logic;
      sddqm       : out std_logic_vector(3 downto 0);
      sdclk       : out std_logic;
      sa          : out std_logic_vector(14 downto 0);
      sd          : inout std_logic_vector(31 downto 0);
      -- LCD (AMBA)
      ltm_hd      : out std_logic;
      ltm_vd      : out std_logic;
      ltm_r       : out std_logic_vector(7 downto 0);
      ltm_g       : out std_logic_vector(7 downto 0);
      ltm_b       : out std_logic_vector(7 downto 0);
      ltm_nclk    : out std_logic;
      ltm_den     : out std_logic;
      ltm_grest   : out std_logic;
      -- AUX UART
      aux_uart_rx : in  std_logic;
      aux_uart_tx : out std_logic
      );    
  end component;

  -- SDRAM simulation model
  component mt48lc16m16a2
    generic (
      -- Timing Parameters for -75 (PC133) and CAS Latency = 2
      tAC       : TIME    :=  6.0 ns;
      tHZ       : TIME    :=  7.0 ns;
      tOH       : TIME    :=  2.7 ns;
      tMRD      : INTEGER :=  2;          -- 2 Clk Cycles
      tRAS      : TIME    := 45.0 ns;
      tRC       : TIME    := 65.0 ns;
      tRCD      : TIME    := 20.0 ns;
      tRP       : TIME    := 20.0 ns;
      tRRD      : TIME    := 15.0 ns;
      tWRa      : TIME    :=  7.5 ns;     -- A2 Version - Auto precharge mode only (1 Clk + 7.5 ns)
      tWRp      : TIME    := 15.0 ns;     -- A2 Version - Precharge mode only (15 ns)
      
      tAH       : TIME    :=  0.8 ns;
      tAS       : TIME    :=  1.5 ns;
      tCH       : TIME    :=  2.5 ns;
      tCL       : TIME    :=  2.5 ns;
      tCK       : TIME    := 10.0 ns;
      tDH       : TIME    :=  0.8 ns;
      tDS       : TIME    :=  1.5 ns;
      tCKH      : TIME    :=  0.8 ns;
      tCKS      : TIME    :=  1.5 ns;
      tCMH      : TIME    :=  0.8 ns;
      tCMS      : TIME    :=  1.5 ns;
      
      addr_bits : INTEGER := 13;
      data_bits : INTEGER := 16;
      col_bits  : INTEGER :=  9;
      index     : INTEGER :=  0;
      fname     : string  := "sdram.srec"	-- initialization file for sdram data
      );
    port (
      Dq    : INOUT STD_LOGIC_VECTOR (data_bits - 1 DOWNTO 0) := (OTHERS => 'Z');
      Addr  : IN    STD_LOGIC_VECTOR (addr_bits - 1 DOWNTO 0) := (OTHERS => '0');
      Ba    : IN    STD_LOGIC_VECTOR := "00";
      Clk   : IN    STD_LOGIC := '0';
      Cke   : IN    STD_LOGIC := '1';
      Cs_n  : IN    STD_LOGIC := '1';
      Ras_n : IN    STD_LOGIC := '1';
      Cas_n : IN    STD_LOGIC := '1';
      We_n  : IN    STD_LOGIC := '1';
      Dqm   : IN    STD_LOGIC_VECTOR (1 DOWNTO 0) := "00"
      );
  end component;
  
  
  
begin

  top_1: top
    port map (
      db_clk         => clk,
      rst            => rst,
      D_RxD          => D_RxD,
      D_TxD          => D_TxD,
      digits         => digits,
      sdcke          => sdcke,
      sdcsn          => sdcsn,
      sdwen          => sdwen,
      sdrasn         => sdrasn,
      sdcasn         => sdcasn,
      sddqm          => sddqm,
      sdclk          => sdclk,
      sa             => sa,
      sd             => sd,
      ltm_hd         => ltm_hd,
      ltm_vd         => ltm_vd,
      ltm_r          => ltm_r,
      ltm_g          => ltm_g,
      ltm_b          => ltm_b,
      ltm_nclk       => ltm_nclk,
      ltm_den        => ltm_den,
      ltm_grest      => ltm_grest,
      aux_uart_rx    => aux_uart_rx,
      aux_uart_tx    => aux_uart_tx
      );


  -- SDRAM simulation model
  sdram_model1: mt48lc16m16a2
  port map
  (
    Dq    => sd(15 downto 0),
    Addr  => sa(12 downto 0),
    Ba    => sa(14 downto 13),
    Clk   => sdclk,
    Cke   => sdcke,
    Cs_n  => sdcsn,
    Ras_n => sdrasn,
    Cas_n => sdcasn,
    We_n  => sdwen,
    Dqm   => sddqm(1 downto 0)
  );

  sdram_model2: mt48lc16m16a2
  port map
  (
    Dq    => sd(31 downto 16),
    Addr  => sa(12 downto 0),
    Ba    => sa(14 downto 13),
    Clk   => sdclk,
    Cke   => sdcke,
    Cs_n  => sdcsn,
    Ras_n => sdrasn,
    Cas_n => sdcasn,
    We_n  => sdwen,
    Dqm   => sddqm(3 downto 2)
  );


  
  clkgen : process
  begin
    clk <= '1';
    wait for cc/2;
    clk <= '0'; 
    wait for cc/2;
  end process clkgen;
  
  
  test: process
    
    procedure icwait(cycles: Natural) is
    begin 
      for i in 1 to cycles loop 
      	wait until clk= '0' and clk'event;
      end loop;
    end ;

    procedure ser_send(send: Natural; parity: parity_type) is
      variable parityBit : std_logic;
    begin
      parityBit := '0';
      D_RxD <= '0';-- startbit(0)
      icwait(bittime);  

      -- send data bits
      for i in 0 to 7 loop 
        D_RxD <= to_unsigned(send,8)(i); icwait(bittime);
        parityBit := parityBit xor to_unsigned(send,8)(i);
      end loop;

      -- optional parity bit
      if parity /= none then
        if parity = odd then
          parityBit := not parityBit;
        end if;
        D_Rxd <= parityBit;
        icwait(bittime);
      end if;

      -- Stop1
      D_Rxd <= '1';
      icwait(bittime);
    end;
    
    variable l : line;
    variable c : character;
    variable neol : boolean;
    
  begin

    rst <= RST_ACT;
    D_Rxd <= '1';
    aux_uart_rx <= '1';
    icwait(100);
    rst <= not RST_ACT;

    -- wait until bootloader is ready to receive program
    icwait(2000);
  
    while not endfile(appFile) loop
      readline(appFile, l);
      loop
        read(l, c, neol);
        exit when not neol;
        ser_send(character'pos(c), even);
      end loop;
      -- newline
      ser_send(10, even);
    end loop;

    wait;
  
  end process test;

  

end behaviour; 

