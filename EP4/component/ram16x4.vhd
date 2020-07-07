-------------------------------------------------------
--! @file ram16x4.vhd
--! @brief synchronous ram 16x4
--! @author Edson Midorikawa (emidorik@usp.br)
--! @date 2020-06-16
-------------------------------------------------------
-- baseado em ram.vhd (balbertini@usp.br)
-------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;
use std.textio.all;

entity ram16x4 is
  generic
  (
    data_file_name : string  := "mem_contents.dat" --! arquivo com dados iniciais
  );
  port 
  (
    clock  : in  bit;
    addr   : in  bit_vector(3 downto 0);
    we     : in  bit;
    data_i : in  bit_vector(3 downto 0);
    data_o : out bit_vector(3 downto 0)
  );
end entity;

architecture behavioral of ram16x4 is

  type mem_type is array (0 to 15) of bit_vector(3 downto 0);

   --! Funcao para preenchimento da memoria com dados iniciais em arquivo
  impure function init_mem(file_name : in string) return mem_type is
    file     f       : text open read_mode is file_name;
    variable l       : line;
    variable tmp_bv  : bit_vector(3 downto 0);
    variable tmp_mem : mem_type;
  begin
    for i in mem_type'range loop
      readline(f, l);
      read(l, tmp_bv);
      tmp_mem(i) := tmp_bv;
    end loop;
    return tmp_mem;
  end;

  --! matriz de dados da memoria
  signal mem : mem_type := init_mem(data_file_name);

begin
  -- !escrita (sincrona) da memoria
  writeop: process(clock)
  begin
    if (clock='1' and clock'event) then
      if we='1' then
        mem(to_integer(unsigned(addr))) <= data_i;
      end if;
    end if;
  end process;
  -- !saida de dados da memoria
  data_o <= mem(to_integer(unsigned(addr)));

end architecture;