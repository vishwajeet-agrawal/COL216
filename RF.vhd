library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity RF is
    port(
    clock in std_logic;

    rdin1 in std_logic_vector(3 downto 0);
    rdin2 in std_logic_vector(3 downto 0);
    rdin3 in std_logic_vector(3 downto 0);
    rdout1 out std_logic(31 downto 0);
    rdout2 out std_logic(31 downto 0);
    rdout3 out std_logic(31 downto 0);
    rden1 in std_logic;
    rden2 in std_logic;
    rden3 in std_logic;

    wradr in std_logic_vector(3 downto 0);
    wrdata in std_logic_vector(31 downto 0);
    wren in std_logic:='0';

    pcin in std_logic_vector(31 downto 0);
    pcout out std_logic_vector(31 downto 0);
    pcen in std_logic:='0'
    );
end RF;


architecture behavioral of RF is
type registersarray is array (0 to 15) of std_logic_vector(31 downto 0);
signal registers: registersarray:= ((others=> (others=>'0')));
signal rdout1t: std_logic_vector(31 downto 0);
signal rdout2t: std_logic_vector(31 downto 0);
signal rdout3t: std_logic_vector(31 downto 0);
begin
    -- pcout <= registers(15);
    rdout1t <= registers(to_integer(unsigned(rdin1)));
    rdout2t <= registers(to_integer(unsigned(rdin2)));
    rdout3t <= registers(to_integer(unsigned(rdin3)));
    process(clock) begin
        if(rising_edge(clock)) then
            if (wren='1' and (not wradr="1111")) then
                registers(to_integer(unsigned(wradr))) <= wrdata;    
            end if;
            if pcen='1' then 
                pcout <= pcin;
            end if;
            if rden1='1' then
                rdout1 <= rdout1t;
            end if;
            if rden2='1' then
                rdout2 <= rdout2t;
            end if;
            if rden3='1' then 
                rdout3 <= rdout3t;
            end if; 
        end if;
    end process;
end behavioral;