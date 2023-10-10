library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity blender1 is
    Port (
           v0 : in std_logic_vector(7 downto 0);
           v1 : in std_logic_vector(7 downto 0);
           a : in std_logic_vector(7 downto 0);
           clk: in std_logic;
           rst: in std_logic;
           blend1 : out std_logic_vector(15 downto 0)
           );
end blender1;

architecture Behavioral of blender1 is

component clk_wiz_0
port
 (
  clk_100MHz          : out    std_logic;
  clk_50MHz           : out    std_logic;
  locked              : out    std_logic;
  reset             : in     std_logic;
  clk_in1           : in     std_logic
 );
end component;

signal clk_2x, clk_1x, locked: std_logic;
signal SEL: std_logic := '1';
signal ar, m1ar, v0r, v1r, MUX1, MUX2: signed(7 downto 0);
signal t1, t2: signed(15 downto 0);
attribute use_dsp : string;
attribute use_dsp of t1 : signal is "yes";
begin

UUT1 : clk_wiz_0
   port map (  
   clk_100MHz => clk_2x,
   clk_50MHz => clk_1x,
   locked => locked,              
   reset => rst,
   clk_in1 => clk
 );

    process(clk_1x, rst)
    begin
        if(rising_edge(clk_1x)) then
            v0r <= signed(v0);
            v1r <= signed(v1);
            ar <= signed(a);
            m1ar <= "11111111" - signed(a);
            t2 <= t1;
        elsif(rst = '1') then
            v0r <= (others => '0');
            v1r <= (others => '0');
            ar <= (others => '0');
            m1ar <= (others => '0');
            t2 <= (others => '0');
        else
            v0r <= v0r;
            v1r <= v1r;
            ar <= ar;
            m1ar <= m1ar;
            t2 <= t2;
        end if;
    end process;

    MUX1 <= v1r when (SEL = '1') else v0r;
    MUX2 <= m1ar when (SEL = '1') else ar;
   
    process(clk_2x, rst)
    --dsp slice
    begin
        if(rst = '1') then
            t1 <= (others => '0');
        elsif(rising_edge(clk_2x)) then
            if(SEL='0') then
                t1 <= MUX1 * MUX2 ;
                SEL <= '1';
            else
                t1 <= t1 + (MUX1 * MUX2);
                SEL <= '0';
            end if;
        end if;
        end process;
        
    blend1 <= std_logic_vector(t2);
    
end Behavioral;