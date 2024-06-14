library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processador_tb is
end;

architecture processador_tb of processador_tb is
    component processador is
        port
        (
            clk         : IN std_logic ;
            rst         : IN std_logic ;
            state       : OUT unsigned (1 downto 0);
            pc_out      : OUT unsigned (15 downto 0);
            instruction : OUT unsigned (14 downto 0);
            br_ra       : OUT unsigned (15 downto 0);
            br_rb       : OUT unsigned (15 downto 0);
            ula_out     : OUT unsigned (15 downto 0)
        );
    end component;
    -- Clock period
    constant period_time : time := 100 ns;
    signal finished : std_logic := '0';
    signal clk : std_logic;
    -- Aux Signals
    signal rst : std_logic;
    signal pc: unsigned(15 downto 0);
    signal instruction: unsigned(14 downto 0);
    signal ra: unsigned(15 downto 0);
    signal rb: unsigned(15 downto 0);
    signal ula_out: unsigned(15 downto 0);
    signal state: unsigned(1 downto 0);
begin
    proc0: processador
    port map
    (
        clk => clk,
        rst => rst,
        pc_out => pc,
        instruction => instruction,
        br_ra => ra,
        br_rb => rb,
        ula_out => ula_out,
        state => state
    );

    
    --Total simulation time
    sim_time_proc: process
    begin
        wait for 6.0 us;
        finished <= '1';
        wait;
    end process sim_time_proc;
    
    -- Clock generation
    clk_proc: process
    begin
        while finished /= '1' loop
            clk <= '0';
            wait for period_time/2;
            clk <= '1';
            wait for period_time/2;
        end loop;
        wait;
    end process clk_proc;
    
    -- Testing signals
    process
    begin
        -- Limpa estados
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait;
    end process;
end architecture;

