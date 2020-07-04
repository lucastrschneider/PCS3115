--------------------------------------------------------------------------------
--! @file alu_somador_tb.vhd
--! @brief Testbench for 8-bit ALU (S1A2)
--! @author Bruno Albertini (balbertini@usp.br)
--! @date 20200605
--------------------------------------------------------------------------------
library ieee;
use ieee.numeric_bit.all;

entity alu_somador_tb is
end entity alu_somador_tb;

architecture dut of alu_somador_tb is
  component  alu is
    port (
      A, B : in  bit_vector(3 downto 0); -- inputs
      F    : out bit_vector(3 downto 0); -- output
      S    : in  bit_vector(2 downto 0); -- op selection
      Z    : out bit; -- zero flag
      Ov   : out bit; -- overflow flag
      Co   : out bit -- carry out
      );
  end component;
  signal A, B, F: bit_vector(3 downto 0) := (others=>'0');
  signal S: bit_vector(2 downto 0) := (others=>'0');
  signal Ze, Ov, Co: bit;
  signal an, bn, res: integer;
begin
  -- in1, in2, out, selection, flags (zero, overflow, carry-out)
  dut: alu port map (A, B, F, S, Ze, Ov, Co);

  stim: process is
  begin

    report "BOT";

    for an in 0 to 15 loop
      for bn in 0 to 15 loop
          A <= bit_vector(to_unsigned(an,4));
          B <= bit_vector(to_unsigned(bn,4));
          -- AND test
          S <= "000";
          res <= to_integer(to_unsigned(an,4) and to_unsigned(bn,4));
          wait for 1 ns;
          assert F = bit_vector(to_unsigned(res,4))
          report
            "Error on A&B "&
            "A:"&integer'image(to_integer(unsigned(A))) &" "&
            "B:"&integer'image(to_integer(unsigned(B))) &" "&
            "F:"&integer'image(to_integer(unsigned(F))) &" "&
            "expected:"&integer'image(res)
          severity failure;
          -- OR test
          S <= "001";
          res <= to_integer(to_unsigned(an,4) or to_unsigned(bn,4));
          wait for 1 ns;
          assert F = bit_vector(to_unsigned(res,4))
          report
            "Error on A|B "&
            "A:"&integer'image(to_integer(unsigned(A))) &" "&
            "B:"&integer'image(to_integer(unsigned(B))) &" "&
            "F:"&integer'image(to_integer(unsigned(F))) &" "&
            "expected:"&integer'image(res)
          severity failure;
          -- + test
          S <= "010";
          res <= to_integer(to_unsigned(an,4) + to_unsigned(bn,4));
          wait for 1 ns;
          assert F = bit_vector(to_unsigned(res,4))
          report
           "Error on A+B "&
           "A:"&integer'image(to_integer(unsigned(A))) &" "&
           "B:"&integer'image(to_integer(unsigned(B))) &" "&
           "F:"&integer'image(to_integer(unsigned(F))) &" "&
           "expected:"&integer'image(res)
          severity failure;
          -- - test
          S <= "110";
          res <= to_integer(to_unsigned(an,4) - to_unsigned(bn,4));
          wait for 1 ns;
          assert F = bit_vector(to_unsigned(res,4))
          report
           "Error on A-B "&
           "A:"&integer'image(to_integer(unsigned(A))) &" "&
           "B:"&integer'image(to_integer(unsigned(B))) &" "&
           "F:"&integer'image(to_integer(unsigned(F))) &" "&
           "expected:"&integer'image(res)
          severity failure;
      end loop;
    end loop;

    report "EOT";
    wait;
  end process;
end dut;