----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.09.2024 14:55:02
-- Design Name: 
-- Module Name: I2S_TOP - Behavioral
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

entity TOP is
    Generic (
        BIT_DEPTH   : positive := 24;
        SAMPLE_RATE : positive := 48000
    );
    Port (
        clk     : in STD_LOGIC;
        reset   : in STD_LOGIC;
        
        -- I2S-Signals
        sck     : in STD_LOGIC;
        ws      : in STD_LOGIC;
        sd_in   : in STD_LOGIC;
        sd_out  : out STD_LOGIC;
        
        -- dataoutput for data received by receiver
        audio_out_left_rec  : out STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
        audio_out_right_rec : out STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
        
        -- datainput for data to send by transmitter
        audio_in_left_trans   : in STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
        audio_in_right_trans  : in STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
        
        -- statussignals
        tx_ready : out STD_LOGIC;
        rx_ready : out STD_LOGIC
    );
end TOP;

architecture Structural of TOP is

    component i2s_receiver is
        Generic (
            BIT_DEPTH : positive := 24
        );
        Port (
            clk         : in STD_LOGIC;
            reset       : in STD_LOGIC;
            sck         : in STD_LOGIC;
            ws          : in STD_LOGIC;
            sd_in       : in STD_LOGIC;
            audio_left  : out STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
            audio_right : out STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
            rx_ready    : out STD_LOGIC
        );
    end component;
    
    component i2s_transmitter is
        Generic (
            BIT_DEPTH : positive := 24
        );
        Port (
            clk         : in STD_LOGIC;
            reset       : in STD_LOGIC;
            sck         : in STD_LOGIC;
            ws          : in STD_LOGIC;
            audio_left  : in STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
            audio_right : in STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
            sd_out      : out STD_LOGIC;
            tx_ready    : out STD_LOGIC
        );
    end component;
    
    component clock_generator is
        Generic (
            BIT_DEPTH   : positive;
            SAMPLE_RATE : positive
        );
        Port (
            clk_in  : in STD_LOGIC;
            lrck    : out STD_LOGIC;
            sclk    : out STD_LOGIC
        );
    end component;
    
    component audio_processor is
        Generic (
            BIT_DEPTH : positive := 24
        );
        Port (
            clk         : in STD_LOGIC;
            reset       : in STD_LOGIC;
            
            -- Eingangssignale vom Receiver
            sck_in      : in STD_LOGIC;
            ws_in       : in STD_LOGIC;
            audio_left_in : in STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
            audio_right_in : in STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
            
            -- Ausgangssignale zum Transmitter
            sck_out     : out STD_LOGIC;
            ws_out      : out STD_LOGIC;
            audio_left_out : out STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
            audio_right_out : out STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0)
        );
    end component;
    
    --signal reset : STD_LOGIC := '1';
    signal sd_in_int : STD_LOGIC;
    signal sd_out_int : STD_LOGIC;
    signal sck_int : STD_LOGIC;
    signal ws_int : STD_LOGIC;
    
    -- I2S Receiver Signals
    signal ws_rec : STD_LOGIC;
    
    -- I2S Transmitter Signals
    signal ws_trans : STD_LOGIC;
    
    -- I2S Transfer signals to/from audio processor
    signal rec_l_transfer   : STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
    signal rec_r_transfer   : STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
    signal trans_l_transfer : STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
    signal trans_r_transfer : STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
    
begin
    receiver_inst : i2s_receiver
        generic map (BIT_DEPTH => BIT_DEPTH)
        port map (
            clk => clk,
            reset => reset,
            sck => sck_int,
            ws => ws,
            sd_in => sd_in,
            audio_left => audio_out_left_rec,
            audio_right => audio_out_right_rec,
            rx_ready => rx_ready
        );
    
    transmitter_inst : i2s_transmitter
        generic map (BIT_DEPTH => BIT_DEPTH)
        port map (
            clk => clk,
            reset => reset,
            sck => sck_int,
            ws => ws,
            audio_left => audio_in_left_trans,
            audio_right => audio_in_right_trans,
            sd_out => sd_out,
            tx_ready => tx_ready
        );
    
    clock_gen_inst : clock_generator
        generic map (BIT_DEPTH => BIT_DEPTH, SAMPLE_RATE => SAMPLE_RATE)
        port map (
            clk_in => clk,
            lrck => ws_int,
            sclk => sck_int
        );
        
     processor_inst : audio_processor
        generic map (BIT_DEPTH => BIT_DEPTH)
        port map (
            clk => clk,
            reset => reset,
            sck_in => sck_int,
            ws_in => ws,
            audio_left_in => rec_l_transfer,
            audio_right_in => rec_r_transfer,
            sck_out => sck_int,
            ws_out => ws_trans,
            audio_left_out => trans_l_transfer,
            audio_right_out => trans_r_transfer
        );
        
        -- send and receive signals to/from audio_processor
        --rec_l_transfer <= audio_out_left_rec;
        --rec_r_transfer <= audio_out_right_rec;
        --audio_in_left_trans <= trans_l_transfer;
        --audio_in_right_trans <= trans_r_transfer;
        
       
        
        
end Structural;

