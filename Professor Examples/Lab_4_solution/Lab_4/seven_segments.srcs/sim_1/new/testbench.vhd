-------------------------------------------------------------------------------
-- Title      : Seven Segment Display Testbench
-- Project    : 
-------------------------------------------------------------------------------
-- File       : testbench.vhd
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
-- 2023-09-24  1.0      ptracton	Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use std.env.finish;
use IEEE.NUMERIC_STD.all;


entity testbench is
end testbench;

architecture Behavioral of testbench is

  component top is

    port (
      XCLK            : in    std_logic;  -- 125MHz clock
      XRESET          : in    std_logic;  -- Button Reset
      XSWITCHES       : inout std_logic_vector(3 downto 0);
      XLEDS           : inout std_logic_vector(3 downto 0);
      XSEVEN_SEGMENTS : out   std_logic_vector(7 downto 0);
      XLOCKED         : out   std_logic;
      XTESTBUS        : out   std_logic_vector(3 downto 0)
      );

  end component;

  constant CLK_PERIOD      : time      := 8 ns;  --125MHz
  signal clk_tb            : std_logic := '0';
  signal reset_tb          : std_logic := '0';
  signal switches_tb       : std_logic_vector(3 downto 0);
  signal leds_tb           : std_logic_vector(3 downto 0);
  signal locked_tb         : std_logic;
  signal seven_segments_tb : std_logic_vector(7 downto 0);
  signal testbus_tb        : std_logic_vector(3 downto 0);
begin

  ------------------------------------------------------------------------------
  -- Free running clock from the board
  ------------------------------------------------------------------------------      
  clk_process : process
  begin
    clk_tb <= '0';
    wait for CLK_PERIOD/2;
    clk_tb <= '1';
    wait for CLK_PERIOD/2;
  end process;

  ------------------------------------------------------------------------------
  -- Push button reset
  ------------------------------------------------------------------------------      
  reset_process : process
  begin
    reset_tb <= '0';
    wait for 50 ns;
    reset_tb <= '1';
    wait for 100 ns;
    reset_tb <= '0';
    wait;
  end process;

  DUT : top
    port map(
      XCLK            => clk_tb,
      XRESET          => reset_tb,
      XSWITCHES       => switches_tb,
      XLEDS           => leds_tb,
      XSEVEN_SEGMENTS => seven_segments_tb,
      XLOCKED         => locked_tb,
      XTESTBUS        => testbus_tb
      );


  test_process : process
  begin
    wait until rising_edge(locked_tb);

    wait for 3.25 ms;

    finish;
  end process;

end Behavioral;
