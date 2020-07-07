-------------------------------------------------------
--! @file littlesort_tb.vhd
--! @brief testbench for littlesort circuit
--! @author Edson Midorikawa (emidorik@usp.br)
--! @date 2020-06-19
-------------------------------------------------------


-------------------------------------------------------
--! @brief 2-to-1 1-bit multiplexer
--! @author Edson Midorikawa (emidorik@usp.br)
--! @date 2020-06-30
-------------------------------------------------------
entity mux_2to1 is
  port 
  (
    SEL : in  bit;    
    A :   in  bit;
    B :   in  bit;
    Y :   out bit
  );
end entity;

architecture with_select of mux_2to1 is
begin
  with SEL select
    Y <= A when '0',
         B when '1',
         '0' when others;
end architecture;


-------------------------------------------------------
--! @brief testbench for littlesort circuit
--! @author Edson Midorikawa (emidorik@usp.br)
--! @date 2020-06-19
-------------------------------------------------------
library ieee;
use ieee.numeric_bit.all;
use std.textio.all;

-- entidade do testbench
entity littlesort_tb is
end entity;

architecture tb of littlesort_tb is

  -- Funcoes usadas para o report para bit_vector
  -- autor: Bruno Albertini (balbertini@usp.br)
  function to_bstring(b : bit) return string is
  variable b_str_v : string(1 to 3);
  begin
    b_str_v := bit'image(b);
    return "" & b_str_v(2);
  end function;

  function to_bstring(bv : bit_vector) return string is
    alias    bv_norm : bit_vector(1 to bv'length) is bv;
    variable b_str_v : string(1 to 1);
    variable res_v    : string(1 to bv'length);
  begin
    for idx in bv_norm'range loop
      b_str_v := to_bstring(bv_norm(idx));
      res_v(idx) := b_str_v(1);
    end loop;
    return res_v;
  end function;

  -- Componente a ser testado (Device Under Test -- DUT)
  component littlesort
  port
  (
      clock:           in  bit;
      reset:           in  bit;
      Iniciar:         in  bit;
      mem_we:          out bit;
      mem_endereco:    out bit_vector(3 downto 0);
      mem_dado_write:  out bit_vector(3 downto 0);
      mem_dado_read:   in  bit_vector(3 downto 0);
      Pronto:          out bit
  );
  end component;

  -- componente da memoria externa ao circuito
  component ram16x4
  generic
  (
      data_file_name : string
  );
  port
  (
      clock  : in  bit;
      addr   : in  bit_vector(3 downto 0);
      we     : in  bit;
      data_i : in  bit_vector(3 downto 0);
      data_o : out bit_vector(3 downto 0)
  );
  end component;

  -- componente do mux de endereco da memoria
  component mux4_2to1
  port
  (
      SEL : in bit;    
      A :   in bit_vector  (3 downto 0);
      B :   in bit_vector  (3 downto 0);
      Y :   out bit_vector (3 downto 0)
  );
  end component;

  -- componente do mux para o we
  component mux_2to1 is
  port 
  (
    SEL : in  bit;    
    A :   in  bit;
    B :   in  bit;
    Y :   out bit
  );
  end component;
  
  ---- Declaração de sinais para conectar a componente
  signal clk_in: bit := '0';
  signal rst_in: bit := '0';

  ---- Declaracao dos sinais iniciar e pronto dos casos de teste
  signal iniciar_in, pronto_out: bit := '0';

  ---- Declaracao dos sinais de conexao com as memorias dos casos de teste
  -- conexao com a memoria
  signal mem_we:         bit;
  signal mem_endereco:   bit_vector(3 downto 0);
  signal mem_dado_write: bit_vector(3 downto 0);
  signal mem_dado_read:  bit_vector(3 downto 0);
  -- conexao com muxes
  signal tb_sel_mux:     bit;
  signal dut_endereco:   bit_vector(3 downto 0);
  signal tb_endereco:    bit_vector(3 downto 0);
  signal dut_we:         bit;
  signal tb_we:          bit;

  -- Configurações do clock
  signal keep_simulating: bit := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod : time := 1 ns;
  
begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período especificado. 
  -- Quando keep_simulating=0, clock é interrompido, bem como a simulação de eventos
  clk_in <= (not clk_in) and keep_simulating after clockPeriod/2;
  
  ---- DUT para Caso de Teste
  dut: littlesort
       port map
       (
          clock=>           clk_in,
          reset=>           rst_in,
          Iniciar=>         iniciar_in,
          mem_we=>          dut_we,
          mem_endereco=>    dut_endereco,
          mem_dado_write=>  mem_dado_write,
          mem_dado_read=>   mem_dado_read,
          Pronto=>          pronto_out
       );

  mem: ram16x4
       generic map
       ( 
         data_file_name => "EP4/memoria1.dat"
       )
       port map
       (
         clock=>  clk_in,
         addr=>   mem_endereco,
         we=>     mem_we,
         data_i=> mem_dado_write,
         data_o=> mem_dado_read
       );

  mux1: mux4_2to1
        port map
        (
          SEL=> tb_sel_mux,    
          A =>  dut_endereco,
          B =>  tb_endereco,
          Y =>  mem_endereco
        );

  mux2: mux_2to1
        port map
        (
          SEL=> tb_sel_mux,    
          A =>  dut_we,
          B =>  tb_we,
          Y =>  mem_we
        );

 
  ---- Gera sinais de estimulo
  stimulus: process is
  begin

    -- inicio da simulacao
    report "inicio da simulacao";
    keep_simulating <= '1';

    -->> Caso de teste: memoria1.dat (aleatorio, maior no meio) <<
    --- Fase 1: DUT 
    tb_sel_mux <= '0';  -- DUT acessa a memoria
    iniciar_in <= '0';

    -- gera pulso de reset (1 periodo de clock)
    rst_in <= '1';
    wait for clockPeriod;
    rst_in <= '0';

    wait until falling_edge(clk_in);
    -- pulso do sinal de Iniciar
    iniciar_in <= '1';
    wait until falling_edge(clk_in);
    iniciar_in <= '0';

    -- espera pelo termino da ordenacao
    wait until pronto_out='1';
    report "fim da ordenacao";
    wait for clockPeriod;

    --- Fase 2: verificacao da memoria
    tb_we      <= '0';
    tb_sel_mux <= '1';     -- TB acessa a memoria
    wait for clockPeriod;

    --  Teste 1 - Verifica posicao 2 da memoria (valor esperado A)
    tb_endereco <= "0010"; -- posicao 2 
    wait for clockPeriod;
    -- mostra conteudo da memoria
    report "memoria1[0010]=" & to_bstring(mem_dado_read);
    wait for clockPeriod;

    --  Teste 2 - Verifica ultima posicao da memoria (valor esperado F)
    tb_endereco <= "1111"; -- ultima posicao
    wait for clockPeriod;
    -- mostra conteudo da memoria
    report "memoria1[1111]=" & to_bstring(mem_dado_read);

    wait for clockPeriod;
    tb_sel_mux <= '0';     

    ---- final do testbench
    report "fim da simulacao";
    keep_simulating <= '0';

    wait; -- fim da simulação: processo aguarda indefinidamente
  end process;

end architecture;