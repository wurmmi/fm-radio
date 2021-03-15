--------------------------------------------------------------------------------
-- Title       : z^{-1} delay
-- Project     : FPGA Based Digital Signal Processing
--               FH OÖ Hagenberg/HSD, SCD5
--------------------------------------------------------------------------------
-- RevCtrl     : $Id: DspDly-e.vhd 711 2017-11-03 18:22:43Z mroland $
-- Authors     : Markus Pfaff, Linz/Austria, Copyright (c) 2003-2005
--               Michael Roland, Hagenberg/Austria, Copyright (c) 2011-2017
--------------------------------------------------------------------------------
-- Description :
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.fm_pkg.all;

entity delay_vector is
  generic (
    gDelay : natural := 256);
  port (
    -- Sequential logic inside this unit
    iClk         : in std_ulogic;
    inResetAsync : in std_ulogic;

    -- Input audio channels
    iDdry   : in sample_t;
    iValDry : in std_ulogic;

    -- Output audio channel
    oDwet : out sample_t);

end delay_vector;

architecture RtlRam of delay_vector is

  ----------------------------------------------------------------------------
  -- Signals
  ----------------------------------------------------------------------------

  signal readVal : sample_t;

  ----------------------------------------------------------------------------
  -- Registers
  ----------------------------------------------------------------------------

  type aRamMem is array (integer range <>) of sample_t;
  signal ram     : aRamMem(0 to gDelay - 1)  := (others => (others => '0'));
  signal addrCnt : natural range 0 to gDelay := 0;

begin

  ----------------------------------------------------------------------------
  -- Outputs
  ----------------------------------------------------------------------------

  oDwet <= readVal;

  ----------------------------------------------------------------------------
  -- Signal assignments
  ----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  -- Logic
  ----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  -- Read and write RAM
  ----------------------------------------------------------------------------
  ReadWrite : process (iClk) is
  begin
    if rising_edge(iClk) then
      if iValDry = '1' then
        ram(addrCnt) <= iDdry;

        if addrCnt = gDelay - 1 then
          addrCnt <= 0;
        else
          addrCnt <= addrCnt + 1;
        end if;
      end if;

      if addrCnt = gDelay - 1 then
        readVal <= ram(0);
      else
        readVal <= ram(addrCnt + 1);
      end if;
    end if;
  end process ReadWrite;

end RtlRam;
