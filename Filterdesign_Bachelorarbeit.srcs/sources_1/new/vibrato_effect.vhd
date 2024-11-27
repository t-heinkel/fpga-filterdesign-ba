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
        VIBRATO_DEPTH : real := 0.5
    );
    Port (
        clk             : in STD_LOGIC;
        reset           : in STD_LOGIC;
        ws              : in std_logic;
        audio_left_in   : in STD_LOGIC_VECTOR(BIT_DEPTH - 1 downto 0);
        audio_right_in  : in STD_LOGIC_VECTOR(BIT_DEPTH - 1 downto 0);
        audio_left_out  : out STD_LOGIC_VECTOR(BIT_DEPTH - 1 downto 0);
        audio_right_out : out STD_LOGIC_VECTOR(BIT_DEPTH - 1 downto 0);
        sine_value      : in STD_LOGIC_VECTOR(8 downto 0)
    );
end vibrato_effect;

architecture Behavioral of vibrato_effect is

    constant MAX_DEPTH : INTEGER := 255;
    constant MAX_RATE : INTEGER := 255;
    
    signal modulated_phase_left     : UNSIGNED(BIT_DEPTH - 1 downto 0) := (others => '0');
    signal modulated_phase_right    : UNSIGNED(BIT_DEPTH - 1 downto 0) := (others => '0');
    
    signal depth_factor             : STD_LOGIC_VECTOR(8 downto 0) := (others => '0');
    
    signal ws_del                   : STD_LOGIC;
    
begin
    
    
    -- Phasenmodulation
    phase_mod : process(clk)
    begin
        if (ws = '0'AND ws_del = '1') then
            depth_factor <= "0" & sine_value(8 downto 1);
            modulated_phase_left <= UNSIGNED(audio_left_in) + unsigned(depth_factor);
            modulated_phase_right <= UNSIGNED(audio_right_in) + unsigned(depth_factor);
        end if;
        ws_del <= ws;
    end process;
    
    audio_left_out <= std_logic_vector(modulated_phase_left);
    audio_right_out <= std_logic_vector(modulated_phase_right);
    
--    -- for testing
--    audio_left_out <= audio_left_in;
--    audio_right_out <= audio_right_in;
        
end Behavioral;