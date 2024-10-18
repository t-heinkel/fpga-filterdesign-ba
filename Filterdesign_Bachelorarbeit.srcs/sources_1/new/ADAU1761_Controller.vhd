----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.10.2024 12:43:00
-- Design Name: 
-- Module Name: ADAU1761_Controller - Behavioral
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

entity ADAU1761_Controller is
    Port (
        clk         : in STD_LOGIC;
        reset       : in STD_LOGIC;
        ena         : out STD_LOGIC;
        addr        : out STD_LOGIC_VECTOR(6 downto 0);
        rw          : out STD_LOGIC;
        config_done : out STD_LOGIC
    );
end ADAU1761_Controller;

architecture Behavioral of ADAU1761_Controller is
    type config_states is (idle, reg0, pll_div, pll_n, pll_k, pll_p, pll_lock, done);
    signal current_state    : config_states := idle;
    signal config_done_int  : STD_LOGIC;

begin

    adau1761_config : process(clk)
        variable register_addr : unsigned(15 downto 0);
        variable register_data : unsigned(7 downto 0);
    begin
        if rising_edge(clk) then
            if reset = '1' then
                current_state <= idle;
                config_done_int <= '0';
            elsif config_done_int = '0' then
                case current_state is
                    when idle =>
                        ena <= '1';
                        addr <= "0011010";
                        rw <= '0';
                        register_addr := x"4000";
                        register_data := x"01";
                        current_state <= reg0;
                        
                    when reg0 =>
                        register_addr := x"4001";
                        register_data := x"00";
                        current_state <= pll_div;
                        
                    when pll_div =>
                        register_addr := x"4002";
                        register_data := x"03";
                        current_state <= pll_n;
                        
                    when pll_n =>
                        register_addr := x"4003";
                        register_data := x"04";
                        current_state <= pll_k;
                        
                    when pll_k =>
                        register_addr := x"4004";
                        register_data := x"05";
                        current_state <= pll_p;
                        
                    when pll_p =>
                        register_addr := x"4005";
                        register_data := x"06";
                        current_state <= pll_lock;
                        
                    when pll_lock =>
                        current_state <= done;
                        
                    when done =>
                        config_done_int <= '1';
                end case;
            end if;
            
            config_done <= config_done_int;
        end if;
    end process;
end Behavioral;
