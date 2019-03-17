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
        -- ES: in std_logic_vector(3 downto 0):="000";
        IR: in std_logic_vector(31 downto 0):=(others=>'0');
        IorD: out std_logic:='0';
        Pw: out std_logic:='0'; --pcenable
        Rw: out std_logic:='0'; --registerenable
        Aw: out std_logic:='0'; --rfirstout
        Bw: out std_logic:='0'; --rsecondout
        Rew:out std_logic:='0'; --resultregister
        Mw: out std_logic:='0'; --memwrite
        Iw: out std_logic:='0'; --instrreg
        Dw: out std_logic:='0'; --datareg

        Rsrc: out std_logic:='0'; --r2 select
        Asrc1:out std_logic:='0'; --alu1select
        Asrc2:out std_logic_vector(1 downto 0):="00"; --alu2select
    
        op: out std_logic_vector(3 downto 0):="0000"; 
        carry: out std_logic:='0'; --carrybittoalu
        flgset: out std_logic:='0'; --fseten
        AluorMem: out std_logic:='0';   --resultorfrommemselect
        
        reset: in std_logic;
        step: in std_logic;
        instr: in std_logic;
        go: in std_logic

        );
end controller;
        
architecture Behavioral of controller is
type controlfsm is (fetch,decode,arith,addr,brn,halt,res2RF,mem_wr,mem_rd,mem2RF);
type executionfsm is (intial,onestep,oneinstr,cont,done);

signal ES: executionfsm:=initial;
signal CS: controlfsm:=fetch;

begin   


IorD <= '0' when CS = fetch
    else '1';
Iw <= '1' when CS = fetch else '0';
Pw <= '1' when CS = fetch or CS = brn;
Mw <= '1' when CS = mem_wr else '0';
Dw <= '1' when CS = mem_rd else '0';
AluorMem <= 
        '1' when CS = mem_rd or CS = mem2RF or CS = addr
        else '0';

Aw <= '1' when CS = decode else '0';
Bw  <= '1' when CS = decode else '0';
Rw <= '1' when CS = mem2RF or CS = res2RF else '0';
Rsrc <= '1' when IR(27 downto 26) = "01" and IR(20)='0' else '0';
Asrc1 <= '0' when CS = brn else '1';
Asrc2 <= "00" when CS = arith and IR(27 downto 25) = "000"
    else "01" when CS = fetch
    else "10" when (CS = addr and IR(27 downto 25) = "010" )
                   or (CS = arith and IR(27 downto 25) = "001")
    else "11";
Rew <= '1' when (CS = arith or CS = addr or CS = brn or CS = fetch) and perform='1' else '0';


-- op <= '1' when IR(24 downto 21) = "0100" else '0';
op <= 
    IR(24 downto 21) when IR(27 downto 26) = "00",--add
    "0100" when IR(27 downto 26) = "10" or (IR(27 downto 26)="01" and IR(23)='1'),
    "0010" when IR(27 downto 26) = "01" and IR(23) = '0',
    "0000" when others;

carry <= '1' when CS = brn else '0';

