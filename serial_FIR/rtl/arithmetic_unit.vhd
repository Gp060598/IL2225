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
    sample_in_1   : in  signed(SAMPLE_WIDTH-1 downto 0);
    sample_in_2   : in  signed(SAMPLE_WIDTH-1 downto 0);
    --! Input coefficient
    coefficient_1 : in  signed(SAMPLE_WIDTH-1 downto 0);
    coefficient_2 : in  signed(SAMPLE_WIDTH-1 downto 0);
    read_address_1        : in unsigned(ADDRESS_WIDTH-1 downto 0);
    read_address_2        : in unsigned(ADDRESS_WIDTH-1 downto 0);
    --! Output result
    result      : out signed(RESULT_WIDTH-1 downto 0));

end entity arithmetic_unit;

architecture behaviour of arithmetic_unit is
  signal temp_result_1, MAC_result_1 : signed (RESULT_WIDTH-1 downto 0);
  signal temp_result_2, MAC_result_2 : signed (RESULT_WIDTH-1 downto 0);
begin
   m1:if(read_address_1=read_address_2)generate
    MAC_1: entity work.MAC
    port map (
      sample_in_1   => sample_in_1,
      sample_in_2=>(others=>'0'),
      coefficient_1 => coefficient_1,
      coefficient_2=>(others=>'0'),
      accumulate_1  => temp_result_1,
      accumulate_2=>temp_result_2,
      result_1      => MAC_result_1,
      result_2      => MAC_result_2);
      end generate m1;
 
    m2:if(read_address_1 /= read_address_2) generate
    MAC_1: entity work.MAC
    port map (
      sample_in_1   => sample_in_1,
      coefficient_1 => coefficient_1,
      sample_in_2=>sample_in_2,
      coefficient_2=>coefficient_2,
      accumulate_1  => temp_result_1,
      accumulate_2=>temp_result_2,
      result_1      => MAC_result_1,
      result_2      => MAC_result_2);
    end generate m2;
      
    
  process (clk, n_rst)
  begin
    if n_rst = '0' then
      temp_result_1 <= (others => '0');
      temp_result_2<=(others=>'0');
    elsif rising_edge (clk) then
      if n_rst_MAC = '0' then
        temp_result_1 <= (others => '0');
        temp_result_2<=(others=>'0');
      else
        temp_result_1 <= MAC_result_1;
        temp_result_2<=MAC_result_2;
      end if;
    end if;
  end process;
  result <= temp_result_1+temp_result_2;
end behaviour;
