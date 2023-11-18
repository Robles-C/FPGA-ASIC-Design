-------------------------------------------------------------------------------
-- Title      : Seven Segment in VHDL
-- Project    :
-------------------------------------------------------------------------------
-- File       : top.vhd
-- Author     : Phil Tracton  <ptracton@gmail.com>
-- Company    : CSUN
-- Created    : 2023-09-24
-- Last update: 2023-10-01
-- Platform   : Modelsim on Linux
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2023 CSUN
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2023-09-24  1.0      ptracton        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity top is

  port (
    XCLK            : in    std_logic;  -- 125MHz clock
    XBTNS           : inout std_logic_vector(3 downto 0);-- switc Reset
    XRESET          : in    std_logic;
    XLEDS           : inout std_logic_vector(3 downto 0);
    --XSEVEN_SEGMENTS : out   std_logic_vector(7 downto 0);
    --XRX             : in    std_logic;
    --XTX             : out   std_logic;
    --COL             : buffer std_logic_vector(3 downto 0);
    --ROW             : in    std_logic_vector(3 downto 0);
    XLOCKED         : out   std_logic
    );

end entity top;


architecture rtl of top is
  component system_controller is
    generic (RESET_COUNT : integer := 32);
    port(
      clk_in    : in  std_logic;
      reset_in  : in  std_logic;
      clk_out   : out std_logic;
      locked    : out std_logic;
      reset_out : out std_logic
      );
  end component;

  component gpio is
    generic (
      WIDTH : integer);
    port (
      oe    : in    std_logic_vector(3 downto 0);
      inp   : in    std_logic_vector(3 downto 0);
      outp  : out   std_logic_vector(3 downto 0);
      bidir : inout std_logic_vector(3 downto 0)
      );
  end component;

--  component seven_segments is

--    port (
--      clk            : in  std_logic;
--      reset          : in  std_logic;
--      seven_segments : out std_logic_vector(7 downto 0);
--      timer_expired  : out std_logic
--      );

--  end component;

--  component UART is

--    port(
--      clk      : in std_logic;
--      reset    : in std_logic;
--      tx_start : in std_logic;

--      data_in       : in  std_logic_vector (7 downto 0);
--      data_out      : out std_logic_vector (7 downto 0);
--      rx_data_ready : out std_logic;

--      rx : in  std_logic;
--      tx : out std_logic
--      );
--  end component;
  
--  component pmod_keypad is
--    generic(
--      clk_freq    : integer;
--      stable_time : integer
--    );
--    port(
--      clk     :  in     std_logic;
--      reset_n :  in     std_logic;
--      rows    :  in     std_logic_vector(1 TO 4);
--      columns :  buffer std_logic_vector(1 TO 4);
--      keys    :  out    std_logic_vector(0 TO 15)
--    );
--  end component;

  -- System Signals
  signal clk   : std_logic;
  signal reset : std_logic;

  -- GPIO Signals
  signal gpio_bus : std_logic_vector(3 downto 0);

  -- Seven Segment Display Signals
--  signal seven_segments_int : std_logic_vector(7 downto 0);
--  signal timer_expired      : std_logic;

  -- UART Signals
--  signal tx_start      : std_logic;
--  signal uart_data_rx  : std_logic_vector(7 downto 0);
--  signal uart_data_tx  : std_logic_vector(7 downto 0);
--  signal rx_data_ready : std_logic;

  -- KEYPAD signal
--  signal keys_int    : std_logic_vector(0 to 15) := (others => '0');
begin

  ------------------------------------------------------------------------------
  --
  -- System Controller cleans up the clock and reset signals from the board
  --
  ------------------------------------------------------------------------------
  sys_con : system_controller
    port map(
      clk_in    => XCLK,
      reset_in  => XRESET,
      clk_out   => clk,
      reset_out => reset,
      locked    => XLOCKED
      );

  ------------------------------------------------------------------------------
  --
  -- Drive the LED for the corresponding switch when it is high
  --
  ------------------------------------------------------------------------------
  LEDS : gpio
    generic map(WIDTH => 4)
    port map(
      oe    => (others => '1'),         -- LEDS are outputs
      inp   => gpio_bus,
      outp  => open,
      bidir => XLEDS
      );

  ------------------------------------------------------------------------------
  --
  -- Read the state of the buttons on the board
  --
  ------------------------------------------------------------------------------
  BUTTONS : gpio
    generic map(WIDTH => 4)
    port map(
      oe    => (others => '0'),
      inp   => (others => '0'),
      outp  => gpio_bus,
      bidir => XBTNS
      );

  ------------------------------------------------------------------------------
  --
  -- Seven Segment Displays
  --
  ------------------------------------------------------------------------------
