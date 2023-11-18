-------------------------------------------------------------------------------
-- Title      : Simple Timer
-- Project    : 
-------------------------------------------------------------------------------
-- File       : timer.vhd
-- Author     : Phil Tracton  <ptracton@gmail.com>
-- Company    : CSUN
-- Created    : 2023-09-24
-- Last update: 2023-10-06
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
use IEEE.NUMERIC_STD.all;


entity timer is
  generic (TERMINAL_COUNT : integer := 1000);  -- How long to count
  port (clk   : in  std_logic;
        reset : in  std_logic;
        timer : out std_logic
        );
end timer;

architecture Behavioral of timer is
begin

  ------------------------------------------------------------------------------
  -- Count until terminal_count - 1 and then restart from 0
  ------------------------------------------------------------------------------        
  process (clk)
    variable count : integer;
  begin
    if rising_edge(clk) then
      if (reset = '1') then
        count := 0;
        timer <= '0';
      else
        count := count + 1;

        if count = (TERMINAL_COUNT-1) then
          count := 0;
          timer <= '1';
        else
          timer <= '0';
        end if;
      end if;
    end if;
  end process;


end Behavioral;
