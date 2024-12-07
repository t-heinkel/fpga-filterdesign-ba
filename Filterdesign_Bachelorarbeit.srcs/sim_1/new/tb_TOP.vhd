----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.09.2024 15:17:06
-- Design Name: 
-- Module Name: tb_TOP - Behavioral
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
--use ieee.std_logic_arith.all;

entity tb_TOP is
end tb_TOP;

architecture behavior of tb_TOP is

    component TOP is
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
            AC_SDA      : inout STD_LOGIC
        );
    end component;
    
    component clk_wiz_0 is
          Port (
            clk_24 : out STD_LOGIC;
            clk_9_6 : out STD_LOGIC;
            reset : in STD_LOGIC;
            locked : out STD_LOGIC;
            clk_in1 : in STD_LOGIC
          );
    end component;
    
    component sine_lut is
        Port (
          clk       : in  std_logic;
          i_addr    : in  std_logic_vector(7 downto 0);
          o_data    : out std_logic_vector(8 downto 0)
        );
    end component;

    signal clk                  : STD_LOGIC := '0';
    signal clk_del              : STD_LOGIC;
    signal reset                : STD_LOGIC;
    signal tb_audio_left_in     : STD_LOGIC_VECTOR(27 downto 0) := (others => '0');
    signal tb_audio_right_in    : STD_LOGIC_VECTOR(27 downto 0) := (others => '0');
    signal tb_audio_left_out    : STD_LOGIC_VECTOR(27 downto 0);
    signal tb_audio_right_out   : STD_LOGIC_VECTOR(27 downto 0);
    signal clk_25               : STD_LOGIC := '1';
    signal sck_del              : STD_LOGIC;
    signal ws                   : STD_LOGIC := '0';
    signal sd_in                : STD_LOGIC := '0';
    signal sd_out               : STD_LOGIC := '0';
    signal tb_rx_ready          : STD_LOGIC := '0';
    signal tb_tx_ready          : STD_LOGIC;
    signal sd_value             : STD_LOGIC := '1';
    
    signal sd_cnt               : STD_LOGIC_VECTOR(2 downto 0) := "000";
    signal ws_cnt               : STD_LOGIC_VECTOR(4 downto 0) := "00000";
    
    signal ws_del               : STD_LOGIC;
   
    -- clock wizard signals
    signal clk_24               : STD_LOGIC;
    signal clk_9_6              : STD_LOGIC;
    signal clk_khz_48           : STD_LOGIC := '0';
    signal clk_khz_48_del       : STD_LOGIC;
    signal clk_locked           : STD_LOGIC;
    signal clk_reset            : STD_LOGIC;
    
    signal bclk_counter         : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    
    -- I2C-Signals
    signal sck                  : STD_LOGIC;
    signal sda                  : STD_LOGIC;
    
    
    signal test                 : STD_LOGIC;
    
    signal AC_ADR0              : STD_LOGIC := '1';
    signal AC_ADR1              : STD_LOGIC := '1';
    
    -- Clock Signals
    constant BASE_FREQUENCY     : integer := 2304000; -- 2.304 MHz
    constant BIT_CLOCK_PERIOD   : time := 434.0277777777778 ns;
    signal bit_clk              : STD_LOGIC := '0';
    signal bit_clk_del          : STD_LOGIC := '1';
    
    signal first_sample         : STD_LOGIC := '1';
    signal sample_cnt           : STD_LOGIC_VECTOR(1 downto 0) := "00"; 
    
    -- Sine Signals
    signal sine_counter : STD_LOGIC_VECTOR(17 downto 0) := (others => '0');
    signal sine_data     : STD_LOGIC_VECTOR(8 downto 0);
    signal sine_addr     : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');    

