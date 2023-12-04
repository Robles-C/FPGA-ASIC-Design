-------------------------------------------------------------------------------
-- Title      : VHDL GPIO Wrapper
-- Project    :
-------------------------------------------------------------------------------
-- File       : gpio.vhd
-- Author     : Phil Tracton  <ptracton@gmail.com>
-- Company    : CSUN
-- Created    : 2023-08-27
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
-- 2023-08-27  1.0      ptracton	Created
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity gpio is
  generic (
    WIDTH : integer := 8);
  port (
    oe        : in    std_logic_vector(WIDTH-1 downto 0);
    inp       : in    std_logic_vector(WIDTH-1 downto 0);
    outp      : out   std_logic_vector(WIDTH-1 downto 0);
    bidir     : inout std_logic_vector(WIDTH-1 downto 0);
    clk_in    : in  std_logic;
    reset_in  : in  std_logic
    );
end gpio;

architecture Behavioral of gpio is
  
  component gpio_bit is
    port(
      oe    : in    std_logic;
      inp   : in    std_logic;
      outp  : out   std_logic;
      bidir : inout std_logic;
      clk_in    : in  std_logic;
      reset_in  : in  std_logic
      );
  end component;

begin
  ------------------------------------------------------------------------------
  -- Create as many GPIO bits as specified in WIDTH
  ------------------------------------------------------------------------------
  generate_gpio : for i in WIDTH-1 downto 0 generate
    generated_bit : gpio_bit
      port map(oe(i), inp(i), outp(i), bidir(i), clk_in, reset_in);
  end generate generate_gpio;

end Behavioral;
