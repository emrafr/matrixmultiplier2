library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

entity tb2_matrixmultiplier is
end tb2_matrixmultiplier;

architecture structural of tb2_matrixmultiplier is

component stimulus_generator is
    generic (
        FILE_NAME: string := "input_stimuli.txt";
        SAMPLE_WIDTH: positive
    );
    port (
        clk: in std_logic;
        reset: in std_logic;
	stop : in std_logic;
        finish : in std_logic;
        data_valid : out std_logic;
        stimulus_stream : out std_logic_vector(7 downto 0)
    );
end component;

component matrixmultiplier_top
port(
        clk : in std_logic;
        reset : in std_logic;
        input : in std_logic_vector(7 downto 0);
        valid_input : in std_logic;
	output : out std_logic_vector(8 downto 0);
        finish : out std_logic;
	stop : out std_logic   
);
end component;

signal clk, reset, valid_input, finish, stop : std_logic;

signal input : std_logic_vector(7 downto 0);
signal output : std_logic_vector(8 downto 0);

constant period : time := 10000 ps;

begin

DUT : matrixmultiplier_top
port map(
        clk => clk,
        reset => reset,
        input => input,
        valid_input => valid_input,
	output => output,
        finish => finish,
	stop => stop 
);

stimuli_gen: stimulus_generator
    generic map (
        FILE_NAME => "/h/d8/o/em6584ra-s/matlab/functional_model_stimuli/input_stimuli.txt",
        SAMPLE_WIDTH => 8
    )
    port map (
        clk => clk,
        reset => reset,
        stop => stop,
        finish => finish,
        data_valid => valid_input,
        stimulus_stream => input
);

clk_process : process
begin
    clk <= '0';
    wait for period/2;
    clk <= '1';
    wait for period/2;
end process;

reset <= '1',
         '0' after 1*period;
         
  
end structural;
