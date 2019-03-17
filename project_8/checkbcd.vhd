library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity test1 is 
port (clk: in std_logic;
    number: in std_logic_vector(31 downto 0);
    databcd: out std_logic_vector(44 downto 0));
end test1;
architecture behav of test1 is

function divby10 (inte: unsigned(31 downto 0)) return unsigned is
    variable tmp: unsigned(63 downto 0):=(others=>'0');
    variable ininte: unsigned(63 downto 0):=x"00000000" & inte;
    constant inv10: unsigned(63 downto 0):= x"00000000" & x"19999999";
    constant ten: unsigned(63 downto 0):=x"00000000" & x"0000000" & "1010";
    variable rem10: unsigned(63 downto 0);
    begin
        tmp:=shift_right(inv10*ininte,32);
        rem10:= ininte - tmp*ten;
        tmp(35 downto 32):=rem10(3 downto 0);
        return tmp(35 downto 0);
end divby10;

function  divide  (a : UNSIGNED; b : UNSIGNED) return UNSIGNED is    
    variable a1 : unsigned(a'length-1 downto 0):=a;    
    variable b1 : unsigned(b'length-1 downto 0):=b;    
    variable p1 : unsigned(b'length downto 0):= (others => '0');    
    variable i : integer:=0;               
    begin    
        for i in 0 to b'length-1 loop    
            p1(b'length-1 downto 1) := p1(b'length-2 downto 0);    
            p1(0) := a1(a'length-1);    
            a1(a'length-1 downto 1) := a1(a'length-2 downto 0);    
            p1 := p1-b1;    
            if(p1(b'length-1) ='1') then    
                a1(0) :='0';    
                p1 := p1+b1;    
            else    
                a1(0) :='1';    
            end if;
        end loop;    
    return a1;    
end divide;

function binarytobcd (inbits: std_logic_vector(31 downto 0))
    return unsigned is
    variable ininteger: integer:=to_integer(signed(inbits));
    variable outbcd: unsigned(44 downto 0):=(others=>'0');
    variable num: unsigned(31 downto 0):=(others=>'0');
    variable remain: unsigned(3 downto 0):=(others=>'0');
    variable tmpdigit: unsigned(3 downto 0):="0000";
    constant ten: unsigned(3 downto 0):="1010";

        begin
            if ininteger<0 then
                outbcd(44):='1';
                ininteger:= -ininteger;
            end if;
            num:= to_unsigned(ininteger,32);
            for i in 1 to 11 loop
                if (num=x"00000000") then exit; end if;
                 remain:= num mod ten;
                 num:=num/ten;
                 outbcd(4*i-1 downto 4*(i-1)):=remain;
                 
            end loop;
            return outbcd;
end binarytobcd;
begin
databcd <= std_logic_vector(binarytobcd(number));
end behav;