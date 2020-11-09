library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types_and_constants.all;

entity arithmetic_unit is

  port (
    --! Clock signal
    clk         : in  std_logic;
    --! Active low asynchronous reset
    n_rst       : in  std_logic;
    --! Active low MAC reset. Clears the accumulate value.
    n_rst_MAC   : in  std_logic;
    --! Input sample
    sample_in   : in  signed(SAMPLE_WIDTH-1 downto 0);
    --! Input coefficient
    coefficient : in  signed(SAMPLE_WIDTH-1 downto 0);
    --! Output result
    result      : out signed(RESULT_WIDTH-1 downto 0));

end entity arithmetic_unit;

architecture behaviour of arithmetic_unit is
  signal temp_result, MAC_result : signed (RESULT_WIDTH-1 downto 0);
begin

  -- Instantiate 1 MAC
  MAC_1: entity work.MAC
    port map (
      sample_in   => sample_in,
      coefficient => coefficient,
      accumulate  => temp_result,
      result      => MAC_result);

  process (clk, n_rst)
  begin
    if n_rst = '0' then
      temp_result <= (others => '0');
    elsif rising_edge (clk) then
      if n_rst_MAC = '0' then
        temp_result <= (others => '0');
      else
        temp_result <= MAC_result;
      end if;
    end if;
  end process;
  result <= temp_result;
end behaviour;
