library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity flipflopT is
    port
        (
            clk      : in  std_logic;
            rst      : in  std_logic;
            data_out : out std_logic
        );
end entity flipflopT;

architecture a_flipflopT of flipflopT is
    signal registerS: std_logic := '0';
begin
    process(clk, rst)
    begin
            if rst='1' then
                   registerS<='0';
        else
            if rising_edge(clk) then
                registerS<= not registerS;    
            end if;
        end if;
        end process;
    data_out<=registerS;
end architecture a_flipflopT;
