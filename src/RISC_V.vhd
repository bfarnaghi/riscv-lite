library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use WORK.DEFINES.all;

entity RISC_V is
	generic (
		ins_address_size	:integer := INS_ADDR;  	-- PC Register Size
		ins_data_size		:integer := INS_SIZE;  	-- Number of bit in Instructions
		mem_address_size	:integer := MEM_ADDR;  	-- Size of Data memory address
		mem_data_size		:integer := MEM_SIZE  	-- Number of bit in Data Memory
		);  
	port (
	    CLK	 		:in 	std_logic;	
		RSTn	 	:in 	std_logic;		
		INS_DATA	:in 	std_logic_vector(ins_data_size-1 DOWNTO 0);		--Data from Instruction Memory
		INS_ADDRS	:out 	std_logic_vector(ins_address_size-1 DOWNTO 0);	--Address to Instruction Memory
		MEM_DIN		:in 	std_logic_vector(mem_data_size-1 DOWNTO 0);		--Data from Data Memory
		MEM_DOUT	:out 	std_logic_vector(mem_data_size-1 DOWNTO 0);		--Data from Data Memory
		MEM_ADDRS	:out 	std_logic_vector(mem_address_size-1 DOWNTO 0);	--Address to Data Memory
		MEM_READ	:out	std_logic;
		MEM_WRITE	:out	std_logic);
end RISC_V;

architecture RISC_V_arch of RISC_V is

-- Instruction Fetch components and signals
	signal	IF_MUX_IN_0	: std_logic_vector(PC_REG-1 DOWNTO 0);	-- PC+4
	signal	IF_MUX_IN_1	: std_logic_vector(PC_REG-1 DOWNTO 0);	-- Calculated Address for Jump
	signal	IF_PC4_OUT	: std_logic_vector(PC_REG-1 DOWNTO 0);	-- Next Instruction Request
	signal	IF_MUX_SEL	: std_logic;	-- Instruction Address Select
	signal	IF_PC_OUT	: std_logic_vector(PC_REG-1 DOWNTO 0);	-- PC Address
	
	--Program Counter
	component PC is
		generic (
		ins_address_size	:integer := PC_REG  -- PC Register Size
		);  
	port (
		EN	: in 	std_logic;
		CLK : in 	std_logic;
		RST : in 	std_logic;
		AIN	: in 	std_logic_vector(PC_REG - 1 downto 0);
		AOUT: out	std_logic_vector(PC_REG - 1 downto 0)	
		);
	end component PC;

