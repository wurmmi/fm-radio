# FM Radio

A master thesis project.

<!--The main focus is to compare key metrics of an FM radio receiver implementation in VHDL versus high-level synthesis (HLS).-->
The aim of this thesis is develop a system architecture and concept, that allows the implementation of an FM radio receiver in multiple different ways, while providing an elegant way to compare the different solutions.

An FM radio receiver is developed in GNU Radio, Matlab, and as an FPGA design, using Vivado C++ High-Level Synthesis, as well as manually written VHDL.

This thesis and the accompanying project is being elaborated by Michael Wurm, in the Master's degree programme "Embedded Systems Design" at the University of Applied Sciences Upper Austria, Campus Hagenberg.

[![FH Hagenberg Logo][1]][2]

----

## Matlab System Design

The MathWorks Matlab software is used to build a platform that can be used for the system design.
Matlab is a powerful software to perform this kind of system design approach.
It provides a range of tools for signal processing, such as filter designers or FFT functions, as well as convenient ways to visualize data.

The developed model includes an FM transmitter and receiver.
However, the main focus is on the receiver side.
The chosen approach of having a transmitter model provides a reproducable starting point for the receiver design, because the received and decoded signal is previously known.

### How to run

Open the `fm_transceiver.m` script in Matlab and run it.
It will call the transmitter, receiver, as well as multiple analysis functions to understand and develop the FM system model.

----

## Hardware

An FM receiver is implemented in three levels of abstraction.

1. GNURadio \
    Highest level of abstraction. \
    The receiver is implemented by creating a block-design in a graphical user interface. \
    This version requires none, or very little knowledge about the implementation of the specific blocks.

2. HLS \
    Medium level of abstraction. \
    C++ is used as the high-level language to describe the receiver. \
    Vivado HLS transforms this into Verilog or VHDL. \
    This requires fundamental knowledge of the receiver structure. Also, some knowledge of FPGA design should be existent, to be able to design a receiver that is reasonable to implement in an actual FPGA device.

3. VHDL \
    Lowest level of abstraction. \
    The receiver is implemented in VHDL.
    This requires deep knowledge about the inner workings of an FPGA, as well as DSP.

The following sections provide detailed information about the specific implementations and their development environment.

TODO: move this into the respective directory's READMEs.

### GNURadio

The GNURadio Companion software is used to implement a transmitter and a receiver. \
To actually run the block-design on hardware, two devices are used. \
An RTL-SDR dongle is used for the receiver, and an Ettus USRP B200mini is used for the transmitter.

#### Transmitter

TODO: explain the input sources (file and local PC audio)

1. Open the `fm_transmitter.grc` project in the GNURadio Companion GUI.
2. Make sure the USRP B200mini is connected to your PC.
3. Execute the flowgraph.
4. Use a regular FM receiver device to receive the signal and listen to 'your' radio station!

#### Receiver

1. Open the `fm_receiver.grc` project in the GNURadio Companion GUI.
2. Make sure the RTL-SDR is connected to your PC.
3. Execute the flowgraph.
4. Your PC audio should now play the radio station at the selected frequency.

### VHDL

#### Testbench

explain cocotb, ghdl, gtkwave
source setup_env.sh for python env, then make any target

### HLS

#### Testbench

vivado hls tb, any make target

----

## Software requirements

TODO: add version numbers and install commands

- GNURadio (3.8.2.0 (Python 3.8.5)),
- Matlab,
- GHDL,
- cocotb + cocotbext [https://github.com/corna/cocotbext-axi4stream](https://github.com/corna/cocotbext-axi4stream)
- gtkwave
- Vivado 2018.2,
- Vivado HLS 2018.2

## Hardware requirements

- **RTL-SDR** \
  There are many different producers and vendors of devices, that support RTL-SDR. This project uses a version with an R820T2 tuner, and an RTL2832U chipset. Find a list of supported devices following [this link](3).

- **Ettus USRP B200mini** \
  A powerful SDR that is supported by GNURadio.\
  For more details, please follow [this link](4).

----

## Contact

Michael Wurm <<wurm.michael95@gmail.com>>

[![LinkedIn](https://i.stack.imgur.com/gVE0j.png) Contact me on LinkedIn](https://www.linkedin.com/in/michael-wurm/)

[1]: doc/img/fhooe-logo-small.png
[2]: https://www.fh-ooe.at/en/hagenberg-campus/studiengaenge/master/embedded-systems-design/
[3]: https://www.rtl-sdr.com/buy-rtl-sdr-dvb-t-dongles/
[4]: https://www.ettus.com/all-products/usrp-b200mini/
