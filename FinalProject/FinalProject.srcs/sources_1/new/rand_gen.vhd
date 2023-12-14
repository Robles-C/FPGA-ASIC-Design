-- Importing standard logic and numeric libraries from the IEEE library
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- Entity declaration for rand_gen with generic input and output sizes
entity rand_gen is
    generic(
        input_size: integer := 8; -- Size of the input seed
        output_size: integer := 4 -- Size of the output random number
        );
    port
    (
        clk, rst : in std_logic; -- Clock and reset inputs
        seed     : in std_logic_vector(input_size-1 downto 0); -- Input seed
        output   : out std_logic_vector (output_size-1 downto 0) -- Random number output
    );
end rand_gen;

-- Architecture declaration for rand_gen
architecture Behavioral of rand_gen is
    -- Internal signals for current and next state
    signal currstate, nextstate: std_logic_vector (input_size-1 downto 0);
    -- Internal signal for feedback calculation
    signal feedback: std_logic;
    -- Unused constant declaration
    constant DEFAULT_NONE_ZERO_VAL : std_logic_vector(output_size-1 downto 0) := (0=>'1', others => '0');
begin

    -- Process for state register, sensitive to clock and reset signals
    stateReg: process(clk,rst)
    begin
        if rst = '1' then
            currstate <= seed; -- Initialize current state with seed on reset
        elsif rising_edge(clk) then
            currstate <= nextstate; -- Update current state on clock's rising edge
        end if;
    end process;
    
    -- Calculating feedback signal using XOR operation
    feedback <= currstate(4) xor currstate(3) xor currstate(2) xor currstate(0);
    -- Computing the next state
    nextstate <= feedback & currstate(input_size-1 downto 1);

    -- Output logic based on the most significant bits of the current state
    output <= "1000" when currstate(input_size-1) = '1' else
              "0100" when currstate(input_size-2) = '1' else
              "0010" when currstate(input_size-3) = '1' else
              "0001" when currstate(input_size-4) = '1' else
              "0001"; -- Default output value
end Behavioral;
