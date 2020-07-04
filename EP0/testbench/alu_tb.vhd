--------------------------------------------------------------------------------
--! @file alu_tb.vhd
--! @brief 8-bit ALU testbench
--! @author Lucas Schneider (lucastrschneider@usp.br)
--! @date 2020/06/12
--------------------------------------------------------------------------------

entity alu_tb is
end alu_tb;

architecture alu_tb_arch of alu_tb is

    component alu is
        port (
            A, B : in  bit_vector(3 downto 0); -- inputs
            F    : out bit_vector(3 downto 0); -- output
            S    : in  bit_vector(2 downto 0); -- op selection
            Z    : out bit; -- zero flag
            Ov   : out bit; -- overflow flag
            Co   : out bit -- carry out
            );
    end component alu;

    signal a_in, b_in, f_out : bit_vector(3 downto 0);
    signal sel_in : bit_vector (2 downto 0);
    signal z_out, ov_out, co_out : bit;

    begin
        cp1: alu port map (a_in, b_in, f_out, sel_in, z_out, ov_out, co_out);

        main: process
        begin
            report "BOOT";

            a_in <= "1010";
            b_in <= "1101";

            sel_in <= "000";
            wait for 1 ns;
            assert(f_out="1000") report "Fail 01" severity error;

            sel_in <= "001";
            wait for 1 ns;
            assert(f_out="1111") report "Fail 02" severity error;

            report "EOT";
            wait;
        end process;
end architecture alu_tb_arch;