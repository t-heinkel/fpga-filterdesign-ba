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
        BIT_DEPTH : positive := 24
        OVERDRIVE_GAIN : integer := 200
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

    constant MAX_VALUE : signed(BIT_DEPTH-1 downto 0) := (others => '1');
    constant MIN_VALUE : signed(BIT_DEPTH-1 downto 0) := (others => '0');

    function apply_overdrive(input : signed) return signed is
        variable result : signed(input'range);
        variable abs_input : unsigned(input'length-1 downto 0);
    begin
        abs_input := unsigned(abs(signed(input)));
        if abs_input = MAX_VALUE then
            result := MAX_VALUE;
        elsif abs_input = MIN_VALUE then
            result := MIN_VALUE;
        else
            result := resize(input * OVERDRIVE_GAIN, result'length);
        end if;
        return result;
    end function apply_overdrive;
    
begin
    process(clk)
        variable left_sample : signed(audio_left_in'range);
        variable right_sample : signed(audio_right_in'range);
    begin
        if rising_edge(clk) then
            if reset = '1' then
                audio_left_out <= (others => '0');
                audio_right_out <= (others => '0');
            else
                 -- Konvertiere Eingangssignale zu signed
                left_sample := signed(audio_left_in);
                right_sample := signed(audio_right_in);
                
                -- Wende Overdrive-Effekt an
                audio_left_out <= std_logic_vector(apply_overdrive(left_sample));
                audio_right_out <= std_logic_vector(apply_overdrive(right_sample));
                
                -- Verdoppeln der Eingangsdaten
                --audio_left_out <= std_logic_vector(unsigned(audio_left_in) * 3);
                --audio_right_out <= std_logic_vector(unsigned(audio_right_in) * 3);
                
                -- Signale einfach durchreichen zum Testen
                --audio_left_out <= audio_left_in;
                --audio_right_out <= audio_right_in;
            end if;
        end if;
    end process;
    
    -- Durchreichen der Timing-Signale
    ws_out <= ws_in;
end Behavioral;

