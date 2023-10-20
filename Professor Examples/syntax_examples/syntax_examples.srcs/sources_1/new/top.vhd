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
entity top is
  generic (TERMINAL0_COUNT : integer := 1000;  -- ends with ;
           TERMINAL1_COUNT : integer := 1000   -- last one does NOT
           );
  port(
    clk   : in std_logic;                      -- ends with ;
    reset : in std_logic;

    counter_enable : in  std_logic_vector(1 downto 0);
    counter_done   : out std_logic_vector(1 downto 0)  -- last one does NOT
    );
end top;

-------------------------------------------------------------------------------
-- This is the test bench architecture.  It is where all the signals, components,
-- and instantiations happen.  
-------------------------------------------------------------------------------
architecture rtl of top is
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
  component counter is
    generic (TERMINAL_COUNT : integer := 1000);
    port (
      clk   : in std_logic;
      reset : in std_logic;

      enable : in  std_logic;
      done   : out std_logic
      );
  end component;


begin

  -----------------------------------------------------------------------------
  -- You can instantiate a module as many times as you want.  in this case
  -- we have a single timer that we are instantiating twice!  They need separate
  -- enable and done signals.  The top level has a vector and we split the vector
  -- up to control the individual elements.
  --
  -- notice counter0 uses counter_enable(0) and counter_done(0).  The (0) is
  -- picking off the 0th bit of the vector
  -----------------------------------------------------------------------------       
  counter0 : counter
    generic map (TERMINAL_COUNT => TERMINAL0_COUNT)  -- no comma
    port map (
      clk    => clk,                                 -- end with ,
      reset  => reset,
      enable => counter_enable(0),
      done   => counter_done(0)                      -- no comma for last one
      );                                             -- end with a ;
      
  counter1 : counter
    generic map (TERMINAL_COUNT => TERMINAL1_COUNT)
    port map (
      clk    => clk,
      reset  => reset,
      enable => counter_enable(1),
      done   => counter_done(1)
      );


end rtl;
