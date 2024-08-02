library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use WORK.DEFINES.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity INS_MEM is
  port (
    CLK     : in  std_logic;
    RSTn    : in  std_logic;
    WADX    : in  std_logic_vector(9 downto 0);
    DOUT    : out std_logic_vector(INS_SIZE-1 downto 0);
	READY	: out std_logic
	);
end INS_MEM;

architecture beh of INS_MEM is

  component sram_32_1024_freepdk45 is
    port (
      clk0 : in std_logic;
      csb0 : in std_logic;
      web0 : in std_logic;
      addr0 : in std_logic_vector(9 downto 0);
      din0  : in std_logic_vector(INS_SIZE-1 downto 0);
      dout0 : out std_logic_vector(INS_SIZE-1 downto 0));
  end component;
   
  signal CS:std_logic;	
  signal RDY:std_logic:='0';
  signal web:std_logic:='0';
  signal DIN:std_logic_vector(INS_SIZE-1 downto 0);
  signal index:integer:=0;
  signal x		: unsigned (9 downto 0):=(Others => '0');
  signal addr : std_logic_vector (9 downto 0):=(Others => '0');
  signal addrb : std_logic_vector (9 downto 0):=(Others => '0');

begin  -- architecture beh


	READ_PRG: process (RSTn,CLK)
			file fp: text open READ_MODE is "./main.txt";
			variable f_line : line; 
			variable data : std_logic_vector(INS_SIZE-1 downto 0);
				begin  
					if RSTn = '1' then
						index <= 0;
						web <= '1' ;
					elsif CLK'event and CLK = '1' then
						if not endfile(fp) then
							web <= '0' ;
							readline(fp,f_line);
							hread(f_line,data);
							x <= conv_unsigned (index,x'length);
							DIN <= data;
							
							index <= index + 4;
						else 
							report "End of the file";
							web <= '1' ;
							RDY <= '1';
						end if;
					end if;
			end process READ_PRG;

  READY <= RDY;

      CS <= '0';
  addr <= std_logic_vector(x);
  addrb <= addr when RSTn='0' else WADX;	
  
  ins_block : sram_32_1024_freepdk45
    port map (
      clk0  => CLK,
      csb0  => CS,
      web0  => web,
      addr0 => addrb,
      din0  => DIN,
      dout0 => DOUT);
  
end beh;
