--------------------------------------------------------------------------------
--
--   FileName:         pmod_keypad.vhd
--   Dependencies:     debounce.vhd (Version 2.0)
--   Design Software:  Quartus Prime Version 17.0.0 Build 595 SJ Lite Edition
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 06/28/2019 Scott Larson
--     Initial Public Release
-- 
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY pmod_keypad IS
  GENERIC(
    clk_freq    : INTEGER := 125_000_000;  --system clock frequency in Hz
    stable_time : INTEGER := 10);         --time pressed key must remain stable in ms
  PORT(
    clk     :  IN     STD_LOGIC;                           --system clock
    reset_n :  IN     STD_LOGIC;                           --asynchornous active-low reset
    rows    :  IN     STD_LOGIC_VECTOR(1 TO 4);            --row connections to keypad
    columns :  BUFFER STD_LOGIC_VECTOR(1 TO 4) := "1111";  --column connections to keypad
    keys    :  OUT    STD_LOGIC_VECTOR(0 TO 15));          --resultant key presses
END pmod_keypad;

ARCHITECTURE logic OF pmod_keypad IS
  SIGNAL rows_int    : STD_LOGIC_VECTOR(1 TO 4);                      --synchronizer flip-flops for row inputs
  SIGNAL keys_int    : STD_LOGIC_VECTOR(0 TO 15) := (OTHERS => '0');  --stores key presses except multiples in the same row
  SIGNAL keys_double : STD_LOGIC_VECTOR(0 TO 15) := (OTHERS => '0');  --stores multiple key presses in the same row
  SIGNAL keys_stored : STD_LOGIC_VECTOR(0 TO 15) := (OTHERS => '0');  --final key press values before debounce
  
  --declare debouncer component
  COMPONENT debounce IS
    GENERIC(
      clk_freq    : INTEGER;   --system clock frequency in Hz
      stable_time : INTEGER);  --time button must remain stable in ms
    PORT(
      clk     : IN  STD_LOGIC;   --input clock
      reset_n : IN  STD_LOGIC;   --asynchornous active-low reset
      button  : IN  STD_LOGIC;   --input signal to be debounced
      result  : OUT STD_LOGIC);  --debounced signal
  END COMPONENT;
  
