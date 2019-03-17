library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity cpu is
    port (  clock: in std_logic:='0';
            reset: in std_logic:='0';
            step: in std_logic:='0';
            go: in std_logic:='0';
            instr: in std_logic:='0'

            -- addtoprog,addtomem,datatomem: out std_logic_vector(31 DOWNTO 0);
            -- wenable: out std_logic;
            -- regists: out std_logic_vector(511 DOWNTO 0);
            -- progstate: out std_logic_vector(1 downto 0)); 
    );
    
   end cpu;

architecture Behavorial of cpu is 
    signal IR: std_logic_vector(31 downto 0);
    signal DR: std_logic_vector(31 downto 0);
    signal rdin2: std_logic_vector(3 downto 0);
    signal rden1: std_logic:='1';
    signal rden2: std_logic:='1';
    signal rden3: std_logic:='1';
    signal rdout1: std_logic_vector(31 downto 0);
    signal rdout2: std_logic_vector(31 downto 0);
    signal rdout3: std_logic_vector(31 downto 0);
    signal wrdata: std_logic_vector(31 downto 0);
    signal Pw: std_logic;
    signal Rw: std_logic;
    signal Rew: std_logic;
    signal Mw: std_logic;
    signal Iw: std_logic;
    signal Dw: std_logic;
    signal Rsrc: std_logic;
    signal Asrc1: std_logic;
    signal Asrc2: std_logic;
    signal operation: std_logic_vector(3 downto 0);
    signal carry: std_logic;
    signal flgset: std_logic;
    signal AluorMem: std_logic;
    signal result: std_logic_vector(31 downto 0);
    signal pcout: std_logic_vector(31 downto 0);
    signal shifted: std_logic_vector(31 downto 0);
    --signal BB: std_logic_vector(31 downto 0)
    component dist_mem_gen_1 IS
    PORT (
        a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);    
        -- data to store
         d : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
         clk : IN STD_LOGIC;
         we : IN STD_LOGIC;
        -- data loaded
         spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
    end component;

    begin
    register_files: entity work.RF(behavioral)
        port map(
            clock => clock,

            rdin1 => IR(19 downto 16),
            rdin2 => rdin2,
            rdin3 => IR(11 downto 8),
            rdout1 => rdout1,
            rdout2 => rdout2,
            rdout3 => rdout3,
            rden1 => rden1,
            rden2 => rden2,
            rden3 => rden3,

            wradr => IR(15 downto 12),
            wrdata => wrdata,
            wren => Rw,

            pcin => result(29 downto 0) && "00",
            pcout => pcout,
            pcen => Pw
        );
    alu: entity work.ALU(ALUbehav) 
        port map(
            clock => clock,
            datain1 => datain1,
            datain2 => datain2,
            operation => operation,
            condition => IR(31 downto 28),
            Rew => Rew,
            zflagout => zflag,
            zflagen => flgset,
            carry => carry,
            dataout => result
        );
    controller: entity work.controller(Behavioral)
        port map(
            clock => clock,
            zflag => zflag,
            instruction => IR,

            Pw => Pw, --pcenable
            Rw => Rw, --registerenable
            Aw => rden1, --rfirstout
            Bw => rden2, --rsecondout
            Rew => Rew,--resultregister
            Mw => Mw, --memwrite
            Iw => Iw, --instrreg
            Dw => Dw, --datareg

            Rsrc => Rsrc, --r2 select
            Asrc1 => Asrc1,--alu1select
            Asrc2 => Asrc2, --alu2select
        
            op => operation, --addorsub
            carry => carry, --carrybittoalu
            flgset => flgset, --fseten
            AluorMem => AluorMem,   --resultorfrommemselect
            
            reset => reset,
            step => step,
            instr => instr,
            go => go
        );
    IorDmult: entity work.multiplexer32x2(behav)
        port map(
            in1 => pcout,
            in2 => dataout,
            sel => IorD,
            outdat => adtomem
        );
    Rsrcmult: entity work.multiplexer4x2(behav)
        port map(
            in1 => IR(3 downto 0),
            in2 => IR(15 downto 0),
            sel => Rsrc,
            outdat => rdin2
        );
        
    Asrc1mult: entity work.multiplexer32x2(behav)
        port map(
            in1 => "00" & pcout(31 downto 2),
            in2 => rdout1,
            sel => Asrc1,
            outdat => datain1
        );
    Asrc2mult: entity work.multiplexer32x4(behav)
        port map(
            in1 => rdout2,
            in2 => x"00000001",
            in3 => x"0000"& "0000" & IR(11 downto 0),
            in4 => "000000" & IR(23 downto 0) & "00",
            sel => Asrc2,
            outdat => datain2
        );
    aluormem: entity work.multiplexer32x2(behav)
        port map(
            in1 => DR,
            in2 => IR,
            sel => AluorMem,
            outdat => wrdata
        );
    shifter: entity work.shiftrotatemult(behav)
        port map(
            indata => rdout2,
            IR11to4 => IR(11 downto 4),
            X => rdout3,
            outdata => shifted,
            isimmediate => IR(25),
            carry => carry
        );
    mem: dist_mem_gen_1 
        port map(
            clk => clock,
            a => adtomem,
            d => result,
            we => Mw,
            spo => datafrommem
        );
    
    
    
    process(clock) begin
        if (rising_edge(clock)) then
            if (Iw='1') then
                IR <= datafrommem;
            end if;
            if (Dw='1') then
                DR <= datafrommem;
            end if;
        end if;
    end process;
end Behavorial;