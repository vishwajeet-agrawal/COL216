----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/29/2019 03:21:24 PM
-- Design Name: 
-- Module Name: testbencher - Behavioral
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

entity testbencher is
Port ( clock: in std_logic:='0';
    resetb: in std_logic:='0';
    stepb: in std_logic:='0';
    gob: in std_logic:='0';
    progselect: in std_logic_vector(2 downto 0):="000";
    regists: out std_logic_vector(511 DOWNTO 0);
    memdata: out std_logic_vector(31 downto 0);
    memadr: out std_logic_vector(7 DOWNTO 0);
    cputomem: out std_logic_vector(31 downto 0);
    instruction: out std_logic_vector(31 downto 0);
    progadr: out std_logic_vector(7 downto 0);
    progstate: out std_logic_vector( 1 downto 0)
    );
end testbencher;

architecture Behavioral of testbencher is

--ram
component dist_mem_gen_1 IS
  PORT (
  --a=adress of memory
    a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);    
   -- data to store
    d : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    clk : IN STD_LOGIC;
    we : IN STD_LOGIC;
   -- data loaded
    spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
end component;
--rom
component dist_mem_gen_0 IS
  PORT (
    -- address of mem
    a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    -- data stored
    spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END component;
signal datafrommem:  std_logic_vector(31 downto 0);
signal addtoram:  std_logic_vector(7 DOWNTO 0);
signal datatomem:  std_logic_vector(31 downto 0);
signal instr: std_logic_vector(31 downto 0):=(others => '0');
signal addtoprog: std_logic_vector(31 downto 0);
signal addtomem: std_logic_vector(31 downto 0);
signal addtorom: std_logic_vector(7 DOWNTO 0);
signal wenable: std_logic:='0';
signal reset: std_logic:='0';
signal step: std_logic:='0';
signal go: std_logic:='0';
signal dclock:  std_logic;
signal hclock: std_logic;
begin
    memdata <= datafrommem;
    cputomem <= datatomem;
    memadr <= addtoram;
    instruction <= instr;
    progadr <= addtorom;
    addtoram <= addtomem(9 DOWNTO 2);
    addtorom <= addtoprog(9 DOWNTO 2);
    
cpu: entity work.main(Behavorial)   
    port map( clock=> hclock, 
        proginstr=> instr,
        addtoprog=>addtoprog,
        addtomem=>addtomem, 
        datatomem=>datatomem,
        reset=>resetb,
        step => stepb,
        go => gob,
        progselect => progselect,
        datafrommem=>datafrommem,
        wenable => wenable,
        regists => regists,
        progstate => progstate
        );
    
progMem: dist_mem_gen_0
    port map(a=>addtorom,spo=>instr
    );
    
datMem: dist_mem_gen_1
    port map(a=>addtoram,spo=>datafrommem,we=>wenable,
    clk=>hclock,d=>datatomem
    );


-----DEBOUNCER-----------
clockdivider: entity work.clockslower(behav)
    port map(n => 4000001, clock => clock, slowedclock => dclock);
-- dclock is a 25 Hz Clock
clockdivider1: entity work.clockslower(behav)
    port map(n => 2, clock => clock, slowedclock => hclock);
debounce1: entity work.debounce(Behavioral)
    port map(clock => dclock, xin => resetb, yout => reset);
debounce2: entity work.debounce(Behavioral)
    port map(clock => dclock, xin => gob, yout => go);
debounce3: entity work.debounce(Behavioral)
        port map(clock => dclock, xin => stepb, yout => step);    
----END-------------------

end Behavioral;
