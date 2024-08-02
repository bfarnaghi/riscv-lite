library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
--use IEEE.numeric_std.all;
use WORK.DEFINES.all;



entity RISC_V_TB is

end RISC_V_TB;

architecture TB of RISC_V_TB is

	component DATA_MEM is
	  port (
		CLK     : in  std_logic;
		RSTn    : in  std_logic;
		WEN     : in  std_logic;
		REN     : in  std_logic;
		DIN     : in  std_logic_vector(MEM_SIZE - 1 downto 0);
		WADX    : in  std_logic_vector(9 downto 0);
		DOUT    : out std_logic_vector(MEM_SIZE - 1 downto 0));
	end component;
	
	component INS_MEM is
	  port (
		CLK     : in  std_logic;
		RSTn    : in  std_logic;
		WADX    : in  std_logic_vector(INS_ADDR - 1 downto 0);
		DOUT    : out std_logic_vector(INS_SIZE - 1 downto 0);
		READY	: out std_logic);
	end component;
	
	component RISC_V is
		generic (
			ins_address_size	:integer := INS_ADDR;  	-- PC Register Size
			ins_data_size		:integer := INS_SIZE;  	-- Number of bit in Instructions
			mem_address_size	:integer := MEM_ADDR;  	-- Size of Data memory address
			mem_data_size		:integer := MEM_SIZE  	-- Number of bit in Data Memory
		);  
		port (
			CLK	 	:in 	std_logic;	
			RSTn	 	:in 	std_logic;		
			INS_DATA	:in 	std_logic_vector(ins_data_size-1 DOWNTO 0);		--Data from Instruction Memory
			INS_ADDRS	:out 	std_logic_vector(ins_address_size-1 DOWNTO 0);	--Address to Instruction Memory
			MEM_DIN		:in 	std_logic_vector(mem_data_size-1 DOWNTO 0);		--Data from Data Memory
			MEM_DOUT	:out 	std_logic_vector(mem_data_size-1 DOWNTO 0);		--Data from Data Memory
			MEM_ADDRS	:out 	std_logic_vector(mem_address_size-1 DOWNTO 0);	--Address to Data Memory
			MEM_READ	:out	std_logic;
			MEM_WRITE	:out	std_logic
			);
	end component;
	
	signal CLK:				std_logic := '0';	
	signal CLKM:			std_logic := '0';
	signal RSTn:			std_logic := '0';
	signal MEM_R:			std_logic := '0';
	signal MEM_W:	    	std_logic := '0';
	signal RDY:				std_logic := '0';
	signal START:			std_logic := '1';
	signal MEM_ADDRESS :	std_logic_vector(MEM_ADDR -1 downto 0):=(others=>'0');	
	signal MEM_DIN_TB:		std_logic_vector(MEM_SIZE - 1 DOWNTO 0):=(others=>'0');
	signal MEM_DOUT_TB:		std_logic_vector(MEM_SIZE - 1 DOWNTO 0):=(others=>'0');
	signal INS_ADDRESS :	std_logic_vector(PC_REG - 1 DOWNTO 0):=(others=>'0');
	signal INS_DOUT:		std_logic_vector(INS_SIZE - 1 DOWNTO 0):=(others=>'0');

	begin
	
		CLK 	<= not CLK 	after 5 ns;
		CLKM 	<= not CLKM after 5 ns;
		RSTn 	<= '1' when RDY='1' and CLK='1';
		
		-- Instruction Memory
		INS : INS_MEM port map (CLKM,
								RSTn, 
								INS_ADDRESS(9 downto 0),
								INS_DOUT,
								RDY);
		
		-- Data Memory
		DATA : DATA_MEM port map (	CLK => CLKM,
									RSTn => RSTn, 
									WEN => MEM_W,
									REN => MEM_R,
									DIN => MEM_DIN_TB,
									WADX =>  MEM_ADDRESS(9 downto 0),
									DOUT => MEM_DOUT_TB);
			
		-- RISC-V
		CORE: RISC_V port map ( CLK=> CLK,
								RSTn => RSTn,
								INS_DATA => INS_DOUT,
								INS_ADDRS => INS_ADDRESS(9 downto 0),
								MEM_DIN => MEM_DOUT_TB,
								MEM_DOUT => MEM_DIN_TB,
								MEM_ADDRS => MEM_ADDRESS,
								MEM_READ => MEM_R,
								MEM_WRITE => MEM_W);


end TB;
