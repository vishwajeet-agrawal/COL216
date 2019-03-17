----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/26/2019 02:40:53 PM
-- Design Name: 
-- Module Name: controller - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
        
entity controller is    
    Port (
        clock: in std_logic:='0';
        zflag: in std_logic:='0';
        executionstate: in std_logic_vector(3 downto 0):="000";
        instruction: in std_logic_vector(31 downto 0):=(others=>'0');
        Pw: out std_logic:='0'; 
        Rw: out std_logic:='0';
        Aw: out std_logic:='0';
        Bw: out std_logic:='0';
        Rew:out std_logic:='0';
        Mw: out std_logic:='0';
        Iw: out std_logic:='0';
        Rsrc: out std_logic:='0';
        Asrc1:out std_logic:='0';
        Asrc2:out std_logic_vector(1 downto 0):="00";
        Mr:out std_logic:='0';
        op: out std_logic:='0';
        carry: out std_logic:='0';
        flgset: out std_logic:='0';
        AluorMem: out std_logic_vector:="00"   
        
        );
end controller;
        
architecture Behavioral of controller is
type controlfsm is (fetch,decode,arith,mov,addr,brn,halt,res2RF,mem_wr,mem_rd,mem2RF);
signal controlstate: controlfsm:=fetch;
--type instr_class_type is (DP,DT, branch, halt,unknown);
--type i_decoded_type is (add, sub, cmp, mov, ldr, str, beq, bne, b, unknown);
--signal instr_class: instr_class_type;
--signal i_decoded: i_decoded_type;
--signal opcode: std_logic_vector(3 DOWNTO 0):= (others => '0');


begin   
--opcode <=instruction(24 downto 21);
--with instruction(31 downto 26) select instr_class <=
--    DP when "111000",
--    DT when "111001",
--    branch when "111010",
--    branch when "000010",
--    branch when "000110",
--    halt when "000000",
--    unknown when others;
--instr_class <=
--    DP <= when instruction(27 downto 26
--    DT <=
--    branch <= 
--    halt <=
--    unknown <=
--i_decoded <=
--    add when opcode="0100" and instr_class=DP else
--    sub when opcode="0010" and instr_class=DP else
--    cmp when opcode="1010" and instr_class=DP else
--    mov when opcode="1101" and instr_class=DP else
--    ldr when (opcode="1100" or opcode="1000") and instruction(25)='0' and instruction(20)='1' and instr_class=DT else
--    str when (opcode="1100" or opcode="1000") and instruction(25)='0' and instruction(20)='0' and instr_class=DT else
--    beq when instruction(31 DOWNTO 28)="0000" and instr_class=branch else
--    bne when instruction(31 DOWNTO 28)="0001" and instr_class=branch else
--    b   when instruction(31 DOWNTO 28)="1110" and instr_class=branch else
--    unknown;
Iw <= '1' when controlstate = fetch else '0';
Pw <= '1' when controlstate = fetch or controlstate = brn;
Mw <= '1' when controlstate = mem_wr else '0';
Mr <= '1' when controlstate = mem_rd else '0';
AluorMem <= "00" when controlstate = mov or controlstate = fetch or controlstate = decode 
        else "01" when controlstate = arith or controlstate = res2RF 
        else "10" when controlstate = mem_rd or controlstate = mem2RF or controlstate = addr
        else "11"; 
Aw <= '1' when controlstate = decode else '0';
Bw  <= '1' when controlstate = decode else '0';
Rw <= '1' when controlstate = mem2RF or controlstate = res2RF or controlstate = mov else '0';
Rsrc <= '1' when instruction(27 downto 26) = "01" and instruction(20)='0' else '0';
Asrc1 <= '0' when controlstate = brn else '1';
Asrc2 <= "00" when controlstate = arith and instruction(27 downto 25) = "000"
    else "01" when controlstate = fetch
    else "10" when (controlstate = addr and instruction(27 downto 25) = "010" )
                   or (controlstate = arith and instruction(27 downto 25) = "001")
    else "11";
Rew <= '1' when controlstate = arith or controlstate = addr or controlstate = brn or controlstate = fetch else '0';
op <= '1' when instruction(24 downto 21) = "0100" else '0';
carry <= '1' when controlstate = brn else '0';
flgset <= '1' when instruction(27 downto 26) = "00" and instruction(24 downto 21) = "1010" else '0';

    process(clock) begin
        if (rising_edge(clock)) then
            case controlstate is 
                when fetch => 
                    controlstate<=decode;
                when decode=>
                    if instruction(27 downto 26) ="00" then
                        if instruction(24 downto 21) = "1101" then
                            controlstate<=mov;
                        else
                            controlstate<=arith;
                        end if;
                    elsif instruction(27 downto 26) = "01" then 
                        controlstate<=addr;
                    elsif instruction(27 downto 26) = "01" then 
                        controlstate<=brn;
                    elsif instruction(31 downto 0) = x"00000000" then
                        controlstate<=halt;
                    end if;
               when mov =>
                    controlstate <= fetch;
               when arith=>
                    controlstate<=res2RF;
               when addr=>
                    controlstate<=mem_wr;
               when brn=>
                    controlstate<=mem_rd;
               when halt=>
                    controlstate<=fetch;
               when res2RF=>
                    controlstate<=fetch;
               when mem_wr=>
                    controlstate<=fetch;
               when mem_rd=>
                    controlstate<=mem2RF;
               when mem2RF=>
                    controlstate<=fetch;
           end case;                  
        end if;
    end process;
        
end Behavioral;



----------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity multiplexer32x2 is
    port(
        in1: in std_logic_vector(31 downto 0):=(others=>'0');
        in2: in std_logic_vector(31 downto 0):=(others=>'0');
        outdat: out std_logic_vector(31 downto 0):=(others=>'0');
        sel: in std_logic:='0'
    );
end multiplexer32x2;

architecture behav of multiplexer32x2 is
begin
    with sel select outdat <=
        in1 when '0',
        in2 when '1';
end behav;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity multiplexer4x2 is
    port(
        in1: in std_logic_vector(4 downto 0):=(others=>'0');
        in2: in std_logic_vector(4 downto 0):=(others=>'0');
        outdat: out std_logic_vector(4 downto 0):=(others=>'0');
        sel: in std_logic:='0'
    );
end multiplexer4x2;

architecture behav of multiplexer4x2 is
begin
    with sel select outdat <=
        in1 when '0',
        in2 when '1';
end behav;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity multiplexer4x2 is
    port(
        in1: in std_logic_vector(4 downto 0):=(others=>'0');
        in2: in std_logic_vector(4 downto 0):=(others=>'0');
        outdat: out std_logic_vector(4 downto 0):=(others=>'0');
        sel: in std_logic:='0'
    );
end multiplexer4x2;

architecture behav of multiplexer4x2 is
begin
    with sel select outdat <=
        in1 when '0',
        in2 when '1';
end behav;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity multiplexer32x4 is
    port(
        in1: in std_logic_vector(31 downto 0):=(others=>'0');
        in2: in std_logic_vector(31 downto 0):=(others=>'0');
        in3: in std_logic_vector(31 downto 0):=(others=>'0');
        in4: in std_logic_vector(31 downto 0):=(others=>'0');
        outdat: out std_logic_vector(4 downto 0):=(others=>'0');
        sel: in std_logic_vector(1 downto 0):="00"
    );
end multiplexer32x4;

architecture behav of multiplexer32x4 is
begin
    with sel select outdat <=
        in1 when "00",
        in2 when "01",
        in3 when "10",
        in4 when "11";
end behav;


 