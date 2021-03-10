--------------------------------------------------------------------------------
-- Title       : FIR filter
-- Project     : FPGA Based Digital Signal Processing
--               FH OÖ Hagenberg/HSD, SCD5
--------------------------------------------------------------------------------
-- RevCtrl     : $Id: DspFir.vhd 716 2017-11-12 16:57:46Z mroland $
-- Authors     : Markus Pfaff, Linz/Austria, Copyright (c) 2003-2005
--               Michael Roland, Hagenberg/Austria, Copyright (c) 2011-2017
--               Michael Wurm <wurm.michael95@gmail.com>, 2021
--------------------------------------------------------------------------------
-- Description :
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- fixed_pkg resides in the library ieee since VHDL-2008 (QuestaSim backports
-- this to VHDL-93 too). However, Quartus (as of version 13.0sp1) still does
-- not have native support for ieee.fixed_pkg. Therefore, we provide the
-- VHDL-93 compatibility versions as part of this excercise. These must be
-- compiled into the are located in the library ieee_proposed. Include them in
-- your Config.tcl and don't forget to set the ExtraLibraries and TargetLibrary
-- parameters to compile them into the right library (ieee_proposed) with fhlow.
--library ieee_proposed;
--use ieee_proposed.fixed_float_types.all;
--use ieee_proposed.fixed_pkg.all;
-- In future (when both QuestaSim and Quartus support the VHDL-2008
-- ieee.fixed_pkg) simply use:
--use ieee.fixed_float_types.all;
use ieee.fixed_pkg.all;

use work.fm_pkg.all;

