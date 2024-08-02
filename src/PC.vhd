library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use WORK.DEFINES.all;

entity PC is
	generic (
		ins_address_size	:integer := PC_REG  -- PC Register Size
		);  
	port (
		EN	: in 	std_logic;
		CLK : in 	std_logic;
		RST : in 	std_logic;
		AIN	: in 	std_logic_vector(ins_address_size - 1 downto 0);
		AOUT: out	std_logic_vector(ins_address_size - 1 downto 0)	
		);
end PC;

architecture behavioral_pc of PC is
	
	begin
	
		P_C : process (CLK, RST,AIN)
	
			begin	
				if RST = '0' then                 
					AOUT <= (Others=>'0');
				elsif CLK'event and CLK = '1' then 
					if (EN = '1') then
						AOUT <= AIN;
					end if;
				end if;
				
			end process P_C;

end behavioral_pc;
