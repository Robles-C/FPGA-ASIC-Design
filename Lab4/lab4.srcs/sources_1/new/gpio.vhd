library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity GPIO is
    Port ( gpio_in : in  STD_LOGIC_VECTOR(3 downto 0);
           gpio_out : out STD_LOGIC_VECTOR(3 downto 0)
           );
end GPIO;

architecture Behavioral of GPIO is
begin
    gpio_out <= gpio_in;
end Behavioral;

