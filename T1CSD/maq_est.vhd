library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity maq_est is
    Port ( clk_i      : in  STD_LOGIC;  -- Clock principal
           reset      : in  STD_LOGIC;  -- Reset geral da máquina
           deb_start  : in  STD_LOGIC;  -- Botão de início/continuação
           deb_stop   : in  STD_LOGIC;  -- Botão de parada
           deb_split  : in  STD_LOGIC;  -- Botão de amostragem (split)
           deb_reset  : in  STD_LOGIC;  -- Botão de reset
           start_state: out STD_LOGIC;  -- Sinal de start para os contadores
           split_state: out STD_LOGIC   -- Sinal de split para o comportamento de amostragem
         );
end maq_est;

architecture maq_est of maq_est is
    type state_type is (IDLE, RUNNING, STOPPED, SPLIT);  -- Estados da máquina
    signal current_state, next_state : state_type := IDLE;
    signal start_in, split_in : STD_LOGIC := '0';
begin
    -- Transição de estados
    process(clk_i, reset)
    begin
        if reset = '1' then
            current_state <= IDLE;
        elsif rising_edge(clk_i) then
            current_state <= next_state;
        end if;
    end process;

    -- Lógica de próxima transição
    process(current_state, deb_start, deb_stop, deb_split, deb_reset)
    begin
        next_state <= current_state;
        case current_state is
            -- Estado IDLE: Aguardando para iniciar
            when IDLE =>
                start_in <= '0';
                split_in <= '0';
                if deb_start = '1' then
                    next_state <= RUNNING;
                elsif deb_reset = '1' then
                    next_state <= IDLE;
                end if;
            
            -- Estado RUNNING: Contagem em andamento
            when RUNNING =>
                start_in <= '1';  -- Ativa a contagem
                split_in <= '0';  -- O estado Running implica na contagem estar sendo mostrada, então split deve ser '0'
                if deb_stop = '1' then
                    next_state <= STOPPED;
                elsif deb_split = '1' then
                    next_state <= SPLIT;
                elsif deb_reset = '1' then
                    next_state <= IDLE;
                end if;

            -- Estado STOPPED: Cronômetro pausado
            when STOPPED =>
                start_in <= '0'; -- Para de contar
                split_in <= '0';
                if deb_start = '1' then
                    next_state <= RUNNING;
                elsif deb_reset = '1' then
                    next_state <= IDLE;
                end if;

            -- Estado SPLIT: Mostra tempo amostrado, mas continua contando
            when SPLIT =>
                start_in <= '1';
                split_in <= '1';  -- Ativa comportamento de amostragem
                if deb_split = '1' then
                    next_state <= RUNNING;  -- Retorna ao estado de contagem normal
                elsif deb_reset = '1' then
                    next_state <= IDLE;
                end if;
        end case;
    end process;

    start_state <= start_in;
    split_state <= split_in;
end maq_est;
