library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity rom is
    port(
        clk : in std_logic;
        endereco : in unsigned(15 downto 0);
        dado : out unsigned(14 downto 0)
    );
end entity;
architecture a_rom of rom is
    type mem is array (0 to 8533) of unsigned(14 downto 0);
    constant conteudo_rom : mem := (
        "100001100000101", -- NOP
"101001100000101", -- LDI R3, 5
"101010000001000", -- LDI R4, 8
"000001101000000", -- ADD R3, R4
"010010100110000", -- MOV R5, R3
"100010100000001", -- SUBI R5, 1
"110000000010100", -- JMP 20
"101011100000101", -- LDI R7, 5
"010001101010000", -- MOV R3, R5
"110000000000011", -- JMP 3
"101011000000101", -- LDI R6, 5
--        0 => "100001100000101", -- NOP
--        1 => "101001100000101", -- LDI R3, 5
--        2 => "101010000001000", -- LDI R4, 8
--        3 => "000001101000000", -- ADD R3, R4
--        4 => "010010100110000", -- MOV R5, R3
--        5 => "100010100000001", -- SUBI R5, 1
--        6 => "110000000010100", -- JMP 20
--        7 => "101011100000101", -- LDI R7, 5
--        20 => "010001101010000", -- MOV R3, R5
--        21 => "110000000000011", -- JMP 3
--        22 => "101011000000101", -- LDI R6, 5

        others => (others=>'0')
    );
begin
    process(clk)
    begin
        if(rising_edge(clk)) then
            dado <= conteudo_rom(to_integer(endereco));
        end if;
    end process;
end architecture;