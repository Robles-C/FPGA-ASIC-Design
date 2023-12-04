-------------------------------------------------------------------------------
-- Title      : 1 Bit GPIO
-- Project    :
-------------------------------------------------------------------------------
-- File       : gpio_bit.vhd
-- Author     : Phil Tracton  <ptracton@gmail.com>
-- Company    : CSUN
-- Created    : 2023-08-18
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
-- 2023-08-18  1.0      ptracton        Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity gpio_bit is
  port(
    oe    : in    std_logic;
    inp   : in    std_logic;
    outp  : out   std_logic;
    bidir : inout std_logic;
    clk_in    : in  std_logic;
    reset_in  : in  std_logic
    );
end gpio_bit;

architecture rtl of gpio_bit is
    --declare debouncer component. lab 6 debounce module
  COMPONENT debounce IS
    GENERIC(
      clk_freq    : INTEGER;   --system clock frequency in Hz
      stable_time : INTEGER);  --time button must remain stable in ms
    PORT(
      clk     : IN  STD_LOGIC;   --input clock
      reset_n : IN  STD_LOGIC;   --asynchornous active-low reset
      button  : IN  STD_LOGIC;   --input signal to be debounced
      result  : OUT STD_LOGIC);  --debounced signal
  END COMPONENT;
  signal btn_result : STD_LOGIC := '0';
  signal output : STD_LOGIC := '0';
begin
  -- when OE is asserted drive the bidir signal as an output with the bit
  -- supplied
  bidir <= inp when oe = '1' else 'Z';

  -- when OE is cleared pass the incoming signal into the rest of the system
  output  <= bidir when oe = '0' else 'Z';
    
  outp <= btn_result;
debounce_instance: debounce
    GENERIC MAP(clk_freq => 125_000_000, stable_time => 1)
    PORT MAP(clk => clk_in, reset_n => reset_in, button => output, result => btn_result);

end rtl;
