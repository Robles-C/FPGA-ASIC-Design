library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity single_pulse_detector is
generic(detect_type: std_logic_vector(1 downto 0) := "00");
    port( 
          clk: in std_logic;
          rst: in std_logic;
          input_signal: in std_logic;
          output_pulse: out std_logic);
end single_pulse_detector;

architecture Behavioral of single_pulse_detector is
signal FF0: std_logic;
signal FF1: std_logic;
begin

    process(clk,rst)
    begin 
       if rst = '1' then       
            FF0 <= '0';
            FF1 <= '0';
       elsif rising_edge(clk) then        
            FF0 <= input_signal;          
            FF1 <= FF0;
       end if;

end process;
    
       with detect_type select  output_pulse <=
                                not FF1 and FF0 when "00",
                                not FF0 and FF1 when "01",
                                FF0 xor FF1 when "10",
                                '0' when others;
end Behavioral;