-- Decode stage components and signals
	signal	DE_INS_IN	: std_logic_vector(ins_data_size-1 DOWNTO 0);		-- Instruction incoming from Fetch
	signal	DE_PC_IN	: std_logic_vector(PC_REG-1 DOWNTO 0);	-- PC incoming from Fetch
	signal	DE_PC4_IN	: std_logic_vector(PC_REG-1 DOWNTO 0);	-- PC+4 incoming from Fetch
	
	component HAZARD_DETECTION is
		port(   MEM : IN std_logic;
				BRN : IN std_logic;
				RS_DEC : IN std_logic_vector(9 downto 0);
				RD_EX : IN std_logic_vector(4 downto 0);
				MUXO : OUT std_logic;
				PC_EN : OUT std_logic;
				IF_DE : OUT std_logic);
	end component HAZARD_DETECTION;
	
	component control_unit is
		port(   INSTRUCTION : IN std_logic_vector(31 downto 0);
				BRN : out std_logic_vector(1 downto 0);
				CW : out std_logic_vector(CW_SIZE-1 downto 0); --(0-3)aluop,  (4) EX_M-en , (5-6) RD_RW mem, (7) M_WB-en,    (8) RW of RF, (9) data from mem=1 or from alu=0 , 
				RFDR2 : out std_logic;                  -- (10) mux for pc+4 , (11) mux for imm or op2, (12) mux for giving 0 as second op in alu,
				RFDR1 : out std_logic;
				RFEN : out std_logic;
				FMUX : out std_logic);
	end component control_unit;
	
	component Immidiate_Gen is
		port (
			INPUT	: in 	std_logic_vector(31 downto 0);
			OUTPUT	: out	std_logic_vector(63 downto 0)
			);
	end component Immidiate_Gen;
	
	component RF is
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
	end component RF;
	
	component EQ is
		port (
			BRN	: in 	std_logic_vector(1 downto 0);
			RS1	: in 	std_logic_vector(63 downto 0);
			RS2  : in	std_logic_vector(63 downto 0);
			EQO : out   std_logic	
			);
	end component EQ;

	signal	DE_CW_OUT	: std_logic_vector(CW_SIZE-1 DOWNTO 0);	-- Control word output to next stage
	signal	DE_RD1_DATA	: std_logic_vector(63 DOWNTO 0);	-- Data1 incoming from RF
	signal	DE_RD2_DATA	: std_logic_vector(63 DOWNTO 0);	-- Data2 incoming from RF
	signal	DE_RD1_SUM	: std_logic_vector(63 DOWNTO 0);	-- 
	signal	DE_IMM_GEN	: std_logic_vector(63 DOWNTO 0);	-- Immidiate extented to 64 bit
	signal  DE_CW_RFRD1 : std_logic;
	signal  DE_CW_RFRD2 : std_logic;
	signal  DE_CW_RFEN  : std_logic;
	signal  DE_CW_RFRW  : std_logic;
	signal  DE_INS_RD	: std_logic_vector(4 DOWNTO 0);	-- Destination address from Instruction
	signal  DE_INS_RS	: std_logic_vector(9 DOWNTO 0);	-- Sources addresses from Instruction
	signal  DE_CU_CW	: std_logic_vector(CW_SIZE-1 DOWNTO 0);	-- Control word output from control unit
	signal  DE_CU_FMUX	: std_logic;
	signal  DE_CU_BRN	: std_logic;
	signal  DE_EQ_OUT	: std_logic;
	signal  DE_EQ_BRN_IN: std_logic_vector(1 downto 0);
	signal  DE_CW_SEL	: std_logic;
	signal  DE_HZ_IF	: std_logic;
	signal  DE_HZ_PC	: std_logic;
	signal	DE_SUM_WITH_PC_OUT : std_logic_vector(63 downto 0);

-- EXECUTION stage components and signals

	signal	EX_PC_PLUS_4 		: std_logic_vector(63 downto 0);
	signal	EX_READ_DATA1_FROM_RF : std_logic_vector(63 downto 0);
	signal	EX_READ_DATA2_FROM_RF : std_logic_vector(63 downto 0);
	signal	EX_IMM_GENERATE_IN	: std_logic_vector (63 downto 0);
	signal	EX_PC_IN			: std_logic_vector(63 downto 0);
	signal	EX_RD_ADDR			: std_logic_vector(4 downto 0);
	signal	EX_RS_ADDR			: std_logic_vector(9 downto 0);
	signal  EX_BRN : std_logic_vector(1 downto 0);
	signal	EX_RFRD2			: std_logic;
	signal	EX_RFRD1			: std_logic;
	signal	EX_MEM			: std_logic;  --signal to hazard detaction
	signal	EX_CW_IN : std_logic_vector(11 downto 0);
	
	signal	EX_ALU_OUT	: std_logic_vector(63 DOWNTO 0);	-- alu out put
	signal	EX_ALU_IN1	:std_logic_vector(63 downto 0);		--alu inputs
	signal	EX_ALU_IN2	:std_logic_vector(63 downto 0);
		
	signal	EX_2ND_STAGE_MUX1_IN1 : std_logic_vector(63 downto 0); -- mux with fw select signal inputs
	signal	EX_2ND_STAGE_MUX2_IN1 : std_logic_vector(63 downto 0);
	signal	EX_2ND_STAGE_MUX2 : std_logic_vector(2 downto 0);
	signal	EX_FW_MUXA	: std_logic_vector(1 downto 0);		-- ctrl signals from fw
	signal	EX_FW_MUXB	: std_logic_vector(1 downto 0);	
	
	
	component FW is
		port ( 
			RSTn: in std_logic;
			RS_ADD:	in std_logic_vector (9 downto 0);
			RFRD1: 		in std_logic;
			RFRD2: 		in std_logic;
			RD_MEM: 	in std_logic_vector (4 downto 0);
			WB_MEM: 	in std_logic;
			RD_WB: 		in std_logic_vector (4 downto 0);
			WB_WB:		in std_logic;
			MUXA: 		out std_logic_vector(1 downto 0);
			MUXB: 		out std_logic_vector(1 downto 0));
	end component FW;

	component ALU is
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
	end component ALU;

