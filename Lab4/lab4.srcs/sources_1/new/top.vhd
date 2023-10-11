library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top is
    Port ( sw : in  STD_LOGIC_VECTOR(3 downto 0);
           led : out STD_LOGIC_VECTOR(3 downto 0);
           jc : out  STD_LOGIC_VECTOR(7 downto 0);
           sysclk : in STD_LOGIC);
end top;

architecture Behavioral of top is

    signal currVal : std_logic_vector(3 downto 0); -- switch values
    signal segsel :std_logic := '0'; -- segment display selection
    signal currSeg1 : std_logic_vector(3 downto 0) := "0000"; -- current output on 7 segments in 4 bits
    signal delay_done : std_logic := '0'; -- delay flag
    signal counter : natural := 0; -- counting variable for delay
    constant ssd_delay : natural := 5000; -- delay amount for switching ssd 
    type state_type is (DELAYING, SWITCHING); -- states of seven segment display
    signal state : state_type := DELAYING; -- initial state
    
    component GPIO is
        Port ( gpio_in : in  STD_LOGIC_VECTOR(3 downto 0);
               gpio_out : out STD_LOGIC_VECTOR(3 downto 0));
    end component;
    
    component sevenSeg is
        Port ( segSel : in STD_LOGIC;
               segIn : in  STD_LOGIC_VECTOR(3 downto 0); 
               segOut : out  STD_LOGIC_VECTOR(7 downto 0));
    end component;
    
begin
    GPIO_switches : GPIO 
    port map (
        gpio_in => sw, 
        gpio_out => currVal
    );

    GPIO_leds : GPIO 
    port map (
        gpio_in => currVal,
        gpio_out => led
    );
    
    sevenSegInstance : sevenSeg
    port map (
        segSel => segsel,
        segIn => currSeg1,
        segOut => jc
    );
    process(sysclk)
    begin
    if rising_edge(sysclk) then
        case state is
            -- When the current state is DELAYING
            when DELAYING =>
                -- If the counter has not yet reached the maximum count
                if counter < ssd_delay then
                    counter <= counter + 1;  -- Increment the counter
                else
                    delay_done <= '1';       -- Indicate that the delay is completed
                    counter <= 0;            -- Reset the counter for the next cycle
                    state <= SWITCHING;      -- Change the state to SWITCHING
                end if;
        
            -- When the current state is SWITCHING
            when SWITCHING =>
                delay_done <= '0';           -- Reset the delay_done signal, indicating the start of a new delay cycle
                segsel <= not segsel;        -- Toggle the segsel signal (change its value)
                counter <= 0;                -- Reset the counter for the delay in the next cycle
                state <= DELAYING;           -- Transition back to the DELAYING state to start the delay again
        
        end case;

    end if;

    end process;
    
end Behavioral;
