--------------------------------------------------------------------------------
--! @file alu.vhd
--! @brief 8-bit ALU
--! @author Lucas Schneider (lucastrschneider@usp.br)
--! @date 2020/06/12
--------------------------------------------------------------------------------

entity full_adder is 
    port (
        A, B, Cin : in bit; -- inputs
        Cout, sum : out bit -- outputs
    );
end entity full_adder;

architecture full_adder_df of full_adder is
begin
    sum <= A xor B xor Cin;
    Cout <= ((A xor B) and Cin) or (A and B);
end architecture full_adder_df;


entity alu is
    port (
      A, B : in  bit_vector(3 downto 0); -- inputs
      F    : out bit_vector(3 downto 0); -- output
      S    : in  bit_vector(2 downto 0); -- op selection
      Z    : out bit; -- zero flag
      Ov   : out bit; -- overflow flag
      Co   : out bit -- carry out
      );
end entity alu;

architecture alu_arch of alu is
    component full_adder is 
        port (
            A, B, Cin : in bit; -- inputs
            Cout, sum : out bit -- outputs
        );
    end component full_adder;

    signal carry : bit_vector (4 downto 0);
    signal b_in : bit_vector (3 downto 0);
    signal sum_value : bit_vector (3 downto 0);
    signal f_out : bit_vector (3 downto 0);

begin
    carry(0) <= '1' when (S = "110") else '0';
    b_in <= not(B) when (S = "110") else B;

    fa0: full_adder port map (a(0), b_in(0), carry(0), carry(1), sum_value(0));
    fa1: full_adder port map (a(1), b_in(1), carry(1), carry(2), sum_value(1));
    fa2: full_adder port map (a(2), b_in(2), carry(2), carry(3), sum_value(2));
    fa3: full_adder port map (a(3), b_in(3), carry(3), carry(4), sum_value(3));

    with S select
        f_out <= A and B when "000",
                A or B when "001",
                sum_value when ("010"),
                sum_value when ("110"),
                
                (others => '0') when others;

    Z <= '1' when (f_out = "0000") else '0';
    F <= f_out;
    Co <= carry(4);
    Ov <= carry(3) xor carry(4);
end alu_arch;