-- MEM stage components and signals

	signal MEM_ALU_IN : std_logic_vector(63 DOWNTO 0);
	signal MEM_CW_IN  : std_logic_vector(4 downto 0);
	signal MEM_RD_ADDR : std_logic_vector(4 downto 0);
	signal MEM_READ_DATA2_FROM_RF : std_logic_vector(63 downto 0);


-- WB stage components and signals

	signal WB_MUX_OUT : std_logic_vector(63 DOWNTO 0);
	signal WB_CW_IN  : std_logic_vector( 1 downto 0);
	signal WB_RD_ADDR : std_logic_vector(4 downto 0);
	signal WB_ALU_IN : std_logic_vector(63 DOWNTO 0);
	signal WB_MEM_OUT : std_logic_vector(63 DOWNTO 0);
	
	begin
	
	---------------------------------------------------------------------------------------------------------------
	-- First Stage : Instruction Fetch
	---------------------------------------------------------------------------------------------------------------
		IF_MUX_SEL <= DE_CU_FMUX or DE_EQ_OUT ;
	    IF_PC_OUT <= IF_MUX_IN_0 when IF_MUX_SEL = '0' and CLK='1' else IF_MUX_IN_1 when CLK='1';
		
		RISCV_PC: PC 	port map(
						EN 		=>	DE_HZ_PC,
						CLK		=>	CLK,
						RST		=>	RSTn,
						AIN		=>	IF_PC4_OUT,	
						AOUT	=>	IF_MUX_IN_0);
						
		IF_PC4_OUT	<=	IF_PC_OUT + 4 when RSTn='1' else (Others=>'0');
		IF_MUX_IN_1 <=	DE_SUM_WITH_PC_OUT;
		
		INS_ADDRS	<=	IF_PC_OUT (INS_ADDR-1 downto 0) when RSTn='1';
		
		INS_FETCH: process (CLK, RSTn,DE_HZ_IF)
			begin
				if  RSTn='0' then
					DE_INS_IN 	<=	(others =>'0');
					DE_PC_IN 	<=	(others =>'0');
					DE_PC4_IN 	<=	(others =>'0');
				elsif CLK'event and CLK = '1' and DE_HZ_IF='1' then
					DE_INS_IN 	<= 	INS_DATA;
					DE_PC_IN 	<=	IF_PC_OUT;
					DE_PC4_IN 	<=	IF_PC4_OUT;
				end if;
			end process;

	---------------------------------------------------------------------------------------------------------------
	-- Second Stage : Decode Instruction
	---------------------------------------------------------------------------------------------------------------
	
		RISCV_HAZARD : HAZARD_DETECTION port map (
												MEM => EX_MEM,
												BRN => DE_EQ_BRN_IN(0),
												RS_DEC => DE_INS_RS,
												RD_EX => EX_RD_ADDR,
												MUXO => DE_CW_SEL,
												PC_EN => DE_HZ_PC,
												IF_DE => DE_HZ_IF
												);
		
		RISCV_CU : control_unit port map (
										INSTRUCTION => DE_INS_IN,
										BRN => DE_EQ_BRN_IN,
										CW => DE_CU_CW,
										RFDR2 => DE_CW_RFRD2,   
										RFDR1 =>DE_CW_RFRD1,
										RFEN => DE_CW_RFEN,
										FMUX => DE_CU_FMUX
										);
										
		RISCV_RF : RF port map (
								CLK => CLK,
								RST => RSTn,
								EN =>  DE_CW_RFEN,
								RD1 => DE_CW_RFRD1,
								RD2 => DE_CW_RFRD2,
								WR =>  WB_CW_IN(0),
								ADD_WR => WB_RD_ADDR,
								ADD_R1 => DE_INS_IN (19 downto 15),
								ADD_R2 => DE_INS_IN (24 downto 20),
								D_IN => WB_MUX_OUT,
								DO_1 => DE_RD1_DATA,
								DO_2 => DE_RD2_DATA
								);
						
		RISCV_IMMG : Immidiate_Gen port map(
											INPUT	=> DE_INS_IN,
											OUTPUT	=> DE_IMM_GEN
											);
											
		DE_CW_OUT <= DE_CU_CW when DE_CW_SEL = '1' else "1000000100110";
		
		RISCV_EQ: EQ port map (
			BRN=> DE_EQ_BRN_IN,
			RS1 => DE_RD1_DATA,
			RS2 => DE_RD2_DATA,
			EQO => DE_EQ_OUT
		);		
		DE_INS_RS <= DE_INS_IN (24 downto 15);
		DE_INS_RD <= DE_INS_IN (11 downto 7);
		DE_RD1_SUM <= DE_RD1_DATA when DE_CW_RFRD1='1' else (Others => '0');
		DE_SUM_WITH_PC_OUT <= (DE_IMM_GEN(63 downto 1) & '0') + DE_RD1_SUM when DE_EQ_BRN_IN="11" and DE_CW_RFRD1='1' else DE_PC_IN + (DE_IMM_GEN(63 downto 1) & '0') + DE_RD1_SUM when DE_EQ_BRN_IN="11" else DE_PC_IN + (DE_IMM_GEN(63 downto 1) & '0');

		DE_EXE: process (CLK, RSTn)
			begin
				if  RSTn='0' then
					EX_CW_IN	<= 	(others =>'0');
					EX_PC_PLUS_4	<=	(others =>'0');
					EX_READ_DATA1_FROM_RF 	<=	(others =>'0');
					EX_READ_DATA2_FROM_RF 	<=	(others =>'0');
					EX_IMM_GENERATE_IN	<=	(others =>'0');
					EX_PC_IN	<=	(others =>'0');
					EX_RFRD1	<=	'0';
					EX_RFRD2	<=	'0';
					EX_RS_ADDR	<=	(others =>'0');
					EX_RD_ADDR	<=	(others =>'0');
				elsif CLK'event and CLK = '1' then --and DE_CW_OUT(CW_SIZE-1)='1'
					EX_CW_IN	<= 	DE_CW_OUT(CW_SIZE-2 downto 0);
					EX_PC_PLUS_4	<=	DE_PC4_IN;
					EX_READ_DATA1_FROM_RF 	<=	DE_RD1_DATA;
					EX_READ_DATA2_FROM_RF 	<=	DE_RD2_DATA ;
					EX_IMM_GENERATE_IN	<=	DE_IMM_GEN;
					EX_PC_IN	<=	DE_PC_IN;
					EX_RFRD1	<=	DE_CW_RFRD1;
					EX_RFRD2	<=	DE_CW_RFRD2;
					EX_RS_ADDR	<=	DE_INS_RS;
					EX_RD_ADDR	<=	DE_INS_RD;
					EX_BRN <=  DE_EQ_BRN_IN;
				end if;
			end process;
			
	---------------------------------------------------------------------------------------------------------------
	-- third Stage : EXECUTION Instruction
	---------------------------------------------------------------------------------------------------------------

		EX_2ND_STAGE_MUX1_IN1 <= EX_PC_PLUS_4  when EX_CW_IN(11)='0'  else EX_READ_DATA1_FROM_RF;
		EX_2ND_STAGE_MUX2_IN1 <= (Others=>'0') when EX_BRN="11" else EX_IMM_GENERATE_IN when EX_CW_IN(10)= '0' else EX_READ_DATA2_FROM_RF;   --
		EX_ALU_IN1 <= EX_2ND_STAGE_MUX1_IN1 when EX_FW_MUXA = "00" else  MEM_ALU_IN when  EX_FW_MUXA = "01" else WB_MUX_OUT;
		EX_ALU_IN2 <= EX_2ND_STAGE_MUX2_IN1 when EX_FW_MUXB = "00" else EX_IMM_GENERATE_IN when EX_FW_MUXB = "01" else WB_MUX_OUT;

		EX_MEM <= EX_CW_IN(4);

		RISCV_ALU : ALU port map(RST => RSTn,
								SLC => EX_CW_IN(9 downto 6),	
								input_1	=> EX_ALU_IN1,
								input_2	=> EX_ALU_IN2,
								output 	=> EX_ALU_OUT );

		RISCV_FORWARDING_UNIT : FW port map(RSTn => RSTn,
											RS_ADD => EX_RS_ADDR(9 downto 0),
											RFRD1 => EX_RFRD1,		
											RFRD2 => EX_RFRD2,		
											RD_MEM => MEM_RD_ADDR,	
											WB_MEM => MEM_CW_IN(0),	
											RD_WB => WB_RD_ADDR,		
											WB_WB => WB_CW_IN(0),
											MUXA => EX_FW_MUXA,
											MUXB => EX_FW_MUXB );


		EXE_MEM: process (CLK, RSTn)
					begin
						if  RSTn='0' then		
							MEM_CW_IN <=  (others =>'0');
							MEM_READ_DATA2_FROM_RF <= (others =>'0');
							MEM_ALU_IN <= (others =>'0');
							MEM_RD_ADDR <= (others =>'0');	
						elsif CLK'event and CLK = '1'  then --and EX_CW_IN(5)='1'
							MEM_CW_IN <=  EX_CW_IN(4 downto 0);
							MEM_READ_DATA2_FROM_RF <= EX_READ_DATA2_FROM_RF;
							MEM_ALU_IN <= EX_ALU_OUT;
							MEM_RD_ADDR <= EX_RD_ADDR;	
																				
						end if;
				end process;
								

	---------------------------------------------------------------------------------------------------------------
	-- fourth Stage : Memory Instruction
	---------------------------------------------------------------------------------------------------------------
		
		MEM_ADDRS <= MEM_ALU_IN (MEM_ADDR-1 downto 0);
		
		MEM_DOUT <= MEM_READ_DATA2_FROM_RF;
		
		MEM_READ <= '1' when MEM_CW_IN(4)='1' else '0';
		MEM_WRITE<= '1' when MEM_CW_IN(3)='1' else '0';

		MEM_WB : process (CLK, RSTn)
					begin
						if  RSTn='0' then
			
							WB_CW_IN <= (others =>'0');
							WB_ALU_IN <= (others =>'0');
							WB_RD_ADDR <= (others =>'0');
							WB_MEM_OUT <= (others =>'0');
						elsif CLK'event and CLK = '1' then -- and MEM_CW_IN(2)='1'

							WB_CW_IN <= MEM_CW_IN (1 downto 0);
							WB_ALU_IN <= MEM_ALU_IN;
							WB_RD_ADDR <= MEM_RD_ADDR;
							WB_MEM_OUT <= MEM_DIN;
							
																
						end if;
				end process;
			
	---------------------------------------------------------------------------------------------------------------
	-- fifth Stage : WB Instruction
	---------------------------------------------------------------------------------------------------------------			

	WB_MUX_OUT <= WB_ALU_IN when WB_CW_IN(1)='0' else WB_MEM_OUT;
		
	
		
end RISC_V_arch;
