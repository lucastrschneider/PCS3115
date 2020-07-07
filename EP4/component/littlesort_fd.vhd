--
-- PCS3115 - Sistemas Digitais I
-- 1o Semestre de 2020
--------
-- Projeto 4 - LittleSort
-- Este arquivo contem:
-- 1- Componentes usados para o projeto do Fluxo de Dados
-- 2- Entity do FD que deve ser usada obrigatoriamente
-- Codificaçao: Edson Midorikawa
-- Verificacao: Marco Tulio Carvalho de Andrade
--
-- 2020-07-03
--
-- Last Submission: #567 (10,0 / 10,0)
--

-------------------------------------------------------
--! @brief 4-bit synchronous binary counter
--! @author Lucas Schneider <lucastrschneider@usp.br>
--! @date 2020-07-07
-------------------------------------------------------
library ieee;
use ieee.numeric_bit.all;

entity counter_4bit is
    port (
        clock : in bit;
        enable, reset : in bit;
        Q : out bit_vector(3 downto 0);
        rco : out bit
    );
end entity counter_4bit;

architecture counter_4bit_arch of counter_4bit is
    signal IQ : unsigned (3 downto 0) := "0000";
begin
    process (clock, reset) is
    begin
        if (rising_edge(clock)) then
            if (reset = '1') then
                IQ <= (others => '0');
            elsif (enable = '1') then
                IQ <= IQ + 1;
            end if;
        end if;
    end process;
    Q <= bit_vector(IQ);
    rco <= '1' when IQ=15 else '0';

end architecture counter_4bit_arch;

-------------------------------------------------------
--! @brief 1-bit full adder
--! @author Lucas Schneider <lucastrschneider@usp.br>
--! @date 2020-07-07
-------------------------------------------------------
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

-------------------------------------------------------
--! @brief 4-bit full adder
--! @author Lucas Schneider <lucastrschneider@usp.br>
--! @date 2020-07-07
-------------------------------------------------------
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

-------------------------------------------------------
--! @file mux4_2to1.vhd
--! @brief 2-to-1 4-bit multiplexer
--! @author Edson S. Gomi (gomi@usp.br)
--! @date 2020-05-17
-------------------------------------------------------
library ieee;
use ieee.numeric_bit.all;

entity mux4_2to1 is
    port (
        SEL : in  bit;    
        A :   in  bit_vector (3 downto 0);
        B :   in  bit_vector (3 downto 0);
        Y :   out bit_vector (3 downto 0)
    );
end entity mux4_2to1;

architecture with_select of mux4_2to1 is
begin
    with SEL select
        Y <= A when '0',
            B when '1',
            "0000" when others;
end architecture with_select;

-------------------------------------------------------
--! @brief 4-bit register with asynchronous reset and set
--! @author Lucas Schneider <lucastrschneider@usp.br>
--! @date 2020-07-07
-------------------------------------------------------
library ieee;
use ieee.numeric_bit.all;

entity reg_4bit is 
    port (
        clock : in bit;
        enable : in bit; --0 HOLD, 1 LOAD
        set, reset : in bit; --Asynchronous inputs
        D : in bit_vector(3 downto 0);
        Q : out bit_vector(3 downto 0)
    );
end entity reg_4bit;

architecture reg_4bit_arch of reg_4bit is
    signal IQ : bit_vector(3 downto 0) := (others => '0');
begin
    process (clock, set, reset)
    begin
        if (reset = '1') then IQ <= (others => '0');
        elsif (set = '1') then IQ <= (others => '1');
        elsif (rising_edge(clock)) then
            if (enable = '1') then IQ <= D;
            end if;
        end if;
    end process;
    Q <= IQ;
end architecture reg_4bit_arch;

-------------------------------------------------------
--! @brief 4-bit magnitude comparator
--! @author Lucas Schneider <lucastrschneider@usp.br>
--! @date 2020-07-07
-------------------------------------------------------
library ieee;
use ieee.numeric_bit.all;

