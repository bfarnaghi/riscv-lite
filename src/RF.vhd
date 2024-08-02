library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use WORK.DEFINES.all;

entity RF is

	generic(
		NUM_RF		:integer:=	RF_SIZE;
		NBIT_RF		:integer:=	RF_BIT_SIZE;
		ADD_RF		:integer:=	RF_ADD_SIZE 	--(Log2 #RF_SIZE(32) = 5)
	);

	port ( 
		CLK: 		IN std_logic;
        RST: 		IN std_logic;
		EN: 		IN std_logic;
		RD1: 		IN std_logic;
		RD2: 		IN std_logic;
		WR: 		IN std_logic;
		ADD_WR: 	IN std_logic_vector(ADD_RF-1 downto 0);
		ADD_R1: 	IN std_logic_vector(ADD_RF-1 downto 0);
		ADD_R2: 	IN std_logic_vector(ADD_RF-1 downto 0);
		D_IN: 		IN std_logic_vector(NBIT_RF-1 downto 0);
        DO_1: 		OUT std_logic_vector(NBIT_RF-1 downto 0);
		DO_2: 		OUT std_logic_vector(NBIT_RF-1 downto 0)
		);
end RF;

architecture RF_arch of RF is

	subtype R_ADDR is natural range 0 to NUM_RF-1;
	type 	REG_TYPE is array(R_ADDR) of std_logic_vector(NBIT_RF-1  downto 0);
	signal 	REGISTERS : REG_TYPE;

	begin
		process (CLK,RST,EN,RD1,RD2,WR,ADD_R1,ADD_R2,D_IN,ADD_WR)
		
			begin
			
				if (RST='0') then 
					DO_1 		<= 	(others =>'0');
					DO_2 		<=	(others =>'0');
					REGISTERS(conv_integer(0)) <= (Others => '0');
					REGISTERS(conv_integer(1)) <= (Others => '0');
					REGISTERS(conv_integer(2)) <= (Others => '0');
					REGISTERS(conv_integer(3)) <= conv_std_logic_vector(16#10008000#,64);
					REGISTERS(conv_integer(4)) <= (Others => '0');
					REGISTERS(conv_integer(5)) <= (Others => '0');
					REGISTERS(conv_integer(6)) <= (Others => '0');
					REGISTERS(conv_integer(7)) <= (Others => '0');
					REGISTERS(conv_integer(8)) <= (Others => '0');
					REGISTERS(conv_integer(9)) <= (Others => '0');
					REGISTERS(conv_integer(10)) <= (Others => '0');
					REGISTERS(conv_integer(11)) <= (Others => '0');
					REGISTERS(conv_integer(12)) <= (Others => '0');
					REGISTERS(conv_integer(13)) <= (Others => '0');
					REGISTERS(conv_integer(14)) <= (Others => '0');
					REGISTERS(conv_integer(15)) <= (Others => '0');
					REGISTERS(conv_integer(16)) <= (Others => '0');
					REGISTERS(conv_integer(17)) <= (Others => '0');
					REGISTERS(conv_integer(18)) <= (Others => '0');
					REGISTERS(conv_integer(19)) <= (Others => '0');
					REGISTERS(conv_integer(20)) <= (Others => '0');
					REGISTERS(conv_integer(21)) <= (Others => '0');
					REGISTERS(conv_integer(22)) <= (Others => '0');
					REGISTERS(conv_integer(23)) <= (Others => '0');
					REGISTERS(conv_integer(24)) <= (Others => '0');
					REGISTERS(conv_integer(25)) <= (Others => '0');
					REGISTERS(conv_integer(26)) <= (Others => '0');
					REGISTERS(conv_integer(27)) <= (Others => '0');
					REGISTERS(conv_integer(28)) <= (Others => '0');
					REGISTERS(conv_integer(29)) <= (Others => '0');
					REGISTERS(conv_integer(30)) <= (Others => '0');
					REGISTERS(conv_integer(31)) <= (Others => '0');
				elsif EN='1' then 

					if( RD1 ='1') then
						if (conv_integer(unsigned(ADD_R1))=0) then
							DO_1 <= (others =>'0');
						else
							DO_1 <= REGISTERS(conv_integer(unsigned(ADD_R1)));
						end if;
					else
						DO_1 <= (others =>'0');	
					end if;
					
					if( RD2 ='1') then
						if (conv_integer(unsigned(ADD_R2))=0) then
							DO_2 <= (others =>'0');
						else
							DO_2 <= REGISTERS(conv_integer(unsigned(ADD_R2)));
						end if;
					else
						DO_2 <= (others =>'0');	
					end if;

					if( WR ='1') then
						if (conv_integer(unsigned(ADD_WR))=0) then
							REGISTERS(conv_integer(unsigned(ADD_WR))) <= (others =>'0');
						else
							REGISTERS(conv_integer(unsigned(ADD_WR))) <= D_IN;
						end if;
					end if;

				end if;
		end process;
end RF_arch;
