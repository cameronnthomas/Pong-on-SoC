----------------------------------------------------------------------------------
-- Company: 
-- Engineer: cam!
-- 
-- Create Date: 02/01/2023 06:38:38 PM
-- Design Name: 
-- Module Name: pll - Behavioral
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

entity vga_clk_pll is
    Port ( clk_in : in STD_LOGIC;
           clk_out : out STD_LOGIC);
end vga_clk_pll;

architecture Behavioral of vga_clk_pll is

signal firstDivider, secondDivider: std_logic:= '0';
    begin
        process(clk_in, firstDivider) 
        begin
            if clk_in'event and clk_in = '1' then --T-flip flop 1
                firstDivider <= not firstDivider;
            end if;
            if firstDivider'event and firstDivider = '1' then --T flip flop 2
                secondDivider <= not secondDivider;
            end if;
        end process;
        clk_out <= secondDivider;

end Behavioral;
