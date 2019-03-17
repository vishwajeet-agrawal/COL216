----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Vishwajeet Agrawal
-- 
-- Create Date: 02/12/2019 12:35:00 PM
-- Design Name: 
-- Module Name: debounce - Behavioral
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

entity debounce is
--  Port ( );
port (clock, xin: in std_logic; yout: out std_logic:='0');
end debounce;

architecture Behavioral of debounce is

begin
process (clock)
		begin
			if (rising_edge(clock)) then
				yout<=xin;
			end if;
	end process;

end Behavioral;

------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clockslower is
	port(n: in integer; clock: in std_logic; slowedclock: out std_logic);
end clockslower;

architecture behav of clockslower is
	signal s: integer:=0;
	signal temp: std_logic:='0';
	begin
		slowedclock <= temp;
		process (clock) begin
			if rising_edge(clock) then
				if (s=n) then
					temp<=NOT temp;
					s<=0;
				elsif (s=1) then
					temp<=NOT temp;
					s<=s+1;
				else 
					s<=s+1;
				end if;
			end if;
		end process;
end behav;
------

library ieee;
use ieee.std_logic_1164.all;
 
entity Binary_To_7Segment is
  port (
    i_Clk        : in  std_logic;
    to_disp      : in std_logic;
    i_Binary_Num : in  std_logic_vector(3 downto 0);
    o_Segment_A  : out std_logic;
    o_Segment_B  : out std_logic;
    o_Segment_C  : out std_logic;
    o_Segment_D  : out std_logic;
    o_Segment_E  : out std_logic;
    o_Segment_F  : out std_logic;
    o_Segment_G  : out std_logic
    );
end entity Binary_To_7Segment;
 
architecture RTL of Binary_To_7Segment is
 
  signal r_Hex_Encoding : std_logic_vector(7 downto 0) := (others => '0');
   
begin
 
  -- Purpose: Creates a case statement for all possible input binary numbers.
  -- Drives r_Hex_Encoding appropriately for each input combination.
  process (i_Clk) is
  begin
    if rising_edge(i_Clk) then
      case i_Binary_Num is
        when "0000" =>
          r_Hex_Encoding <= X"7E";
        when "0001" =>
          r_Hex_Encoding <= X"30";
        when "0010" =>
          r_Hex_Encoding <= X"6D";
        when "0011" =>
          r_Hex_Encoding <= X"79";
        when "0100" =>
          r_Hex_Encoding <= X"33";          
        when "0101" =>
          r_Hex_Encoding <= X"5B";
        when "0110" =>
          r_Hex_Encoding <= X"5F";
        when "0111" =>
          r_Hex_Encoding <= X"70";
        when "1000" =>
          r_Hex_Encoding <= X"7F";
        when "1001" =>
          r_Hex_Encoding <= X"7B";
        when "1010" =>
          r_Hex_Encoding <= X"77";
        when "1011" =>
          r_Hex_Encoding <= X"1F";
        when "1100" =>
          r_Hex_Encoding <= X"4E";
        when "1101" =>
          r_Hex_Encoding <= X"3D";
        when "1110" =>
          r_Hex_Encoding <= X"4F";
        when "1111" =>
          r_Hex_Encoding <= X"47";
        when others =>
      end case;
    end if;
  end process;
 
  -- r_Hex_Encoding(7) is unused
  o_Segment_A <= not r_Hex_Encoding(6) or not to_disp;
  o_Segment_B <= not r_Hex_Encoding(5) or not to_disp;
  o_Segment_C <= not r_Hex_Encoding(4) or not to_disp;
  o_Segment_D <= not r_Hex_Encoding(3) or not to_disp;
  o_Segment_E <= not r_Hex_Encoding(2) or not to_disp;
  o_Segment_F <= not r_Hex_Encoding(1) or not to_disp;
  o_Segment_G <= not r_Hex_Encoding(0) or not to_disp;
end architecture RTL;

-------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

 
entity Four7Segment is
  port (
    clock        : in  std_logic;
    i_bcd : in  std_logic_vector(15 downto 0);
    isneg: in std_logic:='0';
    to_disp: in std_logic:='0';
    state1: in std_logic_vector(1 downto 0):="00";
    o_Segment_A  : out std_logic;
    o_Segment_B  : out std_logic;
    o_Segment_C  : out std_logic;
    o_Segment_D  : out std_logic;
    o_Segment_E  : out std_logic;
    o_Segment_F  : out std_logic;
    o_Segment_G  : out std_logic;
    o_anode1    : out std_logic;
    o_anode2    : out std_logic;
    o_anode3    : out std_logic;
    o_anode4    : out std_logic;
    dp          : out std_logic
    );
end entity Four7Segment;

architecture Behav of Four7Segment is
signal binaryseg: std_logic_vector(3 downto 0);
signal anodev: unsigned(3 downto 0):="0111";
signal stand: unsigned(1 downto 0):="00";
--function demux(sel: unsigned(1 downto 0)) return std_logic_vector is
--    begin
--        case sel is when
--        "00" => return "0001"; when
--        "01" => return "0010"; when
--        "10" => return "0100"; when
--        "11" => return "1000";
--        end case;
--end demux;
begin
SevenSeg:   entity work.Binary_To_7Segment(RTL) 
    port map (
            i_Clk => clock,
            to_disp => to_disp,
            o_Segment_A =>  o_Segment_A,
            o_Segment_B =>  o_Segment_B,
            o_Segment_C =>  o_Segment_C,
            o_Segment_D =>  o_Segment_D,
            o_Segment_E =>  o_Segment_E,
            o_Segment_F =>  o_Segment_F,
            o_Segment_G =>  o_Segment_G,
            i_Binary_Num => binaryseg
            
        );
   
    o_anode1<=anodev(0);
    o_anode2<=anodev(1);
    o_anode3<=anodev(2);
    o_anode4<=anodev(3);
    
with stand select anodev <=
"0111" when "11",
"1011" when "10",
"1101" when "01",
"1110" when "00";

with stand select binaryseg <=
i_bcd(15 downto 12) when "10",
i_bcd(11 downto 8) when "01",
i_bcd(7 downto 4) when "00",
i_bcd(3 downto 0) when "11";

dp <=
not isneg when stand="11" else
'0' when 
stand(0)=state1(0)
and stand(1)=state1(1)
else '1';

   process(clock) begin
    if (rising_edge(clock)) then
        case stand is 
        when "00" => stand <="01";
        when "01" => stand <="10";
        when "10" => stand <="11";
        when "11" => stand <="00";
        when others =>
        end case; 
    end if;
   end process;
end Behav;
