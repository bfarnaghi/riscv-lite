library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use WORK.DEFINES.all;

entity EQ is
	port (
		BRN	: in 	std_logic_vector(1 downto 0);
		RS1	: in 	std_logic_vector(63 downto 0);
		RS2  : in	std_logic_vector(63 downto 0);
		EQO : out   std_logic	
		);
end EQ;

architecture beh_eq of EQ is

begin

	process (BRN,RS1,RS2)
		begin
			if (RS1 >= RS2) and (BRN="01") then
				EQO <= '1';
			elsif (RS1 /= RS2) and (BRN="10") then
				EQO <= '1';
			elsif (BRN="11") then
				EQO <= '1';
			else
				EQO <= '0';
			end if;
	end process;

end beh_eq;
