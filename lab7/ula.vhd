library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ula is
    port(
        entrada1  : in unsigned(15 downto 0);
        entrada2  : in unsigned(15 downto 0);
        seletor   : in unsigned(1 downto 0);
        saida     : out unsigned(15 downto 0);
    	cf: in std_logic;
        C: out std_logic; --Carry
        N: out std_logic; --Negative
        O: out std_logic; --Overflow
    	Z: out std_logic; --Zero
	enable_flag: out std_logic
    );
end entity;

architecture a_ula of ula is
signal entrada1S, entrada2S, saidaS: unsigned(16 downto 0);
begin
    entrada1S <= '0' &  entrada1;
    entrada2S <= '0' &  entrada2;

    saidaS <=entrada1S               when seletor="00" else  --MOV acc
	     entrada2S 		     when seletor="01" else  --MOV bdr
	     (entrada2S + entrada1S) when seletor="10" else  --ADD
	     (entrada2S - entrada1S - ("0000000000000000" & cf)) when seletor="11"; --SUB

    saida <= saidaS(15 downto 0);
    
    enable_flag <= seletor(1);

    --CARRY FLAG(unsigned)
    C <= saidaS(16);
    --NEGATIVE FLAG
    N <= '1' when (saidaS(15)='1' )or 
	 	  ((seletor="11")and(entrada2>entrada1)) else 
	 '0';
    --OVERFLOW FLAG(signed)
    O <= '1' when (entrada1(15)='1' and entrada2(15)='1' and saidaS(15)='0') or 
	 	  (entrada1(15)='0' and entrada2(15)='0' and saidaS(15)='1') else 
	 '0';
    --OVERFLOW ZERO
    Z <= '1' when saidaS="00000000000000000" else
	 '0';
end architecture;
