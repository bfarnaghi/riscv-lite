library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use IEEE.numeric_std.all;
--use WORK.DEFINES.all;

entity ALU is
	generic (
		input_size	:integer :=64 ;  
		output_size	:integer :=64
		);  
	port (
		RST 	: in 	std_logic;
		SLC 	: in 	std_logic_vector(3 downto 0);
		input_1	: in 	std_logic_vector(input_size - 1 downto 0);
		input_2	: in 	std_logic_vector(input_size - 1 downto 0);
		output 	: out	std_logic_vector(output_size - 1 downto 0));
end ALU;

architecture behavioral of ALU is

	begin
	
		output <= 	input_1 + input_2 	when SLC = "1111" else
				    input_2 	when SLC = "1110" else
					input_1 + input_2	when SLC = "0000" else
					input_1 - input_2	when SLC = "1000" else
					input_1 xor input_2	when SLC = "0100" or SLC = "1100" else
					to_StdLogicVector((to_bitvector(input_1)) sll (conv_integer(input_2(4 DOWNTO 0) )))	when SLC = "0001" else
					to_StdLogicVector((to_bitvector(input_1)) sra (conv_integer(input_2(4 DOWNTO 0) )))	when SLC = "0101" else
					(others =>'1')	when SLC = "0011" and input_1 >= input_2 else
					(others => '0')	when SLC = "0011" and input_1 < input_2 else
					(input_1 + input_2)	when SLC = "1011";

		--alu : process (SLC,RST)
	
			--begin

			--	if SLC = "1111" then
			--		output <= (others => '0');
				
				--elsif SLC = "0000" then                 
				--	output <= input_1 + input_2;
					
				--elsif SLC = "1000" then                 
					--output <= input_1 - input_2;
					
			--	elsif SLC = "0100" or SLC = "1100" then                 
				--	output <= input_1 xor input_2;	
					
				--elsif SLC = "1001" then                 
					 --input_1  input_2;
				--	 output <=	to_StdLogicVector((to_bitvector(input_1)) sll (conv_integer(input_2(4 DOWNTO 0) )));
				
				--elsif SLC = "0101" then
				--	output <=	to_StdLogicVector((to_bitvector(input_1)) sra (conv_integer(input_2(4 DOWNTO 0) )));
				
				--elsif SLC = "0011" then
					--if input_1 >= input_2 then

					--	output <= (others =>'1');
				--	else
					--	output <= (others => '0');
					--end if;
				--elsif SLC = "1011" then
					
				--	output <= input_1 + input_2 ;
				
					
			--	end if;
				
			--end process alu;

end behavioral;
