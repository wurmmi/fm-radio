# Vivado Project

This is the Vivado project, which includes the HLS and VHDL IPs.

----

## Usage instructions

`make help` is your friend! :wink:

Examples:

- `make project GUI=1` \
  Opens Vivado project. In case it does not exist yet, it creates a new one.
- `make bitstream` \
  Creates the bitstream, (obviously.. :simple_smile:)
- `make sdk GUI=1` \
  Opens Vivado SDK project. In case it does not exist yet, it creates a new one.

## Common use-cases

### **IP was updated, since the Vivado project was created**

  Synthesis will show a warning, saying that IPs are "locked". \
  An example:

  ```None
  WARNING: [BD 41-1661] One or more IPs have been locked in the design 'proj.bd'. Please run report_ip_status for more details and recommendations on how to fix this issue.
  List of locked IPs:
    proj_fm_receiver_hls_0_0
  ```

  Run `make upgrade_ips` to upgrade the IPs in the projects' block design.

### **HLS IP was updated - update the SDK**

  An update to the HLS IP likely brings updates to its firmware driver. \
  The Board Support Package (BSP) in the SDK needs to be re-generated in order to use the latest drivers.

  1. Build a bitstream that includes the new HLS IP (`make bitstream`)
  2. Close the SDK and run `make sdk GUI=1`. \
  This will read the latest Hardware Definition File (HDF) and extract the firmware drivers from it. \
  *NOTE: The HDF is simply a zip-file... Just rename it from \*.hdf to \*.zip and unzip it.*

----

## Contact

Michael Wurm <<wurm.michael95@gmail.com>>

[![LinkedIn](https://i.stack.imgur.com/gVE0j.png) Contact me on LinkedIn](https://www.linkedin.com/in/michael-wurm/)
