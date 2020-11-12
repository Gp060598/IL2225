library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types_and_constants.all;

-- The MAC (Multipply ACcumulate) component performs a very simple
-- arithmetic operation:
-- output = sample * coefficient + accumulate
entity MAC is

  port (
    --! Input sample
    sample_in_1  : in  signed(SAMPLE_WIDTH-1 downto 0);
    --! Input coefficient
    coefficient_1 : in  signed(SAMPLE_WIDTH-1 downto 0);
    sample_in_2  : in  signed(SAMPLE_WIDTH-1 downto 0);
    --! Input coefficient
    coefficient_2 : in  signed(SAMPLE_WIDTH-1 downto 0);
    --! Accumulate input
    accumulate_1  : in  signed(RESULT_WIDTH-1 downto 0);
    --! Output result
     accumulate_2  : in  signed(RESULT_WIDTH-1 downto 0);
  
    result_1      : out signed(RESULT_WIDTH-1 downto 0);
    result_2      : out signed(RESULT_WIDTH-1 downto 0));
  

end entity MAC;

architecture behaviour of MAC is
begin
  result_1 <= (sample_in_1 * coefficient_1) + accumulate_1;
  result_2 <= (sample_in_2 * coefficient_2) + accumulate_2;
end behaviour;

