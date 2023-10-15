library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top is
    Port ( sw : in  STD_LOGIC_VECTOR(3 downto 0);
           led : out STD_LOGIC_VECTOR(3 downto 0);
           jc : out  STD_LOGIC_VECTOR(7 downto 0);
           sysclk : in STD_LOGIC;
           led6_g : out STD_LOGIC;
           btn0 : in STD_LOGIC);
end top;

architecture Behavioral of top is
    -- clock wizard stuff
    signal clk_125: std_logic;
    -- GPIO stuff
    signal currVal : std_logic_vector(3 downto 0); -- switch values
    -- SSD stuff
    signal segsel :std_logic := '0'; -- segment display selection
    
    signal currSeg1 : integer := 0;
    signal currSeg2 : integer := 0;
    signal segInput : integer; -- input to ssd
        --flags
    signal SSDdelay_done : std_logic := '0'; -- delay flag for switch
    signal ONEdelay_done : std_logic := '0'; -- delay flag for one sec
    signal TENdelay_done : std_logic := '0'; -- delay flag for ten sec
        --counts
    signal SSDcounter : natural := 0; -- counting variable for delay
    signal oneScounter : natural := 0; -- counting variable for one second
    signal tenScounter : natural := 0; -- counting variable for ten seconds
        --delays
    constant ssd_delay : natural := 5000; -- delay amount for switching ssd 
    constant oneS_delay : natural := 125000000; -- delay amount for 1 second counter
    constant tenS_delay : natural := 1250000000; -- delay amount for 10 second counter
        --ssd state machine stuff
    type SSDstate is (DELAYING, SWITCHING); -- states of seven segment display
    signal state : SSDstate := DELAYING; -- initial state
    
    type count1states is (COUNT1, ADD1,RESET1); -- states of seven segment display
    signal c1States : count1states := COUNT1; -- initial state
    
    type count10states is (COUNT10, ADD10,RESET10); -- states of seven segment display
    signal c10States : count10states := COUNT10; -- initial state
    -- UART stuff
    signal inputData : std_logic_vector(7 downto 0);
    signal outputData : std_logic_vector(7 downto 0);
        --
    signal txStart :std_logic := '0';
    signal rxSig :std_logic := '0';
    signal rx_ready :std_logic := '0';
    signal txSig :std_logic := '0';
    
    component clk_wiz_0
        Port( reset             : in     std_logic;
              clk_in1           : in     std_logic;
              clk_out1          : out    std_logic;
              locked            : out    std_logic);
    end component;
    
    component GPIO is
        Port ( gpio_in : in  STD_LOGIC_VECTOR(3 downto 0);
               gpio_out : out STD_LOGIC_VECTOR(3 downto 0));
    end component;
    
    component sevenSeg is
        Port ( segSel : in STD_LOGIC;
               segIn  : integer; 
               segOut : out  STD_LOGIC_VECTOR(7 downto 0));
    end component;
    
    component UART is
        Port ( clk      : in  STD_LOGIC;
               reset    : in  STD_LOGIC;
               data_in  : in  STD_LOGIC_VECTOR(7 downto 0);
               data_out : out STD_LOGIC_VECTOR(7 downto 0);
               rx       : in  STD_LOGIC;
               rx_ready : out STD_LOGIC;
               tx       : out STD_LOGIC;
               tx_start : in  STD_LOGIC);
    end component;
    
begin
    clk_manager : clk_wiz_0
    port map (
        reset => btn0, -- input from button 0 goes to reset input for clkwzd
        clk_in1 => sysclk,
        clk_out1 => clk_125,
        locked => led6_g -- lock ouput from wzd goes to rgb green
    );
    
    GPIO_switches : GPIO 
    port map (
        gpio_in => sw, 
        gpio_out => currVal
    );
    
    GPIO_leds : GPIO 
    port map (
        gpio_in => currVal,
        gpio_out => led
    );
    
    sevenSegInstance : sevenSeg
    port map (
        segSel => segsel,
        segIn => segInput,
        segOut => jc
    );
    
    uartInstance : UART
    port map ( 
        clk => clk_125,
        reset => btn0,
        data_in => inputData,
        data_out => outputData,
        rx => rxSig,
        rx_ready => rx_ready,
        tx => txSig,
        tx_start => txStart
    );
    
--    process for ssd
--    process(clk_125)
--    begin
     
--    if rising_edge(clk_125) then
--        --case for switching segments 
--        case state is
--            when DELAYING => -- delay state for switching between ssd 1 and ssd 2
--                if SSDcounter < ssd_delay then
--                    SSDcounter <= SSDcounter + 1;
--                else
--                    SSDdelay_done <= '1';
--                    SSDcounter <= 0;
--                    state <= SWITCHING;
--                end if;
            
--            when SWITCHING => -- actual switch
--                SSDdelay_done <= '0'; -- update flag
--                segsel <= not segsel; -- switch to other ssd
--                SSDcounter <= 0;
--                if segsel = '1' then 
--                    segInput <= currSeg2; -- if segment 1 is selected the ipnut is curseg2
--                elsif segsel = '0' then
--                    segInput <= currSeg1; -- if segment 0 is selected the ipnut is curseg1
--                end if;             
--                state <= DELAYING; -- return to delay state
--        end case;
            
--        --case for 1 second counter
--        case c1States is
--            when COUNT1 => -- count until delay has happened
--                if oneScounter < oneS_delay then
--                    oneScounter <= oneScounter + 1;
--                else
--                    ONEdelay_done <= '1';
--                    oneScounter <= 0;
--                    c1States <= ADD1;
--                end if;
                
--            when ADD1 => -- once delay has happened add one to current segment val
--                ONEdelay_done <= '0';
--                oneScounter <= 0;
--                currSeg2 <= currSeg2 + 1;
--                if currSeg2 < 9 then -- if curseg <9 keep incrementing
--                    c1States <= COUNT1;
--                else -- otherwise reset
--                    c1States <= RESET1;
--                end if;
            
--           when RESET1 => -- set values back to zero and begin again from 1st state
--                currSeg2 <= 0;
--                c1States <= COUNT1;
            
--        end case;
            
--        --case for 10 second counter
--        case c10States is
--            when COUNT10 =>
--                if tenScounter < tenS_delay then
--                    tenScounter <= tenScounter + 1;
--                else
--                    TENdelay_done <= '1';
--                    tenScounter <= 0;
--                    c10States <= ADD10;
--                end if;
            
--           when ADD10 =>
--                TENdelay_done <= '0';
--                tenScounter <= 0;
--                currSeg1 <= currSeg1 + 1;
--                if currSeg1 < 9 then
--                    c10States <= COUNT10;
--                else
--                    c10States <= RESET10;
--                end if;
                    
--            when RESET10 =>
--                currSeg1 <= 0;
--                c10States <= COUNT10;
            
--        end case;
--    end if;
--    if btn0 = '1' then
--        oneScounter <= 0;
--        tenScounter <= 0;
--        c1States <= RESET1;
--        c10States <= RESET10;
--        currSeg1 <= 0;
--        currSeg2 <= 0;
--    end if;
--    end process;
    
end Behavioral;