entity DspFir is

  generic (
    -- The values used as filter coefficients. The number those
    -- coefficients determines the number of taps the filter has.
    gB             : filter_coeffs_t := (-0.000152587890625,  0.00018310546875 ,  0.000152587890625,  0.000152587890625,  0.00018310546875 ,  0.000152587890625,  0.0001220703125  ,  0.00006103515625 ,  0.0              , -0.000091552734375, -0.000213623046875, -0.00030517578125 , -0.0003662109375  , -0.0003662109375  , -0.000335693359375, -0.000274658203125, -0.0001220703125  ,  0.00006103515625 ,  0.000244140625   ,  0.000457763671875,  0.0006103515625  ,  0.000732421875   ,  0.000732421875   ,  0.000640869140625,  0.000457763671875,  0.00018310546875 , -0.000152587890625, -0.000518798828125, -0.0008544921875  , -0.001129150390625, -0.001251220703125, -0.001251220703125, -0.00103759765625 , -0.000701904296875, -0.000213623046875,  0.0003662109375  ,  0.000946044921875,  0.00146484375    ,  0.001861572265625,  0.00201416015625 ,  0.001922607421875,  0.001556396484375,  0.000946044921875,  0.000152587890625, -0.000732421875   , -0.0015869140625  , -0.0023193359375  , -0.0028076171875  , -0.002960205078125, -0.002716064453125, -0.002105712890625, -0.00115966796875 ,  0.0              ,  0.001251220703125,  0.00244140625    ,  0.00341796875    ,  0.00396728515625 ,  0.00408935546875 ,  0.003631591796875,  0.002685546875   ,  0.0013427734375  , -0.00030517578125 , -0.001983642578125, -0.0035400390625  , -0.00469970703125 , -0.005340576171875, -0.00531005859375 , -0.00457763671875 , -0.00323486328125 , -0.001373291015625,  0.000762939453125,  0.0029296875     ,  0.004791259765625,  0.00616455078125 ,  0.00677490234375 ,  0.006561279296875,  0.0054931640625  ,  0.003631591796875,  0.001251220703125, -0.001434326171875, -0.0040283203125  , -0.0062255859375  , -0.0076904296875  , -0.00823974609375 , -0.00775146484375 , -0.006256103515625, -0.003875732421875, -0.000946044921875,  0.00225830078125 ,  0.0052490234375  ,  0.007659912109375,  0.009185791015625,  0.00958251953125 ,  0.008758544921875,  0.006805419921875,  0.00390625       ,  0.00042724609375 , -0.003204345703125, -0.006500244140625, -0.009063720703125, -0.010528564453125, -0.010711669921875, -0.009490966796875, -0.007080078125   , -0.003692626953125,  0.000244140625   ,  0.004180908203125,  0.0076904296875  ,  0.010284423828125,  0.0115966796875  ,  0.011474609375   ,  0.0098876953125  ,  0.00701904296875 ,  0.00323486328125 , -0.001007080078125, -0.005157470703125, -0.00872802734375 , -0.011199951171875, -0.01226806640625 , -0.011810302734375, -0.009857177734375, -0.00665283203125 , -0.002593994140625,  0.0018310546875  ,  0.006011962890625,  0.00946044921875 ,  0.01171875       ,  0.01251220703125 ,  0.01171875       ,  0.00946044921875 ,  0.006011962890625,  0.0018310546875  , -0.002593994140625, -0.00665283203125 , -0.009857177734375, -0.011810302734375, -0.01226806640625 , -0.011199951171875, -0.00872802734375 , -0.005157470703125, -0.001007080078125,  0.00323486328125 ,  0.00701904296875 ,  0.0098876953125  ,  0.011474609375   ,  0.0115966796875  ,  0.010284423828125,  0.0076904296875  ,  0.004180908203125,  0.000244140625   , -0.003692626953125, -0.007080078125   , -0.009490966796875, -0.010711669921875, -0.010528564453125, -0.009063720703125, -0.006500244140625, -0.003204345703125,  0.00042724609375 ,  0.00390625       ,  0.006805419921875,  0.008758544921875,  0.00958251953125 ,  0.009185791015625,  0.007659912109375,  0.0052490234375  ,  0.00225830078125 , -0.000946044921875, -0.003875732421875, -0.006256103515625, -0.00775146484375 , -0.00823974609375 , -0.0076904296875  , -0.0062255859375  , -0.0040283203125  , -0.001434326171875,  0.001251220703125,  0.003631591796875,  0.0054931640625  ,  0.006561279296875,  0.00677490234375 ,  0.00616455078125 ,  0.004791259765625,  0.0029296875     ,  0.000762939453125, -0.001373291015625, -0.00323486328125 , -0.00457763671875 , -0.00531005859375 , -0.005340576171875, -0.00469970703125 , -0.0035400390625  , -0.001983642578125, -0.00030517578125 ,  0.0013427734375  ,  0.002685546875   ,  0.003631591796875,  0.00408935546875 ,  0.00396728515625 ,  0.00341796875    ,  0.00244140625    ,  0.001251220703125,  0.0              , -0.00115966796875 , -0.002105712890625, -0.002716064453125, -0.002960205078125, -0.0028076171875  , -0.0023193359375  , -0.0015869140625  , -0.000732421875   ,  0.000152587890625,  0.000946044921875,  0.001556396484375,  0.001922607421875,  0.00201416015625 ,  0.001861572265625,  0.00146484375    ,  0.000946044921875,  0.0003662109375  , -0.000213623046875, -0.000701904296875, -0.00103759765625 , -0.001251220703125, -0.001251220703125, -0.001129150390625, -0.0008544921875  , -0.000518798828125, -0.000152587890625,  0.00018310546875 ,  0.000457763671875,  0.000640869140625,  0.000732421875   ,  0.000732421875   ,  0.0006103515625  ,  0.000457763671875,  0.000244140625   ,  0.00006103515625 , -0.0001220703125  , -0.000274658203125, -0.000335693359375, -0.0003662109375  , -0.0003662109375  , -0.00030517578125 , -0.000213623046875, -0.000091552734375,  0.0              ,  0.00006103515625 ,  0.0001220703125  ,  0.000152587890625,  0.00018310546875 ,  0.000152587890625,  0.000152587890625,  0.00018310546875 , -0.000152587890625));

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

end entity DspFir;

