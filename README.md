# FM Radio

A master thesis project.

The main focus is to compare key metrics of an FM radio receiver implementation in VHDL versus high-level synthesis (HLS).

This thesis and the accompanying project is being elaborated in the Master's degree programme "Embedded Systems Design" at the University of Applied Sciences Upper Austria, Campus Hagenberg.

[![FH Hagenberg Logo][1]][2]

----

## System Design

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

### GNURadio

### VHDL

### HLS

----

## Software requirements

 GNURadio,
 Matlab,
 GHDL,
 cocotb + cocotbext [https://github.com/corna/cocotbext-axi4stream](https://github.com/corna/cocotbext-axi4stream)
 gtkwave

 Vivado,
 Vivado HLS

----

## Contact

Michael Wurm <<wurm.michael95@gmail.com>>

[![LinkedIn](https://i.stack.imgur.com/gVE0j.png) Contact me on LinkedIn](https://www.linkedin.com/in/michael-wurm/)

[1]: doc/img/fhooe-logo-small.png
[2]: https://www.fh-ooe.at/en/hagenberg-campus/studiengaenge/master/embedded-systems-design/
