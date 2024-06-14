library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processor is
    port(
        resetP, clkP       : in std_logic;
        stateP             : out unsigned(1 downto 0);
        pcP                : out unsigned(6 downto 0);
        instructionP       : out unsigned(15 downto 0);
    	ulaIn1P, ulaIn2P   : out unsigned(15 downto 0);
	saidaUlaP          : out unsigned(15 downto 0)
    );
end;

architecture a_processor of processor is
    component bdr is
        port(
	    regnum      : in unsigned(2  downto 0);     --Registrador que sera lido
            word         : in unsigned(15 downto 0);     --O que sera escrito
            reg_to_write : in unsigned(2 downto 0);      --Qual reg eh para escrver
            write_enable : in std_logic;             --Habilitar para escrever
            clkBD        : in std_logic;
            reset        : in std_logic;
	    reg_data    : out unsigned(15 downto 0)     --Informacao que esta no reg
        );
    end component;
    
    component ula
    port(
        entrada1 : in unsigned(15 downto 0);
        entrada2 : in unsigned(15 downto 0);
        seletor  : in unsigned(1 downto 0);
        saida    : out unsigned(15 downto 0);
    	cf: in std_logic;
        C: out std_logic; --Carry
        N: out std_logic; --Negative
        O: out std_logic; --Overflow
	Z: out std_logic; --Zero
	enable_flag: out std_logic
    );
end component;

component uc is
    port
    (
        updatePC    : in std_logic;
        instruction : in unsigned(15 downto 0);
        address     : in unsigned(6 downto 0);
    	C: in std_logic; --Carry
        N: in std_logic; --Negative
        O: in std_logic; --Overflow
        Z: in std_logic; --Zero
        cte         : out unsigned(15 downto 0);
        isCte       : out std_logic;
        dataO       : out unsigned(6 downto 0);
        regRead     : out unsigned(2 downto 0);
        word_to_ld  : out unsigned(15 downto 0);
        reg_to_w    : out unsigned(2 downto 0);
        Is_to_w     : out std_logic;
        Is_to_ld    : out std_logic;
	w_acc 	    : out std_logic;
        ula_sel     : out unsigned(1 downto 0)
    );
end component;

component pc is
    port (
        clk      : in std_logic;
        rst      : in std_logic;
        wr_en    : in std_logic;
        data_in  : in unsigned(6 downto 0);
        data_out : out unsigned(6 downto 0)
    );
end component;

component rom is
    port(
        clk      : in  std_logic;
        address : in  unsigned(6 downto 0);
        data     : out unsigned(15 downto 0)
    );
end component;

component reg16bits is
    port(
        clk      : in std_logic;
        rst      : in std_logic;
        wr_en    : in std_logic;
        data_in  : in unsigned(15 downto 0);
        data_out : out unsigned(15 downto 0)
    );
end component;

component sm is
    port(
        clk, rst: in std_logic;
        state: out unsigned(1 downto 0);
        FDE: out unsigned(2 downto 0)
    );
end component;

component mux32x16 is
    port(
        data_in0  : in unsigned(15 downto 0);
        data_in1  : in unsigned(15 downto 0);
        data_out : out unsigned(15 downto 0);
        selec: in std_logic
    );
end component;

component reg1bit is
    port(
        clk      : in std_logic;
        rst      : in std_logic;
        wr_en    : in std_logic;
        data_in  : in std_logic;
        data_out : out std_logic
    );
end component;

signal reg_to_mux, cte_to_mux, mux_to_ula, romOutS, romOutI: unsigned(15 downto 0);
signal uc_to_mux, saidaULA, acc_to_ula, mux_to_acc: unsigned(15 downto 0);
signal uc_to_pc, pc_to_ucROM: unsigned(6 downto 0);
signal FDEs, regUc_to_bdr, uc_to_bdrReg: unsigned(2 downto 0);
signal ula_selS: unsigned(1 downto 0);
signal flag_to_mux, uc_to_bdrIs, uc_to_muxLd, w_accS: std_logic;

    --Flags