architecture RtlRam of DspFir is

    ----------------------------------------------------------------------------
    -- Types
    ----------------------------------------------------------------------------
    type aMemory is array (0 to gB'length-1) of
        sample_t;

    type aFirStates is (NewVal, MulSum);

    type aFirParam is record
        firState    : aFirStates;
        writeAdr    : unsigned(LogDualis(gB'length)-1 downto 0);
        readAdr     : unsigned(LogDualis(gB'length)-1 downto 0);
        coeffAdr    : unsigned(LogDualis(gB'length)-1 downto 0);
        valDry      : std_ulogic;
        dDry        : sample_t;
        sum         : sample_t;
        mulRes      : sample_t;
        valWet      : std_ulogic;
    end record aFirParam;

    ----------------------------------------------------------------------------
    -- Constants
    ----------------------------------------------------------------------------
    constant cInitFirParam : aFirParam := ( firState    => NewVal,
                                            writeAdr    => (others => '0'),
                                            readAdr     => (others => '0'),
                                            coeffAdr    => (others => '0'),
                                            valDry      => '0',
                                            dDry        => (others => '0'),
                                            sum         => (others => '0'),
                                            mulRes      => (others => '0'),
                                            valWet      => '0'
                                            );

    ----------------------------------------------------------------------------
    -- Functions
    ----------------------------------------------------------------------------
    function romInit return aMemory is
        variable rom : aMemory := (others => (others => '0'));
    begin
        for adr in rom'range loop
            rom(adr) := to_sfixed(gB(adr), rom(adr));
        end loop;
        return rom;
    end romInit;

    procedure incr_addr (
        signal in_addr  	: in  unsigned(LogDualis(gB'length)-1 downto 0);
        signal out_addr 	: out unsigned(LogDualis(gB'length)-1 downto 0)
    ) is
    begin
        if (in_addr = (gB'length - 1)) then
            out_addr <= (others => '0');
        else
            out_addr <= in_addr + 1;
        end if;
    end incr_addr;

    ----------------------------------------------------------------------------
    -- Signals
    ----------------------------------------------------------------------------
    signal InputRam : aMemory    := (others => (others => '0'));
    signal CoeffRom : aMemory    := romInit;
    signal R        : aFirParam  := cInitFirParam;
    signal nxR      : aFirParam  := cInitFirParam;
    signal readVal  : sample_t := (others => '0');
    signal coeffVal : sample_t := (others => '0');

begin

    ----------------------------------------------------------------------------
    -- Outputs
    ----------------------------------------------------------------------------
    oDwet   <= R.sum;
    oValWet <= R.valWet;

    ----------------------------------------------------------------------------
    -- FSMD
    ----------------------------------------------------------------------------
    Comb : process (R, iValDry, readVal, coeffVal) is
    begin

        nxR <= R;

        case R.firState is
            when NewVal =>
                nxR.valWet <= '0';
                nxR.sum <= (others => '0');

                -- wait here for new sample
                if iValDry = '1' then
                    nxR.firState <= MulSum;

                    incr_addr(R.readAdr, nxR.readAdr);
                end if;

            when MulSum =>
                nxR.mulRes <= ResizeTruncAbsVal(readVal * coeffVal, nxR.mulRes);
                nxR.sum <= ResizeTruncAbsVal(R.sum + R.mulRes, nxR.sum);

                if R.coeffAdr = gB'length-1 then
                    nxR.firState    <= NewVal;
                    nxR.coeffAdr    <= (others => '0');
                    nxR.valWet      <= '1';

                    incr_addr(R.writeAdr, nxR.writeAdr);
                end if;

                incr_addr(R.coeffAdr, nxR.coeffAdr);
                incr_addr(R.readAdr, nxR.readAdr);

            when others =>
                nxR.firState <= NewVal;
        end case;
    end process Comb;

    ----------------------------------------------------------------------------
    -- Read and write RAM
    ----------------------------------------------------------------------------
    AccessInputRam : process (iClk) is
    begin
        if rising_edge(iClk) then
            if iValDry = '1' then
                InputRam(to_integer(R.writeAdr)) <= iDdry;
            end if;

            readVal <= InputRam(to_integer(R.readAdr));
        end if;
    end process AccessInputRam;

    ----------------------------------------------------------------------------
    -- ROM
    ----------------------------------------------------------------------------
    AccessRom : process (iClk) is
    begin
        if rising_edge(iClk) then
            coeffVal <= CoeffRom(to_integer(R.coeffAdr));
        end if;
    end process AccessRom;

    ----------------------------------------------------------------------------
    -- Register process
    ----------------------------------------------------------------------------
    Regs : process (iClk, inResetAsync) is
    begin
        if inResetAsync = '0' then
            R <= cInitFirParam;
        elsif rising_edge(iClk) then
            R <= nxR;
        end if;
    end process Regs;

end architecture;
