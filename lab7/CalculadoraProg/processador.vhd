library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processador is
    port(
        clk: in std_logic;
        rst: in std_logic;
        state: out unsigned(1 downto 0);
        pc_out: out unsigned(15 downto 0);
        instruction: out unsigned(14 downto 0);
        br_ra: out unsigned(15 downto 0);
        br_rb: out unsigned(15 downto 0);
        ula_out: out unsigned(15 downto 0)
    );
end entity;

architecture a_processador of processador is
    component reg16bits is
        port
        (
            clk      : IN std_logic ;
            rst      : IN std_logic ;
            wr_en    : IN std_logic ;
            data_in  : IN unsigned (15 downto 0);
            data_out : OUT unsigned (15 downto 0)
        );
    end component;
    component reg15bits is
        port
        (
            clk      : IN std_logic ;
            rst      : IN std_logic ;
            wr_en    : IN std_logic ;
            data_in  : IN unsigned (14 downto 0);
            data_out : OUT unsigned (14 downto 0)
        );
    end component;
    component rom is
        port
        (
            clk      : IN std_logic ;
            endereco : IN unsigned (15 downto 0);
            dado     : OUT unsigned (14 downto 0)
        );
    end component;
    component maq_estados is
        port
        (
            clk    : IN std_logic ;
            rst    : IN std_logic ;
            estado : OUT unsigned (1 downto 0)
        );
    end component;
    component un_controle is
        port
        (
            clk         : IN std_logic ;
            rst         : IN std_logic ;
            state       : IN unsigned (1 downto 0);
            instr       : IN unsigned (14 downto 0);
            instr_wr_en : OUT std_logic;
            pc_wr_en    : OUT std_logic ;
            pc_rst      : OUT std_logic ;
            jump_en     : OUT std_logic;
            br_wr_en    : OUT std_logic;
            ula_op      : OUT unsigned(2 downto 0);
            ula_in_a_sel: OUT unsigned(1 downto 0);
            ula_in_b_sel: OUT unsigned(1 downto 0)
        );
    end component;
    component bancoReg is
        port
        (
            clk      : IN std_logic ;
            rst      : IN std_logic ;
            wr_en    : IN std_logic ;
            r_reg_0  : IN unsigned (2 downto 0);
            r_reg_1  : IN unsigned (2 downto 0);
            w_data   : IN unsigned (15 downto 0);
            w_reg    : IN unsigned (2 downto 0);
            r_data_0 : OUT unsigned (15 downto 0);
            r_data_1 : OUT unsigned (15 downto 0)
        );
    end component;
    component ula is
        port
        (
            x      : IN signed (15 downto 0);
            y      : IN signed (15 downto 0);
            op     : IN unsigned (2 downto 0);
            result : OUT unsigned (15 downto 0)
        );
    end component;
    signal pc_data_wr: unsigned(15 downto 0) := "0000000000000000";
    signal jmp_addr: unsigned(15 downto 0) := "0000000000000000";
    signal rom_out: unsigned(14 downto 0) := "000000000000000";
    -- Control signals
    signal jump_en: std_logic := '0';
    signal pc_rst: std_logic := '0';
    signal pc_wr_en: std_logic := '0';
    signal instr_wr_en: std_logic := '0';
    -- Aux signals
    signal br_ra_sel: unsigned(2 downto 0);
    signal br_rb_sel: unsigned(2 downto 0);
    signal br_wr_en: std_logic;
    signal br_wr_data: unsigned(15 downto 0);
    signal br_wr_sel: unsigned(2 downto 0);
    signal ula_in_a: unsigned(15 downto 0);
    signal ula_in_b: unsigned(15 downto 0);
    signal ula_op: unsigned(2 downto 0):="000";
    signal ula_in_a_sel: unsigned(1 downto 0);
    signal ula_in_b_sel: unsigned(1 downto 0);
    signal instr_immediate: unsigned(15 downto 0);
begin
    pc: reg16bits
    port map
    (
        clk => clk,
        rst => pc_rst,
        wr_en => pc_wr_en,
        data_in => pc_data_wr,
        data_out => pc_out
    );
    instr_reg: reg15bits
    port map
    (
        clk => clk,
        rst => rst,
        wr_en => instr_wr_en,
        data_in => rom_out,
        data_out => instruction
    );
    m_stados: maq_estados
    port map (
        clk => clk,
        rst => rst,
        estado => state
    );
    u_controle: un_controle
    port map (
        clk => clk,
        rst => rst,
        instr => instruction,
        state => state,
        jump_en => jump_en,
        instr_wr_en => instr_wr_en,
        pc_rst => pc_rst,
        pc_wr_en => pc_wr_en,
        br_wr_en => br_wr_en,
        ula_op => ula_op,
        ula_in_a_sel => ula_in_a_sel,
        ula_in_b_sel => ula_in_b_sel
    );
    m_rom: rom
    port map
    (
        clk => clk,
        endereco => pc_out,
        dado => rom_out
    );
    banco_reg: bancoReg
    port map
    (
        clk      => clk,
        rst      => rst,
        r_reg_0  => br_ra_sel, -- OK
        r_reg_1  => br_rb_sel, -- OK
        wr_en    => br_wr_en, -- OK?
        w_data   => br_wr_data, -- OK?
        w_reg    => br_wr_sel, -- OK
        r_data_0 => br_ra,
        r_data_1 => br_rb
    );
    ula_main: ula
    port map
    (
        x      => signed(ula_in_a), -- OK
        y      => signed(ula_in_b), -- OK?
        op     => ula_op, -- OK?
        result => ula_out
    );
    
    -- Bank Regs connections
    br_ra_sel <= instruction(10 downto 8);
    br_rb_sel <= instruction(6 downto 4);
    br_wr_sel <= instruction(10 downto 8);
    br_wr_data <= ula_out;
    
    -- ULA connections
    ula_in_a <= "0000000000000000" when ula_in_a_sel = "01" else br_ra; -- 00 -> ra | 01 -> zero
    ula_in_b <= instr_immediate when ula_in_b_sel = "01" else br_rb; -- 00 -> rb | 01 -> immediate
    
    -- Completes instruction instruction immediate
    instr_immediate <= "00000000" & instruction(7 downto 0) when instruction(7) = '0' else "11111111" & instruction(7 downto 0);
    
    -- Jump address (direct)
    jmp_addr <= pc_out(15 downto 11) & instruction(10 downto 0);
    
    -- PC jump OR autosum +1 address
    pc_data_wr <= jmp_addr when jump_en = '1' AND state = "01" else  pc_out + 1; -- Chuncho?

end architecture a_processador;