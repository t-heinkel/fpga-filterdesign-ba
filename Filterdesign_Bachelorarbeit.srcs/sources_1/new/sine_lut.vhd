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
      o_data    : out unsigned(7 downto 0)
    );
end sine_lut;

architecture rtl of sine_lut is


type t_sin_table is array(0 to 255) of unsigned(7 downto 0);
constant C_SIN_TABLE : t_sin_table := (
    to_unsigned(128, 8),  to_unsigned(131, 8),  to_unsigned(134, 8),  to_unsigned(137, 8), to_unsigned(140, 8),  to_unsigned(143, 8),  to_unsigned(146, 8),  to_unsigned(149, 8),
    to_unsigned(152, 8),  to_unsigned(155, 8),  to_unsigned(158, 8),  to_unsigned(162, 8), to_unsigned(165, 8),  to_unsigned(167, 8),  to_unsigned(170, 8),  to_unsigned(173, 8),
    to_unsigned(176, 8),  to_unsigned(179, 8),  to_unsigned(182, 8),  to_unsigned(185, 8), to_unsigned(188, 8),  to_unsigned(190, 8),  to_unsigned(193, 8),  to_unsigned(196, 8),     
    to_unsigned(198, 8),  to_unsigned(201, 8),  to_unsigned(203, 8),  to_unsigned(206, 8), to_unsigned(208, 8),  to_unsigned(211, 8),  to_unsigned(213, 8),  to_unsigned(215, 8),    
    to_unsigned(218, 8),  to_unsigned(220, 8),  to_unsigned(222, 8),  to_unsigned(224, 8), to_unsigned(226, 8),  to_unsigned(228, 8),  to_unsigned(230, 8),  to_unsigned(232, 8),     
    to_unsigned(234, 8),  to_unsigned(235, 8),  to_unsigned(237, 8),  to_unsigned(238, 8), to_unsigned(240, 8),  to_unsigned(241, 8),  to_unsigned(243, 8),  to_unsigned(244, 8),     
    to_unsigned(245, 8),  to_unsigned(246, 8),  to_unsigned(248, 8),  to_unsigned(249, 8), to_unsigned(250, 8),  to_unsigned(250, 8),  to_unsigned(251, 8),  to_unsigned(252, 8),     
    to_unsigned(253, 8),  to_unsigned(253, 8),  to_unsigned(254, 8),  to_unsigned(254, 8), to_unsigned(254, 8),  to_unsigned(255, 8),  to_unsigned(255, 8),  to_unsigned(255, 8),    
    to_unsigned(255, 8),  to_unsigned(255, 8),  to_unsigned(255, 8),  to_unsigned(255, 8), to_unsigned(254, 8),  to_unsigned(254, 8),  to_unsigned(254, 8),  to_unsigned(253, 8),   
    to_unsigned(253, 8),  to_unsigned(252, 8),  to_unsigned(251, 8),  to_unsigned(250, 8), to_unsigned(250, 8),  to_unsigned(249, 8),  to_unsigned(248, 8),  to_unsigned(246, 8),     
    to_unsigned(245, 8),  to_unsigned(244, 8),  to_unsigned(243, 8),  to_unsigned(241, 8), to_unsigned(240, 8),  to_unsigned(238, 8),  to_unsigned(237, 8),  to_unsigned(235, 8),   
    to_unsigned(234, 8),  to_unsigned(232, 8),  to_unsigned(230, 8),  to_unsigned(228, 8), to_unsigned(226, 8),  to_unsigned(224, 8),  to_unsigned(222, 8),  to_unsigned(220, 8),    
    to_unsigned(218, 8),  to_unsigned(215, 8),  to_unsigned(213, 8),  to_unsigned(211, 8), to_unsigned(208, 8),  to_unsigned(206, 8),  to_unsigned(203, 8),  to_unsigned(201, 8),     
    to_unsigned(198, 8),  to_unsigned(196, 8),  to_unsigned(193, 8),  to_unsigned(190, 8), to_unsigned(188, 8),  to_unsigned(185, 8),  to_unsigned(182, 8),  to_unsigned(179, 8),     
    to_unsigned(176, 8),  to_unsigned(173, 8),  to_unsigned(170, 8),  to_unsigned(167, 8), to_unsigned(165, 8),  to_unsigned(162, 8),  to_unsigned(158, 8),  to_unsigned(155, 8),     
    to_unsigned(152, 8),  to_unsigned(149, 8),  to_unsigned(146, 8),  to_unsigned(143, 8), to_unsigned(140, 8),  to_unsigned(137, 8),  to_unsigned(134, 8),  to_unsigned(131, 8),     
    to_unsigned(128, 8),  to_unsigned(124, 8),  to_unsigned(121, 8),  to_unsigned(118, 8), to_unsigned(115, 8),  to_unsigned(112, 8),  to_unsigned(109, 8),  to_unsigned(106, 8),     
    to_unsigned(103, 8),  to_unsigned(100, 8),  to_unsigned( 97, 8),  to_unsigned( 93, 8), to_unsigned( 90, 8),  to_unsigned( 88, 8),  to_unsigned( 85, 8),  to_unsigned( 82, 8),     
    to_unsigned( 79, 8),  to_unsigned( 76, 8),  to_unsigned( 73, 8),  to_unsigned( 70, 8), to_unsigned( 67, 8),  to_unsigned( 65, 8),  to_unsigned( 62, 8),  to_unsigned( 59, 8),     
    to_unsigned( 57, 8),  to_unsigned( 54, 8),  to_unsigned( 52, 8),  to_unsigned( 49, 8), to_unsigned( 47, 8),  to_unsigned( 44, 8),  to_unsigned( 42, 8),  to_unsigned( 40, 8),     
    to_unsigned( 37, 8),  to_unsigned( 35, 8),  to_unsigned( 33, 8),  to_unsigned( 31, 8), to_unsigned( 29, 8),  to_unsigned( 27, 8),  to_unsigned( 25, 8),  to_unsigned( 23, 8),     
    to_unsigned( 21, 8),  to_unsigned( 20, 8),  to_unsigned( 18, 8),  to_unsigned( 17, 8), to_unsigned( 15, 8),  to_unsigned( 14, 8),  to_unsigned( 12, 8),  to_unsigned( 11, 8),     
    to_unsigned( 10, 8),  to_unsigned(  9, 8),  to_unsigned(  7, 8),  to_unsigned(  6, 8), to_unsigned(  5, 8),  to_unsigned(  5, 8),  to_unsigned(  4, 8),  to_unsigned(  3, 8),     
    to_unsigned(2, 8),  to_unsigned(2, 8),  to_unsigned(1, 8),  to_unsigned(1, 8), to_unsigned(1, 8),  to_unsigned(1, 8),  to_unsigned(1, 8),  to_unsigned(1, 8),     
    to_unsigned(1, 8),  to_unsigned(1, 8),  to_unsigned(1, 8),  to_unsigned( 1, 8), to_unsigned( 1, 8),  to_unsigned( 1, 8),  to_unsigned( 1, 8),  to_unsigned( 2, 8),     
    to_unsigned( 2, 8),  to_unsigned( 3, 8),  to_unsigned( 4, 8),  to_unsigned( 5, 8), to_unsigned( 5, 8),  to_unsigned( 6, 8),  to_unsigned( 7, 8),  to_unsigned( 9, 8),     
    to_unsigned( 10, 8),  to_unsigned( 11, 8),  to_unsigned( 12, 8),  to_unsigned( 14, 8), to_unsigned( 15, 8),  to_unsigned( 17, 8),  to_unsigned( 18, 8),  to_unsigned( 20, 8),     
    to_unsigned( 23, 8),  to_unsigned( 23, 8),  to_unsigned( 25, 8),  to_unsigned( 27, 8), to_unsigned( 29, 8),  to_unsigned( 31, 8),  to_unsigned( 33, 8),  to_unsigned( 35, 8),     
    to_unsigned( 37, 8),  to_unsigned( 40, 8),  to_unsigned( 42, 8),  to_unsigned( 44, 8), to_unsigned( 47, 8),  to_unsigned( 49, 8),  to_unsigned( 52, 8),  to_unsigned( 54, 8),     
    to_unsigned( 57, 8),  to_unsigned(  59, 8),  to_unsigned(  62, 8),  to_unsigned(  64, 8), to_unsigned(  67, 8),  to_unsigned(  70, 8),  to_unsigned(  73, 8),  to_unsigned(  76, 8), 
    to_unsigned( 79, 8),  to_unsigned( 82, 8),  to_unsigned( 85, 8),  to_unsigned( 88, 8), to_unsigned( 90, 8),  to_unsigned( 93, 8),  to_unsigned( 97, 8),  to_unsigned( 100, 8),     
    to_unsigned( 103, 8),  to_unsigned(  106, 8),  to_unsigned(  109, 8),  to_unsigned(  112, 8), to_unsigned(  115, 8),  to_unsigned(  118, 8),  to_unsigned(  121, 8),  to_unsigned(  124, 8)
);

begin

p_table : process(clk)
begin
  if rising_edge(clk) then
    o_data <= C_SIN_TABLE(to_integer(unsigned(i_addr)));
  end if;
end process p_table;

end rtl;