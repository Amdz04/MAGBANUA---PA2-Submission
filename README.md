### Debouncing Implementation

#### Why Debouncing is Essential
Without debouncing, mechanical switch bounce causes a single button press to register as multiple presses. This leads to erratic behavior in embedded systems, such as counting multiple times from one press or toggling states unpredictably. Debouncing ensures reliable user input by filtering out physical bounce noise.

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
