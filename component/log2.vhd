--------------------------------------------------------------------------------
--! @file log2.vhd
--! @brief 8-bit log base 2 calculator
--! @author Lucas Schneider (lucastrschneider@usp.br)
--! @date 2020/06/17
--! Last submition: #316 (VHDL elaboration error)
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- 8-bit Generic Shift Register ------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity shift_reg_8bit is 
    port (
        clock : in bit;
        S : in bit_vector(1 downto 0); --00 HOLD, 01 LOAD, 10 SR, 11 SL
        left_in, right_in : in bit;
        set_l, reset_l : in bit; --Asynchronous inputs
        D : in bit_vector(7 downto 0);
        Q : out bit_vector(7 downto 0)
    );
end entity shift_reg_8bit;

architecture shift_reg_8bit_arch of shift_reg_8bit is
    signal IQ : bit_vector(7 downto 0) := (others => '0');
begin
    process (clock, set_l, reset_l)
    begin
        if (reset_l = '0') then IQ <= (others => '0');
        elsif (set_l = '0') then IQ <= (others => '1');
        elsif (rising_edge(clock)) then
            case S is
                when "00" => null;                              --HOLD
                when "01" => IQ <= D;                           --LOAD
                when "10" => IQ <= right_in & IQ(7 downto 1);   --SHIFT RIGHT
                when "11" => IQ <= IQ(6 downto 0) & left_in;    --SHIFT LEFT
                when others => null;
            end case;
        end if;
        Q <= IQ;
    end process;
end architecture shift_reg_8bit_arch;

--------------------------------------------------------------------------------
-- 4-bit Generic Register ------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity register_4bit is
    port (
        clock : in bit;
        enable : in bit;
        set_l, reset_l : in bit; --Asynchronous inputs
        D : in bit_vector(3 downto 0);
        Q : out bit_vector(3 downto 0)
    );
end entity register_4bit;

architecture register_4bit_arch of register_4bit is

    signal IQ : bit_vector(3 downto 0) := (others => '0');
begin
    process(clock, set_l, reset_l)
    begin
        if (reset_l = '0') then IQ <= (others => '0');
        elsif (set_l = '0') then IQ <= (others => '1');
        elsif (rising_edge(clock)) then
            if (enable = '1') then IQ <= D;
            else null;
            end if;
        end if;
        Q <= IQ;
    end process;
end architecture register_4bit_arch;

--------------------------------------------------------------------------------
-- 1-bit Full Adder ------------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity full_adder is 
    port (
        A, B, Cin : in bit;
        Cout, sum : out bit
    );
end entity full_adder;

architecture full_adder_df of full_adder is
begin
    sum <= A xor B xor Cin;
    Cout <= ((A xor B) and Cin) or (A and B);
end architecture full_adder_df;

--------------------------------------------------------------------------------
-- 4-bit Adder -----------------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity adder_4bit is
    port (
        A, B : in bit_vector(3 downto 0);
        Cin : in bit;
        sum : out bit_vector(3 downto 0);
        Cout, Ov : out bit
    );
end entity adder_4bit;

architecture adder_4bit_arch of adder_4bit is
    component full_adder is 
        port (
            A, B, Cin : in bit;
            Cout, sum : out bit
        );
    end component full_adder;

    signal carry : bit_vector (3 downto 0);
    signal sum_value : bit_vector (3 downto 0);
begin
    fa0: full_adder port map (A(0), B(0), Cin, carry(0), sum_value(0));
    fa1: full_adder port map (A(1), B(1), carry(0), carry(1), sum_value(1));
    fa2: full_adder port map (A(2), B(2), carry(1), carry(2), sum_value(2));
    fa3: full_adder port map (A(3), B(3), carry(2), carry(3), sum_value(3));

    Cout <= carry(3);
    Ov <= carry(3) xor carry(2);
    sum <= sum_value;
end architecture adder_4bit_arch;

--------------------------------------------------------------------------------
-- Log2 Data Flow --------------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity log2FD is
    port (
        clock : in bit;
        N : in bit_vector(7 downto 0); --entrada de dados
        result : out bit_vector(3 downto 0); --saida de dados
        shift_8, load_8, load_4, set_4 : in bit; --controle
        zero_f : out bit --status
    );
end entity log2FD;

architecture log2FD_arch of log2FD is
    component shift_reg_8bit is 
        port (
            clock : in bit;
            S : in bit_vector(1 downto 0); --00 HOLD, 01 LOAD, 10 SR, 11 SL
            left_in, right_in : in bit;
            set_l, reset_l : in bit; --Asynchronous inputs
            D : in bit_vector(7 downto 0);
            Q : out bit_vector(7 downto 0)
        );
    end component;

    component register_4bit is
        port (
            clock : in bit;
            enable : in bit;
            set_l, reset_l : in bit; --Asynchronous inputs
            D : in bit_vector(3 downto 0);
            Q : out bit_vector(3 downto 0)
        );
    end component;

    component adder_4bit is
        port (
            A, B : in bit_vector(3 downto 0);
            Cin : in bit;
            sum : out bit_vector(3 downto 0);
            Cout, Ov : out bit
        );
    end component;

    signal reg_8bit_control : bit_vector(1 downto 0);
    signal N_shift : bit_vector(7 downto 0);
    signal sum, result_interno : bit_vector(3 downto 0);
    signal set_l_4 : bit;

