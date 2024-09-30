----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.09.2024 15:17:06
-- Design Name: 
-- Module Name: I2S_TOP_tb - Behavioral
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

architecture Behavioral of tb_TOP is

    component TOP is
        Generic (
            BIT_DEPTH   : positive := 24;
            SAMPLE_RATE : positive := 48000
        );
        Port (
            clk             : in STD_LOGIC;
            reset           : in STD_LOGIC;
            sck             : out STD_LOGIC;
            ws              : out STD_LOGIC;
            sd_in           : in STD_LOGIC;
            sd_out          : out STD_LOGIC;
            rx_ready        : out STD_LOGIC;
            tx_ready        : out STD_LOGIC;
            audio_in_left_trans     : in STD_LOGIC_VECTOR(23 downto 0);
            audio_in_right_trans    : in STD_LOGIC_VECTOR(23 downto 0);
            audio_out_left_rec      : out STD_LOGIC_VECTOR(23 downto 0);
            audio_out_right_rec     : out STD_LOGIC_VECTOR(23 downto 0)
        );
    end component;

    signal clk                  : STD_LOGIC := '0';
    signal reset                : STD_LOGIC := '1';
    signal tb_audio_left_in     : STD_LOGIC_VECTOR(23 downto 0);
    signal tb_audio_right_in    : STD_LOGIC_VECTOR(23 downto 0);
    signal tb_audio_left_out    : STD_LOGIC_VECTOR(23 downto 0);
    signal tb_audio_right_out   : STD_LOGIC_VECTOR(23 downto 0);
    signal sck                  : STD_LOGIC := '0';
    signal ws                   : STD_LOGIC := '0';
    signal sd_in                : STD_LOGIC := '0';
    signal sd_out               : STD_LOGIC := '0';
    signal tb_rx_ready          : STD_LOGIC := '0';
    signal tb_tx_ready          : STD_LOGIC := '0';

begin
    -- Instanziierung des zu testenden Systems
    dut : TOP
    Port Map (
        clk => clk,
        reset => reset,
        audio_in_left_trans => tb_audio_left_in,
        audio_in_right_trans => tb_audio_right_in,
        audio_out_left_rec => tb_audio_left_out,
        audio_out_right_rec => tb_audio_right_out,
        sck => sck,
        ws => ws,
        sd_in => sd_in,
        sd_out => sd_out,
        rx_ready => tb_rx_ready,
        tx_ready => tb_tx_ready
    );

    -- Hauptprozess der Testbench
    tb_process : process
    begin
        -- Initialisierung und Reset setzen
        reset <= '1';
        wait for 20 ns;
        reset <= '0';   
        tb_rx_ready <= '0';
        
        -- Test des Empfängers
        tb_rx_ready <= '0';
        sd_in <= '1'; -- Beispielwert für das zu sendende Signal
        tb_rx_ready <= '1';
        
        -- Test des Senders
        tb_tx_ready <= '0';
        tb_audio_left_in <= X"800000"; -- Beispielwert für den Linkskanal
        tb_audio_right_in <= X"000000"; -- Beispielwert für den Rechtssignal-Kanal
        tb_tx_ready <= '1';

        -- Warten auf die Übertragung
        --wait until tx_ready = '1';

        -- Überprüfung des empfangenen Signals
        assert (sd_in = '1')
            report "SD-In Signal ist nicht korrekt"
            severity warning;



        -- Warten auf die Empfangsübertragung
        wait until tb_rx_ready = '1';

        -- Überprüfung des ausgegebenen Signals
        assert (tb_audio_left_out /= X"000000")
            report "Audio Left Output ist leer"
            severity failure;

        -- Simulationsende
        wait for 100 ms;
        wait;
    end process tb_process;
    
    sck_clk_process : process
    begin 
        if (rising_edge(clk)) then
            sck <= not sck;
        end if;
    
        wait for 10ns;
        
    end process sck_clk_process;

end Behavioral;