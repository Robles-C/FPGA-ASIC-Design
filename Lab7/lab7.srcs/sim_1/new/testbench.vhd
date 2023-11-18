-------------------------------------------------------------------------------
-- Title      : Lab 5 Test Bench
-- Project    :
-------------------------------------------------------------------------------
-- File       : testbench.vhd
-- Author     : Phil Tracton  <ptracton@gmail.com>
-- Company    : CSUN
-- Created    : 2023-09-24
-- Last update: 2023-10-04
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
      XRX             : in    std_logic;
      XTX             : out   std_logic;
      COL             : buffer std_logic_vector(4 downto 1);
      ROW             : in    std_logic_vector(4 downto 1)
      );

  end component;

  signal clk_tb            : std_logic := '0';
  signal reset_tb          : std_logic := '0';
  signal switches_tb       : std_logic_vector(3 downto 0);
  signal leds_tb           : std_logic_vector(3 downto 0);
  signal locked_tb         : std_logic;
  signal seven_segments_tb : std_logic_vector(7 downto 0);
  signal col_tb            : std_logic_vector(4 downto 1);
  signal row_tb            : std_logic_vector(4 downto 1);

  component UART_TX_tb
    generic (
      g_CLKS_PER_BIT : integer := 115   -- Needs to be set correctly
      );
    port (
      i_Clk       : in  std_logic;
      i_TX_DV     : in  std_logic;
      i_TX_Byte   : in  std_logic_vector(7 downto 0);
      o_TX_Active : out std_logic;
      o_TX_Serial : out std_logic;
      o_TX_Done   : out std_logic
      );
  end component;
  signal tx_byte   : std_logic_vector(7 downto 0);
  signal tx_active : std_logic;
  signal tx_done   : std_logic;
  signal tx_dv     : std_logic;
  signal tx_tb     : std_logic;

  component UART_RX_tb
    generic (
      g_CLKS_PER_BIT : integer := 115   -- Needs to be set correctly
      );
    port (
      i_Clk       : in  std_logic;
      i_RX_Serial : in  std_logic;
      o_RX_DV     : out std_logic;
      o_RX_Byte   : out std_logic_vector(7 downto 0)
      );
  end component;

  signal rx_byte : std_logic_vector(7 downto 0);
  signal rx_dv   : std_logic;
  signal rx_tb   : std_logic;

  signal uart_pass : boolean;           --:= false;
  signal uart_fail : boolean;           --:= false;

  signal gpio_pass : boolean;           --:= false;
  signal gpio_fail : boolean;           -- := false;
  
  signal kp_pass : boolean;           --:= false;
  signal kp_fail : boolean;           -- := false;

  constant CLK_PERIOD : time := 8 ns;   --125MHz
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

  ------------------------------------------------------------------------------
  -- FPGA to test
  ------------------------------------------------------------------------------
  DUT : top
    port map(
      XCLK            => clk_tb,
      XRESET          => reset_tb,
      XSWITCHES       => switches_tb,
      XLEDS           => leds_tb,
      XSEVEN_SEGMENTS => seven_segments_tb,
      XLOCKED         => locked_tb,
      XRX             => rx_tb,
      XTX             => tx_tb,
      COL             => col_tb,
      ROW             => row_tb
     --     XTESTBUS        => testbus_tb
      );

  ------------------------------------------------------------------------------
  -- UART Transmitter, known good device to send data to test FPGA UART receiver
  ------------------------------------------------------------------------------
  transmit : UART_TX_tb
    generic map (
      g_CLKS_PER_BIT => 1085)
    port map (
      i_Clk       => clk_tb,
      i_TX_DV     => tx_dv,
      i_TX_Byte   => tx_byte,
      o_TX_Active => tx_active,
      o_TX_Serial => rx_tb,
      o_TX_Done   => tx_done
      );

  ------------------------------------------------------------------------------
  -- UART Receiver, known good device to receive data to test FPGA UART transmitter
  ------------------------------------------------------------------------------
  receive : UART_RX_tb
    generic map (
      g_CLKS_PER_BIT => 1085)
    port map (
      i_Clk       => clk_tb,
      i_RX_Serial => tx_tb,
      o_RX_DV     => rx_dv,
      o_RX_Byte   => rx_byte
      );


  ------------------------------------------------------------------------------
  -- UART Test case
  --
  -- Send a character to the FPGA, wait for receiver to indicate it has new data
  -- compare the newly received character with the one sent in.  if they differ
  -- report and terminate test.
  ------------------------------------------------------------------------------
  uart_test_case : process is
  begin
    tx_dv     <= '0';
    tx_byte   <= x"00";
    uart_pass <= false;
    uart_fail <= false;

    -- wait for LOCKED to go high so we know the clocks in FPGA
    -- are good.  then give 20us to make sure reset has completed
    wait until rising_edge(locked_tb);
    wait for 20 us;

    -- Send in character
    wait until rising_edge(clk_tb);
    tx_dv   <= '1';
    tx_byte <= x"73";
    wait until rising_edge(clk_tb);
    tx_dv   <= '0';

    -- wait for transmission to complete
    wait until rx_dv = '1';
    if rx_byte /= x"73" then
      wait for 10 us;
      report "FAILED to RECEIVE 0x73";
      uart_fail <= true;
    else
      report "RECEIVED 0x73";
    end if;

    -- Send in character
    wait until rising_edge(clk_tb);
    tx_dv   <= '1';
    tx_byte <= x"A5";
    wait until rising_edge(clk_tb);
    tx_dv   <= '0';

    -- -- wait for transmission to complete
    wait until rx_dv = '1';
    if rx_byte /= x"A5" then
      wait for 10 us;
      report "FAILED to RECEIVE 0xA5";
      uart_fail <= true;
    else
      report "RECEIVED 0xA5";
    end if;


    report "UART TEST PASSED";
    uart_pass <= true;
    wait;
  end process;


  ------------------------------------------------------------------------------
  -- GPIO Test case
  --
  -- One by one assert each switch and check if the corresponding LED is
  -- asserted
  ------------------------------------------------------------------------------
  gpio_test_case : process
  begin
    gpio_pass   <= false;
    gpio_fail   <= false;
    switches_tb <= x"0";

    -- wait for LOCKED to go high so we know the clocks in FPGA
    -- are good.  then give 20us to make sure reset has completed
    wait until rising_edge(locked_tb);
    wait for 20 us;

    wait until rising_edge(clk_tb);
    switches_tb <= x"1";
    wait until rising_edge(clk_tb);
    if leds_tb /= switches_tb then
      report "LED/SWITCHES FAIL 1";
      gpio_fail <= true;
    end if;

    wait until rising_edge(clk_tb);
    switches_tb <= x"2";
    wait until rising_edge(clk_tb);
    if leds_tb /= switches_tb then
      report "LED/SWITCHES FAIL 2";
      gpio_fail <= true;
    end if;


    wait until rising_edge(clk_tb);
    switches_tb <= x"4";
    wait until rising_edge(clk_tb);
    if leds_tb /= switches_tb then
      report "LED/SWITCHES FAIL 4";
      gpio_fail <= true;

    end if;


    wait until rising_edge(clk_tb);
    switches_tb <= x"8";
    wait until rising_edge(clk_tb);
    if leds_tb /= switches_tb then
      report "LED/SWITCHES FAIL 8";
      gpio_fail <= true;
    end if;

    report "GPIO TEST PASSED";
    gpio_pass <= true;
    wait;
  end process;

    ------------------------------------------------------------------------------
  -- KeyPad Test case
  --
  ------------------------------------------------------------------------------
  keypad_test_case : process
  begin
    kp_pass   <= false;
    kp_fail   <= false;

    -- wait for LOCKED to go high so we know the clocks in FPGA
    -- are good.  then give 20us to make sure reset has completed
    wait until rising_edge(locked_tb);
    wait for 20 us;

    wait until rising_edge(clk_tb);
    col_tb <= "0010";
    row_tb <= "0100";
    wait;
  end process;  
  
  ------------------------------------------------------------------------------
  -- Results Process
  --
  -- Collect the various PASS/FAIL signals to determine if we are done and if
  -- we passed or failed
  ------------------------------------------------------------------------------
  results_process : process (clk_tb)
  begin

    if rising_edge(clk_tb) then

      if locked_tb = '1' then

        if gpio_fail = true or uart_fail = true then
          report "TEST FAILED";
          finish;
        end if;

        if gpio_pass = true and uart_pass = true then
          report "ALL TESTS PASSED";
          finish;
        end if;

      end if;
    end if;

  end process;

end Behavioral;
