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
    attribute use_dsp48         : string;
    attribute use_dsp48 of mixer : signal is "yes";
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
            result <= (others => '0');  -- Reset the result to all zeros
        elsif(rising_edge(clk)) then
            -- Perform multiplication and addition operations
            top <= p0s * as;
            bottom <= p1s * ("11111111" - as);
            result <= top + bottom;
        else
            result <= result;
        end if;
    end process;
    
    mixer <= std_logic_vector(result);

end Behavioral;