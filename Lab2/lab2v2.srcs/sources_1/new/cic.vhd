-- Module Name: cic.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

-- Entity declaration for the CIC filter
entity cic is
    generic (
        CI_SIZE : integer := 18; -- cic input data width
        CO_SIZE : integer := 30; -- cic output data width
        STAGES : integer := 5);  -- number of stages in the integrator and comb sections
    port (
        clk : in std_logic;  -- system clock (80 MHz)
        ce : in std_logic;   -- clock enable for integrator section
        ce_r : in std_logic; -- decimated clock by a factor of 5 used in comb section
        rst : in std_logic;  -- system reset
        d : in std_logic_vector (CI_SIZE - 1 downto 0);  -- input data
        q : out std_logic_vector (CO_SIZE - 1 downto 0)); -- output data
end cic;


architecture syn of cic is
    
    type d_array_type is array (STAGES downto 0) of std_logic_vector(CO_SIZE - 1 downto 0);
    type array_type is array (STAGES downto 1) of std_logic_vector(CO_SIZE - 1 downto 0);
    
    -- Signals used in the filter
    signal d_fs : d_array_type;  -- used in the integrator
    signal d_fsr : d_array_type; -- used in the differentiator
    signal m1 : array_type;      -- used in the differentiator
    signal id : std_logic_vector(CO_SIZE - 1 downto 0) := (others => '0'); -- to use for sign-extended version of the input
begin
    -- output data
    q <= d_fsr(STAGES);  -- The output is the last stage of the differentiator
    
    -- input data
    id(CO_SIZE - 1 downto CI_SIZE) <= (others => d(CI_SIZE - 1));
    id(CI_SIZE - 1 downto 0) <= d;

    process (clk)
    -- integrator
    begin
        if (clk'event and clk = '1') then
            if (rst = '1') then
                -- resetting states to 0
                d_fs(0) <= (others => '0');
                for i in 1 to STAGES loop
                    d_fs(i) <= (others => '0');
                end loop;
            elsif (ce = '1') then
                -- doing the integration
                d_fs(0) <= id;
                for i in 1 to STAGES loop
                    d_fs(i) <= d_fs(i - 1) + d_fs(i);
                end loop;
            end if;
        end if;
    end process;

    -- differentiator section
    process (clk)
    begin
        if (clk'event and clk = '1') then
            if (rst = '1') then
                -- Resetting the differentiator to 0
                d_fsr(0) <= (others => '0');
                for i in 1 to STAGES loop
                    m1(i) <= (others => '0');
                    d_fsr(i) <= (others => '0');
                end loop;
            elsif (ce = '1') then
                -- doing the differentiation
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
