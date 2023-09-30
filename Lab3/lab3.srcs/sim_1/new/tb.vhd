library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb is
end tb;

architecture Behavioral of tb is

component mixer is
    Port ( p0 : in std_logic_vector(7 downto 0);
           p1 : in std_logic_vector(7 downto 0);
           a : in std_logic_vector(7 downto 0);
           clk: in std_logic;
           rst: in std_logic;
           mixer : out std_logic_vector(15 downto 0));
end component mixer;

component blender1 is
    Port (
           v0 : in std_logic_vector(7 downto 0);
           v1 : in std_logic_vector(7 downto 0);
           a : in std_logic_vector(7 downto 0);
           clk: in std_logic;
           rst: in std_logic;
           blend1 : out std_logic_vector(15 downto 0)
           );
end component blender1;

component blender2 is
    Port (
           v0 : in std_logic_vector(7 downto 0);
           v1 : in std_logic_vector(7 downto 0);
           a : in std_logic_vector(7 downto 0);
           clk: in std_logic;
           rst: in std_logic;
           blend2 : out std_logic_vector(15 downto 0)
           );
end component blender2;

    signal sin, cos, a_tb: std_logic_vector(7 downto 0);
    signal clk_tb, rst_tb: std_logic;
    signal mix_out, blend1_out, blend2_out: std_logic_vector(15 downto 0);
    
begin
    uut0: mixer port map (p0 => sin, p1 => cos, a => a_tb, clk => clk_tb, rst => rst_tb, mixer => mix_out);
    uut1: blender1 port map (v0 => sin, v1 => cos, a => a_tb, clk => clk_tb, rst => rst_tb, blend1 => blend1_out);
    uut2: blender2 port map (v0 => sin, v1 => cos, a => a_tb, clk => clk_tb, rst => rst_tb, blend2 => blend2_out);
    
    a_tb <= "01111111";
    process
    --C:\Users\Cristian\ECE524\FPGA-ASIC-Design\Lab3\lab3.srcs\sim_1\new\y1.txt
        file in_file: text open read_mode is "..\..\..\..\lab3.sim\sim_1\behav\xsim\y1.txt";
        file in_file_del: text open read_mode is "..\..\..\..\lab3.sim\sim_1\behav\xsim\y2.txt";
        
        variable in_line: line;
        variable data: integer; 
    begin
        while not endfile(in_file) loop
            readline(in_file, in_line);
            read(in_line, data);
            sin <= std_logic_vector(to_unsigned(data, sin'length));
            
            readline(in_file_del, in_line);
            readline(in_file_del, in_line);
            read(in_line, data);
            cos <= std_logic_vector(to_unsigned(data, cos'length));

            wait for 12.5ns;
        end loop;
        file_close(in_file);
        wait;
    end process;
    
    process
    begin
        clk_tb <= '0';
        wait for 6.25ns;
        clk_tb <= '1';
        wait for 6.25ns;
    end process;
    
    process
        begin
        rst_tb <= '1';
        wait for 5ns;
        rst_tb <= '0';
        wait;
    end process;
    
end Behavioral;
