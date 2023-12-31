library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--mixer1
entity mixer is
    Port (
        p0 : in std_logic_vector(7 downto 0);
        p1 : in std_logic_vector(7 downto 0);
        a : in std_logic_vector(7 downto 0); 
        clk: in std_logic;              
        rst: in std_logic;
        mixer : out std_logic_vector(15 downto 0)
    );
end mixer;

architecture Behavioral of mixer is
    signal p0s, p1s, as: signed(7 downto 0);
    signal top, bottom: signed(15 downto 0);
    signal result: signed(15 downto 0);
    
begin
    p0s <= signed(p0);
    p1s <= signed(p1);
    as <= signed(a);
    
    process(clk, rst)
    begin
        if(rst = '1') then
            result <= (others => '0'); 
        elsif(rising_edge(clk)) then
            -- multiplication and addition operations
            result <= p0s * as + p1s * ("11111111" - as);
        else
            result <= result;
        end if;
    end process;
    
    mixer <= std_logic_vector(result);

end Behavioral;