----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.10.2024 12:43:00
-- Design Name: 
-- Module Name: I2C_Master - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity I2C_Master is
    Port ( clk : in  STD_LOGIC;
            i2c_sda_i : IN std_logic;      
            i2c_sda_o : OUT std_logic;      
            i2c_sda_t : OUT std_logic;      
            i2c_scl : out  STD_LOGIC;
            sw : in std_logic_vector(1 downto 0);
            active : out std_logic_vector(1 downto 0));
end I2C_Master;

architecture Behavioral of I2C_Master is
	COMPONENT I2C_Controller
   Generic( clk_divide : STD_LOGIC_VECTOR (7 downto 0));
	PORT(
		clk          : IN  std_logic;
		i2c_sda_i    : IN  std_logic;      
		i2c_sda_o    : OUT std_logic;      
		i2c_sda_t    : OUT std_logic;      
		i2c_scl      : OUT std_logic;
		inst_data    : IN  std_logic_vector(8 downto 0);
		inputs       : IN  std_logic_vector(15 downto 0);    
		inst_address : OUT std_logic_vector(9 downto 0);
		debug_sda    : OUT std_logic;      
		debug_scl    : OUT std_logic;
		outputs      : OUT std_logic_vector(15 downto 0);
		reg_addr     : OUT std_logic_vector(4 downto 0);
		reg_data     : OUT std_logic_vector(7 downto 0);
		reg_write    : OUT std_logic;
		error        : OUT std_logic
		);
	END COMPONENT;

	COMPONENT ADAU1761_Configuration_Data
	PORT(
		clk     : IN std_logic;
		address : IN std_logic_vector(9 downto 0);          
		data    : OUT std_logic_vector(8 downto 0)
		);
	END COMPONENT;
   
   signal inst_address : std_logic_vector(9 downto 0);          
   signal inst_data    : std_logic_vector(8 downto 0);
   signal sw_full       :std_logic_vector(15 downto 0) := (others => '0');
   signal active_full : std_logic_vector(15 downto 0) := (others => '0');
begin
   sw_full(1 downto 0) <= sw;
   active <= active_full(1 downto 0);
	Inst_adau1761_configuration_data: ADAU1761_Configuration_Data PORT MAP(
		clk     => clk,
		address => inst_address,
		data    => inst_data
	);

	Inst_I2C_Controller: I2C_Controller GENERIC MAP (
      clk_divide => "00111100"   -- 60 (24,000/120 = 400kHz I2C clock)
   ) PORT MAP(
		clk => clk,
		inst_address => inst_address,
		inst_data    => inst_data,
		i2c_scl      => i2c_scl,
		i2c_sda_i      => i2c_sda_i,
		i2c_sda_o      => i2c_sda_o,
		i2c_sda_t      => i2c_sda_t,
		inputs       => sw_full,
		outputs      => active_full,
		reg_addr     => open,
		reg_data     => open,
		reg_write    => open,
        debug_scl    => open,
        debug_sda    => open,
		error        => open
	);

end Behavioral;