library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;


entity ALU is port
(   
    clock: in std_logic:='0';
    datain1: in std_logic_vector(31 DOWNTO 0);
    datain2: in std_logic_vector(31 DOWNTO 0);
    operation: in std_logic_vector(3 downto 0); --"00" for add "01" for sub "10" for rsb "11" for and "100" for orr "101" for eor "110" for bic "111" for mov;
    condition: in std_logic_vector(3 downto 0);
    
    Rew: in std_logic;

    zflagout: out std_logic;
    cflagout: out std_logic;
    nflagout: out std_logic;
    vflagout: out std_logic;

    flagen: in std_logic:='0';
    carry: in std_logic:='0';
   
    
    dataout: out std_logic_vector(31 DOWNTO 0)
    
    -- controlstat : in std_logic_vector(3 downto 0)
    );
end ALU;

architecture ALUbehav of ALU is
signal result: std_logic_vector(31 downto 0);
signal zflag,cflag,nflag,vflag: std_logic;
signal perform: std_logic;

type optype is (add,sub,adc,sbc,rsb,rsc,bic,orr,eor,cmp,cmn,tst,teq,mov,mvn,andd);
signal operator: optype;

begin



zflagout <= zflag;
cflagout <= cflag;
nflagout <= nflag;
vflagout <= vflag;

perform <=
 '1' when 
    condition="0000" and zflag='1' or
    condition="0001" and zflag='0' or
    condition="0010" and cflag='1' or
    condition="0011" and cflag='0' or
    condition="0100" and nflag='1' or
    condition="0101" and nflag='0' or
    condition="0110" and vflag='1' or
    condition="0111" and vflag='0' or
    condition="1000" and cflag='1' and zflag='0' or
    condition="1001" and (cflag='0' or zflag='1') or
    condition="1010" and (nflag=vflag) or
    condition="1011" and ((not nflag) = vflag) or
    condition="1100" and zflag='0' and (nflag=vflag) or
    condition="1101" and (zflag='1' or ((not nflag) = vflag)) or
    condition="1110" else 
'0';

with operation select operator <=
    add when "0100",
    adc when "0101",
    sub when "0010",
    sbc when "0110",
    rsb when "0011",
    rsc when "0111",
    cmp when "1010",
    cmn when "1011",
    mov when "1101",
    mvn when "1111",
    tst when "1000",
    teq when "1001",
    andd when "0000",
    orr when "1100",
    eor when "0001",
    bic when "1110";

result <=  
    std_logic_vector(unsigned(datain1) + unsigned(datain2)+unsigned(carry)) 
    when (operator=add or operator=cmn)
    else
    std_logic_vector(unsigned(datain1) - unsigned(datain2));
    when (operator=sub or operator=cmp)
    else
    std_logic_vector(unsigned(datain1) + unsigned(datain2)+unsigned(cflag))
    when operator=adc
    else
    std_logic_vector(unsigned(datain1)-unsigned(datain2)+1-unsigned(cflag))
    when operator=sbc
    else
    std_logic_vector(unsigned(datain2) - unsigned(datain1))
    when operator=rsb
    else
    std_logic_vector(unsigned(datain2) - unsigned(datain1)+1-unsigned(cflag))
    when operator=rsc
    else
    datain2 and datain1
    when (operator=andd or operator=tst)
    else
    datain2 or datain1
    when (operator=orr)
    else
    datain2 xor datain1
    when (operator=eor or operator=teq)
    else
    datain1 and (not datain2)
    when (operator=bic)
    else
    datain1
    when operator=mov
    else
    not datain1
    when (operator=mvn)
    else x"11111111";

process(clock) begin
    if (rising_edge(clock) ) then
        if(flagen='1') then 
            if (result=x"00000000") then 
                zflag <= '1';
            else 
                zflag <= '0';
            end if;
            if (result(31)='1') then 
                nflag <= '1';
            else 
                nflag <= '0';
            end if;
        end if;
        if (Rew='1' and perform='1') then
            dataout <= result;
        end if;
    end if;
end process;



end ALUbehav;

