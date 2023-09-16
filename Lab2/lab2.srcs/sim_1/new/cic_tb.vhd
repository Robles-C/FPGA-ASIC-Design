library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use ieee.std_logic_textio.all;

entity cic_tb is
--  Port ( );
end cic_tb;

architecture Behavioral of cic_tb is
    component cic is
        generic (
            CI_SIZE : integer := 18; -- cic input data width
            CO_SIZE : integer := 30; -- cic output data width
            STAGES : integer := 5);
        port (
            clk : in std_logic; -- system clock (80 Mhz)
            ce : in std_logic; -- clock enable
            ce_r : in std_logic; -- decimated clock by factor of 5 used in comb section
            rst : in std_logic; -- system reset
            d : in std_logic_vector (CI_SIZE - 1 downto 0); -- input data
            q : out std_logic_vector (CO_SIZE - 1 downto 0)); -- output data
        end component cic;
    
    signal clk_tb, ce_tb, ce_r_tb, rst_tb: std_logic;
    signal count : unsigned(2 downto 0):= "000";
    signal d_tb: std_logic_vector(17 downto 0); 
    signal q_tb: std_logic_vector(29 downto 0);
begin

uut: cic port map (clk => clk_tb, ce => ce_tb, ce_r => ce_r_tb, rst => rst_tb, d => d_tb, q => q_tb);

    process
        file in_file: text open read_mode is "/c/Users/Cristian/ECE524/FPGA-ASIC-Design/lab2/lab2.srcs/sim_1/new/sine_wave_8MHz.txt";
        --file in_file: text open read_mode is "/c/Users/Cristian/ECE524/FPGA-ASIC-Design/lab2/lab2.srcs/sim_1/new/sine_wave_16MHz.txt";
        --file in_file: text open read_mode is "/c/Users/Cristian/ECE524/FPGA-ASIC-Design/lab2/lab2.srcs/sim_1/new/sine_wave_24MHz.txt";
        
        variable in_line: line;
        variable data: std_ulogic_vector(31 downto 0);   
    begin
        wait for 12.5ns;
        while not endfile(in_file) loop
            readline(in_file, in_line);
            hread(in_line, data);
            d_tb <= std_logic_vector(data(17 downto 0));
            wait for 12.5ns;
        end loop;
        file_close(in_file);
        d_tb <= (others => '0');
        wait;
    end process;

  
    process
        file out_file: text open write_mode is "/c/Users/Cristian/ECE524/FPGA-ASIC-Design/lab2/lab2.srcs/sim_1/new/output_8MHz.txt";
        --file out_file: text open write_mode is "/c/Users/Cristian/ECE524/FPGA-ASIC-Design/lab2/lab2.srcs/sim_1/new/output_16MHz.txt";
        --file out_file: text open write_mode is "/c/Users/Cristian/ECE524/FPGA-ASIC-Design/lab2/lab2.srcs/sim_1/new/output_24MHz.txt";
        variable outline: line;
    begin
        clk_tb <= '0';
        wait for 6.25ns;
        clk_tb <= '1';
        wait for 6.25ns;      
        write(outline, q_tb);
        writeline(out_file, outline);
        
    end process;
    
    process
    begin
        rst_tb <= '1';
        ce_tb <= '1';
        wait for 12.5ns;
        rst_tb <= '0';
        wait;
    end process;
    
    process
    begin
        ce_r_tb <= '0';
        wait for 9*6.25ns;
        ce_r_tb <= '1';
        wait for 1*6.25ns;
    end process;


end Behavioral;
