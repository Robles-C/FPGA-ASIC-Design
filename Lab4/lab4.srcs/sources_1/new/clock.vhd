library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity clock is
    Port (
        clk_in     : in  STD_LOGIC;     
        reset      : in  STD_LOGIC;     
        clk_out    : out STD_LOGIC;
        locked_out : out STD_LOGIC
    );
end clock;

architecture Behavioral of clock is

    signal locked      : STD_LOGIC;
    signal btn_reset  : STD_LOGIC := '1';
    signal counter         : integer range 0 to 32 := 0;
    signal counter_enable  : STD_LOGIC := '0';
    
    
    component Clock_Wizard is
        Port (
            clk_in   : in  STD_LOGIC;
            reset    : in  STD_LOGIC;
            clk_out  : out STD_LOGIC;
            locked   : out STD_LOGIC
        );
    end component Clock_Wizard;

begin

    DCM_Instance: Clock_Wizard
    port map (
        clk_in  => clk_in,
        reset   => btn_reset,
        clk_out => clk_out,
        locked  => locked
    );

    process(clk_in)
    begin
        if rising_edge(clk_in) then
            if reset = '1' then
                btn_reset <= '1';
                counter <= 0;
                counter_enable <= '0';
            elsif locked = '1' and counter_enable = '0' then
                counter_enable <= '1'; 
            elsif counter_enable = '1' and counter < 32 then
                counter <= counter + 1;
            elsif counter = 32 then
                btn_reset <= '0'; 
                counter_enable <= '0'; 
            end if;
        end if;
    end process;

end Behavioral;