--  display : seven_segments
--    port map(
--      clk            => clk,
--      reset          => reset,
--      seven_segments => seven_segments_int,
--      timer_expired  => timer_expired
--      );
--  XSEVEN_SEGMENTS <= seven_segments_int;

  ------------------------------------------------------------------------------
  --
  -- USB UART Bridge
  --
  ------------------------------------------------------------------------------
--  uart_inst : UART
--    port map (
--      clk           => clk,
--      reset         => reset,
--      tx_start      => tx_start,
--      data_in       => uart_data_tx,
--      data_out      => uart_data_rx,
--      rx_data_ready => rx_data_ready,
--      rx            => XRX,
--      tx            => XTX
--      );

  ------------------------------------------------------------------------------
  --
  -- KEYPAD
  --
  ------------------------------------------------------------------------------
--  keypad_inst: pmod_keypad generic map (
--    clk_freq    => 125_000_000,
--    stable_time => 10
--  ) port map (
--    clk     => clk,
--    reset_n => reset,
--    rows    => ROW,
--    columns => COL,
--    keys    => keys_int
--  );

  
  ------------------------------------------------------------------------------
  --
  -- Catch received byte and transmit it back to user
  --
  ------------------------------------------------------------------------------
--echo : process(clk)
--begin
--    if rising_edge(clk) then
--        if reset = '1' then
--            tx_start     <= '0';
--            uart_data_tx <= x"00";
----        elsif rx_data_ready = '1' then
----            tx_start     <= '1';
----            uart_data_tx <= uart_data_rx;
----            --uart_data_tx <= "00110000";
--        else
--            if keys_int(0) = '1' then
--                tx_start     <= '1';
--                uart_data_tx <= "00110000";
--            elsif keys_int(1) = '1' then
--                tx_start     <= '1';
--                uart_data_tx <= "00110001";
--            elsif keys_int(2) = '1' then
--                tx_start     <= '1';
--                uart_data_tx <= "00110010";  
--            elsif keys_int(3) = '1' then
--                tx_start     <= '1';
--                uart_data_tx <= "00110011";
--            elsif keys_int(4) = '1' then
--                tx_start     <= '1';
--                uart_data_tx <= "00110100";  
--            elsif keys_int(5) = '1' then
--                tx_start     <= '1';
--                uart_data_tx <= "00110101";  
--            elsif keys_int(6) = '1' then
--                tx_start     <= '1';
--                uart_data_tx <= "00110110";  
--            elsif keys_int(7) = '1' then
--                tx_start     <= '1';
--                uart_data_tx <= "00110111";  
--            elsif keys_int(8) = '1' then
--                tx_start     <= '1';
--                uart_data_tx <= "00111000";  
--            elsif keys_int(9) = '1' then
--                tx_start     <= '1';
--                uart_data_tx <= "00111001";  
--            elsif keys_int(10) = '1' then
--                tx_start     <= '1';
--                uart_data_tx <= "01000001";  
--            elsif keys_int(11) = '1' then
--                tx_start     <= '1';
--                uart_data_tx <= "01000010";  
--            elsif keys_int(12) = '1' then
--                tx_start     <= '1';
--                uart_data_tx <= "01000011";  
--            elsif keys_int(13) = '1' then
--                tx_start     <= '1';
--                uart_data_tx <= "01000100";  
--            elsif keys_int(14) = '1' then
--                tx_start     <= '1';
--                uart_data_tx <= "01000100";  
--            elsif keys_int(15) = '1' then
--                tx_start     <= '1';
--                uart_data_tx <= "01000100";  
--            end if;
--        end if;
--    end if;
--end process;

end architecture rtl;
