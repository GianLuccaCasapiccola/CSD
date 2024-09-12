library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top is
    Port ( clk        : in  STD_LOGIC;  -- Clock de entrada (100 MHz)
           start_btn  : in  STD_LOGIC;  -- Botão de start (centro)
           stop_btn   : in  STD_LOGIC;  -- Botão de stop (baixo)
           split_btn  : in  STD_LOGIC;  -- Botão de split (esquerda)
           reset_btn  : in  STD_LOGIC;  -- Botão de reset (direita)
           an     : out STD_LOGIC_VECTOR(7 downto 0);  -- Anodos dos displays de 7 segmentos
           dspl_drv   : out STD_LOGIC_VECTOR(7 downto 0)   -- Segmentos dos displays de 7 segmentos
         );
end top;

architecture top of top is
    -- Sinais internos
    signal clk_i    : STD_LOGIC;
    signal d1, d2, d3, d4, d5, d6, d7, d8 : STD_LOGIC_VECTOR(5 downto 0);
    signal deb_start, deb_stop, deb_split, deb_reset, start_state, split_state, blink : STD_LOGIC;
    signal centesimos : STD_LOGIC_VECTOR(6 downto 0);
    signal segundos   : STD_LOGIC_VECTOR(5 downto 0);
    signal minutos    : STD_LOGIC_VECTOR(5 downto 0);
    signal horas      : STD_LOGIC_VECTOR(6 downto 0);
    signal centesimos_bcd, segundos_bcd, minutos_bcd, horas_bcd : std_logic_vector(7 downto 0);

    type ROM is array (0 to 99) of std_logic_vector (7 downto 0);	
		-- ROM para converter binario em BCD
		constant conv_to_BCD : ROM:=(
		"00000000", "00000001", "00000010", "00000011", "00000100", -- 01-09
		"00000101", "00000110", "00000111", "00001000", "00001001",  
		"00010000", "00010001", "00010010", "00010011", "00010100", -- 10-19
		"00010101", "00010110", "00010111", "00011000", "00011001",  
		"00100000", "00100001", "00100010", "00100011", "00100100", -- 20-29
		"00100101", "00100110", "00100111", "00101000", "00101001",  
		"00110000", "00110001", "00110010", "00110011", "00110100", -- 30-39
		"00110101", "00110110", "00110111", "00111000", "00111001",  
		"01000000", "01000001", "01000010", "01000011", "01000100", -- 40-49
		"01000101", "01000110", "01000111", "01001000", "01001001",  
		"01010000", "01010001", "01010010", "01010011", "01010100", -- 50-59
		"01010101", "01010110", "01010111", "01011000", "01011001",
		"01100000", "01100001", "01100010", "01100011", "01100100", -- 60-69
		"01100101", "01100110", "01100111", "01101000", "01101001",
		"01110000", "01110001", "01110010", "01110011", "01110100", -- 70-79
		"01110101", "01110110", "01110111", "01111000", "01111001",
		"10000000", "10000001", "10000010", "10000011", "10000100", -- 80-89
		"10000101", "10000110", "10000111", "10001000", "10001001",
		"10010000", "10010001", "10010010", "10010011", "10010100", --90-99
		"10010101", "10010110", "10010111", "10011000", "10011001"
		);
      
begin
    -- Instanciação do divisor de clock
    i_clock_div: entity work.clock_div
        Port map ( 
            clk_in => clk,
            reset => reset_btn,
            clk_out => clk_i
        );

    -- Instanciação dos circuitos debounce para os botões
    i_deb_start: entity work.debounce
        Port map (  
            clk_i => clk_i,
		    rstn_i => reset_btn,
            key_i => start_btn,
            debkey_o => deb_start
        );

    i_deb_stop: entity work.debounce
        Port map (  
            clk_i => clk_i,
            rstn_i => reset_btn,
            key_i => stop_btn,
            debkey_o => deb_stop
        );
    i_deb_split: entity work.debounce
        Port map (  
            clk_i => clk_i,
            rstn_i => reset_btn,
            key_i => split_btn,
            debkey_o => deb_split
        );
    i_deb_reset: entity work.debounce
        Port map (  
            clk_i => clk_i,
            rstn_i => reset_btn,
            key_i => reset_btn,
            debkey_o => deb_reset
        );
    -- Instanciação da máquina de estados
    i_maq_est: entity work.maq_est
        Port map ( 
            clk_i => clk_i,
            reset => reset_btn,
            deb_start => deb_start,
            deb_stop => deb_stop,
            deb_split => deb_split,
            deb_reset => deb_reset,
            start_state => start_state,
            split_state => split_state
        );

    -- Instanciação dos contadores
    i_timer: entity work.timer
        Port map ( 
            clk_i => clk_i,
            reset => reset_btn,
            start_state => start_state,
            split_state => split_state,
            blink => blink,
            centesimos => centesimos,
            segundos => segundos,
            minutos => minutos,
            horas => horas
        );

    centesimos_bcd <= conv_to_BCD(conv_integer(centesimos));
    segundos_bcd <= conv_to_BCD(conv_integer(segundos));
    minutos_bcd <= conv_to_BCD(conv_integer(minutos));
    horas_bcd <= conv_to_BCD(conv_integer(horas));

    d1 <= blink & centesimos_bcd(3 downto 0)  & '1';
    d2 <= blink & centesimos_bcd(7 downto 4)  & '1';
    d3 <= blink & segundos_bcd(3 downto 0)    & '0';
    d4 <= blink & segundos_bcd(7 downto 4)    & '1';
    d5 <= blink & minutos_bcd(3 downto 0)     & '0';
    d6 <= blink & minutos_bcd(7 downto 4)     & '1';
    d7 <= blink & horas_bcd(3 downto 0)       & '0';
    d8 <= blink & horas_bcd(7 downto 4)       & '1';

    -- Instanciação do driver dos displays de 7 segmentos
    i_dspl_drv : entity work.dspl_drv_8dig
    port map(
        clock => clk_i, 
        reset => reset_btn, 
        d1 => d1, 
        d2 => d2,
        d3 => d3,
        d4 => d4,
        d5 => d5,
        d6 => d6,
        d7 => d7,
        d8 => d8,
        an => an, 
        dec_ddp => dspl_drv
    );
               

end top;
