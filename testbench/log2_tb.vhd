--------------------------------------------------------------------------------
--! @file log2_tb.vhd
--! @brief Testbench for 8-bit log base 2 calculator
--! @author Lucas Schneider (lucastrschneider@usp.br)
--! @date 2020/06/17
--------------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.all;

entity log2_tb is
end log2_tb;

architecture dut of log2_tb is
    component log2 is
    port (
        clock, reset: in bit;				-- Sinais de controle globais: clock e reset (para reiniciar)
        start: in bit;						-- Sinal de condicão externo: manda iniciar a execução
        ready: out bit;						-- Sinal de saída: execução finalizada
        N: in bit_vector(7 downto 0);		-- Dados de entrada: valor cujo log2 deve ser calculado
        logval: out bit_vector(3 downto 0)	-- Dados de saída: valor de log2(N)
    );
    end component log2;

    signal clock, reset, start, ready : bit := '0';
    signal N : bit_vector (7 downto 0);
    signal logval : bit_vector (3 downto 0);
    signal logval_int: integer;

    constant PERIOD : time := 1 ns;
	signal finished : boolean := false;
begin
    clock <= not clock after PERIOD/2 when not finished else '0';
    logval_int <= to_integer(signed(logval));

    DUT: log2 port map (clock, reset, start, ready, N, logval);

    MAIN: process
    begin
        report "BOT";
        finished <= false;

        for N_int in 0 to 255 loop
            N <= bit_vector(to_unsigned(N_int,8));

            start <= '1';
            wait until ready = '1' for 200000 ns;
            start <= '0';

            if (ready = '0') then
                report
                    "Max time exceded on log2(" &
                    integer'image(N_int) & ")"
                    severity failure;
            else
                report "log2(" & integer'image(N_int) & ") = " & integer'image(logval_int);

--                if (N_int = 0) then
--                    assert (logval_int = -1) report
--                        "Erro em log2("&integer'image(N_int)&
--                        "). Esperado: -1. Obtido: "&integer'image(logval_int)
--                        severity failure;
--                else
--                    assert(logval_int = integer(floor(log2(real(N_int))))) report
--                        "Erro em log2("&integer'image(N_int)&
--                        "). Esperado: "&integer'image(integer(floor(log2(real(N_int)))))&
--                        ". Obtido: "&integer'image(logval_int)
--                        severity note;
--                end if;
            end if;
        end loop;

        finished <= true;
        report "EOT";
        wait;
    end process;
end architecture;