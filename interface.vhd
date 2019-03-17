library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity interface is
    port(
        clock: in std_logic;
        buttons_in: in std_logic_vector(3 downto 0)
    );
end interface;

architecture behavioral of interface is
    signal buttons_out: std_logic_vector(3 downto 0);
    signal cpuclock: std_logic;
    signal dclock: std_logic;
begin
    cpu: entity work.cpu(behavioral)
        port map(
            clock => cpuclock,
            reset => buttons_out(0),
            step => buttons_out(1),
            instr => buttons_out(2),
            go => buttons_out(3)
        );
    debounce: entity work.debounce3(behavioral)
        port map(
            signalin => buttons_in,
            signalout => buttons_out
        );
    clock_for_debouncer: entity work.clockslower(behav)
        port map(
            n => 4000000,
            clock => clock,
            slowedclock => dclock
        );
    clock_for_cpu: entity work.clockslower(behav)
        port map(
            n => 2,
            clock => clock,
            slowedclock => cpuclock
        );
        
end behavioral;