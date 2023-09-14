library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity testbench is
--  Port ( );
end testbench;

architecture Behavioral of testbench is
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
    signal d_tb: std_logic_vector(17 downto 0); 
    signal q_tb: std_logic_vector(29 downto 0);
begin

end Behavioral;
