----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.11.2024 08:58:53
-- Design Name: 
-- Module Name: tremolo_effect - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vibrato_effect is
    GENERIC (
        BIT_DEPTH : positive := 24;
        DELAY_LINE_LENGTH : integer := 1024; -- Länge der Verzögerungsleitung
        VIBRATO_DEPTH : integer := 10 -- Maximale Modulationstiefe in Samples
    );
    Port (
        clk             : in STD_LOGIC;
        reset           : in STD_LOGIC;
        ws              : in std_logic;
        audio_left_in   : in STD_LOGIC_VECTOR(BIT_DEPTH - 1 downto 0);
        audio_right_in  : in STD_LOGIC_VECTOR(BIT_DEPTH - 1 downto 0);
        audio_left_out  : out STD_LOGIC_VECTOR(BIT_DEPTH - 1 downto 0);
        audio_right_out : out STD_LOGIC_VECTOR(BIT_DEPTH - 1 downto 0);
        sine_value      : in STD_LOGIC_VECTOR(8 downto 0) -- Sinuswert zur Modulation
    );
end vibrato_effect;

architecture Behavioral of vibrato_effect is
    type delay_line_type is array (0 to DELAY_LINE_LENGTH-1) of STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
    signal delay_line_left : delay_line_type := (others => (others => '0'));
    signal delay_line_right : delay_line_type := (others => (others => '0'));
    signal write_index : integer := 0;
    signal read_index : integer := 0;
    signal modulated_delay : integer := 0;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            write_index <= 0;
            read_index <= 0;
        elsif rising_edge(clk) then
            -- Berechne den modulierenden Verzögerungswert basierend auf dem Sinuswert
            modulated_delay <= VIBRATO_DEPTH * (to_integer(signed(sine_value)) - 128) / 128;

            -- Berechne den Leseindex basierend auf dem modulierenden Verzögerungswert
            read_index <= (write_index - modulated_delay + DELAY_LINE_LENGTH) mod DELAY_LINE_LENGTH;

            -- Schreibe aktuelle Samples in die Verzögerungsleitung
            delay_line_left(write_index) <= audio_left_in;
            delay_line_right(write_index) <= audio_right_in;

            -- Inkrementiere den Schreibindex
            write_index <= (write_index + 1) mod DELAY_LINE_LENGTH;

            -- Ausgabe der verzögerten Samples
            audio_left_out <= delay_line_left(read_index);
            audio_right_out <= delay_line_right(read_index);
        end if;
    end process;
end Behavioral;