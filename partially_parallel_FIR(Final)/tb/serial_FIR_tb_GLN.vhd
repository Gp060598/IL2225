library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types_and_constants.all;

entity serial_FIR_tb_GLN is
end entity serial_FIR_tb_GLN;

architecture behavior of serial_FIR_tb_GLN is

  signal clk          : std_logic := '0';
  signal n_rst        : std_logic := '0';
  signal new_sample   : std_logic := '0';
  signal output_ready : std_logic;
  signal sample_in    : signed(SAMPLE_WIDTH-1 downto 0);
  signal output       : signed(RESULT_WIDTH-1 downto 0);

begin
  -- P1 : Top_Serial_FIR port map(clk, rst_n, sample_clk, sample, conv_sum, dav);

  serial_FIR_1 : entity work.serial_FIR
    port map (
      clk          => clk,
      n_rst        => n_rst,
      sample_in    => sample_in,
      new_sample   => new_sample,
      output       => output,
      output_ready => output_ready);

  clk        <= not clk                    after 10 ns;
  n_rst      <= '1'                        after 5 ns;
  sample_in  <= "0000000001", "0000000000" after 60 ns;

  new_sample_generation: process
  begin
    wait for 40 ns;
    for i in 0 to 30 loop
      new_sample <= '1';
      wait for 20 ns;
      new_sample <= '0';
      wait for 360 ns;
    end loop;
  end process;
end behavior;
