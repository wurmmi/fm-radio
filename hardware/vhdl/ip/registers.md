# FM Radio Register Map

FM Radio IP (VHDL)

Register width: 32 bits<br>
Address width: 12 bits

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
| *VALUE*<br> | Bits: `[2:0]`<br>Reset: `0x0` |

---
### ENABLE_FM_RADIO
Enables FM Radio DSP mode; Passthrough mode if disabled.

| Address: `0x8` | *READ_WRITE* |
| :--- | ---: |
| *VALUE*<br> | Bits: `[0]`<br>Reset: `0x1` |

---
### VERSION_ADDR
Set version register to be read.

| Address: `0xC` | *READ_WRITE* |
| :--- | ---: |
| *VALUE*<br> | Bits: `[3:0]`<br>Reset: `0x0` |

---
### VERSION
Version value at address VERSION_ADDR.

| Address: `0x10` | *READ_ONLY* |
| :--- | ---: |
| *VALUE*<br> | Bits: `[31:0]`<br>Reset: `0x0` |


---
*Copyright (C) 2017-2021 Michael Wurm*