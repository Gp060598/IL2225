library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types_and_constants.all;



entity FSM is
  port(
    n_rst               : in  std_logic;
    clk                 : in  std_logic;
    new_sample          : in  std_logic;
    write_enable        : out std_logic;
    write_address       : out unsigned(ADDRESS_WIDTH-1 downto 0);
    read_address_1        : out unsigned(ADDRESS_WIDTH-1 downto 0);
    read_address_2        : out unsigned(ADDRESS_WIDTH-1 downto 0);
    coefficient_address_1 : out unsigned(ADDRESS_WIDTH-1 downto 0);
    coefficient_address_2  : out unsigned(ADDRESS_WIDTH-1 downto 0);
    output_ready        : out std_logic;
    n_rst_MAC           : out std_logic);
end FSM;

architecture behavioral of FSM is

  constant MAX_TAP          : unsigned(ADDRESS_WIDTH-1 downto 0) := to_unsigned(FILTER_TAPS-1, ADDRESS_WIDTH);
  constant NUM_COEFFICIENTS : integer                            := 13;

  -- FSM state signals
  type state_type is (IDLE, CALC, READY);
  signal present_state : state_type;
  signal next_state    : state_type;

  signal n_rst_MAC_tmp           : std_logic;
  signal write_enable_tmp        : std_logic;
  signal counter_1                 : unsigned(ADDRESS_WIDTH-1 downto 0);
  signal counter_2                 : unsigned(ADDRESS_WIDTH-1 downto 0);
  signal write_address_tmp       : unsigned(ADDRESS_WIDTH-1 downto 0);
  signal read_address_tmp_1        : unsigned(ADDRESS_WIDTH-1 downto 0);
  signal read_address_tmp_2        : unsigned(ADDRESS_WIDTH-1 downto 0);
  signal coefficient_address_tmp_1 : unsigned(ADDRESS_WIDTH-1 downto 0);
   signal coefficient_address_tmp_2 : unsigned(ADDRESS_WIDTH-1 downto 0);
  signal read_1_count,read_2_count: unsigned(2 downto 0):="000";                  --to keep track of the number of address generated for LHS and RHS branch
begin

  write_address_pr : process(clk, n_rst)
  begin
    if n_rst = '0' then
      write_address_tmp <= (others => '0');
    elsif rising_edge (clk) then
      if new_sample = '1' then
        if write_address_tmp = MAX_TAP then
          write_address_tmp <= (others => '0');
        else
          write_address_tmp <= write_address_tmp + 1;
        end if;
      end if;
    end if;
  end process write_address_pr;

  read_address_pr : process(clk, n_rst)
  begin
    if n_rst = '0' then
      read_address_tmp_1 <= (others => '0');
      read_address_tmp_2 <= (others => '0');
    elsif rising_edge (clk) then
      if new_sample = '1' then
        read_address_tmp_1 <= write_address_tmp;
        read_address_tmp_2<=write_address_tmp+1;
      else
        if n_rst_MAC_tmp = '0' then
          read_address_tmp_1 <= to_unsigned(0, read_address_tmp_1'length);
           read_address_tmp_2 <= to_unsigned(0, read_address_tmp_2'length);
        elsif read_address_tmp_1 = 0 then
          read_address_tmp_1 <= MAX_TAP;
        elsif read_address_tmp_2= max_tap then         
           read_address_tmp_2 <= (others=>'0');
        elsif(read_1_count= "110" and read_2_count="110") then               --to generate only 6 address for LHS
          read_address_tmp_1 <= (others => '0'); 
          read_1_count<=(others=>'0');
          read_address_tmp_2 <= (others => '0'); 
          read_2_count<=(others=>'0');
          --elsif(read_2_count= "110") then             -- to generate only 6 address for RHS
          --read_address_tmp_2 <= (others => '0'); 
          --read_2_count<=(others=>'0');
        else
          read_address_tmp_1 <= read_address_tmp_1 - to_unsigned(1, read_address_tmp_1'length);
           read_address_tmp_2 <= read_address_tmp_2 + to_unsigned(1, read_address_tmp_2'length);
           read_1_count<=read_1_count +1;
           read_2_count<=read_2_count +1;
        end if;
      end if;
    end if;
  end process read_address_pr;


  counter_pr : process(clk, n_rst)
  begin
    if n_rst = '0' then
      counter_1 <= (others => '0');
      counter_2<=Max_Tap;
    elsif rising_edge (clk) then
      if (n_rst_MAC_tmp = '0') then
        counter_1 <= (others => '0');
        counter_2<=max_tap;
      else
        counter_1 <= counter_1 + 1;
        counter_2<=counter_2-1;
      end if;
    end if;
  end process counter_pr;

  -- purpose: FSM state registers
  -- type   : sequential
  -- inputs : clk, n_rst, present_state
  -- outputs: next_state
  reg_state_pr : process(clk, n_rst)
  begin
    if n_rst = '0' then
      present_state <= IDLE;
    elsif rising_edge (clk) then
      present_state <= next_state;
    end if;
  end process reg_state_pr;


  -- purpose: main FSM logic controling the MACs, address pointers and delay line
  -- type   : combinational
  -- inputs : all (requires VHDL 2008)
  -- outputs: 
  FSM_logic_pr : process(all)
  begin
    next_state              <= present_state;
    coefficient_address_tmp_1 <= (others => '0');
    coefficient_address_tmp_2 <= "1100";
    output_ready            <= '0';
    write_enable_tmp        <= '0';
    n_rst_MAC_tmp           <= '1';
    case present_state is
      when IDLE =>
        n_rst_MAC_tmp <= '0';
        if new_sample = '1' then
          write_enable_tmp <= '1';
          next_state       <= CALC;
        end if;
      when CALC =>
        n_rst_MAC_tmp <= '1';
        if ((counter_1 = "0110")) then --and (counter_2="0111")) then --NUM_COEFFICIENTS -1) then
          next_state <= READY;
          coefficient_address_tmp_2 <=(others=>'0');
        elsif (counter_1 = ("0000")) then --and counter_2=("1100")) then
          coefficient_address_tmp_1 <= (others => '0');
        elsif(counter_2=("1100")) then
          coefficient_address_tmp_2 <= "1100";
        else
          coefficient_address_tmp_1 <= counter_1;
          coefficient_address_tmp_2 <= counter_2;
        end if;

      when READY =>
        output_ready <= '1';
        next_state   <= IDLE;
    end case;
  end process FSM_logic_pr;

  n_rst_MAC           <= n_rst_MAC_tmp;
  write_enable        <= write_enable_tmp;
  write_address       <= write_address_tmp;
  read_address_1        <= read_address_tmp_1;
  read_address_2        <= read_address_tmp_2;
  coefficient_address_1 <= coefficient_address_tmp_1;
  coefficient_address_2 <= coefficient_address_tmp_2;
end behavioral;
