----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.09.2024 12:29:56
-- Design Name: 
-- Module Name: I2S_Receiver - Behavioral
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

entity I2S_Receiver is
    Generic (
        BIT_DEPTH : positive := 24  -- size of each channel (left/right). --> left channel + right channel = 2 * BIT_DEPTH
    );
    Port (
        clk     : in STD_LOGIC;
        reset   : in STD_LOGIC;
        
        -- I2S-Signale
        sck     : in STD_LOGIC;     -- Serial Clock
        ws      : in STD_LOGIC;     -- Word Select (Left/Right Signal)
        sd_in   : in STD_LOGIC;     -- Serial Data Input
        ws_out  : out STD_LOGIC;
        
        -- Output for received Signals
        audio_left  : out STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
        audio_right : out STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0)
                
    );
end I2S_Receiver;

architecture RTL of I2S_Receiver is
    type state_type is (IDLE, RX_LEFT, RX_RIGHT);
    signal current_state : state_type := IDLE;
    
    signal bit_counter      : unsigned(4 downto 0) := "00000";                                  -- Counter for Bit Position
    signal shift_register   : STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0) := (others => '0');        -- Shift Register for received data
    
    signal sd_in_del        : STD_LOGIC;
    
    signal sck_del          : STD_LOGIC;
    
begin
    receiver_process : process(clk)
    begin
        if rising_edge(clk) then
            
            if sck_del = '0' AND sck = '1' then        
                if reset = '1' then
                    -- Reset internal signals
                    current_state   <= IDLE;
                    bit_counter     <= (others => '0');
                    shift_register  <= (others => '0');
                  
                else
                    case current_state is
                        when IDLE =>
                            -- wait for signal
                            if ws = '0' then
                                current_state <= RX_LEFT;
                            elsif ws = '1' then
                                current_state <= RX_RIGHT;
                            end if;
                            
                        when RX_LEFT =>
                            -- receive data into shift register
                            shift_register  <= sd_in_del & shift_register(BIT_DEPTH-1 downto 1);
                            bit_counter     <= bit_counter + 1;
                            
                            -- if every bit is received, then
                            if bit_counter = BIT_DEPTH - 1 then
                                -- assign data and switch state to idle
                                audio_left      <= shift_register;
                                bit_counter <= (others => '0');
                                current_state   <= RX_RIGHT;
                            end if;
                            
                        when RX_RIGHT =>
                            shift_register  <= sd_in_del & shift_register(BIT_DEPTH-1 downto 1);
                            bit_counter     <= bit_counter + 1;
                            
                            if bit_counter = BIT_DEPTH - 1 then
                                audio_right     <= shift_register;
                                bit_counter <= (others => '0');
                                current_state   <= RX_LEFT;
                            end if;
                    end case;
                end if;
            end if;
            
            sd_in_del <= sd_in;
            sck_del <= sck;
            
        end if;
    end process;


end RTL;
