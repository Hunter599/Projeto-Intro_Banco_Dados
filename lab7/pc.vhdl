library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pc is
	port (
            clk      : in std_logic;
            rst      : in std_logic;
            wr_en    : in std_logic;
            data_in  : in unsigned(6 downto 0);
            data_out : out unsigned(6 downto 0)
        );
end;

architecture a_pc of pc is
	signal registerS: unsigned(6 downto 0) := "0000000";
begin
    	process(clk, rst, wr_en)
	begin
		if rst='1' then
			registerS<="0000000";
		elsif wr_en='1' then
			if rising_edge(clk) then
				registerS<= data_in;
			end if; 		
		end if;
    	end process;
	data_out<= registerS;
end architecture;
