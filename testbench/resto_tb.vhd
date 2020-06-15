--------------------------------------------------------------------------------
--! @file resto_tb.vhd
--! @brief Testbench for 16-bit rest of division calculator
--! @author Lucas Schneider (lucastrschneider@usp.br)
--! @date 2020/06/14
--------------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity resto_tb is
end resto_tb;

architecture resto_tb_arch of resto_tb is
    component resto is
    port (
        clock, reset : in bit;
        inicio : in bit;
        fim : out bit;
        dividendo, divisor : in bit_vector(15 downto 0);
        resto : out bit_vector(15 downto 0)
    );
end component;

    signal clock, reset, inicio, fim : bit;
    signal dividendo, divisor, resto_out : bit_vector(15 downto 0);

    constant PERIOD : time := 1 ns;
    signal time_passed : time;
	signal finished : boolean := false;
    signal times_up : boolean := false;
    signal resto_n: integer;
begin
    clock <= not clock after PERIOD/2 when not finished else '0';

    cp1: resto port map (clock, reset, inicio, fim, dividendo, divisor, resto_out);
    
    main: process is
    begin
        report "BOOT";
        finished <= false;

        for dividendo_n in 35530 to 35535 loop
            for divisor_n in 0 to 9 loop
                dividendo <= bit_vector(to_unsigned(dividendo_n,16));
                divisor <= bit_vector(to_unsigned(divisor_n,16));
                if (divisor_n = 0) then
                    resto_n <= dividendo_n;
                else
                    resto_n <= dividendo_n mod divisor_n;
                end if;
                    

                inicio <= '1';
                wait until fim = '1' for 200000 ns;
                inicio <= '0';

                if (fim = '0') then
                    report
                        "Max time exceded on "&
                        integer'image(to_integer(unsigned(dividendo))) &" mod "&
                        integer'image(to_integer(unsigned(divisor)))
                    severity failure;

                else
                    assert resto_n = to_integer(unsigned(resto_out))
                    report
                        "Error "&
                        "dividendo: "&integer'image(to_integer(unsigned(dividendo))) &" "&
                        "divisor: "&integer'image(to_integer(unsigned(divisor))) &" "&
                        "resto: "&integer'image(to_integer(unsigned(resto_out))) &" "&
                        "expected: "&integer'image(resto_n)
                    severity failure;
                    report "SUCESS: "&
                        integer'image(to_integer(unsigned(dividendo))) &" mod "&
                        integer'image(to_integer(unsigned(divisor))) &" = "&
                        integer'image(to_integer(unsigned(resto_out)));
                end if;

                wait for 1 ns;
            end loop;
        end loop;
        
        finished <= true;
        report "EOT";
        wait;
    end process;
end architecture resto_tb_arch;
