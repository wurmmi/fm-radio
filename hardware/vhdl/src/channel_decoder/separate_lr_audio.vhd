-------------------------------------------------------------------------------
--! @file      separate_lr_audio.vhd
--! @author    Michael Wurm <wurm.michael95@gmail.com>
--! @copyright 2021 Michael Wurm
--! @brief     Separate LR audio implementation.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

library work;
use work.fm_global_pkg.all;

entity separate_lr_audio is
  port (
    clk_i : in std_ulogic;
    rst_i : in std_ulogic;

    mono_i         : in sample_t;
    mono_valid_i   : in std_ulogic;
    lrdiff_i       : in sample_t;
    lrdiff_valid_i : in std_ulogic;

    audio_L_o     : out sample_t;
    audio_R_o     : out sample_t;
    audio_valid_o : out std_ulogic);

end entity separate_lr_audio;

architecture rtl of separate_lr_audio is

  -----------------------------------------------------------------------------
  --! @name Types and Constants
  -----------------------------------------------------------------------------
  --! @{

  --! @}
  -----------------------------------------------------------------------------
  --! @name Internal Registers
  -----------------------------------------------------------------------------
  --! @{

  signal audio_L     : sample_t   := (others => '0');
  signal audio_R     : sample_t   := (others => '0');
  signal audio_valid : std_ulogic := '0';

  --! @}
  -----------------------------------------------------------------------------
  --! @name Internal Wires
  -----------------------------------------------------------------------------
  --! @{
  --! @}

  --! @}

begin -- architecture rtl

  ------------------------------------------------------------------------------
  -- Outputs
  ------------------------------------------------------------------------------

  audio_L_o     <= audio_L;
  audio_R_o     <= audio_R;
  audio_valid_o <= audio_valid;

  -----------------------------------------------------------------------------
  -- Signal Assignments
  -----------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- Registers
  ------------------------------------------------------------------------------

  regs : process (clk_i) is
    procedure reset is
    begin
      audio_L     <= (others => '0');
      audio_R     <= (others => '0');
      audio_valid <= '0';
    end procedure reset;
  begin -- process regs
    if rising_edge(clk_i) then
      if rst_i = '1' then
        reset;
      else
        -- Defaults
        audio_valid <= '0';

        if mono_valid_i = '1' then --and lrdiff_valid_i (need to be synced!!)
          audio_L     <= ResizeTruncAbsVal(mono_i + lrdiff_i, audio_L);
          audio_R     <= ResizeTruncAbsVal(mono_i - lrdiff_i, audio_R);
          audio_valid <= '1';
        end if;
      end if;
    end if;
  end process regs;

end architecture rtl;
