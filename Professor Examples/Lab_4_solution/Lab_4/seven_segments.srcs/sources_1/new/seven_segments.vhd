-------------------------------------------------------------------------------
-- Title      : PMOD Seven Segment Display
-- Project    :
-------------------------------------------------------------------------------
-- File       : seven_segments.vhd
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
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity seven_segments is

  port (
    clk            : in  std_logic;
    reset          : in  std_logic;
    seven_segments : out std_logic_vector(7 downto 0);
    timer_expired  : out std_logic
    );

end entity seven_segments;


architecture rtl of seven_segments is
  component timer is
    generic (TERMINAL_COUNT : integer := 1000);
    port (clk   : in  std_logic;
          reset : in  std_logic;
          timer : out std_logic
          );
  end component;

  signal timer_expired_int : std_logic;
  signal segment_select    : std_logic;
  signal segment0          : std_logic_vector(6 downto 0);
  signal segment1          : std_logic_vector(6 downto 0);
  signal segment0_map      : std_logic_vector(6 downto 0);
  signal segment1_map      : std_logic_vector(6 downto 0);
  signal timer_one_second  : std_logic;
  signal increment_digit   : std_logic;
  signal increment_ack     : std_logic;
begin

  ------------------------------------------------------------------------------
  -- This timer is used to manage switching which seven segment display to drive
  ------------------------------------------------------------------------------        
  update_timer : timer
    generic map (TERMINAL_COUNT => 1_250_000)
    --generic map (TERMINAL_COUNT => 1_00)
    port map(
      clk   => clk,
      reset => reset,
      timer => timer_expired_int
      );

  ------------------------------------------------------------------------------
  -- This timer is used to manage incrementing the seven segment display
  ------------------------------------------------------------------------------        
  one_second_timer : timer
    generic map (TERMINAL_COUNT => 125_000_000)
    --generic map (TERMINAL_COUNT => 10_000)
    port map(
      clk   => clk,
      reset => reset,
      timer => timer_one_second
      );

  ------------------------------------------------------------------------------
  -- This process manages the counting for the seven segment displays
  ------------------------------------------------------------------------------        
  process (clk)
    variable segment0_count : integer range 0 to 10;
    variable segment1_count : integer range 0 to 10;
  begin
    if rising_edge(clk) then
      if (reset = '1') then
        segment0_count := 0;
        segment1_count := 0;
        segment0       <= (others => '0');
        segment1       <= (others => '0');
      else
        if timer_one_second = '1' then
          segment0_count := segment0_count + 1;

          if segment0_count = 10 then
            segment0_count := 0;
            segment1_count := segment1_count + 1;
            if segment1_count = 10 then
              segment1_count := 0;
            end if;
            segment1 <= std_logic_vector(to_unsigned(segment1_count, segment0'length));            
          end if;
          
          segment0 <= std_logic_vector(to_unsigned(segment0_count, segment0'length));
        end if;
      end if;
    end if;
  end process;

  ------------------------------------------------------------------------------
  -- This process manages switching which seven segment display to drive
  ------------------------------------------------------------------------------      
  process (clk)    
  begin
    if (rising_edge(clk)) then
      if (reset = '1') then
        segment_select <= '0';
      else
        if timer_expired_int = '1' then
          segment_select <= segment_select xor '1';
        end if;
      end if;
    end if;
  end process;
  
  ------------------------------------------------------------------------------
  -- The maps convert a decimal number to a seven segment display
  ------------------------------------------------------------------------------      
  --               GFEDCBA
  segment0_map <= "0111111" when segment0 = "0000000" else
                  "0000110" when segment0 = "0000001" else
                  "1011011" when segment0 = "0000010" else
                  "1001111" when segment0 = "0000011" else
                  "1100110" when segment0 = "0000100" else
                  "1101101" when segment0 = "0000101" else
                  "1111100" when segment0 = "0000110" else
                  "0000111" when segment0 = "0000111" else
                  "1111111" when segment0 = "0001000" else
                  "1100111" when segment0 = "0001001";

  --               GFEDCBA  
  segment1_map <= "0111111" when segment1 = "0000000" else
                  "0000110" when segment1 = "0000001" else
                  "1011011" when segment1 = "0000010" else
                  "1001111" when segment1 = "0000011" else
                  "1100110" when segment1 = "0000100" else
                  "1101101" when segment1 = "0000101" else
                  "1111100" when segment1 = "0000110" else
                  "0000111" when segment1 = "0000111" else
                  "1111111" when segment1 = "0001000" else
                  "1100111" when segment1 = "0001001";

  ------------------------------------------------------------------------------
  -- Drive outputs based on internal signals
  ------------------------------------------------------------------------------        
  seven_segments(6 downto 0) <= segment0_map when segment_select = '0' else segment1_map;  --"1001111";
  seven_segments(7)          <= segment_select;
  timer_expired              <= timer_expired_int;

end rtl;
