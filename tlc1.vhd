library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tlc1 is
port(	clk_50MHz, rst : in std_logic;
		HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : out std_logic_vector(6 downto 0)
		);
end entity tlc1;

architecture control of tlc1 is
	constant tr				: integer := 2;
	constant t1				: integer := 5;
	constant t2				: integer := 4;
	constant max_timer	: integer := 7;
	
	constant clk_freq : integer := 50e6;
	
	type state is (reset, ns, ew);
	signal pres_state, next_state : state;
	
	constant one	: std_logic_vector(6 downto 0) := "1111001";
	constant two	: std_logic_vector(6 downto 0) := "0100100";
	constant five	: std_logic_vector(6 downto 0) := "0010010";
	
	constant blank	: std_logic_vector(6 downto 0) := "1111111";
	
	constant r : std_logic_vector(6 downto 0) := "0101111";
	constant E : std_logic_vector(6 downto 0) := "0000110";
	constant t : std_logic_vector(6 downto 0) := "0000111";
	
	signal s_clk_1Hz : std_logic;
begin
	create_1Hz_clk: process(clk_50MHz, rst)
		variable cnt : integer range 0 to clk_freq := 0;
	begin
		if rst = '0' then
			cnt := 0;
		elsif rising_edge(clk_50MHz) then
			if cnt >= clk_freq / 2 then
				s_clk_1Hz <= not s_clk_1Hz;
				cnt := 0;
			else
				cnt := cnt + 1;
			end if;
		end if;
	end process;
	
	
	state_transition: process(clk_50MHz, rst)
	begin
		if rst = '0' then
			pres_state <= reset;
		elsif rising_edge(clk_50MHz) then
			pres_state <= next_state;
		end if;
	end process;
	
	state_transition_logic: process(pres_state, rst, s_clk_1Hz)
		variable timer : integer range 0 to max_timer := 0;
	begin
		if rst = '0' then
			next_state <= reset;
			timer := 0;
		elsif rising_edge(s_clk_1Hz) then
			case pres_state is
				when reset =>
					if timer >= tr then
						timer := 0;
						next_state <= ns;
					else
						timer := timer + 1;
					end if;
				when ns =>
					if timer >= t1 then
						timer := 0;
						next_state <= ew;
					else
						timer := timer + 1;
					end if;
				when ew =>
					if timer >= t2 then
						timer := 0;
						next_state <= ns;
					else
						timer := timer + 1;
					end if;
				when others =>
					next_state <= reset;
			end case;
		end if;
	end process;
	
	output_logic: process(pres_state)
	begin
		case pres_state is
			when reset =>
				HEX5 <= r;
				HEX4 <= E;
				HEX3 <= five;
				HEX2 <= E;
				HEX1 <= t;
				HEX0 <= blank;
			when ns =>
				HEX5 <= blank;
				HEX4 <= five;
				HEX3 <= t;
				HEX2 <= one;
				HEX1 <= blank;
				HEX0 <= blank;
			when ew =>
				HEX5 <= blank;
				HEX4 <= five;
				HEX3 <= t;
				HEX2 <= two;
				HEX1 <= blank;
				HEX0 <= blank;
			when others =>
				HEX5 <= blank;
				HEX4 <= blank;
				HEX3 <= blank;
				HEX2 <= blank;
				HEX1 <= blank;
				HEX0 <= blank;
		end case;
	end process;
end architecture control;