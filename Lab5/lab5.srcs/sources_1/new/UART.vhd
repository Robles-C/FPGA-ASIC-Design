library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART is
    Port (
        clk      : in  STD_LOGIC;
        reset    : in  STD_LOGIC;
        tx_start : in  STD_LOGIC;
        data_in  : in  STD_LOGIC_VECTOR(7 downto 0);
        rx       : in  STD_LOGIC;
        data_out : out STD_LOGIC_VECTOR(7 downto 0);
        rx_ready : out STD_LOGIC;
        tx       : out STD_LOGIC
    );
end UART;

architecture Behavioral of UART is
    signal tx_reg        : STD_LOGIC_VECTOR(9 downto 0); -- 1 start bit, 8 data bits, 1 stop bit
    signal tx_count      : integer := 0;
    signal rx_reg        : STD_LOGIC_VECTOR(9 downto 0); -- 1 start bit, 8 data bits, 1 stop bit
    signal rx_count      : integer := 0;
    signal rx_data       : STD_LOGIC_VECTOR(7 downto 0);
    signal rx_ready_flag : STD_LOGIC := '0';

begin
    -- UART Transmitter Process
    process(clk, reset)
    begin
        if reset = '1' then
            tx_reg <= (others => '1'); -- Initialize to all high (marking) state
            tx_count <= 0;
        elsif rising_edge(clk) then
            if tx_count = 0 then
                if tx_start = '1' then
                    tx_reg <= '0' & data_in & '1'; -- Start bit, data bits, stop bit
                    tx_count <= 1;
                end if;
            elsif tx_count > 0 and tx_count <= 10 then
                tx_reg <= '0' & tx_reg(9 downto 1); -- Shift data out
                tx_count <= tx_count + 1;
            else
                tx_reg <= (others => '1'); -- All high (marking) state
                tx_count <= 0;
            end if;
        end if;
    end process;

    tx <= tx_reg(0);

    -- UART Receiver Process
    process(clk, reset)
    begin
        if reset = '1' then
            rx_reg <= (others => '1'); -- Initialize to all high (marking) state
            rx_count <= 0;
            rx_ready_flag <= '0';
        elsif rising_edge(clk) then
            if rx_count = 0 then
                if rx = '0' then
                    rx_reg <= rx & rx_reg(9 downto 1); -- Shift in received bit
                    rx_count <= 1;
                end if;
            elsif rx_count > 0 and rx_count < 10 then
                rx_reg <= rx & rx_reg(9 downto 1); -- Shift in received bit
                rx_count <= rx_count + 1;
            else
                rx_data <= rx_reg(8 downto 1); -- Extract received data bits
                rx_ready_flag <= '1'; -- Data is valid
                rx_count <= 0;
            end if;
        end if;
    end process;

    data_out <= rx_data;
    rx_ready <= rx_ready_flag;

end Behavioral;
