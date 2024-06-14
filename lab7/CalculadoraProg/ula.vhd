library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ula is
    port ( x,y : in signed(15 downto 0);
        op: in unsigned(2 downto 0);
        result: out unsigned(15 downto 0)
    );
end entity;

architecture a_ula of ula is
    signal tmp: signed(31 downto 0);
begin
    tmp <= x*y;
    result <=   unsigned(x + y) when op="000" else -- Soma
    unsigned(x - y) when op="001" else -- Subtração
    unsigned(tmp(15 downto 0)) when op="010" else -- Multiplicação
                "0000000000000001" when op="011" AND x=y else -- X igual a y
                "0000000000000001" when op="100" AND x>y else -- X maior que y
                "0000000000000001" when op="101" AND x(15)='1' else -- X negativo
                "0000000000000000";
end architecture;