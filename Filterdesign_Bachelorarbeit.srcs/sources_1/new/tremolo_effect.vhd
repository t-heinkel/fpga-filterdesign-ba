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

entity tremolo_effect is
    GENERIC (
        BIT_DEPTH : positive := 24
    );
    Port (
        clk             : in STD_LOGIC;
        reset           : in STD_LOGIC;
        ws              : in STD_LOGIC;
        audio_left_in   : in STD_LOGIC_VECTOR(BIT_DEPTH - 1 downto 0);
        audio_right_in  : in STD_LOGIC_VECTOR(BIT_DEPTH - 1 downto 0);
        sine_value      : in unsigned(7 downto 0);
        audio_left_out  : out STD_LOGIC_VECTOR(BIT_DEPTH - 1 downto 0);
        audio_right_out : out STD_LOGIC_VECTOR(BIT_DEPTH - 1 downto 0)
    );
end tremolo_effect;

architecture Behavioral of tremolo_effect is

    signal audio_left_unsigned : unsigned(BIT_DEPTH - 1 downto 0);
    signal audio_right_unsigned : unsigned(BIT_DEPTH - 1 downto 0);
    signal tremolo_left : unsigned(BIT_DEPTH + 8 downto 0);
    signal tremolo_right : unsigned(BIT_DEPTH + 8 downto 0);
    
    signal ws_del : STD_LOGIC;
    
    signal result_left : unsigned(BIT_DEPTH + 7 downto 0);
    signal result_right : unsigned(BIT_DEPTH + 7 downto 0);
    
begin

    process(clk, reset)
        
    begin
        if rising_edge(clk) then
            if reset = '1' then
                audio_left_out <= (others => '0');
                audio_right_out <= (others => '0');
            else
                if (ws_del = '1' AND ws = '0') then
                    
                    audio_left_unsigned <= unsigned(audio_left_in);
                    audio_right_unsigned <= unsigned(audio_right_in);
                                        
                    -- TODO
                    -- Maybe I should try and soften the sine values here so that its not an ON/OFF kind of Tremolo
                    result_left <= audio_left_unsigned * sine_value;
                    result_right <= audio_right_unsigned * sine_value;

                       
                    if result_left = 0 then
                        audio_left_out <= std_logic_vector(result_left(BIT_DEPTH-1 downto 1) & "1");
                    else
                        audio_left_out <= std_logic_vector("00" & result_left(21 downto 0));
                    end if;
        
                    if result_right = 0 then
                        audio_right_out <= std_logic_vector(result_right(BIT_DEPTH-1 downto 1) & "1");
                    else
                        audio_right_out <= std_logic_vector("00" & result_right(21 downto 0));
                    end if;
        
                end if;
            end if;    
            ws_del <= ws;
        end if;
    end process;
    
end Behavioral;
