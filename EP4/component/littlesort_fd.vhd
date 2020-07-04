--
-- PCS3115 - Sistemas Digitais I
-- 1o Semestre de 2020
--------
-- Projeto 4 - LittleSort
-- Este arquivo contem:
-- 1- Componentes usados para o projeto do Fluxo de Dados
-- 2- Entity do FD que deve ser usada obrigatoriamente
-- Codificaçao: Edson Midorikawa
-- Verificacao: Marco Tulio Carvalho de Andrade
--
-- 2020-07-03
--

-------------------------------------------------------
--! @file cont4.vhd
--! @brief 4-bit synchronous binary counter
--! @author Edson Midorikawa (emidorik@usp.br)
--! @date 2020-06-16
-------------------------------------------------------
library ieee;
use ieee.numeric_bit.all;

entity cont4 is
    port (
        clock, clear, enable: in bit;
        Q:                    out bit_vector (3 downto 0);
        rco:                  out bit
    );
end entity;

architecture comportamental of cont4 is

  signal IQ: integer range 0 to 15;

begin
  
  process (clock,clear,enable,IQ)
  begin
    if clear = '1' then IQ <= 0;   
    elsif clock'event and clock='1' then
      if enable = '1' then 
        if IQ = 15 then IQ <= 0; 
        else            IQ <= IQ + 1; 
        end if;
      end if;
    end if;
    
    Q <= bit_vector(to_unsigned(IQ, Q'length)); 

    if IQ=15 then rco <= '1'; 
    else          rco <= '0'; 
    end if;
        
  end process;

end architecture;

-------------------------------------------------------
--! @file fa_1bit.vhd
--! @brief 1-bit full adder
--! @author Edson S. Gomi (gomi@usp.br)
--! @date 2020-03-21
-------------------------------------------------------
library ieee;
use ieee.numeric_bit.all;

entity fa_1bit is
    port (
      A,B  : in  bit;     -- adends
      CIN  : in  bit;     -- carry-in
      SUM  : out bit;     -- sum
      COUT : out bit      -- carry-out
    );
end entity;

architecture wakerly of fa_1bit is
    -- Solution Wakerly's Book (4th Edition, page 475)
begin
  SUM  <= (A xor B) xor CIN;
  COUT <= (A and B) or (CIN and A) or (CIN and B);
end architecture;

-------------------------------------------------------
--! @file fa_4bit.vhd
--! @brief 4-bit full adder
--! @author Edson S. Gomi (gomi@usp.br)
--! @date 2020-03-21
-------------------------------------------------------
library ieee;
use ieee.numeric_bit.all;

entity fa_4bit is
    port (
        A,B :  in  bit_vector(3 downto 0);  -- adends
        CIN :  in  bit;                     -- carry-in
        SUM :  out bit_vector(3 downto 0);  -- sum
        COUT : out bit                      -- carry-out
    );
end entity;

architecture ripple of fa_4bit is
    -- Ripple adder solution

  --  Declaration of the 1 bit adder.  
  component fa_1bit
  port
  (
      A,B :  in  bit;     -- adends
      CIN :  in  bit;     -- carry-in
      SUM :  out bit;     -- sum
      COUT : out bit      -- carry-out
   );
  end component fa_1bit;

  signal x,y :   bit_vector(3 downto 0);
  signal s :     bit_vector(3 downto 0);
  signal cin0 :  bit;
  signal cout0 : bit;  
  signal cout1 : bit;
  signal cout2 : bit;
  signal cout3 : bit;
  
begin
  
  -- Components instantiation
  ADDER0: fa_1bit port map (
    A => x(0),
    B => y(0),
    CIN => cin0,
    SUM => s(0),
    COUT => cout0
    );

  ADDER1: fa_1bit port map (
    A => x(1),
    B => y(1),
    CIN => cout0,
    SUM => s(1),
    COUT => cout1
    );

  ADDER2: fa_1bit port map (
    A => x(2),
    B => y(2),
    CIN => cout1,
    SUM => s(2),
    COUT => cout2
    );  

  ADDER3: fa_1bit port map (
    A => x(3),
    B => y(3),
    CIN => cout2,
    SUM => s(3),
    COUT => cout3
    );

  x <= A;
  y <= B;
  cin0 <= CIN;
  SUM <= s;
  COUT <= cout3;
  
end architecture ripple;

-------------------------------------------------------
--! @file mux4_2to1.vhd
--! @brief 2-to-1 4-bit multiplexer
--! @author Edson S. Gomi (gomi@usp.br)
--! @date 2020-05-17
-------------------------------------------------------
library ieee;
use ieee.numeric_bit.all;

entity mux4_2to1 is
  port (
    SEL : in  bit;    
    A :   in  bit_vector (3 downto 0);
    B :   in  bit_vector (3 downto 0);
    Y :   out bit_vector (3 downto 0)
  );
end entity mux4_2to1;

architecture with_select of mux4_2to1 is
begin
  with SEL select
    Y <= A when '0',
         B when '1',
         "0000" when others;
end architecture with_select;

-------------------------------------------------------
--! @file reg4.vhd
--! @brief 4-bit register with asynchronous reset
--! @author Edson Midorikawa (emidorik@usp.br)
--! @date 2020-06-15
-------------------------------------------------------
library ieee;
use ieee.numeric_bit.all;

entity reg4 is
  port (
      clock, reset, enable: in  bit;
      D:                    in  bit_vector(3 downto 0);
      Q:                    out bit_vector(3 downto 0)
  );
end entity;

architecture arch_reg4 of reg4 is
  signal dado: bit_vector(3 downto 0);
begin
  process(clock, reset)
  begin
    if reset = '1' then
      dado <= (others=>'0');
    elsif (clock'event and clock='1') then
      if enable='1' then
        dado <= D;
      end if;
    end if;
  end process;
  Q <= dado;
end architecture;

-------------------------------------------------------
--! @file comp4.vhd
--! @brief 4-bit magnitude comparator
--! @author Edson Midorikawa (emidorik@usp.br)
--! @date 2020-06-16
-------------------------------------------------------
library ieee;
use ieee.numeric_bit.all;

entity comp4 is
    port (
        A, B:               in  bit_vector (3 downto 0);
        igual, diferente:   out bit;
        maior, maior_igual: out bit; 
        menor, menor_igual: out bit
    );
end entity;

architecture comportamental of comp4 is
begin
  process (A, B)
    begin
      igual<= '0'; diferente<= '0'; maior<= '0'; 
      maior_igual<= '0'; menor <= '0'; menor_igual <= '0'; 

      if A = B  then igual<= '1';        end if;
      if A /= B then diferente<= '1';    end if;
      if A > B  then maior<= '1';        end if;
      if A >= B then maior_igual<= '1';  end if;
      if A < B  then menor <= '1';       end if;
      if A <= B then menor_igual <= '1'; end if;
  end process;
  
end architecture;

-------------------------------------------------------
--! @file littlesort_fd.vhd
--! @brief structural description for littlesort
--! @author Edson Midorikawa (emidorik@usp.br)
--! @date 2020-07-03
-------------------------------------------------------

entity littleSort_fd is
  port ( 
    clock:             in  bit;
    zera_j:            in  bit;  -- sinais de controle
    conta_j:           in  bit;
    selEnd:            in  bit;
    selDado:           in  bit;
    we_mem:            in  bit;
    apaga_regJ:        in  bit;
    carrega_regJ:      in  bit;
    apaga_regJmais1:   in  bit;
    carrega_regJmais1: in  bit;
    fim_j:             out bit;  -- sinais de condicao
    maior:             out bit;
    mem_we:            out bit;  -- interface com memoria externa
    mem_endereco:      out bit_vector(3 downto 0);
    mem_dado_write:    out bit_vector(3 downto 0);
    mem_dado_read:     in  bit_vector(3 downto 0)
  );
end entity;

architecture estrutural of littleSort_fd is
  
begin

  -- instanciacao dos componentes VHDL
  -- <coloque aqui os componentes internos do projeto>
  -- <seguindo uma descricao do tipo estrutural>
  
  -- sinais para interface com a memoria externa
  -- <coloque aqui os comandos para a especificacao dos>
  -- <sinais de interface com a memoria externa>

end architecture;