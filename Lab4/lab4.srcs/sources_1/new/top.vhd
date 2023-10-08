library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top is
    Port ( sw : in  STD_LOGIC_VECTOR(3 downto 0);
           led : out STD_LOGIC_VECTOR(3 downto 0));
end top;

architecture Behavioral of top is

    signal temp_signal : STD_LOGIC_VECTOR(3 downto 0);

    component GPIO is
        Port ( gpio_in : in  STD_LOGIC_VECTOR(3 downto 0);
               gpio_out : out STD_LOGIC_VECTOR(3 downto 0));
    end component;

begin
    -- First instance for reading switches
    GPIO_switches : GPIO 
    port map (
        gpio_in => sw,
        gpio_out => temp_signal
    );

    -- Second instance to drive LEDs
    GPIO_leds : GPIO 
    port map (
        gpio_in => temp_signal,
        gpio_out => led
    );
end Behavioral;
