library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bancoReg is
    port (
        clk         : in  std_logic; -- clock
        rst         : in  std_logic; -- reset flag
        wr_en       : in  std_logic; -- write enable flag
        r_reg_0     : in  unsigned(2 downto 0); -- address of reg for r_data_0
        r_reg_1     : in  unsigned(2 downto 0); -- address of reg for r_data_0
        w_data      : in  unsigned(15 downto 0); -- data to write to reg in address w_reg
        w_reg       : in  unsigned(2 downto 0); -- address to the reg where the data will be written
        r_data_0    : out unsigned(15 downto 0); -- data of the selected reg by r_reg_0
        r_data_1    : out unsigned(15 downto 0) -- data of the selected reg by r_reg_1
    );
end;

architecture a_bancoReg of bancoReg is
    component mux16x8 is
        port(
            sel     : IN unsigned (2 downto 0);
            in_0    : IN unsigned (15 downto 0);
            in_1    : IN unsigned (15 downto 0);
            in_2    : IN unsigned (15 downto 0);
            in_3    : IN unsigned (15 downto 0);
            in_4    : IN unsigned (15 downto 0);
            in_5    : IN unsigned (15 downto 0);
            in_6    : IN unsigned (15 downto 0);
            in_7    : IN unsigned (15 downto 0);
            out_sel : OUT unsigned (15 downto 0)
        );
    end component;
    component reg16bits is
        port(
            clk: IN std_logic;
            rst: IN std_logic;
            wr_en: IN std_logic;
            data_in: IN unsigned (15 downto 0);
            data_out: OUT unsigned (15 downto 0)
        );
    end component;
    
    signal w_en_1, w_en_2, w_en_3, w_en_4, w_en_5, w_en_6, w_en_7: std_logic:='0';
    signal data_1, data_2, data_3, data_4, data_5, data_6, data_7: unsigned (15 downto 0);
    constant data_0: unsigned(15 downto 0) := "0000000000000000";
    
begin
    -- Definition of registers
    reg_1: reg16bits port map (clk => clk, rst => rst, wr_en => w_en_1, data_in => w_data, data_out => data_1);
    reg_2: reg16bits port map (clk => clk, rst => rst, wr_en => w_en_2, data_in => w_data, data_out => data_2);
    reg_3: reg16bits port map (clk => clk, rst => rst, wr_en => w_en_3, data_in => w_data, data_out => data_3);
    reg_4: reg16bits port map (clk => clk, rst => rst, wr_en => w_en_4, data_in => w_data, data_out => data_4);
    reg_5: reg16bits port map (clk => clk, rst => rst, wr_en => w_en_5, data_in => w_data, data_out => data_5);
    reg_6: reg16bits port map (clk => clk, rst => rst, wr_en => w_en_6, data_in => w_data, data_out => data_6);
    reg_7: reg16bits port map (clk => clk, rst => rst, wr_en => w_en_7, data_in => w_data, data_out => data_7);
    -- Output 0 MUX (r_data_0)
    mux_out_0: mux16x8 port map (sel => r_reg_0, out_sel => r_data_0, in_0 => data_0, in_1 => data_1, in_2 => data_2, in_3 => data_3, in_4 => data_4, in_5 => data_5, in_6 => data_6, in_7 => data_7);
    -- Output 1 MUX (r_data_1)
    mux_out_1: mux16x8 port map (sel => r_reg_1, out_sel => r_data_1, in_0 => data_0, in_1 => data_1, in_2 => data_2, in_3 => data_3, in_4 => data_4, in_5 => data_5, in_6 => data_6, in_7 => data_7);
    -- Checking WR_ENABLE for each reg
    w_en_1 <= '1' when wr_en = '1' AND w_reg = "001" else '0';
    w_en_2 <= '1' when wr_en = '1' AND w_reg = "010" else '0';
    w_en_3 <= '1' when wr_en = '1' AND w_reg = "011" else '0';
    w_en_4 <= '1' when wr_en = '1' AND w_reg = "100" else '0';
    w_en_5 <= '1' when wr_en = '1' AND w_reg = "101" else '0';
    w_en_6 <= '1' when wr_en = '1' AND w_reg = "110" else '0';
    w_en_7 <= '1' when wr_en = '1' AND w_reg = "111" else '0';
end architecture;