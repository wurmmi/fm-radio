# HLS implementation

## Design

Several design files are located in the `./src` directory.

## Testbench

Several testbench files are located in the `./tb` directory.

## Usage instructions

`make help` is your friend! :wink:

1. Enter the `./scripts` directory.
2. Use `make` to call run any desired action.

The minimum series of commands for a HLS IP update is the following.

1. `make csim` \
  Simulates the testbench. \
  This is a necessary first sanity check, before going into synthesis. \
  It is much easier to test in simulation, rather than in hardware.
2. `make csynth`
  Runs C synthesis. \
  This transforms the C/C++ code into HDL code.
3. `make ip_export`
  Exports the IP files into a directory structure that Vivado understands as an 'IP directory'.

----

## Contact

Michael Wurm <<wurm.michael95@gmail.com>>

[![LinkedIn](https://i.stack.imgur.com/gVE0j.png) Contact me on LinkedIn](https://www.linkedin.com/in/michael-wurm/)
