library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ssd is
    Port (
        floor_in : in  integer range 0 to 15;
        seg_out  : out std_logic_vector(6 downto 0)
    );
end ssd;

architecture Behavioral of ssd is
begin
    -- Active low seven segment decoder (g-f-e-d-c-b-a)
    process(floor_in)
    begin
        case floor_in is
            when 0 => seg_out <= "1000000"; -- 0
            when 1 => seg_out <= "1111001"; -- 1
            when 2 => seg_out <= "0100100"; -- 2
            when 3 => seg_out <= "0110000"; -- 3
            when 4 => seg_out <= "0011001"; -- 4
            when 5 => seg_out <= "0010010"; -- 5
            when 6 => seg_out <= "0000010"; -- 6
            when 7 => seg_out <= "1111000"; -- 7
            when 8 => seg_out <= "0000000"; -- 8
            when 9 => seg_out <= "0010000"; -- 9
            when others => seg_out <= "1111111"; -- Blank
        end case;
    end process;
end Behavioral;