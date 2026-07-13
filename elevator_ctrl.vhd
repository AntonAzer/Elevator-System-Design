library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity elevator_ctrl is
    Generic (
        NUM_FLOORS : integer := 10;
        CLK_FREQ   : integer := 50000000 -- 50 MHz as required
    );
    Port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        req_buttons : in  std_logic_vector(NUM_FLOORS-1 downto 0);
        
        -- Outputs mapped to LEDs and 7-Seg
        current_floor_out : out integer range 0 to NUM_FLOORS-1;
        door_open   : out std_logic;
        moving_up   : out std_logic;
        moving_down : out std_logic
    );
end elevator_ctrl;

architecture Behavioral of elevator_ctrl is

    type state_type is (IDLE, MOVE_UP, MOVE_DOWN, OPEN_DOOR);
    signal state : state_type := IDLE;

    -- Internal signals
    signal curr_floor : integer range 0 to NUM_FLOORS-1 := 0;
    signal req_reg    : std_logic_vector(NUM_FLOORS-1 downto 0) := (others => '0');
    
    -- Request Resolver signals
    signal req_above : boolean;
    signal req_below : boolean;
    signal pref_dir  : std_logic := '1'; -- 1 for UP, 0 for DOWN

    -- Timers
    signal clk_div   : integer range 0 to CLK_FREQ-1 := 0; -- this from zero to 4999999 then it activate ce_1Hz
    signal ce_1Hz    : std_logic := '0'; -- this is 1 once per sec at 4999999
    signal timer_sec : integer range 0 to 3 := 0; -- this counts the seconds (0->1->2->0)

begin

    current_floor_out <= curr_floor;

    
    -- 1Hz Clock Enable Generator
    
    process(clk, rst)
    begin
        if rst = '1' then
            clk_div <= 0;
            ce_1Hz  <= '0';
        elsif rising_edge(clk) then
            if clk_div = CLK_FREQ - 1 then
                clk_div <= 0;
                ce_1Hz  <= '1';
            else
                clk_div <= clk_div + 1;
                ce_1Hz  <= '0';
            end if;
        end if;
    end process;

    
    -- Request Resolver (Combinational check for requests above/below)
    
    process(req_reg, curr_floor)
        variable above, below : boolean;
    begin
        above := false;
        below := false;
        for i in 0 to NUM_FLOORS-1 loop
            if req_reg(i) = '1' then
                if i > curr_floor then
                    above := true;
                elsif i < curr_floor then
                    below := true;
                end if;
            end if;
        end loop;
        req_above <= above;
        req_below <= below;
    end process;

    -- Main Unit Control (FSM)
    
    process(clk, rst)
    begin
        if rst = '1' then
            state <= IDLE;
            curr_floor <= 0;
            req_reg <= (others => '0');
            pref_dir <= '1';
            timer_sec <= 0;
            door_open <= '0';
            moving_up <= '0';
            moving_down <= '0';
        elsif rising_edge(clk) then
            
            -- Latch new button presses
            for i in 0 to NUM_FLOORS-1 loop
                if req_buttons(i) = '1' then
                    req_reg(i) <= '1';
                end if;
            end loop;

            case state is
                when IDLE =>
                    door_open <= '0';
                    moving_up <= '0';
                    moving_down <= '0';
                    timer_sec <= 0;

                    -- Resolve destination
                    if req_reg(curr_floor) = '1' then
                        state <= OPEN_DOOR;
                    elsif pref_dir = '1' and req_above then
                        state <= MOVE_UP;
                    elsif pref_dir = '1' and not req_above and req_below then
                        pref_dir <= '0'; -- لو طالع لفوق و مفيش حد طالبه فوق خليه نازل لتحت
                        state <= MOVE_DOWN;
                    elsif pref_dir = '0' and req_below then
                        state <= MOVE_DOWN; -- لو نازل لتحت و حد طالبه تحت خليه مكمل لتحت
                    elsif pref_dir = '0' and not req_below and req_above then
                        pref_dir <= '1'; -- لو نازل لتحت و مفيش حد طالبه تحت و في حد طالبه فوق خليه يطلع لفوق
                        state <= MOVE_UP;
                    end if;
-- اقرا السحنالز كويس هتلاقي كل الكوندشنز سهله الفهم :)
                when MOVE_UP =>
                    moving_up <= '1';
                    if ce_1Hz = '1' then
                        if timer_sec = 1 then -- 2 seconds passed (1 -> 2)
                            timer_sec <= 0; 
                            curr_floor <= curr_floor + 1;
                            
                            -- Next logic on arrival at new floor
                            if req_reg(curr_floor + 1) = '1' or not req_above then
                                state <= OPEN_DOOR; -- Open door if requested or top requested floor
                            end if;
                        else
                            timer_sec <= timer_sec + 1;
                        end if;
                    end if;

                when MOVE_DOWN =>
                    moving_down <= '1';
                    if ce_1Hz = '1' then
                        if timer_sec = 1 then
                            timer_sec <= 0;
                            curr_floor <= curr_floor - 1;
                            
                            -- Next logic on arrival at new floor
                            if req_reg(curr_floor - 1) = '1' or not req_below then -- I say (curr_floor-1) because of concurrent behavior of HDL
                                state <= OPEN_DOOR;
                            end if;
                        else
                            timer_sec <= timer_sec + 1;
                        end if;
                    end if;

                when OPEN_DOOR =>
                    moving_up <= '0';
                    moving_down <= '0';
                    door_open <= '1';
                    req_reg(curr_floor) <= '0'; -- Clear request for this floor
                    
                    if ce_1Hz = '1' then
                        if timer_sec = 1 then -- 2 seconds elapsed
                            timer_sec <= 0;
                            state <= IDLE;
                        else
                            timer_sec <= timer_sec + 1;
                        end if;
                    end if;

            end case;
        end if;
    end process;

end Behavioral;