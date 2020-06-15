--------------------------------------------------------------------------------
--! @file resto.vhd
--! @brief 16-bit rest of division calculator
--! @author Lucas Schneider (lucastrschneider@usp.br)
--! @date 2020/06/14
--------------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity resto is
    port (
        clock, reset : in bit;
        inicio : in bit;
        fim : out bit;
        dividendo, divisor : in bit_vector(15 downto 0);
        resto : out bit_vector(15 downto 0)
    );
end entity;

architecture resto_arch of resto is
    type state_t is (IDLE, CHECK, COMPARE, SUBTRACT, OVER);
    signal actual_state, next_state : state_t;
    signal divisor_nulo, resto_menor : bit;
    signal aux_rest : bit_vector(15 downto 0);

begin
--    DEBUG: process(clock)
  --  begin
    --    report "State: "&state_t'image(actual_state);
      --  if (actual_state = CHECK) then report "aux_rest CHECK value: "&integer'image(to_integer(unsigned(aux_rest)));
        --elsif (actual_state = COMPARE) then report "aux_rest COMP value: "&integer'image(to_integer(unsigned(aux_rest)));
        --end if;

        --report "resto_menor flag: "&bit'image(resto_menor);
    --end process DEBUG;

    ESTADO_ATUAL: process(reset, clock)
    begin
        if (reset = '1') then actual_state <= IDLE;
        elsif (rising_edge(clock)) then actual_state <= next_state;
        end if;

    end process ESTADO_ATUAL;

    SUBTRAIR: process(actual_state) 
    begin
        if (actual_state = CHECK) then aux_rest <= dividendo;
        elsif (actual_state = SUBTRACT) then aux_rest <= bit_vector(unsigned(aux_rest) - unsigned(divisor));
        end if;
    end process SUBTRAIR;    

    -- FLAGS PARA CALCULAR PROXIMO ESTADO --
    divisor_nulo <= '1' when (divisor = "0000000000000000") else '0';
    resto_menor <= '1' when (unsigned(aux_rest) < unsigned(divisor)) else '0';     --PRECISA MUDAR

    next_state <=   IDLE when ((actual_state = IDLE) and (inicio = '0')) else
                    CHECK when ((actual_state = IDLE) and (inicio = '1')) else
                    COMPARE when ((actual_state = CHECK) and (divisor_nulo = '0')) else
                    COMPARE when (actual_state = SUBTRACT) else
                    SUBTRACT when ((actual_state = COMPARE) and (resto_menor = '0')) else
                    IDLE when ((actual_state = COMPARE) and (resto_menor = '1')) else
                    IDLE when ((actual_state = CHECK) and (divisor_nulo = '1')) else
                    IDLE;

    -- CALCULA A SAIDA
    fim <=  '1' when ((actual_state = COMPARE) and (resto_menor = '1')) else
            '1' when ((actual_state = CHECK) and (divisor_nulo = '1')) else
            '0';

    resto <= aux_rest; --when (fim = '1') else
                --(others => '0');
                    
end resto_arch;