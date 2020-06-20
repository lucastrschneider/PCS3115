--------------------------------------------------------------------------------
--! @file turbo.vhd
--! @brief Turbo controller
--! @author Lucas Schneider (lucastrschneider@usp.br)
--! @date 2020/06/17
--! Last submition:
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- 8-bit Generic Register ------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity reg_8bit is 
    port (
        clock : in bit;
        S : in bit; --0 HOLD, 1 LOAD
        set_l, reset_l : in bit; --Asynchronous inputs
        D : in bit_vector(7 downto 0);
        Q : out bit_vector(7 downto 0)
    );
end entity reg_8bit;

architecture reg_8bit_arch of reg_8bit is
    signal IQ : bit_vector(7 downto 0) := (others => '0');
begin
    process (clock, set_l, reset_l)
    begin
        if (reset_l = '0') then IQ <= (others => '0');
        elsif (set_l = '0') then IQ <= (others => '1');
        elsif (rising_edge(clock)) then
            case S is
                when '0' => null;       --HOLD
                when '1' => IQ <= D;    --LOAD
                when others => null;
            end case;
        end if;
        Q <= IQ;
    end process;
end architecture reg_8bit_arch;

--------------------------------------------------------------------------------
-- 1-bit Comparator -------------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity comp_1bit is
    port (
        A, B : in bit;
        e_in, lt_in, gt_in : in bit;
        e_out, lt_out, gt_out : out bit
    );
end entity comp_1bit;

architecture comp_1bit_arch of comp_1bit is
    signal e_intern, lt_intern, gt_intern : bit := '0';
begin
    lt_intern <= (not A) and B;
    gt_intern <= A and (not B);
    e_intern <= lt_intern nor gt_intern;

    lt_out <= (e_intern and lt_in) or lt_intern;
    gt_out <= (e_intern and gt_in) or gt_intern;
    e_out <= e_intern and e_in;
end architecture comp_1bit_arch;

--------------------------------------------------------------------------------
-- n-bit Comparator -------------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity comp_n is
    generic (
        n : positive;
    );
    port (
        A, B : in bit_vector (n-1 downto 0);
        equal, less_then, greater_then : out bit
    );
end entity comp_n;

architecture comp_n_arch of comp_n is
    component comp_1bit is
        port (
            A, B : in bit;
            e_in, lt_in, gt_in : in bit;
            e_out, lt_out, gt_out : out bit
        );
    end component comp_1bit;

    signal e_intern, lt_intern, gt_intern : bit_vector (n downto 0);
begin
    gen_comp: for i in (n-1) downto 0 generate
        comparators: comp_1bit port map (A(i), B(i),
                                        e_intern(i), lt_intern(i), gt_intern(i),
                                        e_intern(i+1), lt_intern(i+1), gt_intern(i+1));
    end generate gen_comp;

    e_intern(0) <= '1';
    lt_intern(0) <= '0';
    gt_intern(0) <= '0';

    equal <= e_intern(n);
    less_then <= lt_intern(n);
    greater_then <= gt_intern(n);

end architecture comp_n_arch;

--------------------------------------------------------------------------------
-- Controle Turbo UC -----------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity turboUC is
    port (
        clock : in bit;
        reset : in bit;
        --comando
        --status
    );
end entity turboUC;

architecture turboUC_arch of turboUC is
    
begin

and architecture turboUC_arch;

--------------------------------------------------------------------------------
-- CONTROLE TURBO --------------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity turbo is
  port (
    clock, reset: in bit; 				-- Sinais de controle globais: clock e reset (para reiniciar)
    button: in bit_vector(7 downto 0);	-- Sinal de entrada: conjunto de botões pressionados
	sensib: in bit_vector(3 downto 0);	-- Sinal de entrada: controle de sensibilidade
    cmd: out bit_vector(7 downto 0)		-- Sinal de saída: resultado do pressionamento do botão no controle turbo
  );
end entity;