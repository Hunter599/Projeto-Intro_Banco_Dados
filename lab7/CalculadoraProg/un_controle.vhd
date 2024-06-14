library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity un_controle is
    port (
        clk : in std_logic;
        rst : in std_logic;
        state: in unsigned(1 downto 0);
        instr : in unsigned(14 downto 0);
        instr_wr_en: out std_logic;
        pc_wr_en: out std_logic;
        pc_rst: out std_logic;
        jump_en: out std_logic;
        br_wr_en: out std_logic;
        ula_op: out unsigned(2 downto 0);
        ula_in_a_sel: out unsigned(1 downto 0);
        ula_in_b_sel: out unsigned(1 downto 0)
    );
end;

architecture a_un_controle of un_controle is
    signal opcode_i: unsigned(2 downto 0);
begin
    -- PC reset signal
    pc_rst <= rst;
    
    -- Slice the opcode from the instruction
    opcode_i <= instr(14 downto 12);
    
    -- Fetch & Decode states
    -- "00" => Fetch
    -- "01" => Decode
    -- "10" => Execute
    instr_wr_en <= '1' when state = "00" else '0';
    
    pc_wr_en <= '1' when state = "00" else 
                '1' when opcode_i = "110" AND state ="01" else '0';
    
    br_wr_en <= '1' when state = "10" AND opcode_i /= "110" else '0'; -- only writes on execute
    
    ula_op <= --"000" when opcode_i = "000" OR opcode_i = "010" OR opcode_i = "011" OR opcode_i = "101" else -- ADD ADIW MOV LDI
              "001" when opcode_i = "001" OR opcode_i = "100" else "000"; -- SUB SUBI
    
    ula_in_a_sel <= "00" when opcode_i /= "010" AND opcode_i /= "101" else  "01"; -- 00 -> ra | 01 -> zero
    ula_in_b_sel <= "00" when opcode_i(2) = '0' AND opcode_i(1 downto 0) /= "11" else "01"; -- 00 -> rb | 01 -> immediate

    -- Jump Instr
    jump_en <= '1' when opcode_i = "110" else '0';
    
end architecture;