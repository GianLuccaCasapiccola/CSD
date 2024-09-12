library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity clock_div is
    Port ( clk_in : in STD_LOGIC;  -- Clock de entrada (100 MHz)
           reset  : in STD_LOGIC;  -- Reset do divisor
           clk_out : out STD_LOGIC);  -- Clock de saída (10 ms)
end clock_div;

architecture clock_div of clock_div is
    signal counter : INTEGER := 0;
    signal clk : STD_LOGIC;
    constant MAX_COUNT : INTEGER := 999999;  -- 100 MHz / 10 ms = 1.000.000 ciclos
begin
    process(clk_in, reset)
    begin
        if reset = '1' then
            counter <= 0;
            clk <= '0';
        elsif rising_edge(clk_in) then
            if counter = MAX_COUNT then
                clk <= not clk;
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;
    clk_out <= clk;
end clock_div;
