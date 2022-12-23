library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_bit.all;

entity decrypt is
port(
	clk: in BIT;
	rst: in BIT;
	crtext: in unsigned(63 downto 0);
	input_ready : in BIT;
	output_ready : out BIT; 
	pltext: out unsigned(63 downto 0)
);
end decrypt;

architecture FSM of decrypt is
	type executionstage is (s0,s1,s2,s3);
	signal currentstate, nextstate: executionstage;
	
	signal L		: unsigned(31 downto 0);
	signal R		: unsigned(31 downto 0);
	signal count: unsigned(6 downto 0);
	signal sum	: unsigned(31 downto 0);
	
	constant delta : unsigned(31 downto 0) := x"9E3779B9";
	constant key0	: unsigned(31 downto 0) := x"97B8521F";
	constant key1	: unsigned(31 downto 0) := x"87C8371A";
	constant key2	: unsigned(31 downto 0) := x"32AF88FC";
	constant key3	: unsigned(31 downto 0) := x"58AC159F";
	
	constant ZERO 		: unsigned(31 downto 0) := "00000000000000000000000000000000";
	constant ONE 		: unsigned(31 downto 0) := "00000000000000000000000000000001";
	constant TWO 		: unsigned(31 downto 0) := "00000000000000000000000000000010";
	constant THREE 	: unsigned(31 downto 0) := "00000000000000000000000000000011";
	
begin
	process(currentstate, input_ready)
	begin
		case currentstate is 
			when s0 =>
				if input_ready = '1' then 
					nextstate <= s1;
				else 
					nextstate <= s0;
				end if;
			when s1 =>
				nextstate <= s2;
			when s2 => 
				if (count = "1000000") then	
					nextstate <= s3;
				
				else
					nextstate <= s1;
				
				end if;
			when s3 => 
				nextstate <= s3;
			when others =>
				nextstate <= currentstate;
		end case;
	end process;

	process(clk, rst)
	begin
	if rst = '1' then
		currentstate <= s0;
		pltext <= "0000000000000000000000000000000000000000000000000000000000000000";
		count <= "0000000";
		L <= ZERO;
		R <= ZERO;
		sum <= (delta sll 5);
	else 
		currentstate <= nextstate;
		case nextstate is 
			when s0 =>
				sum <= (delta sll 5);
				L	<= crtext(63 downto 32);
				R	<= crtext(31 downto 0);
			when s1 =>
				case ((sum srl 11) and THREE) is
					when ZERO =>
						R <= R - ((((L sll 4) xor (L srl 5)) + L) xor (sum + key0));
				
					when ONE =>
						R <= R - ((((L sll 4) xor (L srl 5)) + L) xor (sum + key1));
				
					when TWO =>
						R <= R - ((((L sll 4) xor (L srl 5)) + L) xor (sum + key2));
				
					when others =>
						R <= R - ((((L sll 4) xor (L srl 5)) + L) xor (sum + key3));				
				end case;			
			sum <= sum - delta;
			
			when s2 =>
				case (sum and THREE) is
					when ZERO =>
						L <= L - ((((R sll 4) xor (R srl 5)) + R) xor (sum + key0));
				
					when ONE =>
						L <= L - ((((R sll 4) xor (R srl 5)) + R) xor (sum + key1));
				
					when TWO =>
						L <= L - ((((R sll 4) xor (R srl 5)) + R) xor (sum + key2));
				
					when others =>
						L <= L - ((((R sll 4) xor (R srl 5)) + R) xor (sum + key3));				
				end case;
			count <= count + 1;
				
			when s3 =>
				pltext <= L & R;			
		end case;
	end if;
	end process;
end fsm;