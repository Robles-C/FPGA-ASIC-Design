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

    signal currVal : std_logic_vector(3 downto 0);
    signal currSeg : std_logic_vector(7 downto 0) := "11111111";
    signal delay_done : std_logic := '0';
    signal counter : natural := 0;
    constant MAX_COUNT : natural := 500000000;
    
    component GPIO is
        Port ( gpio_in : in  STD_LOGIC_VECTOR(3 downto 0);
               gpio_out : out STD_LOGIC_VECTOR(3 downto 0));
    end component;
    
    component sevenSeg is
        Port ( segIn : in  STD_LOGIC_VECTOR(7 downto 0); 
               segOut : out  STD_LOGIC_VECTOR(7 downto 0));
    end component;
begin
    GPIO_switches : GPIO 
    port map (
        gpio_in => sw, --switches value on board
        gpio_out => currVal -- current value of switches
    );

    GPIO_leds : GPIO 
    port map (
        gpio_in => currVal, -- current value of switches
        gpio_out => led -- output leds
    );
    
    sevenSegInstance : sevenSeg
    port map (
        segIn => currSeg,
        segOut => jc
    );
    process(sysclk)
    begin
    
        if rising_edge(sysclk) then
            if counter < MAX_COUNT then
                counter <= counter + 1;
            elsif delay_done = '0' then
                delay_done <= '1';
                currSeg <= "01111111";
                counter <= 0; 
            end if;
        end if;
    end process;
    
end Behavioral;
