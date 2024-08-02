library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use WORK.DEFINES.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity DATA_MEM is
  port (
    CLK     : in  std_logic;
    RSTn    : in  std_logic;
    WEN     : in  std_logic;
	REN     : in  std_logic;
    DIN     : in  std_logic_vector(MEM_SIZE-1 downto 0);
    WADX    : in  std_logic_vector(9 downto 0);
    DOUT    : out std_logic_vector(MEM_SIZE-1 downto 0));
end DATA_MEM;

architecture beh of DATA_MEM is

  component sram_32_1024_freepdk45 is
    port (
      clk0 : in std_logic;
      csb0 : in std_logic;
      web0 : in std_logic;
      addr0 : in std_logic_vector(9 downto 0);
      din0  : in std_logic_vector(31 downto 0);
      dout0 : out std_logic_vector(31 downto 0));
  end component;

  signal CS:std_logic:='1';	
  signal WE:std_logic:='1';
  signal output:std_logic_vector(MEM_SIZE-1 downto 0);
  signal input:std_logic_vector(MEM_SIZE-1 downto 0);
  signal data_file:std_logic_vector(MEM_SIZE-1 downto 0);
  signal index:integer:=0;
  signal WE_i:std_logic:='0';
  signal RDY:std_logic:='0';
  signal x		: unsigned (9 downto 0):=(Others => '0');
  signal addr : std_logic_vector (9 downto 0):=(Others => '0');
  signal addrb : std_logic_vector (9 downto 0):=(Others => '0');
  signal addrb2 : std_logic_vector (9 downto 0):=(Others => '0');

begin  -- architecture beh

	WRITE_DATA: process (RSTn,CLK)
			file fp: text open READ_MODE is "./data.txt";
			variable f_line : line; 
			variable data : std_logic_vector(MEM_SIZE-1 downto 0);
				begin  
					if RSTn = '1' then
						index <= 0;
						WE_i <= '0';
						RDY <= '1';
					elsif CLK'event and CLK = '1' then
						if not endfile(fp) then
							WE_i <= '1' ;
							readline(fp,f_line);
							hread(f_line,data);
							x <= conv_unsigned (index,x'length);
							data_file <= data;
							index <= index + 4;
						else 
							RDY <='1';
						end if;
					end if;
			end process WRITE_DATA;
	
	CS <= '0' when (WEN or REN or WE_i)='1' else '1';
	WE <= not(WEN or WE_i) ;

	addr <= std_logic_vector(x);
    addrb <= addr when RSTn='0' else WADX;
	addrb2 <= '0' & addrb(8 downto 0);

    input <= data_file when RDY='0' else DIN;
	DOUT <= output;

    data_block10 : sram_32_1024_freepdk45
    port map (
      clk0  => CLK,
      csb0  => CS,
      web0  => WE,
      addr0 => addrb2(9 downto 0),
      din0  => input(31 downto 0),
      dout0 => output(31 downto 0));

    data_block11 : sram_32_1024_freepdk45
    port map (
      clk0  => CLK,
      csb0  => CS,
      web0  => WE,
      addr0 => addrb2(9 downto 0),
      din0  => input(63 downto 32),
      dout0 => output(63 downto 32));

  
end beh;
