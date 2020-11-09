library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types_and_constants.all;

entity parallel_FIR is

  port (
    --! clock signal
    clk          : in  std_logic;
    --! asyncronous active low reset
    n_rst        : in  std_logic;
    --! new sample flag
    new_sample   : in  std_logic;
    --! new sample
    sample_in    : in  signed(SAMPLE_WIDTH-1 downto 0);
    --! output of the FIR filter
    output       : out signed(RESULT_WIDTH-1 downto 0);
    --! output ready flag
    output_ready : out std_logic);

end entity parallel_FIR;

architecture structure of parallel_FIR is

  signal all_coeffs       : coeff_file;
  signal all_samples      : sample_file;
  signal result           : signed (result_width-1 downto 0);
  signal output_ready_tmp : std_logic;
begin  -- architecture structure

  ROM_coefficients_1 : entity work.ROM_coefficients
    port map (
      coeff_out => all_coeffs);

  shift_register_1 : entity work.shift_register
    port map (
      clk         => clk,
      n_rst       => n_rst,
      new_sample  => new_sample,
      sample_in   => sample_in,
      all_samples => all_samples);

  FSM_1 : entity work.FSM
    port map (
      clk          => clk,
      n_rst        => n_rst,
      new_sample   => new_sample,
      output_ready => output_ready_tmp);

  arithmetic_unit_1 : entity work.arithmetic_unit
    port map (
      all_samples      => all_samples,
      all_coefficients => all_coeffs,
      result           => result);

  output_ready <= output_ready_tmp;

  OUT_MUX : output <= result when (output_ready_tmp = '1') else (others => '0');

end architecture structure;
