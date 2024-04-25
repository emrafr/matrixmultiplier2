library ieee;
use ieee.std_logic_1164.all;

entity tb_matrixmultiplier is
end tb_matrixmultiplier;

architecture structural of tb_matrixmultiplier is

component matrixmultiplier_top
port(
        clk : in std_logic;
        reset : in std_logic;
        input : in std_logic_vector(7 downto 0);
        valid_input : in std_logic;
        finish : out std_logic   
);
end component;

signal clk, reset, valid_input, finish : std_logic;
signal input : std_logic_vector(7 downto 0);

constant period : time := 2500 ns;

begin

DUT : matrixmultiplier_top
port map(
        clk => clk,
        reset => reset,
        input => input,
        valid_input => valid_input,
        finish => finish 
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

input <= "00000000",
    "00000001" after 1*period,
    "00000010" after 2*period,
    "00000011" after 3*period,
    "00000100" after 4*period,
    "00000101" after 5*period,
    "00000110" after 6*period,
    "00000111" after 7*period,
    "00001000" after 8*period,
    "00001001" after 9*period,
    "00001010" after 10*period,
    "00001011" after 11*period,
    "00001100" after 12*period,
    "00001101" after 13*period,
    "00001110" after 14*period,
    "00001111" after 15*period,
    "00010000" after 16*period,
    "00000001" after 17*period,
    "00000010" after 18*period,
    "00000011" after 19*period,
    "00000100" after 20*period,
    "00000101" after 21*period,
    "00000110" after 22*period,
    "00000111" after 23*period,
    "00001000" after 24*period,
    "00001001" after 25*period,
    "00001010" after 26*period,
    "00001011" after 27*period,
    "00001100" after 28*period,
    "00001101" after 29*period,
    "00001110" after 30*period,
    "00001111" after 31*period,
    "00010000" after 32*period;
    
    valid_input <= '1',
            '0' after 33*period;    

end structural;