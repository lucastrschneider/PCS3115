-------------------------------------------------------
--! @file littlesort.vhd
--! @brief littlesort circuit
--! @author Edson Midorikawa (emidorik@usp.br)
--! @date 2020-06-30
-------------------------------------------------------

entity littleSort is
  port 
  ( 
    clock:           in  bit;
    reset:           in  bit;
    Iniciar:         in  bit;
    mem_we:          out bit;                     -- sinais da   
    mem_endereco:    out bit_vector(3 downto 0);  -- interface
    mem_dado_write:  out bit_vector(3 downto 0);  -- com a memoria
    mem_dado_read:   in  bit_vector(3 downto 0);  -- externa
    Pronto:          out bit
  );
end entity;

architecture estrutural of littleSort is

  component littlesort_uc
  port 
  (  
    clock:             in  bit;
    reset:             in  bit; 
    iniciar:           in  bit;
    fim_j:             in  bit; 
    maior:             in  bit;
    zera_j:            out bit;
    conta_j:           out bit;
    selEnd:            out bit;
    selDado:           out bit;
    we_mem:            out bit;
    apaga_regJ:        out bit;
    carrega_regJ:      out bit;
    apaga_regJmais1:   out bit;
    carrega_regJmais1: out bit;
    pronto:            out bit
  );
  end component;

  component littleSort_fd
  port 
  ( 
    clock:             in  bit;
    zera_j:            in  bit;
    conta_j:           in  bit;
    selEnd:            in  bit;
    selDado:           in  bit;
    we_mem:            in  bit;
    apaga_regJ:        in  bit;
    carrega_regJ:      in  bit;
    apaga_regJmais1:   in  bit;
    carrega_regJmais1: in  bit;
    fim_j:             out bit;
    maior:             out bit;
    mem_we:            out bit;
    mem_endereco:      out bit_vector(3 downto 0);
    mem_dado_write:    out bit_vector(3 downto 0);
    mem_dado_read:     in  bit_vector(3 downto 0)
  );
  end component;

  -- sinais para conexao do FD e UC
  signal s_clock_n:                              bit;
  signal s_zera_j, s_conta_j:                    bit;
  signal s_selEnd, s_selDado:                    bit;
  signal s_we_mem:                               bit;
  signal s_apaga_regJ, s_carrega_regJ:           bit;
  signal s_apaga_regJmais1, s_carrega_regJmais1: bit;
  signal s_fim_j, s_maior:                       bit;

begin

  s_clock_n <= not clock;  -- FD usa borda de descida

  UC: littlesort_uc
      port map
      (  
        clock             => clock,
        reset             => reset,
        iniciar           => Iniciar,
        fim_j             => s_fim_j,
        maior             => s_maior,
        zera_j            => s_zera_j,
        conta_j           => s_conta_j,
        selEnd            => s_selEnd,
        selDado           => s_selDado,
        we_mem            => s_we_mem,
        apaga_regJ        => s_apaga_regJ,
        carrega_regJ      => s_carrega_regJ,
        apaga_regJmais1   => s_apaga_regJmais1,
        carrega_regJmais1 => s_carrega_regJmais1,
        pronto            => Pronto
      );

  FD: littleSort_fd
      port map
      ( 
        clock             => s_clock_n,
        zera_j            => s_zera_j,
        conta_j           => s_conta_j,
        selEnd            => s_selEnd,
        selDado           => s_selDado,
        we_mem            => s_we_mem,
        apaga_regJ        => s_apaga_regJ,
        carrega_regJ      => s_carrega_regJ,
        apaga_regJmais1   => s_apaga_regJmais1,
        carrega_regJmais1 => s_carrega_regJmais1,
        fim_j             => s_fim_j,
        maior             => s_maior,
        mem_we            => mem_we,
        mem_endereco      => mem_endereco,
        mem_dado_write    => mem_dado_write,
        mem_dado_read     => mem_dado_read
      );

end architecture;