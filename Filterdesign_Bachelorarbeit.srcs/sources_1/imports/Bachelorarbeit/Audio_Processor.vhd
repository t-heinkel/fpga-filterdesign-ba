----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.09.2024 16:45:01
-- Design Name: 
-- Module Name: Audio_Processor - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Meant to apply the Audio Effects to the signal
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

entity audio_processor is
    Generic (
        BIT_DEPTH : positive := 24;
        OVERDRIVE_GAIN : integer := 200;
        SAMPLE_RATE : integer := 48000;
        MOD_FREQ : real := 5.0;
        WIDTH : real := 0.005 
    );
    Port (
        clk             : in STD_LOGIC;
        reset           : in STD_LOGIC;
        
        -- Eingangssignale vom Receiver
        sck_in          : in STD_LOGIC;
        ws_in           : in STD_LOGIC;
        audio_left_in   : in STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
        audio_right_in  : in STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
        
        -- Ausgangssignale zum Transmitter
        ws_out          : out STD_LOGIC;
        audio_left_out  : out STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
        audio_right_out : out STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0)
    );
end audio_processor;

architecture Behavioral of audio_processor is

    component sine_lut is
        Port (
          i_clk          : in  std_logic;
          i_addr         : in  std_logic_vector(7 downto 0);
          o_data         : out std_logic_vector(8 downto 0)
        );
    end component;

    signal sin_data     : STD_LOGIC_VECTOR(8 downto 0);
    signal sin_addr     : STD_LOGIC_VECTOR(7 downto 0);

    signal sine_counter : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    

    constant MAX_VALUE : signed(BIT_DEPTH-1 downto 0) := (others => '1');
    constant MIN_VALUE : signed(BIT_DEPTH-1 downto 0) := (others => '0');
    
    constant DELAY : natural := integer(real(WIDTH) * real(SAMPLE_RATE));
    constant WIDTH_SAMPLES : natural := integer(real(WIDTH) * real(SAMPLE_RATE));
    constant MOD_FREQ_SAMPLES : real := MOD_FREQ / real(SAMPLE_RATE);

    type delay_line_type is array (0 to real(DELAY) + real(WIDTH) - 1) of signed(BIT_DEPTH-1 downto 0);
    signal delay_line : delay_line_type := (others => (others => '0'));

    function apply_overdrive(input : signed) return signed is
        variable result : signed(input'range);
        variable abs_input : unsigned(input'length-1 downto 0);
    begin
        abs_input := unsigned(abs(signed(input)));
        if abs_input = unsigned(MAX_VALUE) then
            result := MAX_VALUE;
        elsif abs_input = unsigned(MIN_VALUE) then
            result := MIN_VALUE;
        else
            result := resize(input * OVERDRIVE_GAIN, result'length);
        end if;
        return result;
    end function apply_overdrive;

--    function apply_chorus(input : signed; delay_length : natural; num_copies : natural) return signed is
--        variable delayed_signal : signed(input'range);
--        variable mixed_signal : signed(input'range);
--        constant DELAY_STEPS : array (0 to num_copies-1) of natural := (delay_length/num_copies, delay_length*2/num_copies, delay_length*3/num_copies);
--        variable read_indices : array (0 to num_copies-1) of natural range 0 to delay_length-1;
--        variable write_index : natural range 0 to delay_length-1 := 0;
--        variable delay_buffer : array (0 to delay_length-1) of signed(input'range) := (others => (others => '0'));
--    begin
--        -- Schreibe aktuelles Sample in den Puffer
--        delay_buffer(write_index) := input;
        
--        -- Aktualisiere Leseindizes für die verzögerten Kopien
--        for i in 0 to num_copies-1 loop
--            read_indices(i) := (write_index + DELAY_STEPS(i)) mod delay_length;
--        end loop;
        
--        -- Mischen des Originalsignals mit den verzögerten Kopien
--        mixed_signal := input;
--        for i in 0 to num_copies-1 loop
--            mixed_signal := mixed_signal + delay_buffer(read_indices(i));
--        end loop;
        
--        -- Durchschnittsbildung und Rückgabe
--        mixed_signal := mixed_signal / (num_copies + 1);
        
--        -- Inkrementiere Schreibindex
--        write_index := (write_index + 1) mod delay_length;
        
--        return mixed_signal;
--    end function apply_chorus;

--    function apply_chorus(input : signed) return signed is
    
--    begin
        
--    end function apply_chorus;

    function apply_vibrato(input : signed; n : natural) return signed is
        variable delayed_signal : signed(input'range);
        variable tap : real;
        variable frac : real;
        variable i : natural;
    begin
        tap := real(DELAY) + WIDTH_SAMPLES * sin(MOD_FREQ_SAMPLES * 2.0 * MATH_PI * real(n));
        i := integer(tap);
        frac := tap - real(i);

        delayed_signal := resize(signed(delay_buffer(i)) * (1.0 - frac) + signed(delay_buffer(i+1)) * frac, input'length);
        return delayed_signal;
    end function apply_vibrato;

begin
    process(clk)
        variable left_sample : signed(audio_left_in'range);
        variable right_sample : signed(audio_right_in'range);
                
    begin
        if rising_edge(clk) then
            if reset = '1' then
                audio_left_out <= (others => '0');
                audio_right_out <= (others => '0');
            else
                 -- Konvertiere Eingangssignale zu signed
                left_sample := signed(audio_left_in);
                right_sample := signed(audio_right_in);
                
                
                -- Wende Overdrive-Effekt an
                audio_left_out <= std_logic_vector(apply_overdrive(left_sample));
                audio_right_out <= std_logic_vector(apply_overdrive(right_sample));
                
                -- Wende Vibrato-Effekt an
                audio_left_out <= std_logic_vector(apply_vibrato(left_sample, sine_counter));
                audio_right_out <= std_logic_vector(apply_vibrato(right_sample, sine_counter));
                
                
                -- Signale einfach durchreichen zum Testen
                --audio_left_out <= audio_left_in;
                --audio_right_out <= audio_right_in;
            end if;
        end if;
    end process;
    
    -- Durchreichen der Timing-Signale
    ws_out <= ws_in;
end Behavioral;

