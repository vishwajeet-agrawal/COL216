----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/26/2019 03:12:06 PM
-- Design Name: 
-- Module Name: mainlab7 - Behavioral
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


----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/22/2019 02:06:27 PM
-- Design Name: 
-- Module Name: main - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependen
-------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mainlab7 is
port (  clock: in std_logic:='0';
        reset: in std_logic:='0';
        step: in std_logic:='0';
        go: in std_logic:='0';
        progselect: in std_logic_vector(2 downto 0):="000";
        proginstr: in std_logic_vector(31 DOWNTO 0):=(others => '0');
        datafrommem: in std_logic_vector(31 DOWNTO 0):=(others=>'0');
        addtoprog,addtomem,datatomem: out std_logic_vector(31 DOWNTO 0);
        wenable: out std_logic;
        regists: out std_logic_vector(511 DOWNTO 0);
        progstate: out std_logic_vector(1 downto 0)); 
end mainlab7;

--rd2 = datatomem
--alout = addtomem

architecture Behavorial of mainlab7 is
signal equalflag: std_logic:='0';
signal rad1: std_logic_vector(3 DOWNTO 0):=(others=>'0');
signal rd2: std_logic_vector(31 DOWNTO 0):=(others=>'0');
signal alout: std_logic_vector(31 downto 0);
signal datain2: std_logic_vector(31 downto 0);
signal progstate1: std_logic_vector(1 downto 0);
signal IR: std_logic_vector(31 downto 0);
begin
    process(clock) begin
        if (rising_edge(clock)) then
            IR <= proginstr(31 downto 0);
        end if;
    end process;
    
    rad1 <= instruction(
    progstate <= progstate1;
    datatomem <= rd2;
    addtomem <= alout;
    wenable <=
    '1' when (progstate1="10" or progstate1="01") and ((proginstr(27 downto 24) = "0101" and proginstr(22 downto 20) = "000")) else '0'; 
                
programCounter: entity work.ProgCounter(PCbehav)
    PORT MAP (instruct => proginstr,
        equalflag => equalflag,
        clock=>clock,adr=>
        addtoprog,
        reset=>reset,
        step => step,
        progstate => progstate1,
        go => go,
        progselect => progselect );
    
registFiles: entity work.RF(Behavioral)
    PORT MAP (
            readin1 => IR(19 downto 16),
            clock => clock,
            dmout => datafrommem,
            alout => alout,
            rd1 => rd1,
            rd2 => rd2,
            aluin2 => datain2,
            regists => regists,
            progstate => progstate1         
               );
    
alu: entity work.ALU(ALUbehav)
    PORT MAP (datain1=>rd1,datain2=>datain2,instreg=>proginstr,dataout=>alout,equalflag=>equalflag,clock=>clock);

end Behavorial;

