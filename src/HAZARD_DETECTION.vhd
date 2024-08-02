library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity HAZARD_DETECTION is
    port(   MEM : IN std_logic;
            BRN : IN std_logic;
            RS_DEC : IN std_logic_vector(9 downto 0);
            RD_EX : IN std_logic_vector(4 downto 0);
            MUXO : OUT std_logic;
            PC_EN : OUT std_logic;
            IF_DE : OUT std_logic);
end HAZARD_DETECTION;

architecture behavioral of HAZARD_DETECTION is

	signal hz:std_logic;
	signal s1_check:std_logic;
	signal s2_check:std_logic;
	signal check:std_logic;

begin

	hz <= MEM ;--or BRN;
	s1_check <= '1' when RD_EX = RS_DEC(9 downto 5) else '0';
	s2_check <= '1' when RD_EX = RS_DEC(4 downto 0) else '0';
	check <= s1_check  or s2_check ;

	MUXO <= '0' when hz='1' and check='1' else '1';
	PC_EN <= '0' when hz='1' and check='1' else '1';
	IF_DE <= '0' when hz='1' and check='1' else '1';

  --  process(RS_DEC,MEM) begin
      --  if MEM='1' or BRN='1' then
        --    if RD_EX = RS_DEC(9 downto 5) or RD_EX = RS_DEC(4 downto 0) then
         --       MUXO <= '0';
        --        PC_EN <= '0';
        --        IF_DE <= '0';
        --    end if;
        --elsif BRN='1' then
            --MUXO <= '0';
            --PC_EN <= '1';
            --IF_DE <= '1';
        
      --  else 
      --      MUXO <= '1';
      --      PC_EN <= '1';
      --      IF_DE <= '1';
        --end if;
    
    --end process;
end architecture;
