library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram_controller is
    port(
        clk : in std_logic;
        reset : in std_logic;
        ready_save : in std_logic;
        p1 : in std_logic_vector(17 downto 0);
        p2 : in std_logic_vector(17 downto 0);
        p3 : in std_logic_vector(17 downto 0);
        p4 : in std_logic_vector(17 downto 0);
        ram_out : in std_logic_vector(31 downto 0);
        ram_address : out std_logic_vector(7 downto 0);
        web : out std_logic;
        output : out std_logic_vector(8 downto 0);
        dataRAM : out std_logic_vector(31 downto 0)
    ); 
end ram_controller;

architecture behavioral of ram_controller is
type state_type is (s_init, s_save1, s_save2, s_save3, s_save4, s_read1, s_read2);
signal current_state, next_state : state_type;
signal read_data, read_data_next : std_logic_vector(8 downto 0);
signal current_p1, next_p1, current_p2, next_p2, current_p3, next_p3, current_p4, next_p4 : std_logic_vector(17 downto 0);
signal address_counter, address_counter_next : unsigned(7 downto 0);
signal read_counter, read_counter_next : unsigned(4 downto 0);

signal save_counter, save_counter_next : unsigned(3 downto 0);

begin

registers : process(clk, reset)
begin
    if reset = '1' then
        address_counter <= (others => '0');
        read_counter <= "00000";
        save_counter <= (others => '0');
        current_state <= s_init;
        read_data <= (others => '0');

    elsif rising_edge(clk) then
        current_p1 <= next_p1;
        current_p2 <= next_p2;
        current_p3 <= next_p3;
        current_p4 <= next_p4;
        current_state <= next_state;
        address_counter <= address_counter_next;
        read_counter <= read_counter_next;
        save_counter <= save_counter_next;
        read_data <= read_data_next;

    end if;
end process;

statemachine : process(save_counter,ram_out, read_data, ready_save, p1, p2, p3, p4, current_p1, current_p2, current_p3, current_p4, address_counter, current_state, read_counter)
begin
ram_address <= std_logic_vector(address_counter);
address_counter_next <= address_counter;
next_p1 <= current_p1;
next_p2 <= current_p2;
next_p3 <= current_p3;
next_p4 <= current_p4;
read_data_next <= read_data;
read_counter_next <= read_counter;
save_counter_next <= save_counter;

output <= (others => '0'); 
dataRAM <= (others => '0');
next_state <= current_state;
case current_state is
    when s_init =>
        web <= '0';    
        if ready_save = '1' then
            next_p1 <= p1;
            next_p2 <= p2;
            next_p3 <= p3;
            next_p4 <= p4;
            next_state <= s_save1;
         else
            next_state <= s_init;
         end if; 

    when s_save1 =>
            dataRAM <= (31 downto 18 => '0') & current_p1;
            web <= '1';
            ram_address <= std_logic_vector(address_counter);
            address_counter_next <= address_counter + 1;
            save_counter_next <= save_counter + 1;
		
            next_state <= s_save2;
    when s_save2 =>
            dataRAM <=  (31 downto 18 => '0') & current_p2;
            web <= '1';
            ram_address <= std_logic_vector(address_counter);
            address_counter_next <= address_counter + 1;
            save_counter_next <= save_counter + 1;
            next_state <= s_save3;
    when s_save3 =>
            dataRAM <= (31 downto 18 => '0') & current_p3;
            web <= '1';
            ram_address <= std_logic_vector(address_counter);
            address_counter_next <= address_counter + 1;
            save_counter_next <= save_counter + 1;
            next_state <= s_save4;
    when s_save4 =>
            dataRAM <=  (31 downto 18 => '0') & current_p4;
            web <= '1';
            ram_address <= std_logic_vector(address_counter);
            address_counter_next <= address_counter + 1;
            save_counter_next <= save_counter + 1;
            if save_counter = "1111" then
                
                next_state <= s_read1;
            else
                next_state <= s_init;
            end if;

    when s_read1 =>
            web <= '0';
            ram_address <= std_logic_vector(address_counter - 1);
            address_counter_next <= address_counter - 1;
            read_data_next <= ram_out(8 downto 0);
            output <= ram_out(17 downto 9);
	    read_counter_next <= read_counter + 1;
            next_state <= s_read2;
    when s_read2 =>
            web <= '0';
            output <= read_data;
            if read_counter = 18 then
                next_state <= s_init;
                read_counter_next <= (others => '0');
                address_counter_next <= address_counter + 18;
            else
                next_state <= s_read1;
		        read_counter_next <= read_counter;
            end if;
    when others =>
            ram_address <= std_logic_vector(address_counter);
            address_counter_next <= address_counter;
            next_p1 <= current_p1;
            next_p2 <= current_p2;
            next_p3 <= current_p3;
            next_p4 <= current_p4;
            read_data_next <= read_data;
            read_counter_next <= read_counter;
            save_counter_next <= save_counter;
            output <= (others => '0'); 
            dataRAM <= (others => '0');
            next_state <= current_state;
            web <= '0';		    
end case;    
end process;
    
end behavioral;
