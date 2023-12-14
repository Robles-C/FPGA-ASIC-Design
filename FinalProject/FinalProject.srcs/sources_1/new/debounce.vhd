-- Importing standard libraries
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- Declaration of the debounce entity with generic parameters
entity debounce is
    generic
    (
        clk_freq    : integer := 125_000_000; -- Clock frequency
        stable_time : integer := 10           -- Time in ms for the signal to be considered stable
    );
    port( 
         clk    : in std_logic; -- Input clock
         rst    : in std_logic; -- Reset signal
         button : in std_logic; -- Input from the button
         result : out std_logic -- Debounced output
    ); 
end debounce;

-- Behavioral architecture of debounce
architecture Behavioral of debounce is
    -- Internal signals
    signal sig: std_logic; -- Signal to hold the debounced state
    signal count: integer range 0 to clk_freq*stable_time/1000; -- Counter for timing
    signal MAX_DELAY: integer := clk_freq*stable_time/1000; -- Maximum delay for debounce timing
begin
    -- Main process, sensitive to clock and reset
    process(clk, rst)
    begin 
        if (rst = '1') then     -- Reset logic                     
            sig <= '0';         -- Reset the debounced signal
            count <= 0;         -- Reset the counter                         
        elsif rising_edge(clk) then -- Logic for clock's rising edge
            if button = '1' then -- If button is pressed
                if count = MAX_DELAY-1 then
                    sig <= '1'; -- Set debounced signal if time has elapsed
                end if;
                count <= count + 1; -- Increment counter                                        
            else
                sig <= '0'; -- Reset debounced signal if button is not pressed
                count <= 0; -- Reset counter                           
            end if;
        end if;
    end process;
    result <= sig; -- Output the debounced signal
end Behavioral;