begin
    REG8: shift_reg_8bit port map(clock, reg_8bit_control, '0', '0', '1', '1', N, N_shift);
    REG4: register_4bit port map(clock, load_4, set_l_4, '1', sum, result_interno);
    ADDER: adder_4bit port map(result_interno, "0001", '0', sum, open, open);

    set_l_4 <= not set_4;

    reg_8bit_control <= "01" when (load_8 = '1') else
                        "10" when (shift_8 = '1') else
                        "00";

    zero_f <= '1' when (unsigned(N_shift) = 0) else '0';
    result <= result_interno;

end architecture log2FD_arch;

--------------------------------------------------------------------------------
-- Log2 Control Unit -----------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity log2UC is
    port (
        clock : in bit;
        reset, start : in bit; --entradas de controle
        zero_f : in bit; --status
        shift_8, load_8, load_4, set_4 : out bit; --controle
        ready : out bit --saida de controle
    );
end entity log2UC;

architecture log2UC_arch of log2UC is
    type state_t is (IDLE, INIT, CHECK, SHIFT, OVER);
    signal actual_state : state_t := IDLE;
    signal next_state : state_t := IDLE;
begin
    STATE_MEMORY: process(reset, clock)
    begin
        if (reset = '1') then actual_state <= IDLE;
        elsif (rising_edge(clock)) then actual_state <= next_state;
        end if;
    end process STATE_MEMORY;

    NEXT_STATE_LOGIC: process(actual_state, start, zero_f)
    begin
        case actual_state is
            when IDLE =>        if (start = '1') then next_state <= INIT;
                                else next_state <= IDLE;
                                end if;                
            when INIT =>        next_state <= CHECK;
            when CHECK =>       if (zero_f = '1') then next_state <= OVER;
                                else next_state <= SHIFT;
                                end if;
            when SHIFT =>       next_state <= CHECK;
            when OVER =>        next_state <= IDLE;
            when others =>      next_state <= IDLE;
        end case;
    end process NEXT_STATE_LOGIC;

    -- CALCULA A SAIDA
    ready <= '1' when (actual_state = OVER) else '0';
    shift_8 <= '1' when (actual_state = SHIFT) else '0';
    load_8 <= '1' when (actual_state = INIT) else '0';
    load_4 <= '1' when (actual_state = SHIFT) else '0';
    set_4 <= '1' when (actual_state = INIT) else '0';

end architecture log2UC_arch;

--------------------------------------------------------------------------------
-- LOG 2 CALCULATOR ------------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity log2 is
  port (
    clock, reset: in bit;				-- Sinais de controle globais: clock e reset (para reiniciar)
	start: in bit;						-- Sinal de condicão externo: manda iniciar a execução
    ready: out bit;						-- Sinal de saída: execução finalizada
    N: in bit_vector(7 downto 0);		-- Dados de entrada: valor cujo log2 deve ser calculado
    logval: out bit_vector(3 downto 0)	-- Dados de saída: valor de log2(N)
  );
end entity log2;

architecture log2_arch of log2 is
    component log2FD is
        port (
            clock : in bit;
            N : in bit_vector(7 downto 0); --entrada de dados
            result : out bit_vector(3 downto 0); --saida de dados
            shift_8, load_8, load_4, set_4 : in bit; --controle
            zero_f : out bit --status
        );
    end component;

    component log2UC is
        port (
            clock : in bit;
            reset, start : in bit; --entradas de controle
            zero_f : in bit; --status
            shift_8, load_8, load_4, set_4 : out bit; --controle
            ready : out bit --saida de controle
        );
    end component;

    signal clock_n : bit;

    signal shift_8, load_8, load_4, set_4 : bit := '0'; --controle
    signal zero_f : bit := '0'; --status

    signal ready_interno : bit; --saida de controle
    signal logval_interno : bit_vector(3 downto 0); --saida de dados
begin

    clock_n <= not clock;

    FD: log2FD port map (clock_n,
                        N,
                        logval_interno,
                        shift_8, load_8, load_4, set_4,
                        zero_f);
    UC: log2UC port map (clock,
                        reset, start,
                        zero_f,
                        shift_8, load_8, load_4, set_4,
                        ready_interno);

    ready <= ready_interno;
    logval <= logval_interno;

end architecture log2_arch;