library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity ALU is port
(   datain1: in std_logic_vector(31 DOWNTO 0);
    datain2: in std_logic_vector(31 DOWNTO 0);
    instreg: in std_logic_vector(31 DOWNTO 0):=(others=>'0');
    dataout: out std_logic_vector(31 DOWNTO 0);
    clock: in std_logic:='0';
    controlstat : in std_logic_vector(3 downto 0);
    equalflag: out std_logic:='0');
end ALU;

architecture ALUbehav of ALU is
type instr_class_type is (DP,DT, branch, unknown);
type i_decoded_type is (add, sub, cmp, mov, ldr, str, beq, bne, b, unknown);
signal instr_class: instr_class_type;
signal i_decoded: i_decoded_type;
signal opcode: std_logic_vector(3 DOWNTO 0):= (others => '0');
signal eqtmp: std_logic:='0';
begin
opcode <=instreg(24 downto 21);
with instreg(31 downto 26) select instr_class <=
    DP when "111000",
    DT when "111001",
    branch when "111010",
    branch when "000010",
    branch when "000110",
    unknown when others;
i_decoded <=
    add when opcode="0100" and instr_class=DP else
    sub when opcode="0010" and instr_class=DP else
    cmp when opcode="1010" and instr_class=DP else
    mov when opcode="1101" and instr_class=DP else
    ldr when (opcode="1100" or opcode="1000") and instreg(25)='0' and instreg(20)='1' and instr_class=DT else
    str when (opcode="1100" or opcode="1000") and instreg(25)='0' and instreg(20)='0' and instr_class=DT else
    beq when instreg(31 DOWNTO 28)="0000" and instr_class=branch else
    bne when instreg(31 DOWNTO 28)="0001" and instr_class=branch else
    b   when instreg(31 DOWNTO 28)="1110" and instr_class=branch else
    unknown;
    

dataout <=
    std_logic_vector(unsigned(datain1) + unsigned(datain2)) 
    when (i_decoded=add or ((i_decoded=str or i_decoded=ldr) and instreg(23)='1')) 
    else
    std_logic_vector(unsigned(datain1) - unsigned(datain2)) 
    when (i_decoded=sub or ((i_decoded=str or i_decoded=ldr) and instreg(23)='0'))
    else
    datain2 when i_decoded=mov else
    (others => '0');

process(clock) begin
    if (rising_edge(clock) and i_decoded=cmp) then
        if (unsigned(datain1)=unsigned(datain2)) then 
            equalflag <= '1';
        else equalflag <= '0';
        end if;
    end if;
end process;



end ALUbehav;
