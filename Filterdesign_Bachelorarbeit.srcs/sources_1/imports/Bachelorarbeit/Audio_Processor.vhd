----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.09.2024 16:45:01
-- Design Name: 
-- Module Name: Audio_Processor - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Meant to apply the Audio Effects to the signal
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

entity audio_processor is
    Generic (
        BIT_DEPTH : positive := 28
    );
    Port (
        clk             : in STD_LOGIC;
        reset           : in STD_LOGIC;
        
        -- Eingangssignale vom Receiver
        sck_in          : in STD_LOGIC;
        ws_in           : in STD_LOGIC;
        audio_left_in   : in STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
        audio_right_in  : in STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
        
        -- Ausgangssignale zum Transmitter
        ws_out          : out STD_LOGIC;
        audio_left_out  : out STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
        audio_right_out : out STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0)
    );
end audio_processor;

architecture Behavioral of audio_processor is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                audio_left_out <= (others => '0');
                audio_right_out <= (others => '0');
            else
                -- Verdoppeln der Eingangsdaten
                --audio_left_out <= std_logic_vector(unsigned(audio_left_in) * 3);
                --audio_right_out <= std_logic_vector(unsigned(audio_right_in) * 3);
                audio_left_out <= audio_left_in;
                audio_right_out <= audio_right_in;
            end if;
        end if;
    end process;
    
    -- Durchreichen der Timing-Signale
    ws_out <= ws_in;
end Behavioral;