BEGIN
  
  --synchronizer flip-flops
  PROCESS(clk)
  BEGIN
    IF(clk'EVENT AND clk = '1') THEN  --rising edge of system clock
      rows_int <= rows;                 --synchronize the row inputs to the system clock
    END IF;
  END PROCESS;
  
  PROCESS(clk, reset_n)
    VARIABLE count   : INTEGER RANGE 0 TO clk_freq/3_300_000 := 0;  --counter between key press readings
    VARIABLE presses : INTEGER RANGE 0 TO 16 := 0;                  --count simultaneous detected key presses
  BEGIN
    IF(reset_n = '0') THEN                  --reset
      columns <= (OTHERS => '1');             --release column outputs
      keys_int <= (OTHERS => '0');            --clear key press buffer
      keys_double <= (OTHERS => '0');         --clear key press buffer
    ELSIF(clk'EVENT AND clk = '1') THEN     --rising edge of system clock
      IF(count < clk_freq/3_300_000) THEN     --time for polling change not reached (<300ns)
        count := count + 1;                     --increment counter
      ELSE                                    --time for polling change reached (=300ns)
        count := 0;                             --reset counter

        --cycle through columns to poll for key presses
        CASE columns IS
        
          --pause polling and process results of last cycle of polls
          WHEN "1111" =>
            presses := 0;                                         --reset keypress counter
            press_count: FOR i IN 0 TO 15 LOOP                    --count how many keys were detected as pressed
              IF(keys_int(i) = '1' OR keys_double(i) = '1') THEN        
                presses := presses + 1;
              END IF;
            END LOOP press_count;
            IF(presses < 3) THEN                                  --2 or fewer keys pressed
              keys_stored <= keys_int OR keys_double;               --store results for debounce
            ELSE                                                  --more than 2 keys pressed
              keys_stored <= (OTHERS => '0');                       --discard unreliable results
            END IF;
            keys_int <= (OTHERS => '0');                          --clear key press buffer for next polling
            keys_double <= (OTHERS => '0');                       --clear key press buffer for next polling
            columns <= "0111";
            
          --check 1st column single presses per row
          WHEN "0111" =>
            keys_int(1) <= NOT rows_int(1);
            keys_int(4) <= NOT rows_int(2);
            keys_int(7) <= NOT rows_int(3);
            keys_int(0) <= NOT rows_int(4);            
            columns <= "1011";
            
          --check 2nd column single presses per row
          WHEN "1011" =>
            keys_int(2) <= NOT rows_int(1);
            keys_int(5) <= NOT rows_int(2);
            keys_int(8) <= NOT rows_int(3);
            keys_int(15) <= NOT rows_int(4);
            columns <= "1101";
          
          --check 3rd column single presses per row
          WHEN "1101" =>
            keys_int(3) <= NOT rows_int(1);
            keys_int(6) <= NOT rows_int(2);
            keys_int(9) <= NOT rows_int(3);
            keys_int(14) <= NOT rows_int(4);
            columns <= "1110";
          
          --check 4th column single presses per row
          WHEN "1110" =>
            keys_int(10) <= NOT rows_int(1);
            keys_int(11) <= NOT rows_int(2);
            keys_int(12) <= NOT rows_int(3);
            keys_int(13) <= NOT rows_int(4);
            columns <= "0011";
          
          --check 1st and 2nd column dual press per row
          WHEN "0011" =>            
            IF(rows_int(1) = '0' AND keys_int(1) = '0' AND keys_int(2) = '0') THEN
              keys_double(1) <= '1';
              keys_double(2) <= '1';
            END IF;
            IF(rows_int(2) = '0' AND keys_int(4) = '0' AND keys_int(5) = '0') THEN
              keys_double(4) <= '1';
              keys_double(5) <= '1';
            END IF;
            IF(rows_int(3) = '0' AND keys_int(7) = '0' AND keys_int(8) = '0') THEN
              keys_double(7) <= '1';
              keys_double(8) <= '1';
            END IF;
            IF(rows_int(4) = '0' AND keys_int(0) = '0' AND keys_int(15) = '0') THEN
              keys_double(0) <= '1';
              keys_double(15) <= '1';
            END IF;
            columns <= "0101";
          
          --check 1st and 3rd column dual press per row
          WHEN "0101" =>
            IF(rows_int(1) = '0' AND keys_int(1) = '0' AND keys_int(3) = '0') THEN
              keys_double(1) <= '1';
              keys_double(3) <= '1';
            END IF;
            IF(rows_int(2) = '0' AND keys_int(4) = '0' AND keys_int(6) = '0') THEN
              keys_double(4) <= '1';
              keys_double(6) <= '1';
            END IF;
            IF(rows_int(3) = '0' AND keys_int(7) = '0' AND keys_int(9) = '0') THEN
              keys_double(7) <= '1';
              keys_double(9) <= '1';
            END IF;
            IF(rows_int(4) = '0' AND keys_int(0) = '0' AND keys_int(14) = '0') THEN
              keys_double(0) <= '1';
              keys_double(14) <= '1';
            END IF;
            columns <= "0110";
          
          --check 1st and 4th column dual press per row
          WHEN "0110" =>
            IF(rows_int(1) = '0' AND keys_int(1) = '0' AND keys_int(10) = '0') THEN
              keys_double(1) <= '1';
              keys_double(10) <= '1';
            END IF;
            IF(rows_int(2) = '0' AND keys_int(4) = '0' AND keys_int(11) = '0') THEN
              keys_double(4) <= '1';
              keys_double(11) <= '1';
            END IF;
            IF(rows_int(3) = '0' AND keys_int(7) = '0' AND keys_int(12) = '0') THEN
              keys_double(7) <= '1';
              keys_double(12) <= '1';
            END IF;
            IF(rows_int(4) = '0' AND keys_int(0) = '0' AND keys_int(13) = '0') THEN
              keys_double(0) <= '1';
              keys_double(13) <= '1';
            END IF;
            columns <= "1001";
          
          --check 2nd and 3rd column dual press per row
          WHEN "1001" =>
            IF(rows_int(1) = '0' AND keys_int(2) = '0' AND keys_int(3) = '0') THEN
              keys_double(2) <= '1';
              keys_double(3) <= '1';
            END IF;
            IF(rows_int(2) = '0' AND keys_int(5) = '0' AND keys_int(6) = '0') THEN
              keys_double(5) <= '1';
              keys_double(6) <= '1';
            END IF;
            IF(rows_int(3) = '0' AND keys_int(8) = '0' AND keys_int(9) = '0') THEN
              keys_double(8) <= '1';
              keys_double(9) <= '1';
            END IF;
            IF(rows_int(4) = '0' AND keys_int(15) = '0' AND keys_int(14) = '0') THEN
              keys_double(15) <= '1';
              keys_double(14) <= '1';
            END IF;
            columns <= "1010";
          
          --check 2nd and 4th column dual press per row
          WHEN "1010" =>
            IF(rows_int(1) = '0' AND keys_int(2) = '0' AND keys_int(10) = '0') THEN
              keys_double(2) <= '1';
              keys_double(10) <= '1';
            END IF;
            IF(rows_int(2) = '0' AND keys_int(5) = '0' AND keys_int(11) = '0') THEN
              keys_double(5) <= '1';
              keys_double(11) <= '1';
            END IF;
            IF(rows_int(3) = '0' AND keys_int(8) = '0' AND keys_int(12) = '0') THEN
              keys_double(8) <= '1';
              keys_double(12) <= '1';
            END IF;
            IF(rows_int(4) = '0' AND keys_int(15) = '0' AND keys_int(13) = '0') THEN
              keys_double(15) <= '1';
              keys_double(13) <= '1';
            END IF;
            columns <= "1100";
          
          --check 3rd and 4th column dual press per row
          WHEN "1100" =>
            IF(rows_int(1) = '0' AND keys_int(3) = '0' AND keys_int(10) = '0') THEN
              keys_double(3) <= '1';
              keys_double(10) <= '1';
            END IF;
            IF(rows_int(2) = '0' AND keys_int(6) = '0' AND keys_int(11) = '0') THEN
              keys_double(6) <= '1';
              keys_double(11) <= '1';
            END IF;
            IF(rows_int(3) = '0' AND keys_int(9) = '0' AND keys_int(12) = '0') THEN
              keys_double(9) <= '1';
              keys_double(12) <= '1';
            END IF;
            IF(rows_int(4) = '0' AND keys_int(14) = '0' AND keys_int(13) = '0') THEN
              keys_double(14) <= '1';
              keys_double(13) <= '1';
            END IF;
            columns <= "1111";
          
          WHEN OTHERS =>
            columns <= "1111";
        
        END CASE;
        
      END IF;  
    END IF;
  END PROCESS;

  --debounce key press results
  row_debounce: FOR i IN 0 TO 15 GENERATE
    debounce_keys: debounce
      GENERIC MAP(clk_freq => clk_freq, stable_time => stable_time)
      PORT MAP(clk => clk, reset_n => reset_n, button => keys_stored(i), result => keys(i));
  END GENERATE;
  
END logic;
