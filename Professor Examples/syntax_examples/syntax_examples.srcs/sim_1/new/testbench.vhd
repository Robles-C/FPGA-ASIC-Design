-------------------------------------------------------------------------------
-- Title      : CSUN Syntax Examples
-- Project    : 
-------------------------------------------------------------------------------
-- File       : top.vhd
-- Author     : Phil Tracton  <ptracton@gmail.com>
-- Company    : CSUN
-- Created    : 2023-10-08
-- Last update: 2023-10-08
-- Platform   : Modelsim on Linux
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2023 CSUN
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2023-10-08  1.0      ptracton        Created
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- These are the default libraries that you probably need for a testbench
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;  -- needed for std_logic and std_logic_vector
use IEEE.NUMERIC_STD.all;               -- needed for doing math
use std.env.finish;           -- needed for simulation to terminate (finish)


-------------------------------------------------------------------------------
-- These is the testbench entity.  Notice it has no port map since there is
-- nothing coming in or out of it.  It is the model of the board the FPGA
-- resides on.
--
-- REMEMBER -- the testbench is not synthesizable!
-- This lets you do things like read/write files and use real data type.
-------------------------------------------------------------------------------
entity testbench is
end testbench;

-------------------------------------------------------------------------------
-- This is the test bench architecture.  It is where all the signals, components,
-- and instantiations happen.  
-------------------------------------------------------------------------------
architecture Behavioral of testbench is
  -----------------------------------------------------------------------------
  -- This is the declaritive area.  all components are listed here and all
  -- signals, variables and constants for this module are declared
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- The component is a copy of the entity you will be instantiating in this module.
  -- Just change the word entity to component and the end needs to be end component;
  -- Everything must be spelled the same and have the same size for both the
  -- generic and ports.  Any size or spelling mis-matches and this will not work.
  -----------------------------------------------------------------------------  
  component top is
    generic (TERMINAL0_COUNT : integer := 1000;  -- ends with ;
             TERMINAL1_COUNT : integer := 1000   -- last one does NOT
             );
    port(
      clk   : in std_logic;                      -- ends with ;
      reset : in std_logic;

      counter_enable : in  std_logic_vector(1 downto 0);  -- We have 2 counters
                                                          -- and each needs an
                                                          -- enable
      counter_done   : out std_logic_vector(1 downto 0)   -- last one does NOT
      );
  end component;


  -----------------------------------------------------------------------------
  -- Constants once declared can not be changed during a simulation
  -- The clock period is a good example since it should not be changing
  -- 10ns --> 100 MHz
  -----------------------------------------------------------------------------  
  constant CLK_PERIOD : time := 10 ns;

  -----------------------------------------------------------------------------
  -- Signals can take on many differet values.  They can be treated as wires
  -- connecting things or as a register type that can hold state.
  --
  -- The _tb signals are in the testbench and expected to be connected to the DUT.
  -- this is just a convention, not a rule.
  -----------------------------------------------------------------------------    
  signal clk_tb   : std_logic;
  signal reset_tb : std_logic;

  signal enable_tb : std_logic_vector(1 downto 0);
  signal done_tb   : std_logic_vector(1 downto 0);

  signal rising_time0 : time;           -- can not synthesize time type
  signal rising_time1 : time;

begin

  ------------------------------------------------------------------------------
  -- Free running clock from the board
  -- This is a 50% duty cycle (high time and low time are equal)
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
  -- all processes run concurrently.  The clock process above and test process
  -- below all start at the same time and run in parallel.
  ------------------------------------------------------------------------------
  reset_process : process
  begin
    reset_tb <= '0';
    wait for 50 ns;
    reset_tb <= '1';
    wait for 100 ns;
    reset_tb <= '0';
    wait;  -- wait forever and never return to this process
  end process;

  ------------------------------------------------------------------------------
  -- FPGA to test
  -- The Device Under Test (DUT) is the module that will go INSIDE the FPGA.
  -- The goal is to make sure it is working correctly for all expected uses
  -- and conditions.
  ------------------------------------------------------------------------------
  DUT : top
    generic map(TERMINAL0_COUNT => 10,  -- comma at the end
                TERMINAL1_COUNT => 21)  -- except for the last one
    port map(
      clk   => clk_tb,                  -- comma at the end
      reset => reset_tb,

      counter_enable => enable_tb,
      counter_done   => done_tb         -- except for the last one
      );                                -- instance ends with ;

  ------------------------------------------------------------------------------
  -- Test case
  -- This is where you will drive signals into the DUT and watch the signals
  -- that come out of it.
  -- 
  -- You want a LOT of different ways to fail a test case and only 1 way to PASS
  -- it.  all failures should report a unique message so you know what failed and
  -- where.  if you read the end of the test, it should indicate a "TEST PASSED"
  -- message
  ------------------------------------------------------------------------------  
  test_case : process
  begin
    -- This code is executed sequentially, 1 statement after the other
    -- This lets us test the code over time.  it starts running at the
    -- beginning of the simulation

    -- At the start of test, set all input to the DUT signals to some default
    -- value.  Usually 0, but it depends on what the design is doing
    enable_tb <= "00";

    -- Do not start testing the module until reset is done.  if you test
    -- while the DUT is in reset, nothing is going to work correctly.

    wait until falling_edge(reset_tb);  -- wait until is expecting to watch a
                                        -- signal to take a specific value

    wait for 100 ns;  -- wait for is waiting for a specified amount of time


    -- Turn on 1 of the timers
    enable_tb <= "01";

    -- when this counter is done, store the time
    wait until rising_edge(done_tb(0));
    rising_time0 <= time(now);

    -- wait for the next time it is done and make sure the
    -- time between the rising edges of the expired signal is
    -- the correct amount of time
    wait until rising_edge(done_tb(0));
    if (now - rising_time0) /= 100 ns then
      report "FAILED COUNTER(0) 100ns  ";
      finish;
    end if;

    -- Turn on the other timer
    enable_tb <= "10";

    -- when this counter is done, store the time
    wait until rising_edge(done_tb(1));
    rising_time1 <= time(now);

    -- wait for the next time it is done and make sure the
    -- time between the rising edges of the expired signal is
    -- the correct amount of time
    wait until rising_edge(done_tb(1));
    if (now - rising_time1) /= 210 ns then
      report "FAILED COUNTER(1) 210ns  ";
      finish;
    end if;

    -- Turn off all timers
    enable_tb <= "00";
    wait for 100 ns;

    report "TEST PASSED";               -- The report command is like printf
    finish;
  end process;

end Behavioral;
