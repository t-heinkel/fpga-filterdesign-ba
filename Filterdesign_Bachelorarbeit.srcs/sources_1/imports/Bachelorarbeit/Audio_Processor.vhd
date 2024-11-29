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
        WIDTH : real := 0.005;
        TREMOLO_FREQ : real := 5.0;
        TREMOLO_AMPLITUDE : real := 0.5;
        EFFECTS_CHOICE : positive := 3
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
          clk       : in  std_logic;
          i_addr    : in  std_logic_vector(7 downto 0);
          o_data    : out std_logic_vector(8 downto 0)
        );
    end component;

    component vibrato_effect is
        Port (
            clk             : in STD_LOGIC;
            reset           : in STD_LOGIC;
            ws              : in STD_LOGIC;
            audio_left_in   : in STD_LOGIC_VECTOR(23 downto 0);
            audio_right_in  : in STD_LOGIC_VECTOR(23 downto 0);
            audio_left_out  : out STD_LOGIC_VECTOR(23 downto 0);
            audio_right_out : out STD_LOGIC_VECTOR(23 downto 0);
            sine_value      : in STD_LOGIC_VECTOR(8 downto 0)
        );
    end component;
    
    component overdrive_effect is
        Port (
            clk             : in STD_LOGIC;
            reset           : in STD_LOGIC;
            ws              : in STD_LOGIC;
            audio_left_in   : in STD_LOGIC_VECTOR(BIT_DEPTH - 1 downto 0);
            audio_right_in  : in STD_LOGIC_VECTOR(BIT_DEPTH - 1 downto 0);
            audio_left_out  : out STD_LOGIC_VECTOR(BIT_DEPTH - 1 downto 0);
            audio_right_out : out STD_LOGIC_VECTOR(BIT_DEPTH - 1 downto 0)
        );
    end component;
    
    component tremolo_effect is
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
    end component;


    signal sine_data     : STD_LOGIC_VECTOR(8 downto 0);
    signal sine_addr     : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');    

    constant MAX_VALUE : signed(BIT_DEPTH-1 downto 0) := (others => '1');
    constant MIN_VALUE : signed(BIT_DEPTH-1 downto 0) := (others => '0');
    
    -- VIBRATO
    signal vibrato_left_out   : STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0) := (others => '0');
    signal vibrato_right_out  : STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0) := (others => '0'); 
    
    -- TREMOLO
    signal tremolo_left_out   : STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0) := (others => '0');
    signal tremolo_right_out  : STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0) := (others => '0'); 
    
    -- OVERDRIVE
    signal overdrive_left_out   : STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0) := (others => '0');
    signal overdrive_right_out  : STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0) := (others => '0'); 
    
    signal sine_counter : STD_LOGIC_VECTOR(17 downto 0) := (others => '0');


begin

    sine_lut_inst : sine_lut
        Port map(
          clk => clk,
          i_addr => sine_addr,
          o_data => sine_data
        );
            
    vibrato_effect_inst : vibrato_effect
        Port map(
            clk => clk,
            reset => reset,
            ws => ws_in,
            audio_left_in => audio_left_in,
            audio_right_in => audio_right_in,
            audio_left_out => vibrato_left_out,
            audio_right_out => vibrato_right_out,
            sine_value => sine_data
        );
        
    overdrive_effect_inst : overdrive_effect
        Port map(
            clk => clk,
            reset => reset,
            ws => ws_in,
            audio_left_in => audio_left_in,
            audio_right_in => audio_right_in,
            audio_left_out => overdrive_left_out,
            audio_right_out => overdrive_right_out
        );   
        
    tremolo_effect_inst : tremolo_effect
        Port map(
            clk => clk,
            reset => reset,
            ws => ws_in,
            audio_left_in => audio_left_in,
            audio_right_in => audio_right_in,
            sine_value => sine_data,
            audio_left_out => tremolo_left_out,
            audio_right_out => tremolo_right_out           
        );
    
    
    main_proc : process(clk)
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
                if(EFFECTS_CHOICE = 1) then
                    audio_left_out <= overdrive_left_out;
                    audio_right_out <= overdrive_right_out;
                end if;
                
                -- Wende Vibrato-Effekt an
                if(EFFECTS_CHOICE = 2) then
                    audio_left_out <= vibrato_left_out;
                    audio_right_out <= vibrato_right_out;
                end if;               
                
                -- Wende Tremolo-Effekt an
                if (EFFECTS_CHOICE = 3) then
                    audio_left_out <= tremolo_left_out;
                    audio_right_out <= tremolo_right_out;
                end if;
                
                -- Signale einfach durchreichen zum Testen
                --audio_left_out <= audio_left_in;
                --audio_right_out <= audio_right_in;
            end if;
        end if;
    end process main_proc;
    
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
    
--    tremolo_proc : process(clk)
--        variable result_left    : INTEGER;
--        variable result_right   : INTEGER;
--    begin
--        if rising_edge(clk) then
--            result_left     := (to_integer(unsigned(audio_left_in)) * to_integer(unsigned(sine_data)));
--            result_right    := (to_integer(unsigned(audio_right_in)) * to_integer(unsigned(sine_data)));

--            if(result_left = 0) then
--                result_left := 1;
--            else
--                result_left := result_left / 350;
--            end if;
            
--            if(result_right = 0) then
--                result_right := 1;
--            else
--                result_right := result_right / 350;
--            end if;           
            
--            tremolo_left_out <= std_logic_vector(to_unsigned(result_left, BIT_DEPTH));
--            tremolo_right_out <= std_logic_vector(to_unsigned(result_right, BIT_DEPTH));
            
--        end if;
--    end process tremolo_proc;    
     
    
    -- Durchreichen der Timing-Signale
    ws_out <= ws_in;
end Behavioral;

