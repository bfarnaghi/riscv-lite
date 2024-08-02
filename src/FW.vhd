------------------------------- Forwarding Unit ------------------------------
------------------------------------------------------------------------------
-- We use Forwarding for avoiding some stalls in pipline due to Data Hazard --
-- For this reason we transfer addresses of source registers (RS1 and RS2)  --
-- From Decode stage to Execution stage through DE_EX pipline register      --
-- Also the the address of destination register should transfer through		--
-- pipeline registers to the last stage. Then we can check two possible 	--
-- Data Hazarad : 1) When RD_MEM = RS1 or RD_MEM = RS2 -> Forward from ALU  --
--				: 2) When RD_WB  = RS1 or RD_WB  = RS2 -> Forward from WB	--
-- Also we should check three conditions : 	1) RD_MEM != 0					--
--											2) WB of Control word = 1		--
--											3) RFRD1 or RFRD2 = 1			--
-- The forwarded data will be available throug two MUXs in ALU inputs		--
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use WORK.DEFINES.all;

entity FW is
	port ( 
		RSTn:	in	std_logic;
		RS_ADD:	in std_logic_vector (9 downto 0);
        RFRD1: 		in std_logic;
		RFRD2: 		in std_logic;
		RD_MEM: 	in std_logic_vector (4 downto 0);
		WB_MEM: 	in std_logic;
		RD_WB: 		in std_logic_vector (4 downto 0);
		WB_WB:		in std_logic;
        MUXA: 		out std_logic_vector(1 downto 0);
		MUXB: 		out std_logic_vector(1 downto 0)
		);
end FW;

architecture behavioral of FW is

	signal rd_rs1_mem,rd_rs1_wb,rd_rs2_mem,rd_rs2_wb: std_logic;
	signal RS1_ADD,RS2_ADD : std_logic_vector (4 downto 0);
	begin
	
		RS1_ADD <= RS_ADD(4 downto 0) when RSTn='1';
		RS2_ADD <= RS_ADD(9 downto 5) when RSTn='1';
	-- Check the equality of source addresses and destination address 
	-- in two stages, MEM and WB
	rd_rs1_mem 	<= 	'1' when RS1_ADD = RD_MEM else '0';
	rd_rs2_mem 	<= 	'1' when RS2_ADD = RD_MEM else '0';
	rd_rs1_wb  	<= 	'1' when RS1_ADD = RD_WB  else '0';
	rd_rs2_wb  	<= 	'1' when RS2_ADD = RD_WB  else '0';	
	
	-- Then add other conditions to change the select bits
	-- of MUXs in input of ALU
	MUXA	 	<= "01" when (rd_rs1_mem and RFRD1 and WB_MEM) ='1' else	-- Forward data from ALU output in MEM stage
				   "10" when (rd_rs1_wb  and RFRD1 and WB_WB) = '1'  else	-- Forward data from MUX's output in WB stage
				   "00";

	MUXB	 	<= "01" when (rd_rs2_mem and RFRD2 and WB_MEM) = '1' else   -- Forward data from ALU output in MEM stage
				   "10" when (rd_rs2_wb  and RFRD2 and WB_WB) = '1'  else	-- Forward data from MUX's output in WB stage
				   "00";

end behavioral;
