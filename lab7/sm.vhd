library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--sm = state machine
entity sm is
	port(
		clk,rst : in std_logic;
		state   : out unsigned(1 downto 0);
		FDE     : out unsigned(2 downto 0) --Fetch, Decode and Execute 	
   	);
end entity;

architecture a_sm of sm is
   	signal stateS: unsigned(1 downto 0) :=  "00";
begin
	FDE <= "100" when stateS="00" else 
	       "010" when stateS="01" else
	       "001" when stateS="10";
  	
       	process(clk,rst)
   	begin
   	   if rst='1' then
   	      stateS <= "00";
   	   elsif rising_edge(clk) then
   	      if stateS="10" then        -- se agora esta em 2
   	         stateS <= "00";         -- o prox vai voltar ao zero
   	      else
   	         stateS <= stateS + 1;   -- senao avanca
   	      end if;
   	   end if;
   	end process;
	state <= stateS;
end architecture;
