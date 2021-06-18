# FM Radio Register Map

FM Radio IP (VHDL)

Register width: 32 bits<br>
Address width: 2 bits

---
### MAGIC_VALUE
Magic constant to identify FM Radio IP.

| Address: `0x0` | *READ_ONLY* |
| :--- | ---: |
| *VALUE*<br> | Bits: `[31:0]`<br>Reset: `0xDEADBEEF` |

---
### LED_CONTROL
Represents the physical LED value.

| Address: `0x4` | *READ_WRITE* |
| :--- | ---: |
| *VALUE*<br> | Bits: `[3:0]`<br>Reset: `0x0` |


---
*Copyright (C) 2017-2021 Michael Wurm*