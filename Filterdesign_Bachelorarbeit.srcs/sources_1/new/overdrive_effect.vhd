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

entity overdrive_effect is
    GENERIC (
        BIT_DEPTH : positive := 24
    );
    Port (
        clk             : in STD_LOGIC;
        reset           : in STD_LOGIC;
        ws              : in STD_LOGIC;
        audio_left_in   : in STD_LOGIC_VECTOR(BIT_DEPTH - 1 downto 0);
        audio_right_in  : in STD_LOGIC_VECTOR(BIT_DEPTH - 1 downto 0);
        audio_left_out  : out STD_LOGIC_VECTOR(BIT_DEPTH - 1 downto 0);
        audio_right_out : out STD_LOGIC_VECTOR(BIT_DEPTH - 1 downto 0)
    );
end overdrive_effect;

architecture Behavioral of overdrive_effect is

    signal audio_left_signed : signed(BIT_DEPTH - 1 downto 0);
    signal audio_right_signed : signed(BIT_DEPTH - 1 downto 0);
    signal overdriven_left : signed(BIT_DEPTH + 2 downto 0);
    signal overdriven_right : signed(BIT_DEPTH + 2 downto 0);
    constant MAX_VALUE : signed(BIT_DEPTH - 1 downto 0) := (others => '1');
    constant MIN_VALUE : signed(BIT_DEPTH - 1 downto 0) := (others => '0');
    signal OVERDRIVE_GAIN : signed(5 downto 0) := "100000";
    
    signal ws_del : STD_LOGIC;
    
begin

    process(clk, reset)
    begin
        if reset = '1' then
            audio_left_out <= (others => '0');
            audio_right_out <= (others => '0');
        elsif rising_edge(clk) then
        
            if (ws_del = '1' AND ws = '0') then
                audio_left_signed <= signed(audio_left_in);
                audio_right_signed <= signed(audio_right_in);
    
                overdriven_left <= resize(audio_left_signed * OVERDRIVE_GAIN, overdriven_left'length);
                overdriven_right <= resize(audio_right_signed * OVERDRIVE_GAIN, overdriven_right'length);
    
                if overdriven_left > MAX_VALUE then
                    audio_left_out <= std_logic_vector(MAX_VALUE);
                end if;
    
                if overdriven_right > MAX_VALUE then
                    audio_right_out <= std_logic_vector(MAX_VALUE);
                end if;
                
                
            end if;
            
            ws_del <= ws;
        end if;
    end process;
    
end Behavioral;