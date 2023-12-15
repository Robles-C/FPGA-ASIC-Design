library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sevenSeg is
    Port ( segSel : in  STD_LOGIC;
           segIn  : in  integer; 
           segOut : out  STD_LOGIC_VECTOR(7 downto 0));
end sevenSeg;

architecture Behavioral of sevenSeg is

begin
    process(segIn, segSel)
    variable temp : STD_LOGIC_VECTOR(3 downto 0);  
    variable temp2 : STD_LOGIC_VECTOR(6 downto 0); 
    begin
        case segIn is
            when 0 => temp := "0000";
            when 1 => temp := "0001";
            when 2 => temp := "0010";
            when 3 => temp := "0011";
            when 4 => temp := "0100";
            when 5 => temp := "0101";
            when 6 => temp := "0110";
            when 7 => temp := "0111";
            when 8 => temp := "1000";
            when 9 => temp := "1001";
            when others => temp := "1111";
        end case;
        
        case temp is
            when "0000" => temp2 := "0111111";
            when "0001" => temp2 := "0000110";
            when "0010" => temp2 := "1011011";
            when "0011" => temp2 := "1001111";
            when "0100" => temp2 := "1100110";
            when "0101" => temp2 := "1101101";
            when "0110" => temp2 := "1111101";
            when "0111" => temp2 := "0000111";
            when "1000" => temp2 := "1111111";
            when "1001" => temp2 := "1100111";
            when others => temp2 := "0000000";
        end case;
        --segsel 1 bit and 7 temp bits
        segOut <= segSel & temp2;
    end process;
end Behavioral;