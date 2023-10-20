-------------------------------------------------------------------------------
-- Title      : Seven Segment in VHDL
-- Project    :
-------------------------------------------------------------------------------
-- File       : top.vhd
-- Author     : Phil Tracton  <ptracton@gmail.com>
-- Company    : CSUN
-- Created    : 2023-09-24
-- Last update: 2023-09-24
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
    XRESET          : in    std_logic;  -- Button Reset
    XSWITCHES       : inout std_logic_vector(3 downto 0);
    XLEDS           : inout std_logic_vector(3 downto 0);
    XSEVEN_SEGMENTS : out   std_logic_vector(7 downto 0);
    XLOCKED         : out   std_logic;
    XTESTBUS        : out   std_logic_vector(3 downto 0)
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

  component seven_segments is

    port (
      clk            : in  std_logic;
      reset          : in  std_logic;
      seven_segments : out std_logic_vector(7 downto 0);
      timer_expired  : out std_logic
      );

  end component;

  signal gpio_bus : std_logic_vector(3 downto 0);

  signal clk                : std_logic;
  signal reset              : std_logic;
  signal seven_segments_int : std_logic_vector(7 downto 0);
  signal timer_expired      : std_logic;
begin

  ------------------------------------------------------------------------------
  --
  -- Test bus to PMOD E
  --
  ------------------------------------------------------------------------------
  XTESTBUS(0) <= '0';
  XTESTBUS(1) <= timer_expired;
  XTESTBUS(2) <= '1';
  XTESTBUS(3) <= clk;

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
  -- Read the state of the switches on the board
  --
  ------------------------------------------------------------------------------
  SWITCHES : gpio
    generic map(WIDTH => 4)
    port map(
      oe    => (others => '0'),         -- Switches are inputs
      inp   => (others => '0'),
      outp  => gpio_bus,
      bidir => XSWITCHES
      );

  ------------------------------------------------------------------------------
  --
  -- Seven Segment Displays
  --
  ------------------------------------------------------------------------------
  display : seven_segments
    port map(
      clk            => clk,
      reset          => reset,
      seven_segments => seven_segments_int,
      timer_expired  => timer_expired
      );
  XSEVEN_SEGMENTS <= seven_segments_int;
end architecture rtl;
