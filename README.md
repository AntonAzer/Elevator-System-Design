# Elevator-System-Design

# Conditions of FSM diagram :
| Key  | VHDL Condition | Description |
| :--- | :--- | :--- |
| [C1] | req_reg(curr_floor) = '1' | Request at the current floor (Open door immediately). |
| [C2] | pref_dir = '1' AND req_above | Preferred direction is UP, and there are pending requests above. |
| [C3] | pref_dir = '0' AND req_below | Preferred direction is DOWN, and there are pending requests below. |
| [C4] | ce_1Hz = '1' AND timer_sec /= 1 | Timer has not reached 2 seconds yet (Hold current state). |
| [C5] | ce_1Hz = '1' AND timer_sec = 1 AND (req_arrival OR NOT req_above) | 2 seconds passed AND (arrived at requested floor OR no more requests above). |
| [C6] | ce_1Hz = '1' AND timer_sec = 1 AND (req_arrival OR NOT req_below) | 2 seconds passed AND (arrived at requested floor OR no more requests below). |
| [C7] | ce_1Hz = '1' AND timer_sec = 1 | 2 seconds passed with the door open (Close door and return to IDLE). |

--------------------------------------------
<img width="1016" height="647" alt="image" src="https://github.com/user-attachments/assets/8d3ba24d-56d0-453b-993b-ccbf2638e664" />
