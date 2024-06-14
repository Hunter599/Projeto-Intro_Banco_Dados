library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
    port( 
        clk      : in  std_logic;
              address : in  unsigned(6 downto 0);
        data      : out unsigned(15 downto 0)
    );
end entity;

architecture a_romof of rom is 
    type mem is array (0 to 127) of unsigned(15 downto 0);
    constant content_rom : mem := (
        0  => B"000000000101_0011",    -- li r3, 5
        --Carregando r2 com 30 para ser usado no CMP
        1  => B"000000011110_0011",     -- li a, 30
                2  => B"00000000_1_010_0101",   -- mov r2, a
        --A. Carrega R3 (o registrador 3) com o valor 0
        3  => B"000000000000_0011",        -- li a, 0
                4  => B"00000000_1_011_0101",   -- mov r3, a
        --B. Carrega R4 com 0
        5  => B"000000000000_0011",        -- li a, 0
                6  => B"00000000_1_100_0101",   -- mov r4, a
        --C. Soma R3 com R4 e guarda em R4
        7  => B"00000000_0_011_0101",   -- mov a, r3
                8  => B"000000000_100_0001",    -- add a, r4
                9  => B"00000000_1_100_0101",   -- mov r4, a
        --D. Soma 1 em R3
        10 => B"000000000001_0011",        -- li a, 1
        11 => B"000000000_011_0001",    -- add a, r3
        12 => B"00000000_1_011_0101",   -- mov r3, a
        --Se R3<30 salta para a instrução do passo C
        13 => B"000000000_010_0111",    -- cmp r2, a
                14 => B"0_11_11111001_1_0100",  -- jr z, -7
        --F. Copia valor de R4 para R5
        15 => B"00000000_0_100_0101",   -- mov a, r4
        16 => B"00000000_1_101_0101",   -- mov r5, a
        others => (others=>'0')
    );
begin
    process(clk)
    begin                              --Aqui é "falling" e nao "rising" para sincronizar
        if(falling_edge(clk)) then --com a o flipflop da UC que esta em "rising"
            data <= content_rom(to_integer(address));
        end if;
    end process;
end architecture;    

