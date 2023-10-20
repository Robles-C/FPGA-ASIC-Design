-------------------------------------------------------------------------------
-- Title      : CSUN Syntax Examples
-- Project    :
-------------------------------------------------------------------------------
-- File       : counter.vhd
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
-- These are the default libraries that you probably need for a design
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;  -- needed for std_logic and std_logic_vector
use IEEE.NUMERIC_STD.all;               -- needed for doing math

-------------------------------------------------------------------------------
-- This is your design entity.  it is a list of all signals that come in and
-- go out of the module.  It also can list generics which are configurable
-- parameters that can be modified at instantiation.
--
-- Signals listed in the entity can be used in the architecture without needing
-- to declare them again
--
-- This is a design file it must be synthesizable
-------------------------------------------------------------------------------
entity counter is
  generic (TERMINAL_COUNT : integer := 1000);
  port (
    clk   : in std_logic;
    reset : in std_logic;

    enable : in  std_logic;
    done   : out std_logic
    );
end counter;

-------------------------------------------------------------------------------
-- This is the test bench architecture.  It is where all the signals, components,
-- and instantiations happen.
-------------------------------------------------------------------------------
architecture rtl of counter is
  -----------------------------------------------------------------------------
  -- This is the declaritive area.  all components are listed here and all
  -- signals, variables and constants for this module are declared
  -----------------------------------------------------------------------------
  signal debug_count : std_logic_vector(31 downto 0);
begin

  counter_process : process (clk)
    ---------------------------------------------------------------------------
    -- Create an integer variable local to this process.  std_logic_vectors
    -- can't do math, but integers can.  So we use an integer to count the clock
    -- edges.  if we reach TERMINAL-1 we are done and need to start over
    ---------------------------------------------------------------------------
    variable counter : integer;
  begin
    -- This is always the first if statement in a
    -- sequential process.
    if (rising_edge(clk)) then

      -- This is a synchronous reset as Xilinx
      -- recommends!  Only works if there is a clock edge
      -- if the reset was before the rising_edge(clk) then it
      -- would be asynchronous which is  good for ASICs, but
      -- bad for FPGA.
      if (reset = '1') then

        -- Set all signals and variables of this process to
        -- defaul values
        counter := 0;
        done    <= '0';

        debug_count <= (others => '0');  -- others is a quick way to set all
                                         -- bits in a vector
      else
        -- if in VHDL is just =, not == like most languages
        if enable = '1' then
          if counter = (TERMINAL_COUNT-1) then  -- Count to terminal -1, since
                                                -- we want to assert the bit to
                                                -- indicate time
            done    <= '1';             -- assert this signal
            counter := 0;               -- reset the count to start over

            -- counter variable is not visible in waveforms, debug_count is
            debug_count <= std_logic_vector(to_unsigned(counter, debug_count'length));
          else
            -- We have a rising clock, no reset and enable is 1, count is not
            -- terminal, so count + 1
            counter     := counter + 1;
            debug_count <= std_logic_vector(to_unsigned(counter, debug_count'length));
            done        <= '0';
          end if;
        else
          -- Counter no longer enabled, reset everything to 0
          counter     := 0;
          debug_count <= std_logic_vector(to_unsigned(counter, debug_count'length));
          done        <= '0';
        end if;
      end if;
    end if;
  end process;

end rtl;
