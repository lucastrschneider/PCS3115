--------------------------------------------------------------------------------
--! @file resto.vhd
--! @brief 16-bit rest of division calculator
--! @author Lucas Schneider (lucastrschneider@usp.br)
--! @date 2020/06/14
--! Last submition: #270
--------------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity restoDF is
    port (
        clock : in bit;
        dividendo, divisor : in bit_vector(15 downto 0); --entrada de dados
        inicializa, subtrai, compara : in bit; --controle
        resto : out bit_vector(15 downto 0); --saida de dados
        divisor_nulo, resto_menor_divisor : out bit --status
    );
end entity;

architecture restoDF_arch of restoDF is
    signal resto_interno : bit_vector(15 downto 0) := dividendo;
    signal minuendo : bit_vector(15 downto 0) := dividendo;
begin
    
    SUB: process(clock)
    begin
        if (falling_edge(clock)) then
            if (inicializa = '1') then
                resto_interno <= dividendo;
            elsif (subtrai = '1') then
                resto_interno <= bit_vector(unsigned(minuendo) - unsigned(divisor));
            elsif (compara = '1') then
                minuendo <= resto_interno;
            end if;
        end if;
    end process;

    divisor_nulo <= '1' when (unsigned(divisor) = 0) else '0';
    resto_menor_divisor <= '1' when (unsigned(resto_interno) < unsigned(divisor)) else '0';

    resto <= resto_interno;

end architecture;

--------------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity restoCU is
    port (
        clock : in bit;
        reset, inicio : in bit; --entradas de controle
        resto_menor_divisor, divisor_nulo : in bit; --status
        inicializa, subtrai, compara : out bit; --controle
        fim : out bit --saidas de controle
    );
end entity;

architecture restoCU_arch of restoCU is
    type state_t is (IDLE, INIT, COMPARE, SUBTRACT, OVER);
    signal actual_state : state_t := IDLE;
    signal next_state : state_t := IDLE;

begin

--    DEBUG: process (clock)
--    begin
--        if (rising_edge(clock)) then report "SUBIDA"; else report "DESCIDA"; end if; 
--        report "actual_state: "&state_t'image(actual_state)&"\n    next_state: "&state_t'image(next_state)
--            &"\n    STATUS-> resto_menor_divisor: "&bit'image(resto_menor_divisor)&"    divisor_nulo: "&bit'image(divisor_nulo)
--            &"\n    CONTROLE-> inicializa: "&bit'image(inicializa)&"    subtrai: "&bit'image(subtrai)&"    compara: "&bit'image(compara);
--    end process DEBUG;

    STATE_MEMORY: process(reset, clock)
    begin
        if (reset = '1') then actual_state <= IDLE;
        elsif (rising_edge(clock)) then actual_state <= next_state;
        end if;
    end process STATE_MEMORY;

    NEXT_STATE_LOGIC: process(actual_state, inicio, resto_menor_divisor, divisor_nulo)
    begin
        case actual_state is
            when IDLE =>        if (inicio = '1') then next_state <= INIT;
                                else next_state <= IDLE;
                                end if;                
            when INIT =>        if (divisor_nulo = '1') then next_state <= OVER;
                                else next_state <= COMPARE;
                                end if;
            when COMPARE =>     if (resto_menor_divisor = '1') then next_state <= OVER;
                                else next_state <= SUBTRACT;
                                end if;
            when SUBTRACT =>    next_state <= COMPARE;
            when OVER =>        next_state <= IDLE;
            when others =>      next_state <= IDLE;
        end case;
    end process NEXT_STATE_LOGIC;

    -- CALCULA A SAIDA
    fim <= '1' when (actual_state = OVER) else '0';
    inicializa <= '1' when (actual_state = INIT) else '0';
    subtrai <= '1' when (actual_state = SUBTRACT) else '0';
    compara <= '1' when (actual_state = COMPARE) else '0';

end architecture;

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
    component restoDF is
        port (
            clock : in bit;
            dividendo, divisor : in bit_vector(15 downto 0); --entrada de dados
            inicializa, subtrai, compara : in bit; --controle
            resto : out bit_vector(15 downto 0); --saida de dados
            divisor_nulo, resto_menor_divisor : out bit --status
        );
    end component;

    component restoCU is
        port (
            clock : in bit;
            reset, inicio : in bit; --entradas de controle
            resto_menor_divisor, divisor_nulo : in bit; --status
            inicializa, subtrai, compara : out bit; --controle
            fim : out bit --saidas de controle
        );
    end component;

    signal inicializa : bit := '0'; --controle
    signal subtrai : bit := '0'; --controle
    signal compara : bit := '0'; --controle

    signal divisor_nulo : bit := '0'; --status
    signal resto_menor_divisor : bit := '0'; --status

    signal fim_out : bit; --saida de controle
    signal resto_out : bit_vector(15 downto 0); --saida de dados

begin

    CU: restoCU port map(clock,
                        reset, inicio,
                        resto_menor_divisor, divisor_nulo,
                        inicializa, subtrai, compara,
                        fim_out);

    DF: restoDF port map(clock,
                        dividendo, divisor,
                        inicializa, subtrai, compara,
                        resto_out,
                        divisor_nulo, resto_menor_divisor);

    fim <= fim_out;
    resto <= resto_out;
                    
end resto_arch;