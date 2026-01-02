## Debouncing Implementation

### Why Debouncing Is Essential
Without debouncing, mechanical switch bounce can cause a single button press to be detected multiple times. This results in erratic behavior in embedded systems, such as counters incrementing more than once per press or states toggling unpredictably. Debouncing ensures reliable user input by filtering out the noise caused by physical switch bounce.

---

### Software Debouncing Techniques

#### a) Time Delay (Debounce Delay)
When a button press is first detected, the software waits for a short, fixed time—typically **5–50 ms**.

- During this delay, all bouncing transitions are ignored.
- The delay allows the switch contacts to settle into a stable state.

**Example concept:**

This approach prevents multiple toggles caused by rapid contact bouncing.

---

#### b) Confirm-After-Delay Check
After the debounce delay, the software reads the button again to verify that it remains in the expected state.

- If the button is still pressed, the input is considered **valid**.
- If the button has returned to its previous state, the input is ignored as noise.

This step ensures the input is stable rather than a momentary bounce.

---

#### c) Optional “Wait for Release”
To avoid repeated actions while the button is held down, the software can wait until the button is released before accepting another press.

- Once a valid press is registered, further input is ignored until the button returns to its inactive state.
- This guarantees exactly **one action per press**, even if the button is held.

This method is especially useful for counters or menu navigation.

---

### Method Implemented
The system implements the **confirm-after-delay method** with the following characteristics:

#### Delay Constant
**Reasoning for 10 ms:**
- Typical mechanical switch bounce lasts **1–10 ms**
- 10 ms provides a safe margin for most switches
- Short enough to maintain good user responsiveness
- Balances reliability and performance

---

### Algorithm Steps
1. Detect the initial button state change  
2. Wait **10 ms** for bouncing to settle  
3. Read the button state again to confirm  
4. If the state remains changed, process it as a valid press  
5. Use edge detection to trigger on the falling edge (**1 → 0**)  
6. Optionally wait for button release before accepting the next press  

---

### Active-LOW Consideration
The DE1-SoC pushbuttons are **active-LOW**:

- `0` = button pressed  
- `1` = button not pressed  

This requires inverted logic in the button detection code.
