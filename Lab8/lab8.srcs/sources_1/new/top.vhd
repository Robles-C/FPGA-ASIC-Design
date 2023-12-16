library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
    Port ( CLKX : in STD_LOGIC;
           BTN : in STD_LOGIC_VECTOR (3 downto 0);
           LEDL : out STD_LOGIC;
           jc : out  STD_LOGIC_VECTOR(7 downto 0);
           RGB_R : out STD_LOGIC;
           RGB_G : out STD_LOGIC;
           RGB_B : out STD_LOGIC;
           XRX : in std_logic;
           XTX : out std_logic;
           SW1 : in STD_LOGIC);
           
end top;

architecture Behavioral of top is

signal clk_125: std_logic;
signal lck: std_logic;

constant INPUT_FREQ: integer := 125_000_000;
signal rst: std_logic;
signal btn_db0: std_logic;
signal btn_db1: std_logic;
signal btn_db2: std_logic;
signal btn_db3: std_logic;
signal rgb_rs: std_logic := '0';
signal rgb_ys: std_logic := '0';
signal rgb_gs: std_logic := '0';
signal led_r: std_logic;
signal led_y: std_logic;
signal led_g: std_logic;
signal counter : natural := 0;

    -- SSD stuff
    signal segsel :std_logic := '0'; -- segment display selection
    
    signal timerDone: std_logic:='0';
    signal lock: std_logic:='0';
    
    signal currSeg1 : integer := 10;
    signal currSeg2 : integer := 10;
    signal segInput : integer; -- input to ssd
        --flags
    signal SSDdelay_done : std_logic := '0'; -- delay flag for switch
    signal ONEdelay_done : std_logic := '0'; -- delay flag for one sec
        --counts
    signal SSDcounter : natural := 0; -- counting variable for delay
    signal oneScounter : natural := 0; -- counting variable for one second
    signal flashCounter : natural := 0; -- counting variable for flashes
        --delays
    constant ssd_delay : natural := 5000; -- delay amount for switching ssd 
    constant oneS_delay : natural := 50000000;--125000000; -- delay amount for 1 second counter
        --state machine stuff
    type SSDstate is (DELAYING, SWITCHING); -- states of seven segment display
    signal state : SSDstate := DELAYING; -- initial state
    
    type count1states is (COUNT1, SUB1, RESET1); -- blinker for win signaling
    signal c1States : count1states := COUNT1; -- initial state
    
    type rollOver is (IDLE, ROLLING); -- states of seven segment display
    signal rollState : rollOVER := ROLLING; -- initial state
    signal target_num : integer;
    signal temp : integer := 0;
    
    type userStates is (IDLE, CHECK, CORRECT, DELAYING);
    signal user : userStates := IDLE; 
    signal guess : integer := 0;
    signal lastGuess : integer := 104;
--    type int_array is array (natural range <>) of integer;
--    signal myCharArray : int_array(0 to 3):= ('x', 'x', 'x', 'x');
    
      -- UART Signals
    signal tx_start      : std_logic;
    signal uart_data_rx  : std_logic_vector(7 downto 0);
    signal uart_data_tx  : std_logic_vector(7 downto 0);
    signal rx_data_ready : std_logic;
    signal start_transmit : std_logic := '0';
    
    component clk_wiz_0
        Port( reset             : in     std_logic;
              clk_in1           : in     std_logic;
              clk_out1          : out    std_logic;
              locked            : out    std_logic);
    end component;

    component debounce is
        generic
        (
            clk_freq    : integer := 125_000_000;
            stable_time : integer := 10
            );
        port
        ( 
             clk    : in std_logic;
             rst    : in std_logic;
             button : in std_logic;
             result : out std_logic); 
    end component debounce;

    component sevenSeg is
        Port ( segSel : in STD_LOGIC;
               segIn  : integer; 
               segOut : out  STD_LOGIC_VECTOR(7 downto 0));
    end component;
    
    component UART is

    port(
      clk      : in std_logic;
      reset    : in std_logic;
      tx_start : in std_logic;

      data_in       : in  std_logic_vector (7 downto 0);
      data_out      : out std_logic_vector (7 downto 0);
      rx_data_ready : out std_logic;

      rx : in  std_logic;
      tx : out std_logic
      );
  end component;
    
begin
    clk_manager : clk_wiz_0
        port map (
            reset => SW1,
            clk_in1 => CLKX,
            clk_out1 => clk_125,
            locked => LEDL
        );
    rst <= SW1;
    
    debounce_inst_1: debounce port map(clk => CLKX, rst => rst, button => BTN(0), result => btn_db0);
    debounce_inst_2: debounce port map(clk => CLKX, rst => rst, button => BTN(1), result => btn_db1);
    debounce_inst_3: debounce port map(clk => CLKX, rst => rst, button => BTN(2), result => btn_db2);
    debounce_inst_4: debounce port map(clk => CLKX, rst => rst, button => BTN(3), result => btn_db3);
    
    sevenSegInstance : sevenSeg
    port map (
        segSel => segsel,
        segIn => segInput,
        segOut => jc
    );
    
    uart_inst : UART
    port map (
      clk           => CLKX,
      reset         => rst,
      tx_start      => tx_start,
      data_in       => uart_data_tx,
      data_out      => uart_data_rx,
      rx_data_ready => rx_data_ready,
      rx            => XRX,
      tx            => XTX
      );
    
