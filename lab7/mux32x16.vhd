library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mux32x16 is
    port(
        data_in0  : in unsigned(15 downto 0);
        data_in1  : in unsigned(15 downto 0);
        data_out : out unsigned(15 downto 0);
        selec: in STD_LOGIC
    );
end entity mux32x16;

architecture a_mux32x16 of mux32x16 is
    signal out0: unsigned(15 downto 0);
begin
    out0 <= data_in0 when selec ='0' else 
    	    data_in1 when selec ='1' else
    "0000000000000000";
    
    data_out <= out0;
    

end architecture a_mux32x16;
