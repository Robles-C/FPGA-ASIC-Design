library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity delayer is
    port(
        D : in std_logic_vector(7 downto 0);
        CLK : in std_logic;
        Q : out std_logic_vector(7 downto 0)
        );
end delayer;

architecture Behavioral of delayer is
    signal del : std_logic_vector(7 downto 0) := (others => '0');
begin

    process(CLK)
    begin
        if rising_edge(CLK) then
            del <= D;
        end if;
    end process;

    Q <= del;
end Behavioral;
