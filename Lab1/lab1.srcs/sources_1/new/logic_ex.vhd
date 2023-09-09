library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity logic_ex is
    Port (
        SW : in std_logic_vector(1 downto 0);
        LED : out std_logic_vector(3 downto 0)
    );
end entity logic_ex;

architecture Behavioral of logic_ex is
begin
   LED <= (SW(1) xor SW(0)) & (SW(1) or SW(0)) & (SW(1) and SW(0)) & (not SW(1));

end architecture Behavioral;