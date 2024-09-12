library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_top_level is
end tb_top_level;

architecture Behavioral of tb_top_level is
    -- Sinais internos para simulação
    signal clk        : STD_LOGIC := '0';
    signal reset      : STD_LOGIC := '0';
    signal start_btn  : STD_LOGIC := '0';
    signal stop_btn   : STD_LOGIC := '0';
    signal split_btn  : STD_LOGIC := '0';
    signal reset_btn  : STD_LOGIC := '0';
    signal anodes     : STD_LOGIC_VECTOR(7 downto 0);
    signal segments   : STD_LOGIC_VECTOR(6 downto 0);

    -- Período de clock de 100 MHz
    constant clk_period : time := 10 ns;

    -- Instanciação do top level
    component top_level
        Port ( clk        : in  STD_LOGIC;
               reset      : in  STD_LOGIC;
               start_btn  : in  STD_LOGIC;
               stop_btn   : in  STD_LOGIC;
               split_btn  : in  STD_LOGIC;
               reset_btn  : in  STD_LOGIC;
               anodes     : out STD_LOGIC_VECTOR(7 downto 0);
               segments   : out STD_LOGIC_VECTOR(6 downto 0));
    end component;
    
begin
    -- Instância do top level
    uut: top_level
        Port map ( clk => clk,
                   reset => reset,
                   start_btn => start_btn,
                   stop_btn => stop_btn,
                   split_btn => split_btn,
                   reset_btn => reset_btn,
                   anodes => anodes,
                   segments => segments);

    -- Geração do clock de 100 MHz
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Processo de estímulos para simulação
    stimulus: process
    begin
        -- Inicializa com reset ativo
        reset <= '1';
        wait for 100 ns;
        reset <= '0';

        -- Pressiona o botão de start
        start_btn <= '1';
        wait for 20 ns;
        start_btn <= '0';
        wait for 500 ms;  -- Espera o cronômetro contar um pouco

        -- Pressiona o botão de stop
        stop_btn <= '1';
        wait for 20 ns;
        stop_btn <= '0';
        wait for 100 ms;

        -- Pressiona o botão de start novamente para continuar
        start_btn <= '1';
        wait for 20 ns;
        start_btn <= '0';
        wait for 500 ms;

        -- Pressiona o botão de split para amostrar o tempo
        split_btn <= '1';
        wait for 20 ns;
        split_btn <= '0';
        wait for 100 ms;

        -- Pressiona o botão de split novamente para voltar à contagem normal
        split_btn <= '1';
        wait for 20 ns;
        split_btn <= '0';
        wait for 300 ms;

        -- Pressiona o botão de reset para zerar o cronômetro
        reset_btn <= '1';
        wait for 20 ns;
        reset_btn <= '0';

        -- Fim da simulação
        wait;
    end process;
end Behavioral;
