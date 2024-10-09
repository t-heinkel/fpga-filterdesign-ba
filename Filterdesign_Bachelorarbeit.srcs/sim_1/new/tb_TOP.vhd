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
            BIT_DEPTH   : positive := 24;
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
            audio_in_left_trans     : in STD_LOGIC_VECTOR(23 downto 0);
            audio_in_right_trans    : in STD_LOGIC_VECTOR(23 downto 0);
            audio_out_left_rec      : out STD_LOGIC_VECTOR(23 downto 0);
            audio_out_right_rec     : out STD_LOGIC_VECTOR(23 downto 0)
        );
    end component;

    signal clk                  : STD_LOGIC := '0';
    signal clk_del              : STD_LOGIC;
    signal reset                : STD_LOGIC;
    signal tb_audio_left_in     : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
    signal tb_audio_right_in    : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
    signal tb_audio_left_out    : STD_LOGIC_VECTOR(23 downto 0);
    signal tb_audio_right_out   : STD_LOGIC_VECTOR(23 downto 0);
    signal tb_sck               : STD_LOGIC := '1';
    signal sck_del              : STD_LOGIC;
    signal ws                   : STD_LOGIC := '0';
    signal sd_in                : STD_LOGIC := '0';
    signal sd_out               : STD_LOGIC := '0';
    signal tb_rx_ready          : STD_LOGIC := '0';
    signal tb_tx_ready          : STD_LOGIC;
    
    signal sd_cnt               : STD_LOGIC_VECTOR(2 downto 0) := "000";

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
        sck => tb_sck,
        ws => ws,
        sd_in => sd_in,
        sd_out => sd_out,
        rx_ready => tb_rx_ready,
        tx_ready => tb_tx_ready
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
            tb_audio_left_in <= X"800000"; -- Beispielwert für den Linkskanal
            tb_audio_right_in <= X"000000"; -- Beispielwert für den Rechtssignal-Kanal
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
    
    sd_in_process : process(clk, tb_sck)
    begin
        if rising_edge(clk) then
            tb_rx_ready <= '0';
            --tb_tx_ready <= '0';
            --for testing
            --sd_cnt <= std_logic_vector(unsigned(sd_cnt) + 1);
            
            if rising_edge(tb_sck) then
                
                case sd_cnt is
                    when "000" =>
                        sd_in <= '0';
                    when "001" =>
                        sd_in <= '0';
                    when "010" =>
                        sd_in <= '0';
                    when "011" =>
                        sd_in <= '1';
                    when "100" =>
                        sd_in <= '1';
                    when others =>
                        sd_in <= '1';
                end case;
                
                if(sd_cnt = "101") then
                    sd_cnt <= "000";
                    ws <= not ws;
                end if;
                
                sd_cnt <= std_logic_vector(unsigned(sd_cnt) + 1);
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
        tb_sck <= not tb_sck;
        wait for 20ns;
    end process sck_clk_process;
    

end behavior;