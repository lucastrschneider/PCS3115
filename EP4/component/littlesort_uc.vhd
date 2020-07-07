-------------------------------------------------------
--! @file littlesort_uc.vhd
--! @brief control unit for littlesort
--! @author Edson Midorikawa (emidorik@usp.br)
--! @date 2020-06-30
-------------------------------------------------------

entity littlesort_uc is
  port 
  (  
    clock:             in  bit;
    reset:             in  bit; 
    iniciar:           in  bit;  -- entrada de controle
    fim_j:             in  bit;  -- sinais de condicao
    maior:             in  bit;
    zera_j:            out bit;  -- sinais de controle
    conta_j:           out bit;
    selEnd:            out bit;
    selDado:           out bit;
    we_mem:            out bit;
    apaga_regJ:        out bit;
    carrega_regJ:      out bit;
    apaga_regJmais1:   out bit;
    carrega_regJmais1: out bit;
    pronto:            out bit   -- saida de controle
  );
end entity;

architecture fsm of littlesort_uc is
  type state_t is (WAITINICIAR,ZRJ,LDREGS1,LDREGS2,SWPMEM1,SWPMEM2,INCJ,RDY);
  signal next_state, current_state: state_t;
begin

  -- Memoria de estado
  process(clock, reset)
  begin
    if reset='1' then
      current_state <= WAITINICIAR;
    elsif clock'event and clock='1' then
      current_state <= next_state;
    end if;
  end process;

  -- Logica de proximo estado
  next_state <=
    WAITINICIAR when (current_state = WAITINICIAR) and (iniciar = '0') else
    ZRJ         when (current_state = WAITINICIAR) and (iniciar = '1') else
    LDREGS1     when (current_state = ZRJ)         and (fim_j = '0')   else
    RDY         when (current_state = ZRJ)         and (fim_j = '1')   else
    LDREGS2     when (current_state = LDREGS1)                         else
    INCJ        when (current_state = LDREGS2)     and (maior = '0')   else
    SWPMEM1     when (current_state = LDREGS2)     and (maior = '1')   else
    SWPMEM2     when (current_state = SWPMEM1)                         else
    INCJ        when (current_state = SWPMEM2)                         else
    LDREGS1     when (current_state = INCJ)        and (fim_j = '0')   else
    RDY         when (current_state = INCJ)        and (fim_j = '1')   else
    WAITINICIAR when (current_state = RDY)                             else
    WAITINICIAR;
 
  -- Decodifica o estado para gerar sinais de controle para o FD
  zera_j            <= '1' when current_state=ZRJ                              else '0';
  conta_j           <= '1' when current_state=INCJ                             else '0';
  selEnd            <= '1' when current_state=LDREGS2 or current_state=SWPMEM2 else '0';
  selDado           <= '1' when current_state=LDREGS2 or current_state=SWPMEM1 else '0';
  we_mem            <= '1' when current_state=SWPMEM1 or current_state=SWPMEM2 else '0';
  apaga_regJ        <= '1' when current_state=WAITINICIAR                      else '0';
  carrega_regJ      <= '1' when current_state=LDREGS1                          else '0';
  apaga_regJmais1   <= '1' when current_state=WAITINICIAR                      else '0';
  carrega_regJmais1 <= '1' when current_state=LDREGS2                          else '0';

  -- Decodifica o estado para gerar as saídas de controle da UC
  pronto            <= '1' when current_state=RDY                              else '0';

end architecture;