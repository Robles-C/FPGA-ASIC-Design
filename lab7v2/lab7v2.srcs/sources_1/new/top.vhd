library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
    Port ( CLKX : in STD_LOGIC;
           BTNX : in STD_LOGIC_VECTOR (3 downto 0);
           LEDX : out STD_LOGIC_VECTOR (3 downto 0);
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
signal btn_db : std_logic_vector(3 downto 0);
signal btn_db_ad : std_logic_vector(1 downto 0);
signal rgb_reg: std_logic_vector(2 downto 0) := "000";
signal led_reg: std_logic_vector(3 downto 0);
signal counter : natural := 0;

signal adminPassword : std_logic_vector(3 downto 0) := "0011";
signal lastPressad : std_logic_vector(1 downto 0):= "00";
signal lastPress : std_logic_vector(3 downto 0):= "1111";
signal done :std_logic;
signal correct : std_logic := '0';
signal locked : std_logic;
signal incor : natural := 0;

type ringCount is (DELAY, ADD, OFF);
signal rcStates : ringCount := OFF; 

type userStates is (IDLE, P2, P3, P4, CHECK, INC, COR, EVAL, OFF);
signal user : userStates := IDLE; 

type char_array is array (natural range <>) of character;
signal myCharArray : char_array(0 to 3):= ('x', 'x', 'x', 'x');

type char_arrayad is array (natural range <>) of character;
signal admCharArray : char_array(0 to 1):= ('x', 'x');

type pass_array is array (natural range <>) of character;
signal password : pass_array(0 to 3) := ('a', 'b', 'a', 'd');

type adpass_array is array (natural range <>) of character;
signal adpassword : pass_array(0 to 1) := ('a', 'b');


type adminStates is (IDLE, Pa1, Pa2, CHECK, EVAL, COR, INC);
signal admin : adminStates := IDLE; 
signal last_btn_db : std_logic_vector(3 downto 0) := "0000";
signal ONEdelay_done : std_logic := '0'; -- delay flag for one sec
    --counts
signal oneScounter : natural := 0; -- counting variable for one second
    --delays
constant oneS_delay : natural := 6250000; -- delay amount for 1 second counter
signal attempts : natural := 0;
signal index : natural := 0;
signal arrays_equal : boolean := true;
signal ad_arrays_equal : boolean := true;
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

    component single_pulse_detector is
    generic(detect_type: std_logic_vector(1 downto 0) := "00");
        port(clk: in std_logic;
             rst: in std_logic;
             input_signal: in std_logic;
             output_pulse: out std_logic);
    end component single_pulse_detector;

begin
    clk_manager : clk_wiz_0
        port map (
            reset => SW1,
            clk_in1 => CLKX,
            clk_out1 => clk_125,
            locked => lck
        );
    rst <= SW1;
    
    debounce_inst_0: debounce port map(clk => CLKX, rst => rst, button => BTNX(0), result => btn_db(0));
    debounce_inst_1: debounce port map(clk => CLKX, rst => rst, button => BTNX(1), result => btn_db(1));
    debounce_inst_2: debounce port map(clk => CLKX, rst => rst, button => BTNX(2), result => btn_db(2));
    debounce_inst_3: debounce port map(clk => CLKX, rst => rst, button => BTNX(3), result => btn_db(3));
    btn_db_ad(0) <= btn_db(0);
    btn_db_ad(1) <= btn_db(1);
process(clk_125, rst)
begin
    if rst = '1' then
        rcStates <= OFF;
        rgb_reg <= (others => '0');
        led_reg <= (others => '0');
        user <= IDLE;
        lastPress <= "1111";
        myCharArray <=  ('x', 'x', 'x', 'x');
        arrays_equal <= true;
        oneScounter <= 0;
        counter <= 0;
        correct <= '0';
        last_btn_db <= "0000";
        
    elsif rising_edge(CLKX) then
        case rcStates is --ring counter states
            when OFF =>--ring counter off
                if correct = '1' then
                    rcStates <= DELAY;
                end if;
            when DELAY => -- delay for human seeable pattern
            if oneScounter < oneS_delay then
                    oneScounter <= oneScounter + 1;
                else
                    ONEdelay_done <= '1';
                    oneScounter <= 0;
                    counter <= counter + 1;
                    rcStates <= ADD;
                end if;
            when ADD =>
                if counter < 16 then
                    led_reg <= std_logic_vector(unsigned(led_reg) + 1);
                    rcStates <= DELAY;
                else
                    led_reg <= (others => '0');
                    counter <=0;
                    rcStates <= DELAY;
                end if;
        end case;
        
        case user is
                when IDLE =>
                if btn_db /= lastPress then
                    if btn_db /= "0000" then
                        if btn_db = "0001" then
                            myCharArray(0) <= 'd';
                            lastPress <= "0001";
                            user <= P2;
                        elsif btn_db = "0010" then
                            myCharArray(0) <= 'c';
                            lastPress <= "0010";
                            user <= P2;
                        elsif btn_db = "0100" then
                            myCharArray(0) <= 'b';
                            lastPress <= "0100";
                            user <= P2;
                        elsif btn_db = "1000" then
                            myCharArray(0) <= 'a';
                            lastPress <= "1000";
                            user <= P2;
                        end if;
                    end if;
                 end if;
                when P2 =>
                if btn_db /= lastPress then
                    if btn_db /= "0000" then
                        if btn_db = "0001" then
                                myCharArray(1) <= 'd';
                                lastPress <= "0001";
                                user <= P3;
                            elsif btn_db = "0010" then
                                myCharArray(1) <= 'c';
                                lastPress <= "0010";
                                user <= P3;
                            elsif btn_db = "0100" then
                                myCharArray(1) <= 'b';
                                lastPress <= "0100";
                                user <= P3;
                            elsif btn_db = "1000" then
                                myCharArray(1) <= 'a';
                                lastPress <= "1000";
                                user <= P3;
                        end if;
                   end if;
                end if;
                when P3 =>
                if btn_db /= lastPress then
                    if btn_db /= "0000" then
                        if btn_db = "0001" then
                                myCharArray(2) <= 'd';
                                lastPress <= "0001";
                                user <= P4;
                            elsif btn_db = "0010" then
                                myCharArray(2) <= 'c';
                                lastPress <= "0010";
                                user <= P4;
                            elsif btn_db = "0100" then
                                myCharArray(2) <= 'b';
                                lastPress <= "0100";
                                user <= P4;
                            elsif btn_db = "1000" then
                                myCharArray(2) <= 'a';
                                lastPress <= "1000";
                                user <= P4;
                        end if;
                    end if;
                end if;
                when P4 =>
                if btn_db /= lastPress then
                    if btn_db /= "0000" then
                        if btn_db = "0001" then
                                myCharArray(3) <= 'd';
                                user <= CHECK;
                            elsif btn_db = "0010" then
                                myCharArray(3) <= 'c';
                                user <= CHECK;
                            elsif btn_db = "0100" then
                                myCharArray(3) <= 'b';
                                user <= CHECK;
                            elsif btn_db = "1000" then
                                myCharArray(3) <= 'a';
                                user <= CHECK;
                        end if;
                    end if;
                end if;
                when CHECK =>
                     for i in 0 to 3 loop
                        if myCharArray(i) /= password(i) then -- Compare each element
                            arrays_equal <= false;
                            exit;
                        end if;
                    end loop;
                    user <= EVAL;
                when EVAL =>
                    if arrays_equal = false then
                        incor <= incor + 1;
                        user <= INC;
                    else 
                        user <= COR;
                    end if;
                when INC =>
                        if incor < 4 then 
                            -- if max amount of attempts is not yet reached then restart
                            lastPress <= "1111";
                            myCharArray <=  ('x', 'x', 'x', 'x');
                            arrays_equal <= true;
                            correct <= '0';
                            user <= IDLE;
                        else 
                            -- if more than 3 incorrect do this
                            locked <= '1';
                            user <= OFF;
                        end if;
                when COR =>
                -- correct is final state
                        correct <= '1';
                        rgb_reg <= "010";
                when OFF =>
                    if locked = '0' then 
                    --reset then return to idle
                        lastPress <= "0010";
                        rgb_reg <= "000";
                        myCharArray <=  ('x', 'x', 'x', 'x');
                        arrays_equal <= true;
                        correct <= '0';
                        user <= IDLE;
                    end if;
            end case;
        
        case admin is
            when IDLE => -- idle lock state
            if locked = '1' then
                rgb_reg <= "001";
                admin <= Pa1;
            end if;
            when Pa1 => --compare password
                if btn_db_ad /= "00" then
                    if btn_db_ad = "01" then
                        admCharArray(0) <= 'a';
                        lastPressad <= "01";
                        admin <= Pa2;
                    elsif btn_db_ad = "10" then
                        admCharArray(0) <= 'b';
                        lastPressad <= "10";
                        admin <= Pa2;
                    end if;
                end if;
            when Pa2 =>
            if btn_db_ad /= lastPressad then
                if btn_db_ad /= "00" then
                    if btn_db_ad = "01" then
                        admCharArray(1) <= 'a';
                        admin <= CHECK;
                    elsif btn_db_ad = "10" then
                        admCharArray(1) <= 'b';
                        admin <= CHECK;
                    end if;
                end if;
             end if;
             when CHECK =>
                     for i in 0 to 1 loop
                        if admCharArray(i) /= adpassword(i) then -- Compare each element
                            ad_arrays_equal <= false;
                            exit;
                        end if;
                    end loop;
                    admin <= EVAL;
                when EVAL =>
                    if ad_arrays_equal = false then
                        admin <= INC;
                    else 
                        admin <= COR;
                    end if;
                when INC =>
                    lastPressad <= "00";
                    admCharArray <=  ('x', 'x');
                    ad_arrays_equal <= true;
                    admin <= IDLE;
                when COR =>
                -- correct is final state
                    lastPressad <= "00";
                    admCharArray <=  ('x', 'x');
                    ad_arrays_equal <= true;
                    incor <= 0;
                    locked <= '0';
                    admin <= IDLE;
        end case;
    end if;
end process;

LEDX <= led_reg;
RGB_R <= rgb_reg(0);
RGB_G <= rgb_reg(1);
RGB_B <= rgb_reg(2);

end Behavioral;
