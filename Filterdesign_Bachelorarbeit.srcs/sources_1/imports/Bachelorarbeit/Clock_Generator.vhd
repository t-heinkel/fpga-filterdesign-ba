----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.09.2024 12:29:56
-- Design Name: 
-- Module Name: Clock_Generator - Behavioral
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

entity Clock_Generator is
    Generic (
        BIT_DEPTH : positive := 24;
        SAMPLE_RATE : positive := 48000
    );
    Port (
        clk_in : in STD_LOGIC;
        
        -- Ausgangssignale
        lrck : out STD_LOGIC;
        sclk : out STD_LOGIC
    );
end Clock_Generator;

architecture RTL of Clock_Generator is
    constant CLOCK_PERIOD : time := 1000 ns / SAMPLE_RATE;
    constant LRCK_DIV : positive := CLOCK_PERIOD / (BIT_DEPTH * 100 ns);
    constant SCLK_DIV : positive := LRCK_DIV / 2;
    
    signal clk_count : unsigned(23 downto 0) := (others => '0');
    signal lrck_int : STD_LOGIC := '0';
    signal sclk_int : STD_LOGIC := '0';
    
begin
    clock_generator_process : process(clk_in)
    begin
        if rising_edge(clk_in) then
            clk_count <= clk_count + 1;
            
            -- LRCK (Word Clock) Generierung
            if clk_count = LRCK_DIV - 1 then
                lrck_int <= not lrck_int;
                clk_count <= (others => '0');
            end if;
            
            -- SCLK (Bit Clock) Generierung
            if clk_count < SCLK_DIV then
                sclk_int <= '1';
            else
                sclk_int <= '0';
            end if;
        end if;
    end process;
    
    lrck <= lrck_int;
    sclk <= sclk_int;
    
end RTL;
