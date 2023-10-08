library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb is
end tb;

architecture sim of tb is

    signal clk_in      : STD_LOGIC := '0';
    signal reset       : STD_LOGIC := '0';
    signal clk_out     : STD_LOGIC;
    signal locked     : STD_LOGIC;

    component clock is
        Port (
            clk_in     : in  STD_LOGIC;
            reset      : in  STD_LOGIC;
            clk_out    : out STD_LOGIC;
            locked_out : out STD_LOGIC
        );
    end component;

    constant clk_period : time := 8 ns;

begin

    UUT: clock port map (
        clk_in  => clk_in,
        reset   => reset,
        clk_out => clk_out,
        locked_out => locked
    );

    clk_process : process
    begin
        clk_in <= not clk_in;
        wait for clk_period / 2;
    end process clk_process;
    
    -- Stimulus process
    stim_process : process
    begin
        -- Hold reset for a while
        wait for clk_period * 5;
        reset <= '0';
        
        wait for clk_period * 10; -- Wait a bit before emulating LOCKED
        locked <= '1'; -- Emulate DCM getting locked
    
        wait for clk_period * 100; -- Wait for some time to observe behavior
    
        locked <= '0'; -- Emulate DCM getting unlocked
        reset <= '1'; -- Assert reset again to check behavior
        wait for clk_period * 5;
        reset <= '0';
    
        wait for clk_period * 10; -- Wait a bit before emulating LOCKED
        locked <= '1'; -- Emulate DCM getting locked again
    
        wait for clk_period * 100; -- Continue observing behavior
    
        wait; -- End the simulation
    end process stim_process;
    
        
    end sim;
