----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.12.2024 12:38:14
-- Design Name: 
-- Module Name: btn_handler - Behavioral
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

entity btn_handler is
    Port ( 
        clk     : in STD_LOGIC;
    
        -- Buttons for effects
        btnL    : in STD_LOGIC;
        btnC    : in STD_LOGIC;
        btnR    : in STD_LOGIC;
        btnU    : in STD_LOGIC;
        
        effects_choice : out STD_LOGIC_VECTOR(3 downto 0) := (others => '0')
    );
end btn_handler;

architecture Behavioral of btn_handler is
    signal debounce_counter : unsigned(21 downto 0) := (others => '0');
    
    signal btnL_sync        : STD_LOGIC := '0';
    signal btnL_sync_sync   : STD_LOGIC := '0';
    
    signal btnC_sync        : STD_LOGIC := '0';
    signal btnC_sync_sync   : STD_LOGIC := '0';
    
    signal btnR_sync        : STD_LOGIC := '0';
    signal btnR_sync_sync   : STD_LOGIC := '0';
    
    signal btnU_sync        : STD_LOGIC := '0';
    signal btnU_sync_sync   : STD_LOGIC := '0';
    
begin

    cnt_proc : process(clk)
    begin
        if rising_edge(clk) then
            
            if(btnL_sync_sync = '1') then
                debounce_counter <= debounce_counter + 1;               
                if(debounce_counter(21) = '1') then         -- = 2.097.152 => roughly 2ms
                    effects_choice <= "0001";
                    debounce_counter <= (others => '0');
                end if; 
            end if;

            if(btnC_sync_sync = '1') then
                debounce_counter <= debounce_counter + 1;
                if(debounce_counter(21) = '1') then
                    effects_choice <= "0010";
                    debounce_counter <= (others => '0');
                end if; 
            end if;
            
            if(btnR_sync_sync = '1') then
                debounce_counter <= debounce_counter + 1;
                if(debounce_counter(21) = '1') then
                    effects_choice <= "0100";
                    debounce_counter <= (others => '0');
                end if; 
            end if;
            
            if(btnU_sync_sync = '1') then
                debounce_counter <= debounce_counter + 1;
                if(debounce_counter(21) = '1') then
                    effects_choice <= "0000";
                    debounce_counter <= (others => '0');
                end if; 
            end if;
            
            btnL_sync <= btnL;
            btnL_sync_sync <= btnL_sync;
            
            btnC_sync <= btnC;
            btnC_sync_sync <= btnC_sync;
            
            btnR_sync <= btnR;
            btnR_sync_sync <= btnR_sync;
            
            btnU_sync <= btnU;
            btnU_sync_sync <= btnU_sync;
            
        end if;
    end process cnt_proc;

end Behavioral;
