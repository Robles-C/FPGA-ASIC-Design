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
signal rgb_rs: std_logic;
signal rgb_ys: std_logic;
signal rgb_gs: std_logic;
signal led_r: std_logic;
signal led_y: std_logic;
signal led_g: std_logic;
signal counter : natural := 0;

signal currVal : std_logic_vector(3 downto 0); -- switch values
    -- SSD stuff
    signal segsel :std_logic := '0'; -- segment display selection
    
    signal timerDone: std_logic:='0';
    signal lock: std_logic:='0';
    
    signal currSeg1 : integer := 0;
    signal currSeg2 : integer := 0;
    signal segInput : integer; -- input to ssd
        --flags
    signal SSDdelay_done : std_logic := '0'; -- delay flag for switch
    signal ONEdelay_done : std_logic := '0'; -- delay flag for one sec
    signal TENdelay_done : std_logic := '0'; -- delay flag for ten sec
    signal W10delay_done : std_logic := '0'; -- delay flag for ten
    signal W50delay_done : std_logic := '0'; -- delay flag for 50 sec
    signal S10 : std_logic := '0'; -- delay flag for starting 10 sec
    signal S50 : std_logic := '0'; -- delay flag for starting 50 sec
        --counts
    signal SSDcounter : natural := 0; -- counting variable for delay
    signal oneScounter : natural := 0; -- counting variable for one second
    signal tenScounter : natural := 0; -- counting variable for ten seconds
    signal w10counter : natural := 0; -- counting variable for w10
    signal w50counter : natural := 0; -- counting variable for w50
        --delays
    constant ssd_delay : natural := 5000; -- delay amount for switching ssd 
    constant oneS_delay : natural := 125000000;--125000000; -- delay amount for 1 second counter
    constant tenS_delay : natural := 1250000000; -- delay amount for 10 second counter
    constant w10s : natural := 625000000; -- delay amount for 1 second counter
    constant w50s : natural := 1250000000; -- delay amount for 10 second counter
        --ssd state machine stuff
    type SSDstate is (DELAYING, SWITCHING); -- states of seven segment display
    signal state : SSDstate := DELAYING; -- initial state
    
    type count1states is (COUNT1, SUB1,RESET1); -- states of seven segment display
    signal c1States : count1states := COUNT1; -- initial state
    
    type count10states is (COUNT10, SUB10,RESET10); -- states of seven segment display
    signal c10States : count10states := COUNT10; -- initial state
    
    type lightStates is (AgBr, AyBr, ArBg, ArBy); -- states of light
    signal lState : lightStates := AgBr; -- initial state
    
    type crossTime is (IDLE, WAIT10, WAIT50, RESET); -- states of seven segment display
    signal crossState : crossTime := IDLE; -- initial state
    
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
    
process(clk_125, rst)
begin
    if rst = '1' then
        --reset
        
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
        
         
        
    end if;
end process;

RGB_R <= rgb_rs;
RGB_G <= rgb_gs;
RGB_B <= rgb_ys;

end Behavioral;
