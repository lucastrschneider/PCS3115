--------------------------------------------------------------------------------
--! @file resto.vhd
--! @brief 16-bit rest of division calculator
--! @author Lucas Schneider (lucastrschneider@usp.br)
--! @date 2020/06/14
--! Last submition: #177 
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
    signal actual_state : state_t := IDLE;
    signal next_state : state_t := IDLE;
    signal resto_aux : bit_vector(15 downto 0) := dividendo;
    signal divisor_nulo : boolean := true;
    signal resto_menor : boolean := false;

begin
--    DEBUG: process(clock)
--    begin
--        report "State: "&state_t'image(actual_state);
--        if (actual_state = CHECK) then report "resto_aux CHECK value: "&integer'image(to_integer(unsigned(resto_aux)));
--        elsif (actual_state = COMPARE) then report "resto_aux COMP value: "&integer'image(to_integer(unsigned(resto_aux)));
--        end if;
--        report "resto_menor flag: "&boolean'image(resto_menor);
--    end process DEBUG;

    STATE_MEMORY: process(reset, clock)
    begin
        if (reset = '1') then actual_state <= IDLE;
        elsif (rising_edge(clock)) then actual_state <= next_state;
        end if;
    end process STATE_MEMORY;

    NEXT_STATE_LOGIC: process(inicio, actual_state)
    begin
        case actual_state is
            when IDLE =>        if (inicio = '1') then next_state <= CHECK;
                                else next_state <= IDLE;
                                end if;                
            when CHECK =>       if (unsigned(divisor) = 0) then next_state <= OVER;
                                else next_state <= COMPARE;
                                end if;
                                --ACTION--
                                resto_aux <= dividendo;

            when COMPARE =>     if (unsigned(resto_aux) < unsigned(divisor)) then next_state <= OVER;
                                else next_state <= SUBTRACT;
                                end if;
            when SUBTRACT =>    next_state <= COMPARE;
                                --ACTION--
                                resto_aux <= bit_vector(unsigned(resto_aux) - unsigned(divisor));

            when OVER =>        next_state <= IDLE;
            when others =>      next_state <= IDLE;
        end case;
    end process NEXT_STATE_LOGIC;

    -- CALCULA A SAIDA
    fim <= '1' when (actual_state = OVER) else '0';
    resto <= resto_aux;
                    
end resto_arch;