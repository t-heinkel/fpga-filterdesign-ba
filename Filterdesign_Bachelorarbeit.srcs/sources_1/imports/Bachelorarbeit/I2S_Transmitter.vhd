----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.09.2024 12:29:56
-- Design Name: 
-- Module Name: I2S_Transmitter - Behavioral
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

entity I2S_Transmitter is
    Generic (
        BIT_DEPTH : positive := 24
    );
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        
        -- I2S-Signale
        sck : in STD_LOGIC;
        ws : in STD_LOGIC;
        
        -- Dateninterface
        audio_left : in STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
        audio_right : in STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
        
        -- Ausgangssignal
        sd_out : out STD_LOGIC

    );
end I2S_Transmitter;

architecture RTL of I2S_Transmitter is
    type state_type is (IDLE, TX_LEFT, TX_RIGHT);
    signal current_state : state_type := IDLE;
    
    signal bit_counter : unsigned(4 downto 0) := (others => '0');
    signal shift_register : STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
    
    signal sck_del      : STD_LOGIC;
    
begin
    transmitter_process : process(clk)
    begin
        if rising_edge(clk) then
        
            if sck_del = '0' AND sck = '1' then
                if reset = '1' then
                    current_state <= IDLE;
                    bit_counter <= (others => '0');
                    shift_register <= (others => '0');
                else
                    case current_state is
                        when IDLE =>
                            if ws = '0' then
                                current_state <= TX_LEFT;
                                shift_register <= audio_left;
                            elsif ws = '1' then
                                current_state <= TX_RIGHT;
                                shift_register <= audio_right;
                            end if;
                            
                        when TX_LEFT | TX_RIGHT =>
                            sd_out <= shift_register(BIT_DEPTH-1);
                            shift_register <= shift_register(BIT_DEPTH-2 downto 0) & '0';
                            
                            if bit_counter = BIT_DEPTH - 1 then
                                bit_counter <= "00000";
                                current_state <= IDLE;
                            end if;
                            
                            bit_counter <= bit_counter + 1;
                    end case;
                end if;
            end if;
            
            sck_del <= sck;
            
        end if;
    end process;

end RTL;
