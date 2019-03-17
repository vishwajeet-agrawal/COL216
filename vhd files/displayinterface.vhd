----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/12/2019 01:27:15 PM
-- Design Name: 
-- Module Name: displayinterface - Behavioral
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
use IEEE.numeric_std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity displayinterface is
  Port (clock: in std_logic:='0';
        reset: in std_logic:='0';
        step: in std_logic:='0';
        go: in std_logic:='0';
        progselect: in std_logic_vector(2 downto 0):="000";
        progstateornot: in std_logic:='0';
        displaymode: in std_logic:='0';
        todisplay: in std_logic:='0';
        switch7seg: in std_logic:='0';
        registerormem: in std_logic:='0';
        whichdatatodisp: in std_logic_vector(3 downto 0):="0000";
        dataorprogram: in std_logic:='0';
        leds: out std_logic_vector(15 downto 0):=(others => '0');
        o_Segment_A  : out std_logic;
        o_Segment_B  : out std_logic;
        o_Segment_C  : out std_logic;
        o_Segment_D  : out std_logic;
        o_Segment_E  : out std_logic;
        o_Segment_F  : out std_logic;
        o_Segment_G  : out std_logic;
        anode   : out std_logic_vector(3 downto 0);
        dp: out std_logic
         );
end displayinterface;

architecture Behavioral of displayinterface is
signal regists: std_logic_vector(511 DOWNTO 0);
signal memdata: std_logic_vector(31 downto 0);
signal memadr: std_logic_vector(7 DOWNTO 0);
signal cputomem: std_logic_vector(31 downto 0);
signal instruction: std_logic_vector(31 downto 0);
signal progadr: std_logic_vector(7 downto 0);
signal datatodisp: std_logic_vector(31 downto 0):=x"00000000";
signal progstate: std_logic_vector(1 downto 0):="00";  
signal databcd: std_logic_vector(44 downto 0):=(others=>'0');
signal bcdtodisp: std_logic_vector(15 downto 0):=(others=>'0');
signal switch7segr: std_logic:='0';

signal st1: std_logic_vector(1 downto 0):="00";

--function divby10 (inte: unsigned(31 downto 0)) return unsigned is
--    variable tmp: unsigned(63 downto 0):=(others=>'0');
--    variable ininte: unsigned(63 downto 0):=x"00000000" & inte;
--    constant inv10: unsigned(63 downto 0):= x"00000000" & x"19999999";
--    constant ten: unsigned(63 downto 0):=x"00000000" & x"0000000" & "1010";
--    variable rem10: unsigned(63 downto 0);
--    begin
--        tmp:=shift_right(inv10*ininte,32);
--        rem10:= ininte - tmp*ten;
--        tmp(35 downto 32):=rem10(3 downto 0);
--        return tmp(35 downto 0);
--end divby10;

function binarytobcd (inbits: signed(31 downto 0))
    return unsigned is
    variable ininteger: integer:=to_integer(inbits);
    variable outbcd: unsigned(44 downto 0):=(others=>'0');
    variable num: unsigned(31 downto 0):=(others=>'0');
    variable remain: unsigned(3 downto 0):=(others=>'0');
    constant ten: unsigned(3 downto 0):="1010";

    variable tmpdigit: unsigned(3 downto 0):="0000";
    variable divremtmp: unsigned(35 downto 0);
        begin
            if ininteger<0 then
                outbcd(44):='1';
                ininteger:= -ininteger;
            end if;
            num:= to_unsigned(ininteger,32);
            for i in 1 to 11 loop
                if (num=x"00000000") then exit; end if;
                 remain := num mod ten;
                 num := num/ten;
                 outbcd(4*i-1 downto 4*(i-1)):=remain;
            
            end loop;
            return outbcd;
end binarytobcd;



function getsig (ind: std_logic_vector(31 downto 0); loru: std_logic) 
    return std_logic_vector is
        begin
            if loru='0' then
                return ind(15 downto 0);
            else
                return ind(31 downto 16);
            end if;
end getsig;

function getreg (inrega: std_logic_vector(511 downto 0);
                    regsel: std_logic_vector(3 downto 0)
                    ) 
         return std_logic_vector   is
         variable regn: integer:=to_integer(unsigned(regsel));
         variable dat: std_logic_vector(31 downto 0);
         begin
            regn:= to_integer(unsigned(regsel));
            dat:= inrega((16-regn)*32-1 downto (15-regn)*32);
            return dat;
end getreg; 

signal slowedclock: std_logic:='0';
signal sslowedclock: std_logic:='0';
signal st2: std_logic:='0';
signal anodev: std_logic_vector(3 downto 0):="0000";

begin

sevenseg: entity work.Four7Segment(behav) 
    port map(
            clock => slowedclock,
            i_bcd => bcdtodisp,
            to_disp => todisplay,
            isneg => datatodisp(31),
            state1 => st1,
            o_Segment_A =>  o_Segment_A,
            o_Segment_B =>  o_Segment_B,
            o_Segment_C =>  o_Segment_C,
            o_Segment_D =>  o_Segment_D,
            o_Segment_E =>  o_Segment_E,
            o_Segment_F =>  o_Segment_F,
            o_Segment_G =>  o_Segment_G,
            o_anode1    => anodev(0),
            o_anode2    => anodev(1),
            o_anode3    => anodev(2),
            o_anode4   => anodev(3),
            dp => dp
            
    );
slowfordisp: entity work.clockslower(behav)
    port map(
        clock=> clock,
        slowedclock => slowedclock,
        n => 500001
    );
slowforbut: entity work.clockslower(behav)
    port map(
        clock=> clock,
        slowedclock => sslowedclock,
        n => 4000001
    );
armarch: entity work.testbencher(Behavioral)
    port map(clock => clock,
               progselect => progselect,
               gob=> go,
               stepb => step,
               resetb => reset,
               regists=>regists,
               cputomem=>cputomem,
               instruction=>instruction,
               progadr=>progadr,
               memadr=>memadr,
               memdata=>memdata,
               progstate=> progstate
               );
debouncedisp: entity work.debounce(Behavioral)
    port map(
        clock => sslowedclock,
        xin => switch7seg,
        yout => switch7segr  
    );
    


anode <= anodev when todisplay='1' else "0000";

leds <= getsig(datatodisp,displaymode);

bcdtodisp <= 
    "0000" & databcd(43 downto 32) when st1="10" else
    databcd(31 downto 16) when st1="01" else
    databcd(15 downto 0) when st1="00";
    
databcd <= std_logic_vector(binarytobcd(signed(datatodisp)));

datatodisp <=
    x"00000000" when todisplay='0' else
    x"0000000" & "00" & progstate when progstateornot='0' else
    getreg(regists,whichdatatodisp) when (registerormem='0') else
    x"000000" & progadr when (dataorprogram='1' and whichdatatodisp(0)='0') else
    instruction when (dataorprogram='1' and whichdatatodisp(0)='1') else
    cputomem when (whichdatatodisp(1 downto 0)="01") else
    memdata when (whichdatatodisp(1 downto 0)="11") else
    x"000000" & memadr;
    
process(clock)
    begin
    if(rising_edge(clock)) then
        st2<= switch7segr;
        if (switch7segr='1'and st2='0') then
            case st1 is when 
            "00"=> st1<="10"; 
            when "01" => st1<="00";
            when "10" => st1<="01";
            when others => st1<="00";
            end case;
        end if;
       
    end if;
    end process;
end Behavioral;
