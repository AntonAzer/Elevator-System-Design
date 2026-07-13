library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity elevator_ctrl_tb is
end elevator_ctrl_tb;

architecture Behavioral of elevator_ctrl_tb is
    
    constant NUM_FLOORS : integer := 10;
    -- Reduce clock frequency strictly for simulation so we don't wait millions of ticks.
    -- 10 cycles = 1 second in this testbench.
    constant SIM_CLK_FREQ : integer := 10; -- virtually make the f = 10Hz for simulation
    -- the signals that will be connected to the ctrl files ports
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '1';
    signal req_buttons : std_logic_vector(NUM_FLOORS-1 downto 0) := (others => '0');
    signal curr_floor  : integer range 0 to NUM_FLOORS-1;
    signal door_open   : std_logic;
    signal moving_up   : std_logic;
    signal moving_down : std_logic;

    -- Instantiate SSD to verify it compiles and connects correctly
    signal ssd_out : std_logic_vector(6 downto 0);

begin

    -- Instantiate the Unit Under Test (UUT)
    UUT: entity work.elevator_ctrl
        generic map (
            NUM_FLOORS => NUM_FLOORS,
            CLK_FREQ   => SIM_CLK_FREQ -- set the CLK as this file virtual clock
        )
        port map (
            clk               => clk,
            rst               => rst,
            req_buttons       => req_buttons,
            current_floor_out => curr_floor,
            door_open         => door_open,
            moving_up         => moving_up,
            moving_down       => moving_down
			-- connecting the signals
        );

    -- Instantiate the SSD
    SSD_INST: entity work.ssd
        port map(
            floor_in => curr_floor,
            seg_out  => ssd_out
        );

    -- Clock Generation (10ns period -> 100MHz nominal, scaled by generic)
    clk_process: process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;

    -- Stimulus Process
    stim_proc: process
    begin
        -- 1. Reset system
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 20 ns;

        -- Check initial state
        assert curr_floor = 0 report "Start floor is not 0" severity error;
		-- self checking that the reset makes the system in "idle" state 
        
        -- 2. Issue multiple simultaneous requests: Floor 3 and Floor 6
        req_buttons(3) <= '1';
        req_buttons(6) <= '1';
        wait for 20 ns;
        req_buttons(3) <= '0';
        req_buttons(6) <= '0';

        -- The logic demands 2 secs (20 cycles) per floor move + 2 secs (20 cycles) for door.
        
        -- Wait until it arrives at Floor 3
        wait until curr_floor = 3;
        assert moving_up = '1' report "Elevator didn't move UP" severity error;
		-- the queue now 6 at front then continue to moving up as expected
        
        -- Wait for door to open at Floor 3
        wait until door_open = '1';
        report "Arrived at Floor 3 and Door is open!";
        
        -- Wait until it continues moving up to Floor 6
        wait until curr_floor = 6;
        wait until door_open = '1';
        report "Arrived at Floor 6 and Door is open!";
        
        -- 3. Now request a lower floor (Floor 1)
        req_buttons(1) <= '1';
        wait for 20 ns;
        req_buttons(1) <= '0';
        
        -- Wait to arrive at Floor 1
        wait until curr_floor = 1;
        assert moving_down = '1' report "Elevator didn't move DOWN" severity error;
   -- to understand this point you need to understand the concurrent behavior of the VHDL: in the same moment floor is one after t=0 check if it moving down
   -- I tried to explain from cpp perspective as you may think it wrong to be movnig down at the des already!
        wait until door_open = '1';
        report "Arrived back at Floor 1!";

        -- Stop Simulation
        wait for 100 ns;
        report "Simulation Complete. All tests passed!";
			wait;
    end process;

end Behavioral;
