library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types_and_constants.all;

entity partially_parallel_FIR is

  port (
    --! Clock signal
    clk          : in  std_logic;
    --! Active low asynchronous reset
    n_rst        : in  std_logic;
    --! Sample input
    sample_in    : in  signed(SAMPLE_WIDTH-1 downto 0);
    --! New sample flag
    new_sample   : in  std_logic;
    --! Output of the FIR filter
    output       : out signed(RESULT_WIDTH-1 downto 0);
    --! Output ready flag
    output_ready : out std_logic);

end entity partially_parallel_FIR;

architecture structural of partially_parallel_FIR is

  signal n_rst_MAC           : std_logic;
  signal write_enable        : std_logic;
  signal result              : signed(RESULT_WIDTH-1 downto 0);
  signal write_address       : unsigned(ADDRESS_WIDTH-1 downto 0);
  signal read_address_1,read_address_2: unsigned(ADDRESS_WIDTH-1 downto 0);
  signal coefficient_address_2,coefficient_address_1: unsigned(ADDRESS_WIDTH-1 downto 0);
  signal sample_out_1,sample_out_2          : signed(SAMPLE_WIDTH-1 downto 0);
  signal coefficient_1,coefficient_2         : signed(SAMPLE_WIDTH-1 downto 0);
  signal output_ready_tmp    : std_logic;
  signal mac_en              :std_logic;

begin

  arithmetic_unit_1 : entity work.arithmetic_unit
    port map (
      clk         => clk,
      n_rst       => n_rst,
      n_rst_MAC   => n_rst_MAC,
      mac_en      =>mac_en,
      sample_in_1   => sample_out_1,
      coefficient_1 => coefficient_1,
      sample_in_2=>sample_out_2,
      coefficient_2=>coefficient_2,
      read_address_1=>read_address_1,
      read_address_2=>read_address_2,
      result      => result);

  FSM_1 : entity work.FSM
    port map (
      clk                 => clk,
      n_rst               => n_rst,
      new_sample          => new_sample,
      write_enable        => write_enable,
      write_address       => write_address,
      read_address_1        => read_address_1,
      read_address_2      =>read_address_2,
      output_ready        => output_ready_tmp,
      n_rst_MAC           => n_rst_MAC,
      mac_en              =>mac_en,
      coefficient_address_1 => coefficient_address_1,
      coefficient_address_2 => coefficient_address_2);

  ROM_coefficients_1 : entity work.ROM_coefficients
    port map (
      coeff_addr_1 => coefficient_address_1,
      coeff_addr_2=>coefficient_address_2,
      coeff_out_1  => coefficient_1,
      coeff_out_2=>coefficient_2 );

  delay_line_1 : entity work.delay_line
    port map (
      clk           => clk,
      n_rst         => n_rst,
      new_sample    => new_sample,
      write_address => write_address,
      write_enable  => write_enable,
      sample_in     => sample_in,
      read_address_1  => read_address_1,
      read_address_2=>read_address_2,
      sample_out_1  => sample_out_1,
       sample_out_2=>sample_out_2);

  output_select : output <= result when (output_ready_tmp = '1') else (others => '0');
  output_ready <= output_ready_tmp;
end structural;

