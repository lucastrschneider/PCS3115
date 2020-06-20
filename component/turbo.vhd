--------------------------------------------------------------------------------
--! @file turbo.vhd
--! @brief Turbo controller
--! @author Lucas Schneider (lucastrschneider@usp.br)
--! @date 2020/06/20
--! Last submition: #334 (Elaboration Error)
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
            if (S = '1') then IQ <= D;
            end if;
        end if;
    end process;
    Q <= IQ;
end architecture reg_8bit_arch;

--------------------------------------------------------------------------------
-- n-bit Comparator -------------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity comp_n is
    generic (
        n : positive
    );
    port (
        A, B : in bit_vector (n-1 downto 0);
        equal, less_then, greater_then : out bit
    );
end entity comp_n;

architecture comp_n_arch of comp_n is
begin
    equal <= '1' when (unsigned(A) = unsigned(B)) else '0';
    less_then <= '1' when (unsigned(A) < unsigned(B)) else '0';
    greater_then <= '1' when (unsigned(A) > unsigned(B)) else '0';
end architecture comp_n_arch;

--------------------------------------------------------------------------------
-- 4-bit Counter ---------------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity counter_4bit is
    port (
        clock : in bit;
        enable, reset_l : in bit;
        Q : out bit_vector(3 downto 0)
    );
end entity counter_4bit;

architecture counter_4bit_arch of counter_4bit is
    signal IQ : unsigned (3 downto 0) := "0000";
begin
    process (clock, reset_l) is
    begin
        if (rising_edge(clock)) then
            if (reset_l = '0') then
                IQ <= (others => '0');
            elsif (enable = '1') then
                IQ <= IQ + 1;
            end if;
        end if;
    end process;
    Q <= bit_vector(IQ);
end architecture counter_4bit_arch;

--------------------------------------------------------------------------------
-- Controle Turbo FD -----------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity turboFD is
    port (
        clock : in bit;
        push, zero_f, hold_down : out bit;  -- Status
        cmd_sel, reset_count_l, enable_count, reset_reg_l : in bit;  -- Control
        button: in bit_vector(7 downto 0);	-- Entrada de dados
	    sensib: in bit_vector(3 downto 0);	-- Entrada de dados
        cmd: out bit_vector(7 downto 0)	    -- Saida de dados
    );
end entity turboFD;

architecture turboFD_arch of turboFD is
    component reg_8bit is 
        port (
            clock : in bit;
            S : in bit; --0 HOLD, 1 LOAD
            set_l, reset_l : in bit; --Asynchronous inputs
            D : in bit_vector(7 downto 0);
            Q : out bit_vector(7 downto 0)
        );
    end component reg_8bit;

    component comp_n is
        generic (
            n : positive
        );
        port (
            A, B : in bit_vector (n-1 downto 0);
            equal, less_then, greater_then : out bit
        );
    end component comp_n;

    component counter_4bit is
        port (
            clock : in bit;
            enable, reset_l : in bit;
            Q : out bit_vector(3 downto 0)
        );
    end component counter_4bit;

    signal clock_n, push_n, counter_lt_sensib : bit;
    signal button_intern, r2_out : bit_vector(7 downto 0);
    signal counter_out : bit_vector(3 downto 0);

begin

    clock_n <= not clock;

    R1: reg_8bit
        port map(clock_n, '1', '1', '1', button, button_intern);

    R2: reg_8bit
        port map(clock, '1', '1', reset_reg_l, button_intern, r2_out);

    COMP8 : comp_n
        generic map (8)
        port map(button, r2_out, push_n, open, open);

    COMP4 : comp_n
        generic map (4)
        port map(counter_out, sensib, open, counter_lt_sensib, open);
    
    COUNT: counter_4bit port map(clock, enable_count, reset_count_l, counter_out);

    push <= not push_n;
    zero_f <= '1' when (unsigned(button_intern) = 0) else '0';
    hold_down <= counter_lt_sensib;

    cmd <= button_intern when (cmd_sel = '1') else (others => '0');


end architecture turboFD_arch;

--------------------------------------------------------------------------------
-- Controle Turbo UC -----------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity turboUC is
    port (
        clock : in bit;
        reset : in bit; -- Entrada de controle
        push, zero_f, hold_down : in bit;   -- Status
        cmd_sel, reset_count_l, enable_count, reset_reg_l : out bit -- Control
    );
end entity turboUC;

architecture turboUC_arch of turboUC is
    type state_t is (INIT, SEND, PULSE, SENSE);
    signal actual_state : state_t := INIT;
    signal next_state : state_t := INIT;
begin
    STATE_MEMORY: process(reset, clock)
    begin
        if (reset = '1') then actual_state <= INIT;
        elsif (rising_edge(clock)) then actual_state <= next_state;
        end if;
    end process STATE_MEMORY;

    NEXT_STATE_LOGIC: process(actual_state, reset, push, zero_f, hold_down)
    begin
        case actual_state is
            when INIT =>        if (reset = '1') then next_state <= INIT;
                                elsif (push = '1') then next_state <= PULSE;
                                else next_state <= INIT;
                                end if;

            when SEND =>        if (push = '1') then next_state <= PULSE;
                                else next_state <= SEND;
                                end if;

            when PULSE =>       if (push = '1') then next_state <= PULSE;
                                elsif (zero_f = '1') then next_state <= SEND;
                                else next_state <= SENSE;
                                end if;
                                    
            when SENSE =>       if (push = '1') then next_state <= PULSE;
                                elsif (hold_down = '1') then next_state <= SENSE;
                                else next_state <= SEND;
                                end if;

            when others =>      next_state <= SEND;
        end case;
    end process NEXT_STATE_LOGIC;

    -- CALCULA A SAIDA
    cmd_sel <=  '0' when (actual_state = INIT) else
                '0' when (actual_state = SENSE) else
                '1';
                
    reset_count_l <= '0' when (actual_state = PULSE) else '1';
    enable_count <= '1' when (actual_state = SENSE) else '0';
    reset_reg_l <= '0' when (actual_state = INIT) else '1';

end architecture turboUC_arch;

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
end entity turbo;

architecture turbo_arch of turbo is
    component turboUC is
        port (
            clock : in bit;
            reset : in bit; -- Entrada de controle
            push, zero_f, hold_down : in bit;   -- Status
            cmd_sel, reset_count_l, enable_count, reset_reg_l : out bit -- Control
        );
    end component turboUC;

    component turboFD is
        port (
            clock : in bit;
            push, zero_f, hold_down : out bit;  -- Status
            cmd_sel, reset_count_l, enable_count, reset_reg_l : in bit;  -- Control
            button: in bit_vector(7 downto 0);	-- Entrada de dados
            sensib: in bit_vector(3 downto 0);	-- Entrada de dados
            cmd: out bit_vector(7 downto 0)	    -- Saida de dados
        );
    end component turboFD;

    signal clock_n : bit;
    signal push, zero_f, hold_down : bit; -- Status
    signal cmd_sel, reset_count_l, enable_count, reset_reg_l : bit; -- Control
    signal cmd_out : bit_vector(7 downto 0);
    
begin
    clock_n <= not clock;

    UC: turboUC port map    (clock,
                            reset,
                            push, zero_f, hold_down,
                            cmd_sel, reset_count_l, enable_count, reset_reg_l);

    FD: turboFD port map    (clock_n,
                            push, zero_f, hold_down,
                            cmd_sel, reset_count_l, enable_count, reset_reg_l,
                            button,
                            sensib,
                            cmd_out);

    cmd <= cmd_out;

end architecture turbo_arch;
