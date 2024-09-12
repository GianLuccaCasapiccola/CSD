library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity timer is
    Port ( clk_i   : in  STD_LOGIC;  -- Clock de 10 ms do divisor de clock
           reset      : in  STD_LOGIC;  -- Reset geral dos contadores
           start_state: in  STD_LOGIC;  -- Sinal que indica se deve contar
           split_state: in STD_LOGIC; -- Sinal que indica se deve mostrar o tempo
           blink    : out STD_LOGIC; -- sinal que indica que o display está piscando no estado de split a cada 250ms
           centesimos : out STD_LOGIC_VECTOR (6 downto 0);  -- Contador de centésimos (0-99)
           segundos   : out STD_LOGIC_VECTOR (5 downto 0);  -- Contador de segundos (0-59)
           minutos    : out STD_LOGIC_VECTOR (5 downto 0);  -- Contador de minutos (0-59)
           horas      : out STD_LOGIC_VECTOR (6 downto 0)   -- Contador de horas (0-99)
         );
end timer;

architecture timer of timer is
    --sinais de contagem do tempo
    signal centesimo_count : INTEGER := 0;
    signal segundo_count : INTEGER := 0;
    signal minuto_count : INTEGER := 0;
    signal hora_count : INTEGER := 0;

    -- sinais enviados para o display, só alteram quando split está inativo
    signal centesimo_dspl : INTEGER := 0;
    signal segundo_dspl : INTEGER := 0;
    signal minuto_dspl : INTEGER := 0;
    signal hora_dspl : INTEGER := 0;
    
    signal blink_dspl : STD_LOGIC := '1';
    signal blink_count : INTEGER := 0;
    

begin
    process(clk_i, reset)
    begin
        if reset = '1' then
            centesimo_count <= 0;
            segundo_count <= 0;
            minuto_count <= 0;
            hora_count <= 0;
            centesimo_dspl <= 0;
            segundo_dspl <= 0;
            minuto_dspl <= 0;
            hora_dspl <= 0;
            blink_dspl <= '1';
        elsif rising_edge(clk_i) then
            if start_state = '1' then  -- Inicia ou continua a contagem
                if split_state = '0' then
                    blink_dspl <= '1'; -- O display está sempre ligado fora do estado de split
                    centesimo_dspl <= centesimo_count;
                    segundo_dspl <= segundo_count;
                    minuto_dspl <= minuto_count;
                    hora_dspl <= hora_count;
                elsif split_state = '1' then 
                    if blink_count = 24 then -- contador de 25cs para piscar o display quando split
                        blink_dspl <= not blink_dspl;
                        blink_count <= 0;
                    else blink_count <= blink_count + 1;
                    end if;
                    centesimo_dspl <= centesimo_dspl;
                    segundo_dspl <= segundo_dspl;
                    minuto_dspl <= minuto_dspl;
                    hora_dspl <= hora_dspl;
                end if;
                -- Contador de centésimos (0-99)
                if centesimo_count = 99 then
                    centesimo_count <= 0;
                    -- Contador de segundos (0-59)
                    if segundo_count = 59 then
                        segundo_count <= 0;
                        -- Contador de minutos (0-59)
                        if minuto_count = 59 then
                            minuto_count <= 0;
                            -- Contador de horas (0-99)
                            if hora_count = 99 then
                                hora_count <= 0;
                            else
                                hora_count <= hora_count + 1;
                            end if;
                        else
                            minuto_count <= minuto_count + 1;
                        end if;
                    else
                        segundo_count <= segundo_count + 1;
                    end if;
                else
                    centesimo_count <= centesimo_count + 1;
                end if;
            end if;
        end if;
    end process;


    -- Saídas dos contadores
    centesimos<= std_logic_vector(to_unsigned(centesimo_dspl, centesimos'length));
    segundos  <= std_logic_vector(to_unsigned(segundo_dspl, segundos'length));
    minutos   <= std_logic_vector(to_unsigned(minuto_dspl, minutos'length));
    horas     <= std_logic_vector(to_unsigned(hora_dspl, horas'length));
    blink     <= blink_dspl;  
end timer;
