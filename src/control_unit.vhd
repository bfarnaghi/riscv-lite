library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
    port(   INSTRUCTION : IN std_logic_vector(31 downto 0);
            BRN : out std_logic_vector(1 downto 0);
            CW : out std_logic_vector(12 downto 0); --(0) DE_EX-en , (1-4)aluop,  (5) EX_M-en , (6-7) RD_RW mem, (8) M_WB-en,    (9) RW of RF, (10) data from mem=1 or from alu=0 , 
                                                     -- (11) mux for pc+4 , (12) mux for imm or op2,
           -- CONTROL : OUT std_logoc; -- for defining type of add and addi
            RFDR2 : out std_logic;                 
            RFDR1 : out std_logic;
            RFEN : out std_logic;
            FMUX : out std_logic);
end control_unit;

-- R_TYPE instruction opcode         0110011
-- I_TYPE instruction opcode         0010011
-- I_TYPE instruction opcode (lw)    0000011
-- S_TYPE instruction opcode (sw)    0100011
-- B_TYPE instruction opcode         1100011
-- U_TYPE instruction opcode (auipc) 0010111
-- U_TYPE instruction opcode (lui)   0110111
-- J_TYPE instruction opcode (jal)   1101111
-- J_TYPE instruction opcode (jalr)  1100111


architecture behavioral of control_unit is 


begin

    process (INSTRUCTION) begin
        case INSTRUCTION (6 downto 0) is
            
            --R_TYPE
            when "0110011" => 
                CW <=  "111" & INSTRUCTION(30) &	INSTRUCTION(14 downto 12) & "100101";
                BRN <= "00";
                RFDR2 <= '1';
                RFDR1 <= '1';
				RFEN <= '1';
                FMUX <= '0';
            
            --I_TYPE
            when "0010011" => 
                CW <=  "1100" & INSTRUCTION(14 downto 12) &	"100101";
                BRN <= "00";
                RFDR2 <= '0';
                RFDR1 <= '1';
				RFEN <= '1';
                FMUX <= '0';

            --I_TYPE lw
            when "0000011" => 
                CW <=  "1100000110111";  --& INSTRUCTION(14 downto 12);
                BRN <= "00";
                RFDR2 <= '0';
                RFDR1 <= '1';
				RFEN <= '1';
                FMUX <= '0';
            
            --S_TYPE sw
            when "0100011" => 
                CW <=  "1100000101100"; --  & INSTRUCTION(14 downto 12); 
                BRN <= "00";
                RFDR2 <= '1';
                RFDR1 <= '1';
				RFEN <= '1';
                FMUX <= '0';
            
            --B_TYPE
            when "1100011" => 
                if INSTRUCTION(14 downto 12)="001" then  --bne
                    CW <= "1111111100100"; --1111 alu cnt for 0+0 nop
                    BRN <= "10";
                    RFDR2 <= '1';
                    RFDR1 <= '1';
					RFEN <= '1';
                    FMUX <= '0'; --?

                elsif INSTRUCTION(14 downto 12) ="101" then  --bge

                    CW <= "1110011100100"; --define 0011 for checking grater or eq in alu
                    BRN <= "01";
                    RFDR2 <= '1';
                    RFDR1 <= '1';
					RFEN <= '1';
                    FMUX <= '0';
                
                end if;  
                    

            --U_TYPE auipc
            when "0010111" =>   --?????????????????????
                CW <= "1001011100101";  --1011 for adding (pc+4)-4 and imm
                BRN <= "00";
                RFDR2 <= '0';
                RFDR1 <= '0';
				RFEN <= '1';
                FMUX <= '0';
            
            --U_TYPE lui
            when "0110111" =>

                CW <= "1101110100101"; --1110 make op1 alu0 and add it to immidiate
				BRN <= "00";
                RFDR2 <= '0';
                RFDR1 <= '0';
                FMUX <= '0'; 
				RFEN <= '1';

            --J_TYPE jal
            when "1101111" => 

                CW <= "1001011100101";
				BRN <= "11";
                RFDR2 <= '0';
                RFDR1 <= '0';
                FMUX <= '1'; 
                RFEN <= '1';
            --J_TYPE jalr
            when "1100111" =>

                CW <= "1001011100101";
				BRN <= "11";
                RFDR2 <= '0';
                RFDR1 <= '1';
                FMUX <= '1';
				RFEN <= '1';

            when others =>
                CW <= "1111111100110";
				BRN <= "00";
                RFDR2 <= '0';
                RFDR1 <= '0';
                FMUX <= '0';
				RFEN <= '1';
        end case;
       
    end process;


end architecture;

