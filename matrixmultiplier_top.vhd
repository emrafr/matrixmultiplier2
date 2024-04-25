library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity matrixmultiplier_top is
    port(
        clk : in std_logic;
        reset : in std_logic;
        input : in std_logic_vector(7 downto 0);
        valid_input : in std_logic;
        finish : out std_logic;
	    output : out  std_logic_vector(8 downto 0);
	    stop : out std_logic	    
    );
end matrixmultiplier_top;

architecture structural of matrixmultiplier_top is

  component CPAD_S_74x50u_IN            --input PAD

    port (
      COREIO : out std_logic;
      PADIO  : in  std_logic);
  end component;

  component CPAD_S_74x50u_OUT           --output PAD
    port (
      COREIO : in  std_logic;
      PADIO  : out std_logic);
  end component;

component controller is
    port(
        clk : in std_logic;
        reset : in std_logic;
        ready_save : in std_logic; -- will be one when one column is done
        done : in std_logic;
        ready : out std_logic;   
        finish : out std_logic;
        column_counter : out unsigned(2 downto 0)  
    );
end component;

component shift_input is
    port(
        reset : in std_logic;
        clk : in std_logic;
        input : in std_logic_vector(7 downto 0);
        valid_input : in std_logic;
        row1_reg : out std_logic_vector(63 downto 0); 
        row2_reg : out std_logic_vector(63 downto 0); 
        row3_reg : out std_logic_vector(63 downto 0); 
        row4_reg : out std_logic_vector(63 downto 0);
        done : out std_logic;
	stop : out std_logic    
    );
end component;

component multiply is
    port(
        clk : in std_logic;
        reset : in std_logic;
        done : in std_logic;
        column_counter : in unsigned(2 downto 0);
        row1_reg : in std_logic_vector(63 downto 0);
        row2_reg : in std_logic_vector(63 downto 0);
        row3_reg : in std_logic_vector(63 downto 0);
        row4_reg : in std_logic_vector(63 downto 0);
        dataROM : in std_logic_vector(13 downto 0);
        romAddress : out std_logic_vector(3 downto 0);
        p1 : out std_logic_vector(17 downto 0);
        p2 : out std_logic_vector(17 downto 0);
        p3 : out std_logic_vector(17 downto 0);
        p4 : out std_logic_vector(17 downto 0);
        ready_save : out std_logic
    );
end component;

component rom is
    port(
        clk : in std_logic;
        romAddress : in std_logic_vector(3 downto 0);
        dataROM : out std_logic_vector(13 downto 0)  
    );
end component;

component ram_controller is
    port(
        clk : in std_logic;
        reset : in std_logic;
        ready_save : in std_logic;
	--finish : in std_logic;
	    ram_out : in std_logic_vector(31 downto 0);
        p1 : in std_logic_vector(17 downto 0);
        p2 : in std_logic_vector(17 downto 0);
        p3 : in std_logic_vector(17 downto 0);
        p4 : in std_logic_vector(17 downto 0);
	    output : out std_logic_vector(8 downto 0);
        ram_address : out std_logic_vector(7 downto 0);
        web : out std_logic;
        dataRAM : out std_logic_vector(31 downto 0)
    );
end component;

component sram_wrapper is
    port(
        clk: in std_logic;
        cs_n: in std_logic;  -- Active Low
        we_n: in std_logic;  --Active Low
        address: in std_logic_vector(7 downto 0);
        ry: out std_logic;
        write_data: in std_logic_vector(31 downto 0);
        read_data: out std_logic_vector(31 downto 0)
    );
end component;

signal ready_save, done, ready, web, ry, inv_web: std_logic;
signal row1_reg, row2_reg, row3_reg, row4_reg : std_logic_vector(63 downto 0);
signal dataROM: std_logic_vector(13 downto 0);
signal romAddress: std_logic_vector(3 downto 0);
signal p1, p2, p3, p4: std_logic_vector(17 downto 0);
signal ram_address: std_logic_vector(7 downto 0);
signal dataRAM, ram_out: std_logic_vector(31 downto 0);
signal column_counter : unsigned(2 downto 0);

signal clki, reseti, valid_inputi, finishi, stopi : std_logic;
signal inputi : std_logic_vector(7 downto 0);
signal outputi : std_logic_vector(8 downto 0);

begin

clkpad : CPAD_S_74x50u_IN
    port map (
      COREIO => clki,
      PADIO  => clk);

resetpad : CPAD_S_74x50u_IN
    port map (
      COREIO => reseti,
      PADIO  => reset);

valid_inputpad : CPAD_S_74x50u_IN
    port map (
      COREIO => valid_inputi,
      PADIO  => valid_input);

InPads_input : for i in 0 to 7 generate
InPad_input : CPAD_S_74x50u_IN
      port map (
        COREIO => inputi(i),
        PADIO  => input(i));
end generate InPads_input;

finishpad : CPAD_S_74x50u_OUT
    port map (
      COREIO => finishi,
      PADIO  => finish);

stoppad : CPAD_S_74x50u_OUT
    port map (
      COREIO => stopi,
      PADIO  => stop);

OutPads_output : for i in 0 to 8 generate
  OutPad_output : CPAD_S_74x50u_OUT
      port map (
        COREIO => outputi(i),
        PADIO  => output(i));
end generate OutPads_output;

controller_inst : controller 
port map(
        clk => clki,
        reset => reseti,
        ready_save => ready_save,
        done => done,
        ready => ready,
        finish => finishi,
        column_counter => column_counter
);

shift_input_inst : shift_input
port map(
        reset => reseti,
        clk => clki,
        input => inputi,
        valid_input  => valid_inputi,
        row1_reg => row1_reg,
        row2_reg => row2_reg,
        row3_reg => row3_reg,
        row4_reg => row4_reg,
        done => done,
	    stop => stopi   
);

multiply_inst : multiply
port map(
        clk => clki,
        reset => reseti,
        done => done,
        column_counter => column_counter,
        row1_reg => row1_reg,
        row2_reg => row2_reg,
        row3_reg => row3_reg, 
        row4_reg => row4_reg,
        dataROM => dataROM,
        romAddress => romAddress,
        p1 => p1,
        p2 => p2,
        p3 => p3,
        p4 => p4,
        ready_save => ready_save
);

rom_inst : rom
port map(
        clk => clki,
        romAddress => romAddress,
        dataROM  => dataROM
);

ram_controller_inst : ram_controller
port map(
        clk => clki,
        reset => reseti,
        ready_save  => ready_save,
        p1 => p1,
        p2 => p2,
        p3 => p3,
        p4 => p4,
	    ram_out => ram_out,
        ram_address => ram_address,
        web => web,
	    output => outputi,
        dataRAM => dataRAM
);

inv_web <= not(web);
ram_inst : sram_wrapper
port map(
        clk => clki,
        cs_n => '0',
        we_n => inv_web,
        address => ram_address,
        ry => ry,
        write_data => dataRAM,
        read_data => ram_out
);


end structural;
