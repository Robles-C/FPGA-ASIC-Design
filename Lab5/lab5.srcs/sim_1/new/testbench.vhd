library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use std.env.finish;

entity testbench is
    --port();
end testbench;

architecture Behavioral of testbench is

  component top is

    port (
      sw                : in  std_logic_vector(3 downto 0);
      led               : out std_logic_vector(3 downto 0);
      jc                : out std_logic_vector(7 downto 0);
      sysclk            : in  std_logic;
      led6_g            : out  std_logic;
      btn0              : in  std_logic;
      XTX               : out STD_LOGIC;
      XRX               : in STD_LOGIC);

  end component;
  
  component uart_rx_tb is 
    generic (
        g_CLKS_PER_BIT : integer := 217
    );
    port (
        i_Clk       : in  std_logic;
        i_RX_Serial : in  std_logic;
        o_RX_DV     : out std_logic;
        o_RX_Byte   : out std_logic_vector(7 downto 0)
    );
  end component;
  
  component uart_tx_tb is 
    generic (
        g_CLKS_PER_BIT : integer := 217
    );
    port (
        i_Clk       : in  std_logic;
        i_TX_DV     : in  std_logic;
        i_TX_Byte   : in  std_logic_vector(7 downto 0);
        o_TX_Active : out std_logic;
        o_TX_Serial : out std_logic;
        o_TX_Done   : out std_logic
    );
  end component;
    
  --ssd and led stuff from lab4
  constant CLK_PERIOD      : time      := 8 ns;
  signal clk_tb            : std_logic := '0';
  signal reset_tb          : std_logic := '0';
  signal switches_tb       : std_logic_vector(3 downto 0);
  signal leds_tb           : std_logic_vector(3 downto 0);
  signal locked_tb         : std_logic;
  signal ssd_tb            : std_logic_vector(7 downto 0);
  --uart stuff from lab 5 
  --given UART
  signal TX_Byte_tb        : std_logic_vector(7 downto 0) := ("00000000");
  signal RX_Byte_tb        : std_logic_vector(7 downto 0);
  signal TX_DV_tb          : std_logic := '0';
  signal RX_DV_tb          : std_logic;
  signal TX_Active_tb      : std_logic;
  signal TX_Serial_tb      : std_logic;
  signal TX_Done_tb        : std_logic;
  --my own uart
  signal TX_board_tb       : std_logic;
  signal RX_board_tb       : std_logic := '0';
  
  constant g_CLKS_PER_BIT: integer := 1085;  --125MHz/115200
begin
   
  clk_gen : process
  begin
    clk_tb <= not clk_tb;
    wait for CLK_PERIOD / 2;
  end process;
   
  reset_gen : process
  begin
      reset_tb <= '0';
      wait for 5 ns;
      reset_tb <= '1';
      wait for 10 ns;
      reset_tb <= '0';
    wait;
  end process;

  DUT : top
    port map(
        sw              => switches_tb,
        led             => leds_tb,
        jc              => ssd_tb,
        sysclk          => clk_tb,
        led6_g          => locked_tb,
        btn0            => reset_tb,
        XTX             => TX_board_tb,
        XRX             => RX_board_tb
      );
  
  U1: uart_tx_tb
  generic map (
    g_CLKS_PER_BIT => g_CLKS_PER_BIT
  )
  port map (
    i_Clk       => clk_tb,
    i_TX_DV     => TX_DV_tb,
    i_TX_Byte   => TX_Byte_tb,
    o_TX_Active => TX_Active_tb,
    o_TX_Serial => TX_Serial_tb,
    o_TX_Done   => TX_Done_tb
  );

  U2: uart_rx_tb
  generic map (
    g_CLKS_PER_BIT => g_CLKS_PER_BIT
  )
  port map (
    i_Clk       => clk_tb,
    i_RX_Serial => TX_Serial_tb,
    o_RX_DV     => RX_DV_tb, -- wait for RX_DV_tb
    o_RX_Byte   => RX_Byte_tb
  );
  
  test_process : process
  begin
    wait until rising_edge(locked_tb);
    -- lab 4 tests
    switches_tb <= "0011";
    
    wait for 200 ns;
    
    switches_tb <= "1100";
    
    wait for 200 ns;
    
    switches_tb <= "0101";
    
    wait for 200ns;
    RX_board_tb <= '1';
    wait for 20ns;
    RX_board_tb <= '0';
    --lab 5 tests
    
    TX_Byte_tb <= "10101111"; --data sent. 0xAF in hex 
    TX_DV_tb <= '1'; -- data ready to send flag
   
    wait until rising_edge(TX_Active_tb); --wait until tx is not active
  
    TX_DV_tb <= '0'; -- tx done
   
    wait until rising_edge(RX_DV_tb); -- wait until rx data is valid
    
    RX_Byte_tb <= TX_Byte_tb; 
    
    wait for 1000ns;
   
    if RX_Byte_tb /= TX_Byte_tb then
        report "RX does not match TX" severity error;
    else
        report "RX does match TX" severity note;
    end if;
    
    finish;
    
  end process;

end Behavioral;