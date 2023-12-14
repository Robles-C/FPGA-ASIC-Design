-- Importing standard logic and numeric libraries
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- Entity declaration for single_pulse_detector with a generic parameter
entity single_pulse_detector is
generic(detect_type: std_logic_vector(1 downto 0) := "00"); -- Type of edge detection
    port( 
          clk: in std_logic; -- Clock input
          rst: in std_logic; -- Reset input
          input_signal: in std_logic; -- Input signal to detect pulses
          output_pulse: out std_logic -- Output pulse generated
    );
end single_pulse_detector;

-- Behavioral architecture of single_pulse_detector
architecture Behavioral of single_pulse_detector is
    -- Internal flip-flops for edge detection
    signal FF0: std_logic; -- First flip-flop
    signal FF1: std_logic; -- Second flip-flop
begin
    -- Process sensitive to clock and reset
    process(clk, rst)
    begin 
        if rst = '1' then   -- If reset is active     
            FF0 <= '0';     -- Reset FF0
            FF1 <= '0';     -- Reset FF1
        elsif rising_edge(clk) then -- On rising edge of the clock        
            FF0 <= input_signal; -- Capture input signal in FF0         
            FF1 <= FF0; -- Propagate FF0's value to FF1
        end if;
    end process;
    
    -- Output logic based on detect_type
    with detect_type select
        output_pulse <=
            not FF1 and FF0 when "00", -- Detect rising edge
            not FF0 and FF1 when "01", -- Detect falling edge
            FF0 xor FF1 when "10", -- Detect any edge
            '0' when others; -- Default case, no pulse
end Behavioral;
