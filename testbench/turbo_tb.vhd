--------------------------------------------------------------------------------
--! @file turbo_tb.vhd
--! @brief Testbench for Turbo Controller
--! @author Lucas Schneider (lucastrschneider@usp.br)
--! @date 2020/06/20
--------------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.all;

entity turbo_tb is
end entity turbo_tb;

architecture turbo_tb_arch of turbo_tb is
    component turbo is
        port (
            clock, reset: in bit; 				-- Sinais de controle globais: clock e reset (para reiniciar)
            button: in bit_vector(7 downto 0);	-- Sinal de entrada: conjunto de botões pressionados
            sensib: in bit_vector(3 downto 0);	-- Sinal de entrada: controle de sensibilidade
            cmd: out bit_vector(7 downto 0)		-- Sinal de saída: resultado do pressionamento do botão no controle turbo
        );
    end component turbo;

    signal clock, reset : bit := '0';
    signal button, cmd : bit_vector (7 downto 0) := (others => '0');
    signal sensib : bit_vector (3 downto 0);

    constant PERIOD : time := 10 ns;
	signal finished : boolean := false;
begin
    clock <= not clock after PERIOD/2 when not finished else '0';

    DUT: turbo port map (clock, reset, button, sensib, cmd);

    sensib <= "0001";

    MAIN: process
    begin
        report "BOT";
        finished <= false;

        wait for 20 ns;

        wait for 2 ns;

        button <= "00000001";

        wait for 40 ns;

        button <= "00000010";

        wait for 10 ns;

        reset <= '1';
        button <= "00000011";

        wait for 30 ns;

        reset <= '0';

        wait for 40 ns;

        button <= "00000100";

        wait for 50 ns;

        button <= "00000101";

        finished <= true;
        report "EOT";
        wait;
    end process;
end architecture turbo_tb_arch;