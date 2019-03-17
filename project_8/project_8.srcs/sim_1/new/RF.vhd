----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/26/2019 02:03:23 PM
-- Design Name: 
-- Module Name: RF - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RF is
    Port (
        clock: in std_logic:='0';
         
        readin1: in std_logic_vector(3 DOWNTO O):="0000";
        readout1: out std_logic_vector(3 DOWNTO 0):="0000";
        readen1: in std_logic:='0';
        
        readin2: in std_logic_vector(3 DOWNTO O):="0000";
        readout2: out std_logic_vector(3 downto 0):="0000";
        readen2: in std_logic:'0';
        
        write_en: in std_logic:='0';
        writein1: in std_logic_vector(3 downto 0):="0000";
        datain1: in std_logic_vector(31 downto 0):=(others=>'0');
        
        pcwrite_en: in std_logic:='0';
        pcdatain: in std_logic_vector(31 downto 0):=(others=>'0');
        pcdataout: out std_logic_vector(31 downto 0):=(others=>'0')
    );
end RF;

architecture Behavioral of RF is
type register_array is array(0 to 15) of std_logic_vector(31 DOWNTO 0);
signal registers: register_array:= ((others=> (others=>'0')));

begin
     process(clock) begin
        if(rising_edge(clock))) then
            if (write_en='1') then
            registers(to_integer(unsigned(writein1))) <= datain1; 
            end if;
            if (readen1='1') then
            readout1 <= registers(to_integer(unsigned(readin1));
            end if;
            if (readen2='1') then
            readout2 <= registers(to_integer(unsigned(readin2));  
            end if;
            if (pcwrite_en='1') then
            pcdataout <= pcdatain;
        end if;
end process;

end Behavioral;


--------------------------