entity shiftrotatemul is 
port(
    --shifttype: in std_logic_vector(1 downto 0);
    indata: in std_logic_vector(31 downto 0);
    IR11to4: in std_logic_vector(7 downto 0); 
    X: in std_logic_vector(31 downto 0);
    outdata: out std_logic_vector(31 downto 0);
    isimmediate: in std_logic;
    carry: out std_logic
);
architecture behav of shiftrotate is 
signal shiftvalue: std_logic_vector(4 downto 0);
signal shifted: std_logic_vector(31 downto 0);
variable shiftype: std_logic_vector(1 downto 0:=IR11to4(2 downto 1));

function shift_logical(X1: std_logic_vector(31 downto 0); y: std_logic_vector(4 downto 0); left: std_logic)
    return std_logic_vector is
        variable out1: std_logic_vector(31 downto 0):=X1;
        begin
        if (left='0') then 
            if y(0)='1' then 
            out1:= '0' & out1(31 downto 1);
            end if;
            
            if y(1)='1' then 
            out1:="00" & out1(31 downto 2);
            end if;

            if y(2)='1' then 
            out1:="0000" & out1(31 downto 4);
            end if;

            if y(3)='1' then 
            out1:=x"00" & out1(31 downto 8);
            end if;

            if y(4)='1' then 
            out1:=x"0000" & out1(31 downto 16);
            end if;

        else
            if y(0)='1' then 
            out1:=  out1(30 downto 0) & '0';
            end if;
            
            if y(1)='1' then 
            out1:= out1(29 downto 0) & "00";
            end if;

            if y(2)='1' then 
            out1:= out1(27 downto 0) & "0000" ;
            end if;

            if y(3)='1' then 
            out1:= out1(23 downto 0) & x"00" ;
            end if;

            if y(4)='1' then 
            out1:= & out1(15 downto 0) & x"0000";
            end if;
        end if;
        return out1;
end shift_logical;
function shiftarith(X1: std_logic_vector(31 downto 0); y: std_logic_vector(4 downto 0))
    return std_logic_vector is
    begin
        variable out1:=std_logic_vector(31 downto 0):=X1;
        
            if y(0)='1' then 
            if out1(31)='1' then 
                out1:= '1' & out1(31 downto 1);
            else
                out1:='0' & out1(31 downto 1);
            end if;
            
            if y(1)='1' then 
            if out1(31)='1' then 
                out1:= "11" & out1(31 downto 1);
            else
                out1:="00" & out1(31 downto 1);
            end if;
            end if;

            if y(2)='1' then 
            if out1(31)='1' then 
                out1:= x"1" & out1(31 downto 1);
            else
                out1:=x"0" & out1(31 downto 1);
            end if;
            end if;

            if y(3)='1' then 
            if out1(31)='1' then 
                out1:= x"11" & out1(31 downto 1);
            else
                out1:=x"00" & out1(31 downto 1);
            end if;
            end if;

            if y(4)='1' then 
            if out1(31)='1' then 
                out1:= x"1111" & out1(31 downto 1);
            else
                out1:=x"0000" & out1(31 downto 1);
            end if;
            end if;
            return out1;
end shiftarith;
function rotateright(X1: std_logic_vector(31 downto 0); y: std_logic_vector(4 downto 0)))
    return std_logic_vector is
    variable out1:=std_logic_vector(31 downto 0):=X1;
    begin
        if y(0)='1' then 
        out1:= out1(0) & out1(31 downto 1);
        end if;
        
        if y(1)='1' then 
        out1:=out1(1 downto 0) & out1(31 downto 2);
        end if;

        if y(2)='1' then 
        out1:=out1(3 downto 0) & out1(31 downto 4);
        end if;

        if y(3)='1' then 
        out1:=out1(7 downto 0) & out1(31 downto 8);
        end if;

        if y(4)='1' then 
        out1:=out1(15 downto 0) & out1(31 downto 16);
        end if;
        return out1;

begin
    outdata <= indata ror shift_left(unsigned(x"0000000" & IR11to4(7 downto 4)),1)
    when isimmediate = '1' else
    shifted;

    shiftvalue <=
    IR11to4(7 downto 3) when IR11to4(0) = '0' else
    X;

    with shiftype select 
    shifted <= 
    shift_logical(indata,shiftvalue,'1') when "00",
    shift_logical(indata,shiftvalue,'0') when "01",
    shiftarith(indata,shiftvalue) when "10",
    rotateright(indata,shiftvalue) when "11";

end behav;