process(clk_125, rst)
begin
   if rst = '1' then
        tx_start <= '0';
        uart_data_tx <= x"00";
        start_transmit <= '0';
        rgb_gs <= '0';
        rgb_rs <= '0';
        rgb_ys <= '0';
        counter <= 0;
        SSDcounter <= 0;
        oneScounter <= 0;
        flashCounter <= 0;
        state <= DELAYING;
        c1States <= COUNT1;
        rollState <= ROLLING;
        user <= IDLE;
        segsel <= '0';
        timerDone <= '0';
        lock <= '0';
        currSeg1 <= 10;
        currSeg2 <= 10;
        segInput <= 0;
        SSDdelay_done <= '0';
        ONEdelay_done <= '0';
        temp <= 0;
        target_num <= 0;
        guess <= 0;
        lastGuess <= 104;

    elsif rising_edge(clk_125) then
        case state is
            when DELAYING => -- delay state for switching between ssd 1 and ssd 2
                if SSDcounter < ssd_delay then
                    SSDcounter <= SSDcounter + 1;
                else
                    SSDdelay_done <= '1';
                    SSDcounter <= 0;
                    state <= SWITCHING;
                end if;
            
            when SWITCHING => -- actual switch
                SSDdelay_done <= '0'; -- update flag
                segsel <= not segsel; -- switch to other ssd
                SSDcounter <= 0;
                if segsel = '1' then 
                    segInput <= currSeg2; -- if segment 1 is selected the ipnut is curseg2
                elsif segsel = '0' then
                    segInput <= currSeg1; -- if segment 0 is selected the ipnut is curseg1
                end if;             
                state <= DELAYING; -- return to delay state
        end case;
        
       case rollState is
            when IDLE =>
                target_num <= temp;
                tx_start <= '1';
                --currSeg1 <= target_num;
            when ROLLING =>
                if btn_db0 = '0' and btn_db1 = '0' and btn_db2 = '0' and btn_db3 = '0' then
                    if temp < 3 then
                        temp <= temp + 1;
                    else
                        temp <= 0;
                    end if;
                else
                    rollState <= IDLE;
                end if;
        end case;
        
        case user is
            when IDLE =>
                if btn_db0 = '1' then
                    guess <= 0; 
                    uart_data_tx <= std_logic_vector(to_unsigned(guess, uart_data_rx'length));
                    user <= CHECK;
                end if;
                if btn_db1 = '1' then
                    guess <= 1;
                    uart_data_tx <= std_logic_vector(to_unsigned(guess, uart_data_rx'length));
                    user <= CHECK;
                end if;
                if btn_db2 = '1' then
                    guess <= 2;
                    uart_data_tx <= std_logic_vector(to_unsigned(guess, uart_data_rx'length));
                    user <= CHECK;
                end if;
                if btn_db3 = '1' then
                    guess <= 3;
                    uart_data_tx <= std_logic_vector(to_unsigned(guess, uart_data_rx'length));
                    user <= CHECK;
                end if;
            when CHECK => 
                --if guess = target => correct
                if guess = target_num then
                    user <= CORRECT;
                else 
                    if abs(lastGuess - target_num) > abs(guess - target_num) and lastGuess < 99 then
                        rgb_rs <= '1';
                        rgb_ys <= '0';
                        rgb_gs <= '0';
                        else if abs(lastGuess - target_num) < abs(guess - target_num) then
                            rgb_rs <= '0';
                            rgb_ys <= '1';
                            rgb_gs <= '0';
                        end if;
                    end if;
                    currSeg1 <= lastGuess;
                    currSeg2 <= guess;
                    lastGuess <= guess;
                    user <= IDLE;
                end if;
            when CORRECT => 
                currSeg1 <= 104;
                currSeg2 <= target_num;
                rgb_rs <= '0';
                rgb_ys <= '0';
                if flashCounter < 20 then
                    user <= DELAYING;
                else
                    rgb_rs <= '0';
                    rgb_ys <= '0';
                    rgb_gs <= '1';
                end if;
                
            when DELAYING => 
                if oneScounter < oneS_delay then
                    oneScounter <= oneScounter + 1; -- Increment the counter
                else
                    oneScounter <= 0; -- Reset the counter
                    flashCounter <= flashCounter + 1; -- Increment flashCounter
                    rgb_gs <= not rgb_gs; -- Toggle the rgb_gs signal
                    user <= CORRECT; -- Transition back to CORRECT state
                end if;
        end case;
    end if;
end process;

RGB_R <= rgb_rs;
RGB_G <= rgb_gs;
RGB_B <= rgb_ys;

end Behavioral;
