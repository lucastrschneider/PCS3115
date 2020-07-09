--------------------------------------------------------------------------------
--! @file turbo_tb.vhd
--! @brief Testbench for Turbo Controller
--! @author Lucas Schneider (lucastrschneider@usp.br)
--! @date 2020/06/20
--------------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;
use std.textio.all;

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

    constant PERIOD : time := 1 ns;
	signal finished : boolean := false;
begin
    clock <= not clock after PERIOD/2 when not finished else '0';

    DUT: turbo port map (clock, reset, button, sensib, cmd);

    MAIN: process
        file tb_file : text open read_mode is "EP3/turbo_tb.dat";
        variable tb_line: line;
        variable space: character;
        variable sensib_v : bit_vector(3 downto 0);
        variable button_v, cmd_v : bit_vector(7 downto 0);
        variable counter : integer := 0;
    begin
        report "BOT";
        finished <= false;

        wait for PERIOD*2;
        reset <= '1';
        wait for PERIOD*2;
        reset <= '0';
        wait for PERIOD;

        while not endfile(tb_file) loop
            -- read inputs
            readline(tb_file, tb_line);
            read(tb_line, sensib_v);
            sensib <= sensib_v;

            button <= "00000000";
            wait for PERIOD*2;
            wait until falling_edge(clock);

            for i in 1 to 32 loop
            read(tb_line, space);
            read(tb_line, button_v);
            read(tb_line, space);
            read(tb_line, cmd_v);
            
            button <= button_v;
            wait until rising_edge(clock);
            wait for PERIOD*3/4;

            assert cmd = cmd_v
                report "Test " &integer'image(counter) & ": Failed with sensibility "&
                integer'image(to_integer(unsigned(sensib))) &" on iteration number "&
                integer'image(i)
                severity failure;
            

            end loop;

            report "Test " &integer'image(counter) & ": SUCCESS";
            counter := counter + 1;
        end loop;

        finished <= true;
        report "EOT";
        wait;
    end process;
end architecture turbo_tb_arch;