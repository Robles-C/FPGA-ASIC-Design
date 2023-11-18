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
    bidir : inout std_logic
    );
end gpio_bit;


architecture rtl of gpio_bit is

begin
  -- when OE is asserted drive the bidir signal as an output with the bit
  -- supplied
  bidir <= inp   when oe = '1' else 'Z';

  -- when OE is cleared pass the incoming signal into the rest of the system
  outp  <= bidir when oe = '0' else 'Z';

end rtl;
