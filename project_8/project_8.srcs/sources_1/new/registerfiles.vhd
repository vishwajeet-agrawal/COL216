
---------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity registerfiles is

port ( 
    instruct: in std_logic_vector(31 DOWNTO 0):=(others=>'0'); -- two read port combined + one data in port
        clock: in std_logic:='0';  
        dmout: in std_logic_vector(31 DOWNTO 0):=(others=>'0');
        alout: in std_logic_vector(31 DOWNTO 0):=(others=>'0');
        rd1: out std_logic_vector(31 DOWNTO 0); --data out port 1
        rd2: out std_logic_vector(31 DOWNTO 0); --data out port 2
        aluin2: out std_logic_vector(31 DOWNTO 0);
        controlstat: in std_logic_vector( 3 downto 0);
        regists: out std_logic_vector(511 DOWNTO 0);
        progstate: in std_logic_vector(1 downto 0)
        );
end registerfiles;

architecture behav1 of registerfiles is
type register_array is array(0 to 15) of std_logic_vector(31 DOWNTO 0);
signal registers: register_array:= ((others=> (others=>'0')));
signal rad1: std_logic_vector(0 to 3):="0000";
signal rad2: std_logic_vector(0 to 3):="0000";
signal wad: std_logic_vector(0 to 3):="0000";
signal wd: std_logic_vector(31 DOWNTO 0):= (others => '0');
signal wenable: std_logic:='1';
begin
    wad <= instruct(15 downto 12);
    
M: for i in 0 to 15 generate
        regists((16-i)*32 -1 downto (15-i)*32) <= registers(i);
   end generate M;
    
    wenable <= '1' when (progstate="01" or progstate="10") and (instruct(27 downto 26) = "00" or (instruct(27 downto 26) = "01" and instruct(20) ='1'))
    else '0';
        
--    rad1 <= instruct(19 downto 16);
   
     
--    with instruct(27 downto 26) select rad2 <=
--        instruct(3 downto 0) when "00",
--        wad when "01",
--        (others => '0') when others;
  
    
    with instruct(27 downto 25) select aluin2 <=
     registers(to_integer(unsigned(rad2))) when "000",
     "00000000000000000000" & instruct(11 DOWNTO 0) when "010",
     "00000000000000000000" & instruct(11 DOWNTO 0) when "001",
     (others => '0') when others;
    
    with instruct(27 downto 26) select wd <=
        alout when "00",
        dmout when "01",
        (others => '0') when others;
    
    process(clock) begin
        if(rising_edge(clock) and wenable='1') then
            registers(to_integer(unsigned(wad))) <= wd; 
            case controlstat is 
                when "0001" =>
                rd1 <= registers(to_integer(unsigned(instruct(19 downto 16))));
                rd2 <= registers(to_integer(unsigned(instruct(3 downto 0))));
                when "0011" =>
                rd2 <= registers(to_integer(unsigned(instruct(15 downto 12))));
                when others =>
            end case;
        end if;
    end process;

end behav1;

---------