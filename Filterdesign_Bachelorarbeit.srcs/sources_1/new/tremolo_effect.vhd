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
        sine_value      : in STD_LOGIC_VECTOR(8 downto 0);
        audio_left_out  : out STD_LOGIC_VECTOR(BIT_DEPTH - 1 downto 0);
        audio_right_out : out STD_LOGIC_VECTOR(BIT_DEPTH - 1 downto 0)
    );
end tremolo_effect;

architecture Behavioral of tremolo_effect is

    signal audio_left_signed : signed(BIT_DEPTH - 1 downto 0);
    signal audio_right_signed : signed(BIT_DEPTH - 1 downto 0);
    signal tremolo_left : signed(BIT_DEPTH + 8 downto 0);
    signal tremolo_right : signed(BIT_DEPTH + 8 downto 0);
    
    signal ws_del : STD_LOGIC;
    
begin

    process(clk, reset)
        variable result_left : integer;
        variable result_right : integer;
        
    begin
    
        if reset = '1' then
            audio_left_out <= (others => '0');
            audio_right_out <= (others => '0');
            
        elsif rising_edge(clk) then
        
            if (ws_del = '1' AND ws = '0') then
                
                audio_left_signed <= signed(audio_left_in);
                audio_right_signed <= signed(audio_right_in);
                
                
                -- TODO
                -- Maybe I should try and soften the sine values here so that its not an ON/OFF kind of Tremolo
                result_left := to_integer(audio_left_signed) * to_integer(signed(sine_value));
                result_right := to_integer(audio_right_signed) * to_integer(signed(sine_value));
                   
                if result_left = 0 then
                    result_left := 1;
                else
                    result_left := result_left / 350;
                end if;
    
                if result_right = 0 then
                    result_right := 1;
                else
                    result_right := result_right / 350;
                end if;
    
                audio_left_out <= std_logic_vector(to_signed(result_left, BIT_DEPTH));
                audio_right_out <= std_logic_vector(to_signed(result_right, BIT_DEPTH));
            end if;
            
            ws_del <= ws;
        end if;
    end process;
    
end Behavioral;
