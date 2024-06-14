library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bdr is
	port(
		regnum      : in unsigned(2  downto 0); 	--Registrador que sera lido
		word         : in unsigned(15 downto 0); 	--O que sera escrito
		reg_to_write : in unsigned(2 downto 0);  	--Qual reg eh para escrver
		write_enable : in std_logic; 			--Habilitar para escrever
		clkBD        : in std_logic;		
		reset        : in std_logic;
		reg_data    : out unsigned(15 downto 0)  	--Informacao que esta no reg 
	);
end entity;

architecture a_bdr of bdr is
	component reg16bits is
      		port( 	clk      : in std_logic;
                	rst      : in std_logic;
                	wr_en    : in std_logic;
                	data_in  : in unsigned(15 downto 0);
                	data_out : out unsigned(15 downto 0)
	 	 );	
	end component;	
	--Declarando sinais
	signal wr_en_sig: unsigned(7 downto 1);
	signal out_sig: unsigned(127 downto 0);
begin
	--Declarando registradores
	reg7: reg16bits port map(clk=>clkBD,rst=>reset,wr_en=>wr_en_sig(7),data_in=>word,data_out=>out_sig(127 downto 112));
 	reg6: reg16bits port map(clk=>clkBD,rst=>reset,wr_en=>wr_en_sig(6),data_in=>word,data_out=>out_sig(111 downto 96));
 	reg5: reg16bits port map(clk=>clkBD,rst=>reset,wr_en=>wr_en_sig(5),data_in=>word,data_out=>out_sig(95  downto 80));
 	reg4: reg16bits port map(clk=>clkBD,rst=>reset,wr_en=>wr_en_sig(4),data_in=>word,data_out=>out_sig(79  downto 64));
 	reg3: reg16bits port map(clk=>clkBD,rst=>reset,wr_en=>wr_en_sig(3),data_in=>word,data_out=>out_sig(63  downto 48));
	reg2: reg16bits port map(clk=>clkBD,rst=>reset,wr_en=>wr_en_sig(2),data_in=>word,data_out=>out_sig(47  downto 32));
 	reg1: reg16bits port map(clk=>clkBD,rst=>reset,wr_en=>wr_en_sig(1),data_in=>word,data_out=>out_sig(31  downto 16));
        --Pelas especificacoes no pdf esse cara deve ser sempre 0
 	reg0: reg16bits port map(clk=>clkBD,rst=>reset,wr_en=>'0',data_in=>"0000000000000000",data_out=>out_sig(15 downto 0));

	--LOGICA  PARA ESCRITA
	--wr_en_sig(TO_INTEGER(reg_to_write)) <= '1' when write_enable='1';
	--wr_en_sig <= "0000000" when write_enable='0';
        
	--LOGICA PARA SAIDA
        reg_data <= out_sig( ((TO_INTEGER(regnum)+1)*16 -1) downto (TO_INTEGER(regnum)*16) );

	wr_en_sig<= "0000000" when write_enable='0'   else	
		    "0000001" when reg_to_write="001" else
		    "0000010" when reg_to_write="010" else
		    "0000100" when reg_to_write="011" else
		    "0001000" when reg_to_write="100" else
		    "0010000" when reg_to_write="101" else
		    "0100000" when reg_to_write="110" else
		    "1000000" when reg_to_write="111" else
		    "0000000";
		   	 
	--process(write_enable, reg_to_write)
	--begin	
		----LOGICA  PARA ESCRITA(ARRUMAR ISSO DAQUI ALGUM DIA)
		--if write_enable='1' then
		--	wr_en_sig <= "0000000";
		--	wr_en_sig(TO_INTEGER(reg_to_write)) <= '1';
		--else 
		--	wr_en_sig <= "0000000";
		--end if;
	--end process;

end architecture;