flgset <= '1' when IR(27 downto 26) = "00" and IR(20)='1' else '0';

    process(clock) begin
        if (rising_edge(clock)) then
            case CS is 
                when fetch => 
                    if (ES!=done and ES!=initial) then
                        CS<=decode;
                        if (ES=onestep) then
                            ES<=done;
                        end if;
                    elsif (ES=done) then
                        if (step='0' and go = '0' and instr='0') then
                            ES<=initial;
                        end if;

                    elsif (ES=initial) then
                        if (step='1') then
                            ES<=onestep;
                        elsif (go='1') then
                            ES<=cont;
                        elsif (instr='1') then
                            ES<=go;
                        end if;    

                    end if;
                    
                when decode=>
                if (ES!=done and ES!=initial) then
                    if IR(27 downto 26) ="00" then
                        
                            CS<=arith;
                            if (ES=onestep) then
                                ES<=done;
                            end if;
                      
                    elsif IR(27 downto 26) = "01" then 
                        CS<=addr;
                        if (ES=onestep) then
                            ES<=done;
                        end if;
                    elsif IR(27 downto 26) = "01" then 
                        CS<=brn;
                        if (ES=onestep or ES=oneinstr) then
                            ES<=done;
                        end if;
                    elsif IR(31 downto 0) = x"00000000" then
                        CS<=halt;
                        ES<=done;
                    end if;
                elsif (ES=done) then
                    if (step='0' and go = '0' and instr='0') then
                        ES<=initial;
                    end if;
                
                elsif (ES=initial) then
                    if (step='1') then
                        ES<=onestep;
                    elsif (go='1') then
                        ES<=cont;
                    elsif (instr='1') then
                        ES<=go;
                    end if;

                end if;
               when arith=>
               if (ES!=done and ES!=initial) then
                    CS<=res2RF;
                    if (ES=onestep or ES=oneinstr) then
                        ES<=done;
                    end if;
                elsif (ES=done) then
                    if (step='0' and go = '0' and instr='0') then
                        ES<=initial;
                    end if;
                    
                elsif (ES=initial) then
                    if (step='1') then
                        ES<=onestep;
                    elsif (go='1') then
                        ES<=cont;
                    elsif (instr='1') then
                        ES<=go;
                    end if;
                end if;
               when addr=>
               if (ES!=done and ES!=initial) then
                    CS<=mem_wr;
                    if (ES=onestep or ES=oneinstr) then
                        ES<=done;
                    end if;
                elsif (ES=done) then
                    if (step='0' and go = '0' and instr='0') then
                        ES<=initial;
                    end if;
                    
                elsif (ES=initial) then
                    if (step='1') then
                        ES<=onestep;
                    elsif (go='1') then
                        ES<=cont;
                    elsif (instr='1') then
                        ES<=go;
                    end if;
                end if;
               when brn=>
               if (ES!=done and ES!=initial) then
                    CS<=mem_rd;
                    if (ES=onestep) then
                        ES<=done;
                    end if;
                elsif (ES=done) then
                    if (step='0' and go = '0' and instr='0') then
                        ES<=initial;
                    end if;
                    
                elsif (ES=initial) then
                    if (step='1') then
                        ES<=onestep;
                    elsif (go='1') then
                        ES<=cont;
                    elsif (instr='1') then
                        ES<=go;
                    end if;
                end if;
               when halt=>
               if (ES!=done and ES!=initial) then
                    CS<=fetch;
                    if (ES=onestep) then
                        ES<=done;
                    end if;
                end if;
               when res2RF=>
               if (ES!=done and ES!=initial) then
                    CS<=fetch;
                    if (ES=onestep) then
                        ES<=done;
                    end if;
                elsif (ES=done) then
                    if (step='0' and go = '0' and instr='0') then
                        ES<=initial;
                    end if;
                        
                elsif (ES=initial) then
                    if (step='1') then
                        ES<=onestep;
                    elsif (go='1') then
                        ES<=cont;
                    elsif (instr='1') then
                        ES<=go;
                    end if;
                end if;
               when mem_wr=>
               if (ES!=done and ES!=initial) then
                    CS<=fetch;
                    if (ES=onestep) then
                        ES=done;
                    end if;
                end if;
               when mem_rd=>
               if (ES!=done and ES!=initial) then
                    CS<=mem2RF;
                    if (ES=onestep) then
                        ES=done;
                    end if;
                elsif (ES=done) then
                    if (step='0' and go = '0' and instr='0') then
                        ES<=initial;
                    end if;
                        
                elsif (ES=initial) then
                    if (step='1') then
                        ES<=onestep;
                    elsif (go='1') then
                        ES<=cont;
                    elsif (instr='1') then
                        ES<=go;
                    end if;
                end if;
               when mem2RF=>
               if (ES!=done and ES!=initial) then
                    CS<=fetch;
                    if (ES=onestep) then
                        ES=done;
                    end if;
                elsif (ES=done) then
                    if (step='0' and go = '0' and instr='0') then
                        ES<=initial;
                    end if;
                        
                elsif (ES=initial) then
                    if (step='1') then
                        ES<=onestep;
                    elsif (go='1') then
                        ES<=cont;
                    elsif (instr='1') then
                        ES<=go;
                    end if;
                end if;
           end case;              
        end if;
    end process;
        
end Behavioral;



----------------------

