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
use work.fm_global_pkg.all;

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
    oDwet   : out sample_t;
    oValWet : out std_ulogic);

end delay_vector;

architecture RtlRam of delay_vector is

  ----------------------------------------------------------------------------
  -- Signals
  ----------------------------------------------------------------------------
  ----------------------------------------------------------------------------
  -- Registers
  ----------------------------------------------------------------------------

  type aRamMem is array (integer range <>) of sample_t;
  signal ram     : aRamMem(0 to gDelay - 1)      := (others => (others => '0'));
  signal addrCnt : natural range 0 to gDelay - 1 := 0;

  signal valid      : std_ulogic;
  signal next_valid : std_ulogic;
  --signal next_valid : std_ulogic_vector(gDelay - 1 downto 0) := (others => '0');
  signal readVal : sample_t;

begin

  ----------------------------------------------------------------------------
  -- Outputs
  ----------------------------------------------------------------------------

  oDwet   <= readVal;
  oValWet <= valid;

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
    procedure reset is
    begin
      next_valid <= '0';
      valid      <= '0';
      readVal    <= (others => '0');
      addrCnt    <= 0;
    end procedure;
  begin
    if rising_edge(iClk) then
      if inResetAsync = '0' then
        reset;
      else
        valid      <= next_valid;
        next_valid <= '0';

        if iValDry = '1' then
          next_valid   <= '1';
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
    end if;
  end process ReadWrite;

  --  ReadWrite : process (iClk) is
  --    procedure reset is
  --    begin
  --      next_valid <= (others => '0');
  --      valid      <= '0';
  --      readVal    <= (others => '0');
  --      addrCnt    <= 0;
  --    end procedure;
  --  begin
  --    if rising_edge(iClk) then
  --      if inResetAsync = '0' then
  --        reset;
  --      else
  --        -- Defaults
  --        valid <= '0';
  --
  --        if iValDry = '1' then
  --          next_valid <= next_valid(next_valid'high - 1 downto next_valid'low) & '1';
  --          valid      <= next_valid(next_valid'high);
  --
  --          ram(addrCnt) <= iDdry;
  --
  --          if addrCnt = gDelay - 1 then
  --            addrCnt <= 0;
  --          else
  --            addrCnt <= addrCnt + 1;
  --          end if;
  --        end if;
  --
  --        if addrCnt = gDelay - 1 then
  --          readVal <= ram(0);
  --        else
  --          readVal <= ram(addrCnt + 1);
  --        end if;
  --      end if;
  --    end if;
  --  end process ReadWrite;

end RtlRam;
