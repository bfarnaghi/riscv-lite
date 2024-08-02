library ieee;
use ieee.std_logic_1164.all;

package DEFINES is

	constant 	PC_REG 		: 	integer 	:=  64; -- PC Register Size (address of instruction memory)
	constant 	INS_SIZE 	: 	integer 	:=  32; -- Size of Instructions
	constant 	INS_ADDR 	: 	integer 	:=  10; -- 
	constant 	MEM_SIZE 	: 	integer 	:=  64; -- Number of bit in Data Memory
	constant 	MEM_ADDR 	: 	integer 	:=  40; -- Size of Data memory address
	constant 	RF_SIZE 	: 	integer 	:=  32; -- Size of General Registers
	constant 	RF_BIT_SIZE : 	integer 	:=  64; -- Number of bits of General Registers
	constant 	RF_ADD_SIZE : 	integer 	:=  5 ; -- Size of address bus of Register File (Log2 #RF_SIZE(32) = 5)
	constant 	CW_SIZE     : 	integer 	:=  13;
	
end DEFINES;
