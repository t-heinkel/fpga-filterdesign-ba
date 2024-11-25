------------------------------------------------------------------------------------
---- Company: 
---- Engineer: 
---- 
---- Create Date: 20.11.2024 13:22:13
---- Design Name: 
---- Module Name: sine_lut - Behavioral
---- Project Name: 
---- Target Devices: 
---- Tool Versions: 
---- Description: 
---- 
---- Dependencies: 
---- 
---- Revision:
---- Revision 0.01 - File Created
---- Additional Comments:
---- 
------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sine_lut is
    Port (
      clk       : in  std_logic;
      i_addr    : in  std_logic_vector(7 downto 0);
      o_data    : out std_logic_vector(8 downto 0)
    );
end sine_lut;

architecture rtl of sine_lut is

type t_sin_table is array(0 to 255) of integer range 0 to 350;
constant C_SIN_TABLE : t_sin_table := (
    175, 179, 184, 188, 192, 196, 201, 205, 209, 213, 218, 222, 226, 230, 234, 238, 242, 246, 250, 254, 257, 261, 265, 269, 272, 276, 279, 283, 286,
    
    289, 293, 296, 299, 302, 305, 308, 310, 313, 316, 318, 321, 323, 325, 327, 329, 331, 333, 335, 337, 338, 340, 341, 342, 344, 345, 346, 347, 347,
    
    348, 349, 349, 350, 350, 350, 350, 350, 350, 350, 349, 349, 348, 347, 347, 346, 345, 344, 342, 341, 340, 338, 337, 335, 333, 331, 329, 327, 325,
    
    323, 321, 318, 316, 313, 310, 308, 305, 302, 299, 296, 293, 289, 286, 283, 279, 276, 272, 269, 265, 261, 257, 254, 250, 246, 242, 238, 234, 230,
    
    226, 222, 218, 213, 209, 205, 201, 196, 192, 188, 184, 179, 175, 171, 166, 162, 158, 154, 149, 145, 141, 137, 132, 128, 124, 120, 116, 112, 108,
    
    104, 100, 96, 93, 89, 85, 81, 78, 74, 71, 67, 64, 61, 57, 54, 51, 48, 45, 42, 40, 37, 34, 32, 29, 27, 25, 23, 21, 19,
    
    17, 15, 13, 12, 10, 9, 8, 6, 5, 4, 3, 3, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3, 3, 4, 5,
    
    6, 8, 9, 10, 12, 13, 15, 17, 19, 21, 23, 25, 27, 29, 32, 34, 37, 40, 42, 45, 48, 51, 54, 57, 61, 64, 67, 71, 74,
    
    78, 81, 85, 89, 93, 96, 100, 104, 108, 112, 116, 120, 124, 128, 132, 137, 141, 145, 149, 154, 158, 162, 166, 171
);

begin

p_table : process(clk)
begin
  if(rising_edge(clk)) then
    o_data  <= std_logic_vector(to_unsigned(C_SIN_TABLE(to_integer(unsigned(i_addr))),8));
  end if;
end process p_table;
end rtl;