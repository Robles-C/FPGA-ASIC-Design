library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use ieee.std_logic_textio.all;

entity cic_tb is
end cic_tb;

architecture Behavioral of cic_tb is
    component cic is
        generic (
            CI_SIZE : integer := 16; 
            CO_SIZE : integer := 30; 
            STAGES : integer := 5);
        port (
            clk : in std_logic;
            ce : in std_logic;
            ce_r : in std_logic;
            rst : in std_logic;
            d : in std_logic_vector (CI_SIZE - 1 downto 0);
            q : out std_logic_vector (CO_SIZE - 1 downto 0));
        end component cic;

    signal clk_tb, ce_tb, ce_r_tb, rst_tb: std_logic;
    signal d_tb: std_logic_vector(15 downto 0); 
    signal q_tb: std_logic_vector(29 downto 0);
begin
    uut: cic port map (clk => clk_tb,
                       ce => ce_tb, 
                       ce_r => ce_r_tb, 
                       rst => rst_tb, 
                       d => d_tb, 
                       q => q_tb);
    --create clk
    process
    begin
        clk_tb <= '0';
        wait for 8ns;
        clk_tb <= '1';
        wait for 8ns;
    end process;

    -- Input data reading
    process
        --file in_file: text open read_mode is "..\..\..\..\lab2v2.srcs\sim_1\new\16MHz.txt";
        file in_file: text open read_mode is "\24MHz.txt";
        --file in_file: text open read_mode is "..\..\..\..\lab2v2.sim\sim_1\behav\xsim\24MHz.txt";
        
        variable in_line: line;
        variable data: std_ulogic_vector(31 downto 0);   
    begin
        wait for 16ns;
        while not endfile(in_file) loop
            readline(in_file, in_line);
            hread(in_line, data);
            d_tb <= std_logic_vector(data(15 downto 0));
            wait for 16ns;
        end loop;
        file_close(in_file);
        d_tb <= (others => '0');
        wait;
    end process;

    -- Output data write
    process(clk_tb)
        --file out_file: text open write_mode is "..\..\..\..\lab2v2.sim\sim_1\behav\xsim\O8MHz.txt";
        file out_file: text open read_mode is "\O24MHz.txt";
        --file out_file: text open write_mode is "..\..\..\..\lab2v2.sim\sim_1\behav\xsim\O24MHz.txt";
        variable outline: line;
    begin
        if rising_edge(clk_tb) then
            write(outline, q_tb);
            writeline(out_file, outline);
        end if;
    end process;

    -- Reset and Clock Enable
    process
    begin
        rst_tb <= '1';
        ce_tb <= '1';
        wait for 8ns;
        rst_tb <= '0';
        wait for 100 us;
        wait;
    end process;

    process
    begin
        ce_r_tb <= '0';
        wait for 70ns;
        ce_r_tb <= '1';
        wait for 8ns;
    end process;

end Behavioral;