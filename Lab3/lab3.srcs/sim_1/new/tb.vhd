library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb is
--  Port ( );
end tb;

architecture Behavioral of tb is

component mixer is
    Port ( p0 : in std_logic_vector(7 downto 0);
           p1 : in std_logic_vector(7 downto 0);
           a : in std_logic_vector(7 downto 0);
           clk: in std_logic;
           rst: in std_logic;
           pout : out std_logic_vector(15 downto 0));
end component mixer;

component blender1 is
    Port (
           v0 : in std_logic_vector(7 downto 0);
           v1 : in std_logic_vector(7 downto 0);
           a : in std_logic_vector(7 downto 0);
           clk: in std_logic;
           rst: in std_logic;
           pout : out std_logic_vector(15 downto 0)
           );
end component blender1;

component blender2 is
    Port (
           v0 : in std_logic_vector(7 downto 0);
           v1 : in std_logic_vector(7 downto 0);
           a : in std_logic_vector(7 downto 0);
           clk: in std_logic;
           rst: in std_logic;
           pout : out std_logic_vector(15 downto 0)
           );
end component blender2;



begin

    process
        file in_file: text open read_mode is "y1.txt";
        file in_delay_file: text open read_mode is "y2.txt";
        
        variable in_line: line;
        variable data: integer;   
    begin
        while not endfile(in_file) loop
            readline(in_file, in_line);
            read(in_line, data);
            
            wait for 12.5ns;
        end loop;
        file_close(in_file);
        wait;
    end process;
    

end Behavioral;