signal flag_c, flag_n, flag_o, flag_z, e_flagS: std_logic;
signal flag_c_ula, flag_n_ula, flag_o_ula, flag_z_ula: std_logic;
begin
    U_L_A: ula port map(
        entrada1 => acc_to_ula,
        entrada2 => mux_to_ula,
        seletor => ula_selS,
        saida => saidaULA,
	cf => flag_o,
        C => flag_c_ula,
        N => flag_n_ula,
        O => flag_o_ula,
	Z => flag_z_ula,
	enable_flag => e_flagS
    );

    B_D_R: bdr port map(
        reg_data     => reg_to_mux,
        regnum       => regUc_to_bdr,
        word         => saidaULA,
        reg_to_write => uc_to_bdrReg,
        write_enable => uc_to_bdrIs,
        clkBD        => clkP,
        reset        => resetP
    );

    U_C: uc port map(
        updatePC    => clkP, --FDEs(2)
        instruction => romOutI,
        address     => pc_to_ucROM,
	C 	    => flag_c,
        N 	    => flag_n,
        O 	    => flag_o,
        Z 	    => flag_z,
        cte         => cte_to_mux,
        isCte       => flag_to_mux,
        dataO       => uc_to_pc,
        regRead     => regUc_to_bdr,
        word_to_ld  => uc_to_mux,
        reg_to_w    => uc_to_bdrReg,
        Is_to_w     => uc_to_bdrIs,
        Is_to_ld    => uc_to_muxLd,
	w_acc       => w_accS,
        ula_sel     => ula_selS
    );

    P_C: pc port map(
        clk      => clkP,
        rst      => resetP,
        wr_en    => '1',
        data_in  => uc_to_pc,
        data_out => pc_to_ucROM
    );

    R_O_M: rom port map(
        clk     => clkP, --FDEs(2)
        address => pc_to_ucRom,
        data    => romOutS
    );

    --Intruction register
    I_R: reg16bits port map(
        clk      => clkP,
        rst      => resetP,
        wr_en    => clkP,  --FDEs(2)
        data_in  => romOutS,
        data_out => romOutI
    );
    --Accumulator  
    A_C_C: reg16bits port map(
	clk      => clkP,
	rst      => resetP,
	wr_en    => w_accS,
	data_in  => mux_to_acc,
	data_out => acc_to_ula
    );


    S_M: sm port map(
        clk   => clkP,
        rst   => resetP,
        state => stateP,
        FDE   => FDEs
    );

    M_U_X_C: mux32x16 port map(
        data_in0 => reg_to_mux,
        data_in1 => cte_to_mux,
        data_out => mux_to_ula,
        selec     => flag_to_mux
    );

    M_U_X_L: mux32x16 port map(
        data_in0 => saidaULA,
        data_in1 => uc_to_mux,
        data_out => mux_to_acc,
        selec    => uc_to_muxLd
    );
    
    F_C: reg1bit port map(
        clk      => clkP,
        rst      => resetP,
        wr_en    => e_flagS,
        data_in  => flag_c_ula,
        data_out => flag_c
    );


    F_N: reg1bit port map(
        clk      => clkP,
        rst      => resetP,
        wr_en    => e_flagS,
        data_in  => flag_n_ula,
        data_out => flag_n
    );

    F_O: reg1bit port map(
        clk      => clkP,
        rst      => resetP,
        wr_en    => e_flagS,
        data_in  => flag_o_ula,
        data_out => flag_o
    );
    
    F_Z: reg1bit port map(
        clk      => clkP,
        rst      => resetP,
        wr_en    => e_flagS,
        data_in  => flag_z_ula,
        data_out => flag_z
    );


    pcP           <= pc_to_ucROM;
    instructionP  <= romOutI;
    ulaIn1P       <= reg_to_mux;
    ulaIn2P       <= acc_to_ula;
    saidaUlaP     <= saidaULA;
end architecture a_processor;
