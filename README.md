### Debouncing Implementation

#### Why Debouncing is Essential
Without debouncing, mechanical switch bounce causes a single button press to register as multiple presses. This leads to erratic behavior in embedded systems, such as counting multiple times from one press or toggling states unpredictably. Debouncing ensures reliable user input by filtering out physical bounce noise.

a) Time delay (debounce delay)

When a button press is first detected, the software waits for a short fixed time (usually 5–50 ms).

During this delay, any bouncing transitions are ignored.

The delay allows the switch contacts to settle into a stable state.

Example idea:

Detect press → wait 20 ms → continue processing

This prevents multiple toggles caused by rapid contact bouncing.

b) Confirm-after-delay check

After the delay, the software reads the button again to confirm that it is still in the expected state.

If the button is still pressed after the delay, the press is considered valid.

If the button has returned to its previous state, the press is ignored as noise.

This step is important because it ensures the input is stable, not just momentarily triggered by bounce.

c) Optional “wait for release”

To prevent repeated counting while the button is held down, the software can wait until the button is released before accepting another press.

Once a valid press is registered, the program does nothing until the button returns to its inactive state.

This guarantees one action per press, even if the button is held.

This is especially useful for counters or menu navigation.

#### Method Implemented
We implemented the **confirm-after-delay method** with the following characteristics:

**Delay Constant**:
**Reasoning for 10ms**: 
- Typical mechanical switch bounce lasts 1-10ms
- 10ms provides a safety margin for most switches
- Not too long to affect user experience
- Balances responsiveness with reliability

**Algorithm Steps**
1. Detect initial button state change
2. Wait 10ms for bouncing to settle
3. Read button state again to confirm
4. If state remains changed, process as valid press
5. Implement edge detection to trigger on falling edge (1→0)
6. Optional: Wait for release before accepting next press

**Active-LOW Consideration**: 
The DE1-SoC uses active-LOW buttons (0 = pressed, 1 = not pressed), requiring inverted logic in the detection code.
