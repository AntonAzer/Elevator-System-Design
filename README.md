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
<img width="870" height="601" alt="image" src="https://github.com/user-attachments/assets/fed45921-16ac-4de0-a859-972ac77b5d16" />

Note: some conditions look like behaving unexpectedly this because of the concurrent behavior of HDL , as some conditions like [C4] depending other conditions in the code to behave as required.

example: why have we to continue moving up/down if 2 sec passed? as the code also check in moving up/down case if the 2 sec passed and the current floor is required then stop and open the door , so there is no ambiguity!
