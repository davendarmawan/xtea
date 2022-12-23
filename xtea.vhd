library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_bit.all;

entity xtea is
port(
	sel: in bit;
	clk: in bit;
	rst: in bit;
	in_text: in unsigned(63 downto 0);
	in_ready: in bit;
	out_text: out unsigned(63 downto 0);
	out_ready: out bit
);
end xtea;

architecture xtea_arc of xtea is

component encrypt is
port(
	clk: in BIT;
	rst: in BIT;
	crtext: out unsigned(63 downto 0);
	input_ready : in BIT;
	output_ready : out BIT; 
	pltext: in unsigned(63 downto 0)
);
end component;

component decrypt is
port(
	clk: in BIT;
	rst: in BIT;
	crtext: in unsigned(63 downto 0);
	input_ready : in BIT;
	output_ready : out BIT; 
	pltext: out unsigned(63 downto 0)
);
end component;

signal out_encrypt: unsigned(63 downto 0);
signal out_decrypt: unsigned(63 downto 0);
signal out_ready_enc: bit;
signal out_ready_dec: bit;

begin
	-- Datapath
	enc: encrypt port map(
		clk => clk,
		rst => rst,
		pltext => in_text,
		input_ready => in_ready,
		output_ready => out_ready_enc,
		crtext => out_encrypt
	);
	
	dec: decrypt port map(
		clk => clk,
		rst => rst,
		crtext => in_text,
		input_ready => in_ready,
		output_ready => out_ready_dec,
		pltext => out_decrypt
	);
	
	-- Multiplexer
	process (sel,clk)
	begin

  if rising_edge(clk) then
    case sel is
    -- Output Encrypt
    when '0' =>
      out_text <= out_encrypt;
		  out_ready <= out_ready_enc;
		
		-- Output Decrypt
    when others =>
		  out_text <= out_decrypt;
		  out_ready <= out_ready_dec;
		
	  end case;
	end if;
	end process;

end xtea_arc;