begin
    -- Instanziierung des zu testenden Systems
    uut : TOP
    Port Map (
        clk => clk,
        AC_ADR0 => AC_ADR0,
        AC_ADR1 => AC_ADR1,
        AC_GPIO0 => sd_out,  -- I2S Data TO ADAU1761
        AC_GPIO1 => sd_in,  -- I2S Data FROM ADAU1761
        AC_GPIO2 => bit_clk,  -- I2S_bclk
        AC_GPIO3 => ws,  -- I2S_LR
        AC_MCLK => clk_24,
        AC_SCK => sck,
        AC_SDA => sda,
        sck => clk_24,
        ws => ws_del
    );
    
     clk_wizard : clk_wiz_0
        port map (
          clk_24 => clk_24,
          clk_9_6 => clk_9_6,
          -- Status and control signals
          reset => clk_reset,
          locked => clk_locked,
          -- Clock in ports
          clk_in1 => clk
        );       
        
    sine_lut_inst_2 : sine_lut
        Port map(
          clk => clk,
          i_addr => sine_addr,
          o_data => sine_data
        );
    
    tb_rx_ready <= '1';
    
    clk_khz_48_del <= clk_khz_48;
    
    --bit_clk_del <= bit_clk;
    
    tb_process : process
    begin
        test <= '0';
        wait for 20ns;
        test <= '0';
    end process tb_process;
    
    sd_in_process : process(bit_clk)
    begin
        if (clk_locked = '1') then
            if bit_clk_del = '0' AND bit_clk = '1' then
            
                if first_sample = '1' then
                    ws_del <= ws;
    
                    sd_cnt <= std_logic_vector(unsigned(sd_cnt) + 1);
                    ws_cnt <= std_logic_vector(unsigned(ws_cnt) + 1);                 
                    
                    if(sd_cnt = "001") then
                        sd_value <= not sd_value;
                        sd_cnt <= "000";
                    end if;
                    
                    
                    if(ws_cnt = "11000") then
                        sample_cnt <= std_logic_vector(unsigned(sample_cnt) + 1);
                        ws_cnt <= "00000";
                        ws <= not ws;
                    end if;
                    
                    sd_in <= sd_value;  
                    
                    if(sample_cnt = "10") then
                        first_sample <= '0';
                    end if;
                else    
                    ws_del <= ws;
    
                    sd_cnt <= std_logic_vector(unsigned(sd_cnt) + 1);
                    ws_cnt <= std_logic_vector(unsigned(ws_cnt) + 1);                 
                    
                    if(sd_cnt = "101") then
                        sd_value <= not sd_value;
                        sd_cnt <= "000";
                    end if;
                    
                    
                    if(ws_cnt = "11000") then
                        ws_cnt <= "00000";
                        ws <= not ws;
                    end if;
                                
                    sd_in <= sd_value;         
                end if;
            end if;
        end if;
    end process sd_in_process;
        
    clk_process : process
    begin
        clk <= not clk;
        --clk_del <= clk;
        wait for 5 ns;
    end process clk_process;
    
    bit_clock_process : process
    begin
        bit_clk <= not bit_clk;
        bit_clk_del <= not bit_clk_del;
        wait for BIT_CLOCK_PERIOD / 2;
    end process bit_clock_process;
    
    bclk_process : process(clk_9_6)
    begin 
        if (clk_locked = '1') then
            if rising_edge(clk_9_6) then           
                if(bclk_counter = "11001000") then
                    bclk_counter <= (others => '0');
                    clk_khz_48 <= not clk_khz_48;
                end if;
                bclk_counter <= std_logic_vector(unsigned(bclk_counter) + 1);               
            end if;
        end if;
    end process bclk_process;
    
    -- Aktuell schwer einzubauen, weil weil einzelne Bits übertragen werden und nicht ganze Samples
    sine_count : process(clk) -- Produces a Frequency of Around 2Hz
    begin
        if rising_edge(clk) then
            sine_counter <= STD_LOGIC_VECTOR(unsigned(sine_counter) + 1);
            
--            if(sine_counter = "101110011000110000") then -- 190.000  -> 100MHz / 512  - 2 volle Sinusperiode pro Sekunde
            if(sine_counter = "000000000000110000") then -- 190.000  -> 100MHz / 512  - 2 volle Sinusperiode pro Sekunde
                sine_addr <= STD_LOGIC_VECTOR(unsigned(sine_addr) + 1);
                sine_counter <= (others => '0');
            end if;
        end if;
    end process sine_count;    

end behavior;