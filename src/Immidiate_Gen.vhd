library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity Immidiate_Gen is
	--generic (
	--	32	:integer :=INS_SIZE
		--SIZE_OUTPUT	:integer :=RF_BIT_SIZE
		--);  
	port (
		
		INPUT	: in 	std_logic_vector(31 downto 0);
		OUTPUT	: out	std_logic_vector(63 downto 0)
		);
end Immidiate_Gen;

architecture behavioral of Immidiate_Gen is

	begin
	
	 process (INPUT) begin
				
				if INPUT(6 downto 0) = "0010011" or INPUT(6 downto 0) = "0000011" then      -- I type          
					OUTPUT(11 downto 0) <= INPUT(31 downto 20);
					OUTPUT(63 downto 12) <= (others => INPUT(31));
				
				elsif INPUT(6 downto 0) = "1100111"    then   -- JALR          
					OUTPUT(11 downto 0) <= INPUT(31 downto 20);
					OUTPUT(63 downto 12) <= (others => INPUT(31));
	
				elsif INPUT(6 downto 0) = "0100011" then    -- S type
					OUTPUT(11 downto 0) <= INPUT(31 downto 25) & INPUT(11 downto 7);
					OUTPUT(63 downto 12) <= (others => INPUT(31));
					
				elsif INPUT(6 downto 0) = "1100011" or INPUT(6 downto 0) = "1100011" then    -- SB type
					OUTPUT(11 downto 0) <= INPUT(7) & INPUT(30 downto 25) & INPUT(11 downto 8) & '0';
					OUTPUT(63 downto 12) <= (others => INPUT(31));

				elsif INPUT(6 downto 0) = "1101111" then    -- UJ type
					OUTPUT(19 downto 0) <= INPUT(19 downto 12)& INPUT(20) & INPUT(30 downto 21) & '0';
					OUTPUT(63 downto 20) <= (others => INPUT(31));

				elsif INPUT(6 downto 0) = "0010111" or INPUT(6 downto 0) = "0110111" then    -- U type
					OUTPUT(31 downto 12) <= INPUT(31 downto 12);
					OUTPUT(63 downto 32) <= (others => INPUT(31));
					OUTPUT(11 downto 0) <= (others => '0');
				end if;
				
			end process;
			
	end behavioral;
