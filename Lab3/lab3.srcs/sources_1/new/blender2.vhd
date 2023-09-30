library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity blender2 is
    Port (
           v0 : in std_logic_vector(7 downto 0);
           v1 : in std_logic_vector(7 downto 0);
           a : in std_logic_vector(7 downto 0);
           clk: in std_logic;
           rst: in std_logic;
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
  -- Status and control signals
  reset             : in     std_logic;
  clk_in1           : in     std_logic
 );
end component;

COMPONENT c_shift_ram_0
  PORT (
    D : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    CLK : IN STD_LOGIC;
    Q : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;

signal clk_2x, clk_1x, locked_out: std_logic;
signal SEL: std_logic := '1';
signal ar, br, v0r, v1r, MUX1, MUX2: signed(7 downto 0);
signal v0_d: std_logic_vector(7 downto 0);
signal v, temp1, temp2: signed(15 downto 0);
attribute use_dsp48 : string;
attribute use_dsp48 of temp1 : signal is "yes";
begin
  
UUT1 : clk_wiz_0
   port map ( 
   -- Clock out ports  
   clk_100MHz => clk_2x,
   clk_50MHz => clk_1x,
   locked => locked_out,
  -- Status and control signals                
   reset => rst,
   -- Clock in ports
   clk_in1 => clk
 );
 
 UUT2 : c_shift_ram_0
  PORT MAP (
    D => v0,
    CLK => clk_2x,
    Q => v0_d
  );
 
    process(clk_2x, rst)
    begin
        if(rst = '1') then
            v0r <= (others => '0');
            v1r <= (others => '0');
            ar <= (others => '0');
            br <= (others => '0');
            temp2 <= (others => '0');
        elsif(rising_edge(clk_2x)) then
            v0r <= signed(v0_d);
            v1r <= signed(v1);
            ar <= signed(a);
            br <= "01111111" - signed(a);
            temp2 <= temp1;
        else
            v0r <= v0r;
            v1r <= v1r;
            ar <= ar;
            br <= br;
            temp2 <= temp2;
        end if;
    end process;

    MUX1 <= v0r when (SEL = '0') else
            v1r;
    MUX2 <= ar when (SEL = '0') else
            br;
    blend2 <= std_logic_vector(temp2);
   
    
    process(clk_1x, rst)
    begin
        if(rst = '1') then
            v <= (others => '0');
        elsif(rising_edge(clk_1x)) then
            if(SEL='0') then
                temp1 <= MUX1 * MUX2 ;
                SEL <= '1';
            else
                temp1 <= temp1 + (MUX1 * MUX2);
                SEL <= '0';
            end if;
        else 
            v <= v;
            SEL <= SEL;
        end if;
        end process;
end Behavioral;