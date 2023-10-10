library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity blender2 is
    Port (
           v0  : in std_logic_vector(7 downto 0);
           v1  : in std_logic_vector(7 downto 0);
           a   : in std_logic_vector(7 downto 0);
           clk : in std_logic;
           rst : in std_logic;
           blend2 : out std_logic_vector(15 downto 0)
           );
end blender2;

architecture Behavioral of blender2 is

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

component c_shift_ram_0
port
 (
    D : in std_logic_vector(7 DOWNTO 0);
    CLK : in std_logic;
    Q : out std_logic_vector(7 DOWNTO 0)
 );
end component;

component delayer
  PORT (
    D : in std_logic_vector(7 DOWNTO 0);
    CLK : in std_logic;
    Q : out std_logic_vector(7 DOWNTO 0)
  );
end component;

signal clk_2x, clk_1x, locked: std_logic;
signal SEL: std_logic := '1';
signal ar, m1ar, v0r, v1r, MUX1, MUX2: signed(7 downto 0);
signal v0_d, ar_d: std_logic_vector(7 downto 0);
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
 UUT2 : c_shift_ram_0 
    port map (
    D => v0,
    CLK => clk_1x,
    Q => v0_d
 );
  UUT3 : delayer 
    port map (
    D => std_logic_vector(ar),
    CLK => clk_1x,
    Q => ar_d
 );

    process(clk_1x, rst)
    begin
        if(rising_edge(clk_1x)) then
            v0r <= signed(v0_d); -- gets value coming out of delayer
            v1r <= signed(v1);
            ar <= signed(ar_d); -- gets value of a delayed
            m1ar <= "11111111" - signed(ar_d); -- 1 - value of a delayed
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
    begin
    
    --dsp 48 slice
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
        
        blend2 <= std_logic_vector(t2);
end Behavioral;