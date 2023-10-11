library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sevenSeg is
    Port ( segSel : in  STD_LOGIC;
           segIn  : in  STD_LOGIC_VECTOR(3 downto 0); 
           segOut : out  STD_LOGIC_VECTOR(7 downto 0));
end sevenSeg;

architecture Behavioral of sevenSeg is
begin
    segOut <= segSel & segIn;
end Behavioral;
