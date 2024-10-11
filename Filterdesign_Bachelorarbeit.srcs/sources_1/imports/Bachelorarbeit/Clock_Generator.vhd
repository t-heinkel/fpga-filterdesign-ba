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
        BIT_DEPTH : positive := 28;
        SAMPLE_RATE : positive := 48000
    );
    Port (
        clk_in : in STD_LOGIC;
        
        -- Ausgangssignale
        clk_24 : out STD_LOGIC;
        clk_100 : out STD_LOGIC
    );
end Clock_Generator;

architecture RTL of Clock_Generator is
    
    signal clk_count_100    : unsigned(6 downto 0) := (others => '0');
    signal clk_count_24     : unsigned(4 downto 0) := (others => '0');
    signal lrck_int         : STD_LOGIC := '0';
    signal sclk_int         : STD_LOGIC := '0';
    
    signal clk_1    : STD_LOGIC := '0';
    
begin
    clock_1_generator_process : process(clk_in)
    begin
        if rising_edge(clk_in) then
            clk_count_100 <= clk_count_100 + 1;
            clk_count_24 <= clk_count_24 + 1;
            
            if clk_count_100 = "1100100" then
                clk_1 <= not clk_1;
                clk_count_100 <= (others => '0');
            end if;

        end if;
    end process;

    clock_24_generator_process : process (clk_1)
    begin
        if rising_edge(clk_1) then
        end if;
    end process;
    
end RTL;
