library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity ProgCounter is port
( instruct: in std_logic_vector(31 DOWNTO 0):=(others=>'0');
    instrreg : out std_logic_vector(31 downto 0);
    equalflag: in std_logic:='0';
    clock: in std_logic:='0';
    reset: in std_logic:='0';
    step: in std_logic:='0';
    go: in std_logic:='0';
    progselect: in std_logic_vector(2 downto 0);
    adr: out std_logic_vector(31 DOWNTO 0);
    controlstat: out std_logic_vector(3 downto 0);
    progstate: out std_logic_vector(1 downto 0));
end ProgCounter;

architecture PCbehav of ProgCounter is
type instr_class_type is (DP,DT, branch, unknown,halt);
signal IR: std_logic_vector(31 downto 0);
signal controlstate: std_logic_vector(3 downto 0):="0000";
signal isred: std_logic:='0';
signal instr_class: instr_class_type;
signal adrtmp: std_logic_vector(31 DOWNTO 0):=(others => '0');
--signal offset: std_logic_vector(31 DOWNTO 0):= (others => '0');
signal offset: integer:=0;
signal eqtmp: std_logic:= '0';
type runningstatefsm is (initial, onestep, cont, oneinstruct, done);
signal runningstate: runningstatefsm:=initial;

function updateadr(instrr: std_logic_vector(31 downto 0);
                    stt: std_logic_vector(31 downto 0);
                    flag1: std_logic;
                    offs: integer)
                    return std_logic_vector is
          begin
         
          if (instrr(27 downto 26) ="10") then
              if (instrr(31 downto 28)="1110") then
                     return std_logic_vector(to_unsigned(to_integer(unsigned(stt))+offs+8,32));
              elsif (instrr(31 downto 29) = "000") then
                      if (flag1='1') then
                          return std_logic_vector(to_unsigned(to_integer(unsigned(stt))+offs+8,32));
                      else 
                          return std_logic_vector(unsigned(stt)+to_unsigned(4,32)); 
                      end if;
              else 
                     return std_logic_vector(unsigned(stt)+to_unsigned(4,32));     
              end if;
          else
            return std_logic_vector(unsigned(stt)+to_unsigned(4,32));      
          end if;
end updateadr;

begin
controlstat <= controlstate;
instrreg <= IR;
with IR(31 downto 26) select instr_class <=
    DP when "111000",
    DT when "111001",
    branch when "111010",
    branch when "000010",
    branch when "000110",
    halt when "000000",
    unknown when others;
 
isred <=
    '1' when controlstate="0100" 
        or controlstate="0101"
        or controlstate="0111"
        or controlstate="0110"
        or controlstate="1110"
        else '0';
    progstate <=
    "00" when runningstate=initial else
    "01" when runningstate=onestep else
    "10" when runningstate=cont else
    "11";
    adr<=adrtmp;
    eqtmp <= IR(28) xor equalflag;
    offset <= to_integer(signed(IR(23 downto 0) & "00"));
    process(clock) begin
        if (rising_edge(clock)) then
            
            case controlstate is 
                when "0000" =>
                    if (reset='1') then
                        adrtmp <= x"00000" & "00" & progselect & "0000000";
                    else
                        adrtmp <=  std_logic_vector(unsigned(adrtmp)+to_unsigned(4,32));        
                    end if;
                        IR <= instruct;
                        controlstate <="0001";
                when "0001" =>
                    if (reset='1') then
                        adrtmp <= x"00000" & "00" & progselect & "0000000";
                    end if;
                    case instr_class is
                        when DP => controlstate <="0010";
                        when DT => controlstate <="0011";
                        when branch => controlstate <= "0100";
                        when halt => controlstate <= "0101";
                    end case;
                --DP
                when "0010" =>
                    controlstate <= "0110";
                --DT
                when "0011" => 
                    if IR(20)='0' then controlstate <= "0111";
                    else controlstate <= "1111";
                    end if;
                --branch
                when "0100" => 
                    
                      if (IR(31 downto 28)="1110") then
                             adrtmp <= std_logic_vector(to_unsigned(to_integer(unsigned(adrtmp))+offset+4,32));
                      elsif (IR(31 downto 29) = "000") then
                              if (eqtmp='1') then
                                  adrtmp <= std_logic_vector(to_unsigned(to_integer(unsigned(adrtmp))+offset+4,32));             
                              end if;                      
                      end if;
                      controlstate <="0000";
                --halt
                when "0101" =>
                    controlstate <="0000";
                --arith
                when "0110" =>
                    controlstate <="0000";
                --str
                when "0111" =>
                    controlstate <="0000";
                --ldr 
                when "1111" => 
                    controlstate <= "1110";
                when "1110" => 
                    controlstate <="0000";
                when others => 
            end case; 
                   
            case runningstate is
               when initial =>
                    if ( go='1' ) then
                        runningstate <= cont;
                    elsif step='1' then
                        runningstate <= onestep;   
                    end if;
               when onestep =>
                    runningstate<=done;
               when cont=>
                    if (controlstate="0101") then
                        runningstate<=done;
                    end if;
               when oneinstruct =>
                    if (isred='1') then 
                        runningstate <= done;
                    end if;
               when done=>
                    if (reset='1') then
                        adrtmp <= x"00000" & "00" & progselect & "0000000";
                    elsif (step='0' and go='0') then
                        runningstate <= initial;
                    end if;
            end case;
           end if;
       end process;
   
end PCbehav;
