-- Module Name: cic.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
entity cic is
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
end cic;
architecture syn of cic is
    type d_array_type is array (STAGES downto 0) of std_logic_vector(CO_SIZE - 1 downto 0);
    type array_type is array (STAGES downto 1) of std_logic_vector(CO_SIZE - 1 downto 0);
    signal d_fs : d_array_type;
    signal d_fsr : d_array_type; 
    signal m1 : array_type; 
    signal id : std_logic_vector(CO_SIZE - 1 downto 0) := (others => '0'); 
begin
    q <= d_fsr(STAGES);
    id(CO_SIZE - 1 downto CI_SIZE) <= (others => d(CI_SIZE - 1));
    id(CI_SIZE - 1 downto 0) <= d;
    process (clk)
    begin
        if (clk'event and clk = '1') then
            if (rst = '1') then
                d_fs(0) <= (others => '0');
                for i in 1 to STAGES loop
                    d_fs(i) <= (others => '0');
                end loop;
            elsif (ce = '1') then
                d_fs(0) <= id;
                for i in 1 to STAGES loop
                    d_fs(i) <= d_fs(i - 1) + d_fs(i);
                end loop;
            end if;
        end if;
    end process;
    
    process (clk)
    begin
        if (clk'event and clk = '1') then
            if (rst = '1') then
                d_fsr(0) <= (others => '0');
                for i in 1 to STAGES loop
                    m1(i) <= (others => '0');
                    d_fsr(i) <= (others => '0');
                end loop;
            elsif (ce = '1') then
                d_fsr(0) <= d_fs(STAGES);
                if (ce_r = '1') then
                    for i in 1 to STAGES loop
                        m1(i) <= d_fsr(i - 1);
                        d_fsr(i) <= d_fsr(i - 1) - m1(i);
                    end loop;
                else
                    m1 <= m1;
                    for i in 1 to STAGES loop
                        d_fsr(i) <= d_fsr(i);
                    end loop;
                end if;
            end if;
        end if;
    end process;
end syn;