entity comp_4bit is
    port (
        A, B : in bit_vector (3 downto 0);
        equal, less, greater,
        different, less_equal, greater_equal : out bit
    );
end entity comp_4bit;

architecture comp_4bit_arch of comp_4bit is
    signal in_equal, in_less, in_greater : bit;
begin
    in_equal <= '1' when (unsigned(A) = unsigned(B)) else '0';
    in_less <= '1' when (unsigned(A) < unsigned(B)) else '0';
    in_greater <= '1' when (unsigned(A) > unsigned(B)) else '0';

    equal <= in_equal;
    less <= in_less;
    greater <= in_greater;
    different <= not in_equal;
    less_equal <= in_less or in_equal;
    greater_equal <= in_greater or in_equal;
end architecture comp_4bit_arch;

-------------------------------------------------------
--! @brief Block 2 of little sort (daeals with comparing data)
--! @author Lucas Schneider <lucastrschneider@usp.br>
--! @date 2020-07-07
-------------------------------------------------------
library ieee;
use ieee.numeric_bit.all;

entity littlesort_b1 is
    port (
        clock : in bit;
        zera_j, conta_j,
        selEnd, selDado : in bit; -- Entradas de controle
        fim_j : out bit;  -- Sinais de condicao
        mem_endereco, mem_dado_write : out bit_vector(3 downto 0); -- Interface memória
        regJ, regJmais1 : in bit_vector (3 downto 0) -- Conexão entre blocos
    );
end entity littlesort_b1;

architecture littlesort_b1_arch of littlesort_b1 is
    component counter_4bit is
        port (
            clock : in bit;
            enable, reset : in bit;
            Q : out bit_vector(3 downto 0);
            rco : out bit
        );
    end component counter_4bit;

    component adder_4bit is
        port (
            A, B : in bit_vector(3 downto 0);
            Cin : in bit;
            sum : out bit_vector(3 downto 0);
            Cout, Ov : out bit
        );
    end component adder_4bit;

    component mux4_2to1 is
        port (
            SEL : in  bit;    
            A :   in  bit_vector (3 downto 0);
            B :   in  bit_vector (3 downto 0);
            Y :   out bit_vector (3 downto 0)
        );
    end component mux4_2to1;

    signal in_fim_j : bit := '0';
    signal count_j, count_jmais1, in_mem_endereco, in_mem_dado_write : bit_vector(3 downto 0) := (others => '0');
    
begin

    COUNTER_J: counter_4bit
        port map (clock, conta_j, zera_j, count_j, in_fim_j);

    Jmais1: adder_4bit
        port map (count_j, "0000", '1', count_jmais1, open, open);

    ADD_MUX: mux4_2to1
        port map (selEnd, count_j, count_jmais1, in_mem_endereco);

    DATA_MUX: mux4_2to1
        port map (selDado, regJ, regJmais1, in_mem_dado_write);

    fim_j <= in_fim_j;
    mem_endereco <= in_mem_endereco;
    mem_dado_write <= in_mem_dado_write;

end architecture littlesort_b1_arch ; -- littlesort_b1_arch

-------------------------------------------------------
--! @brief Block 2 of little sort (daeals with comparing data)
--! @author Lucas Schneider <lucastrschneider@usp.br>
--! @date 2020-07-07
-------------------------------------------------------
library ieee;
use ieee.numeric_bit.all;

entity littlesort_b2 is
    port (
        clock : in bit;
        apaga_regJ, carrega_regJ,
        apaga_regJmais1, carrega_regJmais1 : in bit; -- Entradas de controle
        maior : out bit;  -- Sinais de condicao
        mem_dado_read : in bit_vector(3 downto 0); -- Interface memória
        regJ, regJmais1 : out bit_vector (3 downto 0) -- Conexão entre blocos
    );
end entity littlesort_b2;

