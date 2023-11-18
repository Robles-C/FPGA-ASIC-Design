library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UART is
    Port (
        clk  : in  STD_LOGIC;
        reset: in  STD_LOGIC;
        rx   : in  STD_LOGIC;
        tx   : out STD_LOGIC
    );
end UART;

architecture Behavioral of UART is

    constant CLKS_PER_BIT: integer := 1085; -- 125,000,000clks/115200bps = 1085
    
    type delay_states is (IDLE, DEL);
    signal delay_state   : delay_states := IDLE;
    signal delay_done    : std_logic := '0';
    signal start_delay   : std_logic := '0';
    signal delayCounter  : natural := 0;

    -- TX stuff
    type TXstate is (IDLE, START, DATA, STOP);
    signal TX_states : TXstate := IDLE;
    signal Bit_IndexT : integer range 0 to 7 := 0;
    signal TX_Data   : std_logic_vector(7 downto 0) := (others => '0');
    signal TX_Byte   : std_logic_vector(7 downto 0) := "01011001";
    signal TX_Done   : std_logic := '0';
    signal TX_Active : std_logic := '0';
    signal TX_Ready  : std_logic := '1';

    -- RX stuff
    type RXstate is (IDLE, START, DATA, STOP);
    signal RX_states  : RXstate := IDLE;
    signal Bit_IndexR : integer range 0 to 7 := 0;
    signal RX_Data   : std_logic_vector(7 downto 0) := (others => '0');
    signal RX_Byte   : std_logic_vector(7 downto 0) := "00000000";
    signal RX_Done   : std_logic := '0';
    signal RX_Active : std_logic := '0';
    signal RX_Ready  : std_logic := '0';
    
begin

    process(clk, reset)
    begin
        if reset = '1' then
            delay_done <= '0';
            delayCounter <= 0;          
            delay_state <= IDLE;
            
            TX_Done <= '0';
            TX_states <= IDLE;
            
            RX_Done <= '0';
            RX_states <= IDLE;
        elsif rising_edge(clk) then
            case delay_state is
                when DEL => 
                    if delayCounter < CLKS_PER_BIT then
                        delayCounter <= delayCounter + 1;
                    else
                        delay_done <= '1';
                        delayCounter <= 0;
                        start_delay <= '0';
                        delay_state <= IDLE;
                    end if;

                when IDLE =>
                    if start_delay = '1' then      
                        delay_state <= DEL;
                    end if;
            end case;
            case TX_states is
                when IDLE =>
                    TX_Active <= '0';
                    tx <= '1';
                    Bit_IndexT <= 0;
                    
                    if TX_Ready = '1' then
                        TX_states <= START;
                    end if;

                when START =>
                    TX_Active <= '1';
                    tx <= '0';
                    TX_Data <= TX_Byte;
                    delay_done <= '0';
                    start_delay <= '1';
                    
                    TX_states <= DATA;

                when DATA =>
                    for i in 0 to 7 loop
                        tx <= TX_Data(Bit_IndexT);                 
                        delay_done <= '0';
                        start_delay <= '1';
                    end loop;
                    
                    if Bit_IndexT < 7 then
                        Bit_IndexT <= Bit_IndexT + 1;
                    else
                        TX_states <= STOP;
                    end if;

                when STOP =>
                    tx <= '1';
                    delay_done <= '0';
                    start_delay <= '1';
                    
                    TX_Done <= '1';
                    TX_Active <= '0';
                    TX_Ready <= '0';
                    TX_states <= IDLE;
            end case;
            
            case RX_states is
                when IDLE =>
                    RX_Active <= '0';
                    Bit_IndexR <= 0;
                    
                    if rx = '0' then
                        RX_states <= START;
                    end if;
            
                when START =>
                    RX_Active <= '1';
                    delay_done <= '0';
                    start_delay <= '1';
                    
                    RX_states <= DATA;
            
                when DATA =>
                    for i in 0 to 7 loop
                        RX_Data(Bit_IndexR) <= rx;               
                        delay_done <= '0';
                        start_delay <= '1';
                    end loop;
                    
                    if Bit_IndexR < 7 then
                        Bit_IndexR <= Bit_IndexR + 1;
                    else
                        RX_states <= STOP;
                    end if;
            
                when STOP =>
                    delay_done <= '0';
                    start_delay <= '1';
            
                    if rx = '1' then
                        RX_Byte <= RX_Data;
                        RX_Done <= '1';
                        RX_Active <= '0';
                        RX_states <= IDLE;
                    end if;

            end case;
        end if;
        
    end process;

end Behavioral;
