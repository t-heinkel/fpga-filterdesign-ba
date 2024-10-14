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

entity tb_TOP is
end tb_TOP;

architecture behavior of tb_TOP is

    component TOP is
        Generic (
            BIT_DEPTH   : positive := 28;
            SAMPLE_RATE : positive := 48000
        );
        Port (
            clk             : in STD_LOGIC;
            reset           : in STD_LOGIC;
            sck             : in STD_LOGIC;
            ws              : in STD_LOGIC;
            sd_in           : in STD_LOGIC;
            sd_out          : out STD_LOGIC;
            rx_ready        : out STD_LOGIC;
            tx_ready        : out STD_LOGIC;
            audio_in_left_trans     : in STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
            audio_in_right_trans    : in STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
            audio_out_left_rec      : out STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
            audio_out_right_rec     : out STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0)
        );
    end component;
    
    component clk_wiz_0 is
        Port (
          -- Clock out ports
          clk_out1      : out STD_LOGIC;
          -- Status and control signals
          reset         : in STD_LOGIC;
          locked        : out STD_LOGIC;
          -- Clock in ports
          clk_in1       : in STD_LOGIC         
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
    signal sd_value             : STD_LOGIC := '0';
    
    signal sd_cnt               : STD_LOGIC_VECTOR(2 downto 0) := "000";
    signal ws_cnt               : STD_LOGIC_VECTOR(4 downto 0) := "00000";
    
    -- clock wizard signals
    signal clk_24               : STD_LOGIC;
    signal clk_locked           : STD_LOGIC;
    signal clk_reset            : STD_LOGIC;

begin
    -- Instanziierung des zu testenden Systems
    uut : TOP
    Port Map (
        clk => clk,
        reset => reset,
        audio_in_left_trans => tb_audio_left_in,
        audio_in_right_trans => tb_audio_right_in,
        audio_out_left_rec => tb_audio_left_out,
        audio_out_right_rec => tb_audio_right_out,
        sck => clk_24,
        ws => ws,
        sd_in => sd_in,
        sd_out => sd_out,
        rx_ready => tb_rx_ready,
        tx_ready => tb_tx_ready
    );
    
     clk_wizard : clk_wiz_0
        port map (
          clk_out1 => clk_24,
          -- Status and control signals
          reset => clk_reset,
          locked => clk_locked,
          -- Clock in ports
          clk_in1 => clk
        );       

    tb_process : process
    begin
    
        --if (rising_edge(clk)) then
            reset <= '1';
            wait for 20 ns;
            reset <= '0';   
            tb_rx_ready <= '0';
            
            -- Test des Senders
            --tb_tx_ready <= '0';
            --tb_audio_left_in <= X"800000"; -- Beispielwert für den Linkskanal
            --tb_audio_right_in <= X"000000"; -- Beispielwert für den Rechtssignal-Kanal
            wait for 5ns;
            --tb_tx_ready <= '1';
    
            -- Überprüfung des empfangenen Signals
            assert (sd_in = '1')
                report "SD-In Signal ist nicht korrekt"
                severity warning;
    
    
            -- Überprüfung des ausgegebenen Signals
            assert (tb_audio_left_out /= X"000000")
                report "Audio Left Output ist leer"
                severity failure;
    
            -- Simulationsende
            wait for 100 ms;
            wait;
        
        --end if;
    end process tb_process;

    
    tb_rx_ready <= '1';
    
    sd_in_process : process(clk, clk_24)
    begin
        if rising_edge(clk) then
            tb_rx_ready <= '0';
            --tb_tx_ready <= '0';
            --for testing
            --sd_cnt <= std_logic_vector(unsigned(sd_cnt) + 1);
            
            if rising_edge(clk_24) then
                
                if(sd_cnt = "000") then
                    sd_value <= not sd_value;
                end if;
                
                if(sd_cnt = "111") then
                    sd_cnt <= "000";
                end if;
                
                if(ws_cnt = "11100") then
                    ws_cnt <= "00000";
                    ws <= not ws;
                end if;
                
                sd_in <= sd_value;
                sd_cnt <= std_logic_vector(unsigned(sd_cnt) + 1);
                ws_cnt <= std_logic_vector(unsigned(ws_cnt) + 1);
            end if;
        end if;
    end process sd_in_process;
        
    clk_process : process
    begin
        clk <= not clk;
        --clk_del <= clk;
        wait for 5 ns;
    end process clk_process;
    
    sck_clk_process : process
    begin 
        clk_25 <= not clk_25;
        wait for 20ns;
    end process sck_clk_process;
    

end behavior;