architecture littlesort_b2_arch of littlesort_b2 is
    component reg_4bit is 
        port (
            clock : in bit;
            enable : in bit; --0 HOLD, 1 LOAD
            set, reset : in bit; --Asynchronous inputs
            D : in bit_vector(3 downto 0);
            Q : out bit_vector(3 downto 0)
        );
    end component reg_4bit;

    component comp_4bit is
        port (
            A, B : in bit_vector (3 downto 0);
            equal, less, greater,
            different, less_equal, greater_equal : out bit
        );
    end component comp_4bit;

    signal in_maior : bit := '0';
    signal in_regJ, in_regJmais1 : bit_vector(3 downto 0) := (others => '0');
begin

    RJ: reg_4bit
        port map (clock, carrega_regJ, '0', apaga_regJ, mem_dado_read, in_regJ);

    RJmais1: reg_4bit
        port map (clock, carrega_regJmais1, '0', apaga_regJmais1, mem_dado_read, in_regJmais1);

    Compare: comp_4bit
        port map (in_regJ, in_regJmais1, open, open, in_maior, open, open, open);

    maior <= in_maior;
    regJ <= in_regJ;
    regJmais1 <= in_regJmais1;

end architecture littlesort_b2_arch ; -- littlesort_b2_arch


-------------------------------------------------------
--! @brief structural description for littlesort
--! @author Lucas Schneider <lucastrschneider@usp.br>
--! @date 2020-07-07
-------------------------------------------------------
library ieee;
use ieee.numeric_bit.all;

entity littleSort_fd is
    port ( 
        clock:             in  bit;
        zera_j:            in  bit;  -- sinais de controle
        conta_j:           in  bit;
        selEnd:            in  bit;
        selDado:           in  bit;
        we_mem:            in  bit;
        apaga_regJ:        in  bit;
        carrega_regJ:      in  bit;
        apaga_regJmais1:   in  bit;
        carrega_regJmais1: in  bit;
        fim_j:             out bit;  -- sinais de condicao
        maior:             out bit;
        mem_we:            out bit;  -- interface com memoria externa
        mem_endereco:      out bit_vector(3 downto 0);
        mem_dado_write:    out bit_vector(3 downto 0);
        mem_dado_read:     in  bit_vector(3 downto 0)
    );
end entity;

architecture estrutural of littleSort_fd is
    component littlesort_b1 is
        port (
            clock : in bit;
            zera_j, conta_j,
            selEnd, selDado : in bit; -- Entradas de controle
            fim_j : out bit;  -- Sinais de condicao
            mem_endereco, mem_dado_write : out bit_vector(3 downto 0); -- Interface memória
            regJ, regJmais1 : in bit_vector (3 downto 0) -- Conexão entre blocos
        );
    end component littlesort_b1;

    component littlesort_b2 is
        port (
            clock : in bit;
            apaga_regJ, carrega_regJ,
            apaga_regJmais1, carrega_regJmais1 : in bit; -- Entradas de controle
            maior : out bit;  -- Sinais de condicao
            mem_dado_read : in bit_vector(3 downto 0); -- Interface memória
            regJ, regJmais1 : out bit_vector (3 downto 0) -- Conexão entre blocos
        );
    end component littlesort_b2;

    signal in_fim_j, in_maior : bit;
    signal in_mem_endereco, in_mem_dado_write : bit_vector(3 downto 0);
    signal in_regJ, in_regJmais1 : bit_vector(3 downto 0);
        
begin
    BLOCO_1: littlesort_b1
        port map (clock,
                zera_j, conta_j,
                selEnd, selDado,
                in_fim_j,
                in_mem_endereco, in_mem_dado_write,
                in_regJ, in_regJmais1);

    BLOCO_2: littlesort_b2
        port map (clock,
                apaga_regJ, carrega_regJ,
                apaga_regJmais1, carrega_regJmais1,
                in_maior,
                mem_dado_read,
                in_regJ, in_regJmais1);
    
    fim_j <= in_fim_j;
    maior <= in_maior;
    mem_endereco <= in_mem_endereco;
    mem_dado_write <= in_mem_dado_write;

    mem_we <= we_mem;

end architecture;