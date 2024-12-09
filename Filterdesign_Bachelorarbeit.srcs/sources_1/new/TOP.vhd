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
library UNISIM;
use UNISIM.VComponents.all;

entity TOP is
    Generic (
        BIT_DEPTH   : positive := 24;
        SAMPLE_RATE : positive := 48000
    );
    Port (
        clk     : in STD_LOGIC;
        
        -- I2S-Signals
        sck     : in STD_LOGIC;
        ws      : in STD_LOGIC;
        
        AC_ADR0     : out   STD_LOGIC;
        AC_ADR1     : out   STD_LOGIC;
        AC_GPIO0    : out   STD_LOGIC;  -- I2S Data TO ADAU1761
        AC_GPIO1    : in    STD_LOGIC;  -- I2S Data FROM ADAU1761
        AC_GPIO2    : in    STD_LOGIC;  -- I2S_bclk
        AC_GPIO3    : in    STD_LOGIC;  -- I2S_LR
        AC_MCLK     : out   STD_LOGIC;
        AC_SCK      : out   STD_LOGIC;
        AC_SDA      : inout STD_LOGIC;
        
        -- Buttons for effects
        btnL     : in STD_LOGIC := '0';
        btnC     : in STD_LOGIC := '0';
        btnR     : in STD_LOGIC := '0';
        btnU     : in STD_LOGIC := '0'
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
            audio_right : out STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0)
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
            sd_out      : out STD_LOGIC
        );
    end component;
    
    component clock_generator is
        Generic (
            BIT_DEPTH   : positive;
            SAMPLE_RATE : positive
        );
        Port (
            clk_in      : in STD_LOGIC;
            clk_100     : out STD_LOGIC;
            clk_24      : out STD_LOGIC
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
            ws_out      : out STD_LOGIC;
            audio_left_out : out STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
            audio_right_out : out STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
            
            btnL     : in STD_LOGIC;
            btnC     : in STD_LOGIC;
            btnR     : in STD_LOGIC;
            btnU     : in STD_LOGIC
        );
    end component;
    
    component i2c_master is
        Port ( 
            clk         : in  STD_LOGIC;
            i2c_sda_i   : IN std_logic;      
            i2c_sda_o   : OUT std_logic;      
            i2c_sda_t   : OUT std_logic;      
            i2c_scl     : out  STD_LOGIC;
            sw          : in std_logic_vector(1 downto 0);
            active      : out std_logic_vector(1 downto 0)
        );
    end component;
    
    component clk_wiz_0 is
        Port (
          -- Clock out ports
          clk_24      : out STD_LOGIC;
          -- Status and control signals
          reset         : in STD_LOGIC;
          locked        : out STD_LOGIC;
          -- Clock in ports
          clk_in1       : in STD_LOGIC         
        );
    end component;
    
    -- I2S Signals    
    signal bclk_int : STD_LOGIC;
    signal sck_sync : STD_LOGIC;
    signal sck_del : STD_LOGIC;
    signal ws_int : STD_LOGIC;
    signal ws_sync : STD_LOGIC;
    signal ws_del : STD_LOGIC;

    
    -- I2S Receiver Signals
    signal ws_rec : STD_LOGIC;
    signal sd_in_int : STD_LOGIC;

    -- I2S Transmitter Signals
    signal ws_trans : STD_LOGIC;
    signal sd_out_int : STD_LOGIC;
    
    -- I2S Transfer signals to/from audio processor
    signal rec_l_transfer   : STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
    signal rec_r_transfer   : STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
    signal trans_l_transfer : STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
    signal trans_r_transfer : STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
    
    -- I2C Master Signals
    signal i2c_scl      : STD_LOGIC;
    signal i2c_sda_i    : STD_LOGIC;
    signal i2c_sda_o    : STD_LOGIC;
    signal i2c_sda_t    : STD_LOGIC;
    signal sw           : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');

    
    -- clk signals
    signal clk_24       : STD_LOGIC;
    signal clk_reset    : STD_LOGIC;
    signal clk_locked   : STD_LOGIC;
    
    -- reset signal
    signal reset        : STD_LOGIC := '1';
    
    signal btnL_int     : STD_LOGIC := '0';
    signal btnC_int     : STD_LOGIC := '0';
    signal btnR_int     : STD_LOGIC := '0';
    signal btnU_int     : STD_LOGIC := '0';
    
    -- Debug
    attribute MARK_DEBUG : STRING;
    attribute MARK_DEBUG of sd_in_int : signal is "true"; 
    attribute MARK_DEBUG of sd_out_int : signal is "true"; 
    --attribute MARK_DEBUG of AC_SDA : signal is "true";

    --attribute MARK_DEBUG of sck_del : signal is "true";
    
    
