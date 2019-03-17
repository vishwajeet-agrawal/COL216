library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RF is
    port(
    clock in std_logic;

    rdin1 in std_logic_vector(3 downto 0);
    rdin2 in std_logic_vector(3 downto 0);
    rdout1 out std_logic(31 downto 0);
    rdout2 out std_logic(31 downto 0);

    wrin in std_logic_vector(3 downto 0);
    wrout out std_logic_vector(31 downto 0);
    wren in std_logic:='0';

    pcin in std_logic_vector(31 downto 0);
    pcout out std_logic_vector(31 downto 0);
    pcen in std_logic:='0';
    );
end RF;


architecture behavioral of RF is
    signal registers is array (0 to 15) of std_logic_vector(31 downto 0); 

begin
    process(clock) begin
        if(rising_edge(clock)) then
            if wren='1' then

        end if;
    end process;
end behavioral;