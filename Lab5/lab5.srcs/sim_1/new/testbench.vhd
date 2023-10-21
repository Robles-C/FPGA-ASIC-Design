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
      btn0              : in  std_logic
      );

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
  signal tb_TX_DV        : std_logic := '0';
  signal tb_TX_Byte      : std_logic_vector(7 downto 0) := ("00000000");
  signal tb_TX_Active    : std_logic;
  signal tb_TX_Serial    : std_logic;
  signal tb_TX_Done      : std_logic;
  signal tb_RX_DV        : std_logic;
  signal tb_RX_Byte      : std_logic_vector(7 downto 0);
  
  constant g_CLKS_PER_BIT: integer := 217;
begin
   
  clk_process : process
  begin
    clk_tb <= not clk_tb;
    wait for CLK_PERIOD / 2;
  end process;
   
  reset_process : process
  begin
    reset_tb <= '0';
    wait for 50 ns;
    reset_tb <= '1';
    wait for 100 ns;
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
        btn0            => reset_tb
      );
  
  U1: uart_tx_tb
  generic map (
    g_CLKS_PER_BIT => g_CLKS_PER_BIT
  )
  port map (
    i_Clk       => clk_tb,
    i_TX_DV     => tb_TX_DV,
    i_TX_Byte   => tb_TX_Byte,
    o_TX_Active => tb_TX_Active,
    o_TX_Serial => tb_TX_Serial,
    o_TX_Done   => tb_TX_Done
  );

  U2: uart_rx_tb
  generic map (
    g_CLKS_PER_BIT => g_CLKS_PER_BIT
  )
  port map (
    i_Clk       => clk_tb,
    i_RX_Serial => tb_TX_Serial,
    o_RX_DV     => tb_RX_DV,
    o_RX_Byte   => tb_RX_Byte
  );
  
  test_process : process
  begin
    wait until rising_edge(locked_tb);
 
    switches_tb <= "0011";
    
    wait for 200 ns;
    
    switches_tb <= "1100";
    
    wait for 200 ns;
    
    switches_tb <= "0101";
    
    wait for 200ns;
    
    tb_TX_DV <= '1'; -- data ready to send flag
    tb_TX_Byte <= "10101111"; --data sent. 0xAF in hex 
    wait for 1000ns; --delay so data can transmit
    tb_TX_DV <= '0'; -- tx done
    
    wait for 20000ns; -- Wait for transmission to complete
    
    tb_RX_Byte <= tb_TX_Byte; 

    wait for 200ns;
        
    if tb_RX_Byte /= tb_TX_Byte then
        report "RX does not match TX" severity error;
    else
        report "RX does match TX";
    end if;
    
    finish;
    
  end process;

end Behavioral;