begin

    AC_ADR0         <= '1';
    AC_ADR1         <= '1';
    AC_GPIO0        <= sd_out_int;      -- Data to ADAU1761
    sd_in_int       <= AC_GPIO1;        -- Data from ADAU1761
    bclk_int        <= AC_GPIO2;        -- I2S BitClock
    ws_int          <= AC_GPIO3;        -- L/R Channel select
    AC_MCLK         <= clk_24;
    AC_SCK          <= i2c_scl;
    btnL_int        <= btnL;
    btnC_int        <= btnC;
    btnR_int        <= btnR;
    btnU_int        <= btnU;

    receiver_inst : i2s_receiver
        generic map (BIT_DEPTH => BIT_DEPTH)
        port map (
            clk => clk,
            reset => reset,
            sck => sck_del,
            ws => ws_del,
            sd_in => sd_in_int,
            audio_left => rec_l_transfer,
            audio_right => rec_r_transfer
        );
    
    transmitter_inst : i2s_transmitter
        generic map (BIT_DEPTH => BIT_DEPTH)
        port map (
            clk => clk,
            reset => reset,
            sck => sck_del,
            ws => ws_del,
            audio_left => trans_l_transfer,
            audio_right => trans_r_transfer,
            sd_out => sd_out_int
        );
        
     processor_inst : audio_processor
        generic map (BIT_DEPTH => BIT_DEPTH)
        port map (
            clk => clk,
            reset => reset,
            sck_in => sck_del,
            ws_in => ws_del,
            audio_left_in => rec_l_transfer,
            audio_right_in => rec_r_transfer,
            ws_out => ws_trans,
            audio_left_out => trans_l_transfer,
            audio_right_out => trans_r_transfer,
            btnL => btnL_int,
            btnC => btnC_int,
            btnR => btnR_int,
            btnU => btnU_int
        );
     
     i2c_master_inst : i2c_master
        port map(
            clk       => clk_24,
            i2c_sda_i => i2c_sda_i,
            i2c_sda_o => i2c_sda_o,
            i2c_sda_t => i2c_sda_t,
            i2c_scl   => i2c_scl,
            sw => sw,
            active => open        
        );
     
     clk_wizard : clk_wiz_0
        port map (
          clk_24 => clk_24,
          -- Status and control signals
          reset => clk_reset,
          locked => clk_locked,
          -- Clock in ports
          clk_in1 => clk
        );   
        
    i_i2s_sda_obuf : IOBUF
       port map (
          IO => AC_SDA,   -- Buffer inout port (connect directly to top-level port)
          O => i2c_sda_i, -- Buffer output (to fabric)
          I => i2c_sda_o, -- Buffer input  (from fabric)
          T => i2c_sda_t  -- 3-state enable input, high=input, low=output 
       );
        
    reset <= not clk_locked;
        
    sync_proc : process(clk)
    begin
        if rising_edge(clk) then
            sck_sync <= bclk_int;
            sck_del <= sck_sync;
            
            ws_sync <= ws_int;
            ws_del <= ws_sync;
        end if;
    end process sync_proc;        
        
end Structural;

