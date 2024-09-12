library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity debounce is          
	generic(DELAY: integer := 500000);
	port(
		clk_i: in std_logic;
		rstn_i: in std_logic;
		key_i: in std_logic;
		debkey_o: out std_logic
	);
end debounce;

architecture debounce_arch of debounce is
	type state_type is (state1, state2, state3, state4, state5);
	signal state, nextstate: state_type;
	signal intclock: std_logic;
	signal clockdiv: std_logic_vector(23 downto 0);
begin
	process(clk_i, rstn_i)
	begin
		if rstn_i = '0' then
			state <= state1;
		elsif clk_i'event and clk_i = '1' then
			case state is
				when state1 =>	if intclock = '0' then
							if key_i = '1' then
								state <= state2;
							end if;
						end if;
				when state2 =>	if intclock = '1' then
							if key_i = '1' then
								state <= state3;
							else
								state <= state1;
							end if;
						end if;
				when state3 =>	if intclock = '0' then
							if key_i = '0' then
								state <= state4;
							end if;
						end if;
				when state4 =>	if intclock = '1' then
							if key_i = '0' then
								state <= state5;
							else
								state <= state3;
							end if;
						end if;
				when state5 =>	state <= state1;
			end case;
		end if;
	end process;
	
	
	process(clk_i, rstn_i)
	begin
		if rstn_i = '0' then
			clockdiv <= (others => '0');
			intclock <= '0';
		elsif clk_i'event and clk_i = '1' then
			if clockdiv <= DELAY then
				clockdiv <= clockdiv + 1;
			else
				clockdiv <= (others => '0');
				intclock <= not intclock;
			end if;
		end if;
	end process;

	debkey_o <= '1' when state = state3 else '0';

end debounce_arch;
