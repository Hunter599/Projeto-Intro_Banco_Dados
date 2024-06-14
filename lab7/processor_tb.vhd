library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processor_tb is
end;

architecture a_processor_tb of processor_tb is
    component processor is
    port(
        resetP, clkP       : in std_logic;
                stateP             : out unsigned(1 downto 0);
                pcP                : out unsigned(6 downto 0);
                instructionP       : out unsigned(15 downto 0);
                ulaIn1P, ulaIn2P : out unsigned(15 downto 0);
                --ARRUMAR ACUMULADOR
                saidaUlaP           : out unsigned(15 downto 0)
        );
    end component; 
   
    --SINAIS PARA CALCULAR CLCK
       -- 100 ns é o período que escolhi para o clock
        constant period_time : time      := 10 ns;
        signal   finished    : std_logic := '0';
        signal   clk, resetC : std_logic;

    --SINAIS DO PROCESSADR
        signal resetS             : std_logic := '0';
    	signal stateS             : unsigned(1 downto 0);
        signal pcS                : unsigned(6 downto 0);
        signal instructionS       : unsigned(15 downto 0);
        signal ulaIn1S, ulaIn2S : unsigned(15 downto 0);
        --ARRUMAR ACUMULADOR
        signal saidaULAs          : unsigned(15 downto 0);
begin
    pro: processor port map(
        resetP       => resetS,
        clkP         => clk,
        stateP       => stateS,
        pcP          => pcS,
        instructionP => instructionS,
        ulaIn1P      => ulaIn1S,
        ulaIn2P      => ulaIn2S,
        saidaUlaP    => saidaULAs
        );
    
    reset_global: process
    begin
            resetC <= '1';
            wait for period_time*2; -- espera 2 clocks, pra garantir
            resetC <= '0';
               wait;
        end process;

    	sim_time_proc: process
   	begin
        	wait for 10 us;         -- <== TEMPO TOTAL DA SIMULACAO!!!
       		finished <= '1';
        	wait;
    	end process sim_time_proc;
    	clk_proc: process
    	begin                       -- gera clock até que sim_time_proc termine
       		while finished /= '1' loop
            	clk <= '0';
            	wait for period_time/2;
            	clk <= '1';
            	wait for period_time/2;
        	end loop;
        	wait;
    	end process clk_proc;
   	process                      -- sinais dos casos de teste (p.ex.)
   	begin
		wait for 7000 ns;
			resetS <= '1';
      		wait;                     -- <== OBRIGATORIO TERMINAR COM WAIT; !!!
  	end process;
end architecture a_processor_tb;
