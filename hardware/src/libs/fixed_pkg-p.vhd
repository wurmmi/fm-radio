-- --------------------------------------------------------------------

-- "fixed_pkg_c.vhdl" package contains functions for fixed point math.

-- Please see the documentation for the fixed point package.

-- This package should be compiled into "ieee_proposed" and used as follows:

-- use ieee.std_logic_1164.all;

-- use ieee.numeric_std.all;

-- use ieee_proposed.fixed_float_types.all;

-- use ieee_proposed.fixed_pkg.all;

--

--  This verison is designed to work with the VHDL-93 compilers 

--  synthesis tools.  Please note the "%%%" comments.  These are where we

--  diverge from the VHDL-200X LRM.

-- --------------------------------------------------------------------

-- Version    : $Revision: 414 $

-- Date       : $Date: 2015-09-23 17:12:41 +0200 (Wed, 23 Sep 2015) $

-- --------------------------------------------------------------------



use STD.TEXTIO.all;

library IEEE;

use IEEE.STD_LOGIC_1164.all;

use IEEE.NUMERIC_STD.all;

library IEEE_PROPOSED;

use IEEE_PROPOSED.fixed_float_types.all;



package fixed_pkg is

-- generic (

  -- Rounding routine to use in fixed point, fixed_round or fixed_truncate

  constant fixed_round_style : fixed_round_style_type := fixed_round;

  -- Overflow routine to use in fixed point, fixed_saturate or fixed_wrap

  constant fixed_overflow_style : fixed_overflow_style_type := fixed_saturate;

  -- Extra bits used in divide routines

  constant fixed_guard_bits : natural := 3;

  -- If TRUE, then turn off warnings on "X" propagation

  constant no_warning : boolean := (false

                                    );



  -- Author David Bishop (dbishop@vhdl.org)



  -- base Unsigned fixed point type, downto direction assumed

  type UNRESOLVED_ufixed is array (integer range <>) of std_ulogic;

  -- base Signed fixed point type, downto direction assumed

  type UNRESOLVED_sfixed is array (integer range <>) of std_ulogic;



  subtype U_ufixed is UNRESOLVED_ufixed;

  subtype U_sfixed is UNRESOLVED_sfixed;



  subtype ufixed is UNRESOLVED_ufixed;

  subtype sfixed is UNRESOLVED_sfixed;



  --===========================================================================

  -- Arithmetic Operators:

  --===========================================================================



  -- Absolute value, 2's complement

  -- abs sfixed(a downto b) = sfixed(a+1 downto b)

  function "abs" (arg : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;



  -- Negation, 2's complement

  -- - sfixed(a downto b) = sfixed(a+1 downto b)

  function "-" (arg : UNRESOLVED_sfixed)return UNRESOLVED_sfixed;



  -- Addition

  -- ufixed(a downto b) + ufixed(c downto d)

  --   = ufixed(maximum(a,c)+1 downto minimum(b,d))

  function "+" (l, r : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;



  -- sfixed(a downto b) + sfixed(c downto d)

  --   = sfixed(maximum(a,c)+1 downto minimum(b,d))

  function "+" (l, r : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;



  -- Subtraction

  -- ufixed(a downto b) - ufixed(c downto d)

  --   = ufixed(maximum(a,c)+1 downto minimum(b,d))

  function "-" (l, r : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;



  -- sfixed(a downto b) - sfixed(c downto d)

  --   = sfixed(maximum(a,c)+1 downto minimum(b,d))

  function "-" (l, r : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;



  -- Multiplication

  -- ufixed(a downto b) * ufixed(c downto d) = ufixed(a+c+1 downto b+d)

  function "*" (l, r : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;



  -- sfixed(a downto b) * sfixed(c downto d) = sfixed(a+c+1 downto b+d)

  function "*" (l, r : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;



  -- Division

  -- ufixed(a downto b) / ufixed(c downto d) = ufixed(a-d downto b-c-1)

  function "/" (l, r : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;



  -- sfixed(a downto b) / sfixed(c downto d) = sfixed(a-d+1 downto b-c)

  function "/" (l, r : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;



  -- Remainder

  -- ufixed (a downto b) rem ufixed (c downto d)

  --   = ufixed (minimum(a,c) downto minimum(b,d))

  function "rem" (l, r : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;



  -- sfixed (a downto b) rem sfixed (c downto d)

  --   = sfixed (minimum(a,c) downto minimum(b,d))

  function "rem" (l, r : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;



  -- Modulo

  -- ufixed (a downto b) mod ufixed (c downto d)

  --        = ufixed (minimum(a,c) downto minimum(b, d))

  function "mod" (l, r : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;



  -- sfixed (a downto b) mod sfixed (c downto d)

  --        = sfixed (c downto minimum(b, d))

  function "mod" (l, r : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;



  ----------------------------------------------------------------------------

  -- In these routines the "real" or "natural" (integer)

  -- are converted into a fixed point number and then the operation is

  -- performed.  It is assumed that the array will be large enough.

  -- If the input is "real" then the real number is converted into a fixed of

  -- the same size as the fixed point input.  If the number is an "integer"

  -- then it is converted into fixed with the range (l'high downto 0).

  ----------------------------------------------------------------------------



  -- ufixed(a downto b) + ufixed(a downto b) = ufixed(a+1 downto b)

  function "+" (l : UNRESOLVED_ufixed; r : real) return UNRESOLVED_ufixed;



  -- ufixed(c downto d) + ufixed(c downto d) = ufixed(c+1 downto d)

  function "+" (l : real; r : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;



  -- ufixed(a downto b) + ufixed(a downto 0) = ufixed(a+1 downto minimum(0,b))

  function "+" (l : UNRESOLVED_ufixed; r : natural) return UNRESOLVED_ufixed;



  -- ufixed(a downto 0) + ufixed(c downto d) = ufixed(c+1 downto minimum(0,d))

  function "+" (l : natural; r : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;



  -- ufixed(a downto b) - ufixed(a downto b) = ufixed(a+1 downto b)

  function "-" (l : UNRESOLVED_ufixed; r : real) return UNRESOLVED_ufixed;



  -- ufixed(c downto d) - ufixed(c downto d) = ufixed(c+1 downto d)

  function "-" (l : real; r : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;



  -- ufixed(a downto b) - ufixed(a downto 0) = ufixed(a+1 downto minimum(0,b))

  function "-" (l : UNRESOLVED_ufixed; r : natural) return UNRESOLVED_ufixed;



  -- ufixed(a downto 0) + ufixed(c downto d) = ufixed(c+1 downto minimum(0,d))

  function "-" (l : natural; r : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;



  -- ufixed(a downto b) * ufixed(a downto b) = ufixed(2a+1 downto 2b)

  function "*" (l : UNRESOLVED_ufixed; r : real) return UNRESOLVED_ufixed;



  -- ufixed(c downto d) * ufixed(c downto d) = ufixed(2c+1 downto 2d)

  function "*" (l : real; r : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;



  -- ufixed (a downto b) * ufixed (a downto 0) = ufixed (2a+1 downto b)

  function "*" (l : UNRESOLVED_ufixed; r : natural) return UNRESOLVED_ufixed;



  -- ufixed (a downto b) * ufixed (a downto 0) = ufixed (2a+1 downto b)

  function "*" (l : natural; r : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;



  -- ufixed(a downto b) / ufixed(a downto b) = ufixed(a-b downto b-a-1)

  function "/" (l : UNRESOLVED_ufixed; r : real) return UNRESOLVED_ufixed;



  -- ufixed(a downto b) / ufixed(a downto b) = ufixed(a-b downto b-a-1)

  function "/" (l : real; r : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;



  -- ufixed(a downto b) / ufixed(a downto 0) = ufixed(a downto b-a-1)

  function "/" (l : UNRESOLVED_ufixed; r : natural) return UNRESOLVED_ufixed;



  -- ufixed(c downto 0) / ufixed(c downto d) = ufixed(c-d downto -c-1)

  function "/" (l : natural; r : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;



  -- ufixed (a downto b) rem ufixed (a downto b) = ufixed (a downto b)

  function "rem" (l : UNRESOLVED_ufixed; r : real) return UNRESOLVED_ufixed;



  -- ufixed (c downto d) rem ufixed (c downto d) = ufixed (c downto d)

  function "rem" (l : real; r : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;



  -- ufixed (a downto b) rem ufixed (a downto 0) = ufixed (a downto minimum(b,0))

  function "rem" (l : UNRESOLVED_ufixed; r : natural) return UNRESOLVED_ufixed;



  -- ufixed (c downto 0) rem ufixed (c downto d) = ufixed (c downto minimum(d,0))

  function "rem" (l : natural; r : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;



  -- ufixed (a downto b) mod ufixed (a downto b) = ufixed (a downto b)

  function "mod" (l : UNRESOLVED_ufixed; r : real) return UNRESOLVED_ufixed;



  -- ufixed (c downto d) mod ufixed (c downto d) = ufixed (c downto d)

  function "mod" (l : real; r : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;



  -- ufixed (a downto b) mod ufixed (a downto 0) = ufixed (a downto minimum(b,0))

  function "mod" (l : UNRESOLVED_ufixed; r : natural) return UNRESOLVED_ufixed;



  -- ufixed (c downto 0) mod ufixed (c downto d) = ufixed (c downto minimum(d,0))

  function "mod" (l : natural; r : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;



  -- sfixed(a downto b) + sfixed(a downto b) = sfixed(a+1 downto b)

  function "+" (l : UNRESOLVED_sfixed; r : real) return UNRESOLVED_sfixed;



  -- sfixed(c downto d) + sfixed(c downto d) = sfixed(c+1 downto d)

  function "+" (l : real; r : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;



  -- sfixed(a downto b) + sfixed(a downto 0) = sfixed(a+1 downto minimum(0,b))

  function "+" (l : UNRESOLVED_sfixed; r : integer) return UNRESOLVED_sfixed;



  -- sfixed(c downto 0) + sfixed(c downto d) = sfixed(c+1 downto minimum(0,d))

  function "+" (l : integer; r : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;



  -- sfixed(a downto b) - sfixed(a downto b) = sfixed(a+1 downto b)

  function "-" (l : UNRESOLVED_sfixed; r : real) return UNRESOLVED_sfixed;



  -- sfixed(c downto d) - sfixed(c downto d) = sfixed(c+1 downto d)

  function "-" (l : real; r : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;



  -- sfixed(a downto b) - sfixed(a downto 0) = sfixed(a+1 downto minimum(0,b))

  function "-" (l : UNRESOLVED_sfixed; r : integer) return UNRESOLVED_sfixed;



  -- sfixed(c downto 0) - sfixed(c downto d) = sfixed(c+1 downto minimum(0,d))

  function "-" (l : integer; r : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;



  -- sfixed(a downto b) * sfixed(a downto b) = sfixed(2a+1 downto 2b)

  function "*" (l : UNRESOLVED_sfixed; r : real) return UNRESOLVED_sfixed;



  -- sfixed(c downto d) * sfixed(c downto d) = sfixed(2c+1 downto 2d)

  function "*" (l : real; r : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;



  -- sfixed(a downto b) * sfixed(a downto 0) = sfixed(2a+1 downto b)

  function "*" (l : UNRESOLVED_sfixed; r : integer) return UNRESOLVED_sfixed;



  -- sfixed(c downto 0) * sfixed(c downto d) = sfixed(2c+1 downto d)

  function "*" (l : integer; r : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;



  -- sfixed(a downto b) / sfixed(a downto b) = sfixed(a-b+1 downto b-a)

  function "/" (l : UNRESOLVED_sfixed; r : real) return UNRESOLVED_sfixed;



  -- sfixed(c downto d) / sfixed(c downto d) = sfixed(c-d+1 downto d-c)

  function "/" (l : real; r : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;



  -- sfixed(a downto b) / sfixed(a downto 0) = sfixed(a+1 downto b-a)

  function "/" (l : UNRESOLVED_sfixed; r : integer) return UNRESOLVED_sfixed;



  -- sfixed(c downto 0) / sfixed(c downto d) = sfixed(c-d+1 downto -c)

  function "/" (l : integer; r : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;



  -- sfixed (a downto b) rem sfixed (a downto b) = sfixed (a downto b)

  function "rem" (l : UNRESOLVED_sfixed; r : real) return UNRESOLVED_sfixed;



  -- sfixed (c downto d) rem sfixed (c downto d) = sfixed (c downto d)

  function "rem" (l : real; r : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;



  -- sfixed (a downto b) rem sfixed (a downto 0) = sfixed (a downto minimum(b,0))

  function "rem" (l : UNRESOLVED_sfixed; r : integer) return UNRESOLVED_sfixed;



  -- sfixed (c downto 0) rem sfixed (c downto d) = sfixed (c downto minimum(d,0))

  function "rem" (l : integer; r : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;



  -- sfixed (a downto b) mod sfixed (a downto b) = sfixed (a downto b)

  function "mod" (l : UNRESOLVED_sfixed; r : real) return UNRESOLVED_sfixed;



  -- sfixed (c downto d) mod sfixed (c downto d) = sfixed (c downto d)

  function "mod" (l : real; r : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;



  -- sfixed (a downto b) mod sfixed (a downto 0) = sfixed (a downto minimum(b,0))

  function "mod" (l : UNRESOLVED_sfixed; r : integer) return UNRESOLVED_sfixed;



  -- sfixed (c downto 0) mod sfixed (c downto d) = sfixed (c downto minimum(d,0))

  function "mod" (l : integer; r : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;



  -- This version of divide gives the user more control

  -- ufixed(a downto b) / ufixed(c downto d) = ufixed(a-d downto b-c-1)

  function divide (

    l, r : UNRESOLVED_ufixed;

    constant round_style : fixed_round_style_type := fixed_round_style;

    constant guard_bits : natural := fixed_guard_bits)

    return UNRESOLVED_ufixed;



  -- This version of divide gives the user more control

  -- sfixed(a downto b) / sfixed(c downto d) = sfixed(a-d+1 downto b-c)

  function divide (

    l, r : UNRESOLVED_sfixed;

    constant round_style : fixed_round_style_type := fixed_round_style;

    constant guard_bits : natural := fixed_guard_bits)

    return UNRESOLVED_sfixed;



  -- These functions return 1/X

  -- 1 / ufixed(a downto b) = ufixed(-b downto -a-1)

  function reciprocal (

    arg : UNRESOLVED_ufixed;            -- fixed point input

    constant round_style : fixed_round_style_type := fixed_round_style;

    constant guard_bits : natural := fixed_guard_bits)

    return UNRESOLVED_ufixed;



  -- 1 / sfixed(a downto b) = sfixed(-b+1 downto -a)

  function reciprocal (

    arg : UNRESOLVED_sfixed;            -- fixed point input

    constant round_style : fixed_round_style_type := fixed_round_style;

    constant guard_bits : natural := fixed_guard_bits)

    return UNRESOLVED_sfixed;



  -- REM function

  -- ufixed (a downto b) rem ufixed (c downto d)

  --   = ufixed (minimum(a,c) downto minimum(b,d))

  function remainder (

    l, r : UNRESOLVED_ufixed;

    constant round_style : fixed_round_style_type := fixed_round_style;

    constant guard_bits : natural := fixed_guard_bits)

    return UNRESOLVED_ufixed;



  -- sfixed (a downto b) rem sfixed (c downto d)

  --   = sfixed (minimum(a,c) downto minimum(b,d))

  function remainder (

    l, r : UNRESOLVED_sfixed;

    constant round_style : fixed_round_style_type := fixed_round_style;

    constant guard_bits : natural := fixed_guard_bits)

    return UNRESOLVED_sfixed;



  -- mod function

  -- ufixed (a downto b) mod ufixed (c downto d)

  --        = ufixed (minimum(a,c) downto minimum(b, d))

  function modulo (

    l, r : UNRESOLVED_ufixed;

    constant round_style : fixed_round_style_type := fixed_round_style;

    constant guard_bits : natural := fixed_guard_bits)

    return UNRESOLVED_ufixed;



  -- sfixed (a downto b) mod sfixed (c downto d)

  --        = sfixed (c downto minimum(b, d))

  function modulo (

    l, r : UNRESOLVED_sfixed;

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style;

    constant guard_bits : natural := fixed_guard_bits)

    return UNRESOLVED_sfixed;



  -- Procedure for those who need an "accumulator" function.

  -- add_carry (ufixed(a downto b), ufixed (c downto d))

  --         = ufixed (maximum(a,c) downto minimum(b,d))

  procedure add_carry (

    L, R : in UNRESOLVED_ufixed;

    c_in : in std_ulogic;

    result : out UNRESOLVED_ufixed;

    c_out : out std_ulogic);



  -- add_carry (sfixed(a downto b), sfixed (c downto d))

  --         = sfixed (maximum(a,c) downto minimum(b,d))

  procedure add_carry (

    L, R : in UNRESOLVED_sfixed;

    c_in : in std_ulogic;

    result : out UNRESOLVED_sfixed;

    c_out : out std_ulogic);



  -- Scales the result by a power of 2.  Width of input = width of output with

  -- the binary point moved.

  function scalb (y : UNRESOLVED_ufixed; N : integer) return UNRESOLVED_ufixed;

  function scalb (y : UNRESOLVED_ufixed; N : signed) return UNRESOLVED_ufixed;

  function scalb (y : UNRESOLVED_sfixed; N : integer) return UNRESOLVED_sfixed;

  function scalb (y : UNRESOLVED_sfixed; N : signed) return UNRESOLVED_sfixed;



  function Is_Negative (arg : UNRESOLVED_sfixed) return boolean;



  --===========================================================================

  -- Comparison Operators

  --===========================================================================



  function ">" (l, r : UNRESOLVED_ufixed) return boolean;

  function ">" (l, r : UNRESOLVED_sfixed) return boolean;

  function "<" (l, r : UNRESOLVED_ufixed) return boolean;

  function "<" (l, r : UNRESOLVED_sfixed) return boolean;

  function "<=" (l, r : UNRESOLVED_ufixed) return boolean;

  function "<=" (l, r : UNRESOLVED_sfixed) return boolean;

  function ">=" (l, r : UNRESOLVED_ufixed) return boolean;

  function ">=" (l, r : UNRESOLVED_sfixed) return boolean;

  function "=" (l, r : UNRESOLVED_ufixed) return boolean;

  function "=" (l, r : UNRESOLVED_sfixed) return boolean;

  function "/=" (l, r : UNRESOLVED_ufixed) return boolean;

  function "/=" (l, r : UNRESOLVED_sfixed) return boolean;



  function \?=\ (l, r : UNRESOLVED_ufixed) return std_ulogic;

  function \?/=\ (l, r : UNRESOLVED_ufixed) return std_ulogic;

  function \?>\ (l, r : UNRESOLVED_ufixed) return std_ulogic;

  function \?>=\ (l, r : UNRESOLVED_ufixed) return std_ulogic;

  function \?<\ (l, r : UNRESOLVED_ufixed) return std_ulogic;

  function \?<=\ (l, r : UNRESOLVED_ufixed) return std_ulogic;

  function \?=\ (l, r : UNRESOLVED_sfixed) return std_ulogic;

  function \?/=\ (l, r : UNRESOLVED_sfixed) return std_ulogic;

  function \?>\ (l, r : UNRESOLVED_sfixed) return std_ulogic;

  function \?>=\ (l, r : UNRESOLVED_sfixed) return std_ulogic;

  function \?<\ (l, r : UNRESOLVED_sfixed) return std_ulogic;

  function \?<=\ (l, r : UNRESOLVED_sfixed) return std_ulogic;



  function std_match (l, r : UNRESOLVED_ufixed) return boolean;

  function std_match (l, r : UNRESOLVED_sfixed) return boolean;



  -- Overloads the default "maximum" and "minimum" function



  function maximum (l, r : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;

  function minimum (l, r : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;

  function maximum (l, r : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;

  function minimum (l, r : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;



  ----------------------------------------------------------------------------

  -- In these compare functions a natural is converted into a

  -- fixed point number of the bounds "maximum(l'high,0) downto 0"

  ----------------------------------------------------------------------------



  function "=" (l : UNRESOLVED_ufixed; r : natural) return boolean;

  function "/=" (l : UNRESOLVED_ufixed; r : natural) return boolean;

  function ">=" (l : UNRESOLVED_ufixed; r : natural) return boolean;

  function "<=" (l : UNRESOLVED_ufixed; r : natural) return boolean;

  function ">" (l : UNRESOLVED_ufixed; r : natural) return boolean;

  function "<" (l : UNRESOLVED_ufixed; r : natural) return boolean;



  function "=" (l : natural; r : UNRESOLVED_ufixed) return boolean;

  function "/=" (l : natural; r : UNRESOLVED_ufixed) return boolean;

  function ">=" (l : natural; r : UNRESOLVED_ufixed) return boolean;

  function "<=" (l : natural; r : UNRESOLVED_ufixed) return boolean;

  function ">" (l : natural; r : UNRESOLVED_ufixed) return boolean;

  function "<" (l : natural; r : UNRESOLVED_ufixed) return boolean;



  function \?=\ (l : UNRESOLVED_ufixed; r : natural) return std_ulogic;

  function \?/=\ (l : UNRESOLVED_ufixed; r : natural) return std_ulogic;

  function \?>=\ (l : UNRESOLVED_ufixed; r : natural) return std_ulogic;

  function \?<=\ (l : UNRESOLVED_ufixed; r : natural) return std_ulogic;

  function \?>\ (l : UNRESOLVED_ufixed; r : natural) return std_ulogic;

  function \?<\ (l : UNRESOLVED_ufixed; r : natural) return std_ulogic;



  function \?=\ (l : natural; r : UNRESOLVED_ufixed) return std_ulogic;

  function \?/=\ (l : natural; r : UNRESOLVED_ufixed) return std_ulogic;

  function \?>=\ (l : natural; r : UNRESOLVED_ufixed) return std_ulogic;

  function \?<=\ (l : natural; r : UNRESOLVED_ufixed) return std_ulogic;

  function \?>\ (l : natural; r : UNRESOLVED_ufixed) return std_ulogic;

  function \?<\ (l : natural; r : UNRESOLVED_ufixed) return std_ulogic;



  function maximum (l : UNRESOLVED_ufixed; r : natural)

    return UNRESOLVED_ufixed;

  function minimum (l : UNRESOLVED_ufixed; r : natural)

    return UNRESOLVED_ufixed;

  function maximum (l : natural; r : UNRESOLVED_ufixed)

    return UNRESOLVED_ufixed;

  function minimum (l : natural; r : UNRESOLVED_ufixed)

    return UNRESOLVED_ufixed;

  ----------------------------------------------------------------------------

  -- In these compare functions a real is converted into a

  -- fixed point number of the bounds "l'high+1 downto l'low"

  ----------------------------------------------------------------------------



  function "=" (l : UNRESOLVED_ufixed; r : real) return boolean;

  function "/=" (l : UNRESOLVED_ufixed; r : real) return boolean;

  function ">=" (l : UNRESOLVED_ufixed; r : real) return boolean;

  function "<=" (l : UNRESOLVED_ufixed; r : real) return boolean;

  function ">" (l : UNRESOLVED_ufixed; r : real) return boolean;

  function "<" (l : UNRESOLVED_ufixed; r : real) return boolean;



  function "=" (l : real; r : UNRESOLVED_ufixed) return boolean;

  function "/=" (l : real; r : UNRESOLVED_ufixed) return boolean;

  function ">=" (l : real; r : UNRESOLVED_ufixed) return boolean;

  function "<=" (l : real; r : UNRESOLVED_ufixed) return boolean;

  function ">" (l : real; r : UNRESOLVED_ufixed) return boolean;

  function "<" (l : real; r : UNRESOLVED_ufixed) return boolean;



  function \?=\ (l : UNRESOLVED_ufixed; r : real) return std_ulogic;

  function \?/=\ (l : UNRESOLVED_ufixed; r : real) return std_ulogic;

  function \?>=\ (l : UNRESOLVED_ufixed; r : real) return std_ulogic;

  function \?<=\ (l : UNRESOLVED_ufixed; r : real) return std_ulogic;

  function \?>\ (l : UNRESOLVED_ufixed; r : real) return std_ulogic;

  function \?<\ (l : UNRESOLVED_ufixed; r : real) return std_ulogic;



  function \?=\ (l : real; r : UNRESOLVED_ufixed) return std_ulogic;

  function \?/=\ (l : real; r : UNRESOLVED_ufixed) return std_ulogic;

  function \?>=\ (l : real; r : UNRESOLVED_ufixed) return std_ulogic;

  function \?<=\ (l : real; r : UNRESOLVED_ufixed) return std_ulogic;

  function \?>\ (l : real; r : UNRESOLVED_ufixed) return std_ulogic;

  function \?<\ (l : real; r : UNRESOLVED_ufixed) return std_ulogic;



  function maximum (l : UNRESOLVED_ufixed; r : real) return UNRESOLVED_ufixed;

  function maximum (l : real; r : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;

  function minimum (l : UNRESOLVED_ufixed; r : real) return UNRESOLVED_ufixed;

  function minimum (l : real; r : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;

  ----------------------------------------------------------------------------

  -- In these compare functions an integer is converted into a

  -- fixed point number of the bounds "maximum(l'high,1) downto 0"

  ----------------------------------------------------------------------------



  function "=" (l : UNRESOLVED_sfixed; r : integer) return boolean;

  function "/=" (l : UNRESOLVED_sfixed; r : integer) return boolean;

  function ">=" (l : UNRESOLVED_sfixed; r : integer) return boolean;

  function "<=" (l : UNRESOLVED_sfixed; r : integer) return boolean;

  function ">" (l : UNRESOLVED_sfixed; r : integer) return boolean;

  function "<" (l : UNRESOLVED_sfixed; r : integer) return boolean;



  function "=" (l : integer; r : UNRESOLVED_sfixed) return boolean;

  function "/=" (l : integer; r : UNRESOLVED_sfixed) return boolean;

  function ">=" (l : integer; r : UNRESOLVED_sfixed) return boolean;

  function "<=" (l : integer; r : UNRESOLVED_sfixed) return boolean;

  function ">" (l : integer; r : UNRESOLVED_sfixed) return boolean;

  function "<" (l : integer; r : UNRESOLVED_sfixed) return boolean;



  function \?=\ (l : UNRESOLVED_sfixed; r : integer) return std_ulogic;

  function \?/=\ (l : UNRESOLVED_sfixed; r : integer) return std_ulogic;

  function \?>=\ (l : UNRESOLVED_sfixed; r : integer) return std_ulogic;

  function \?<=\ (l : UNRESOLVED_sfixed; r : integer) return std_ulogic;

  function \?>\ (l : UNRESOLVED_sfixed; r : integer) return std_ulogic;

  function \?<\ (l : UNRESOLVED_sfixed; r : integer) return std_ulogic;



  function \?=\ (l : integer; r : UNRESOLVED_sfixed) return std_ulogic;

  function \?/=\ (l : integer; r : UNRESOLVED_sfixed) return std_ulogic;

  function \?>=\ (l : integer; r : UNRESOLVED_sfixed) return std_ulogic;

  function \?<=\ (l : integer; r : UNRESOLVED_sfixed) return std_ulogic;

  function \?>\ (l : integer; r : UNRESOLVED_sfixed) return std_ulogic;

  function \?<\ (l : integer; r : UNRESOLVED_sfixed) return std_ulogic;



  function maximum (l : UNRESOLVED_sfixed; r : integer)

    return UNRESOLVED_sfixed;

  function maximum (l : integer; r : UNRESOLVED_sfixed)

    return UNRESOLVED_sfixed;

  function minimum (l : UNRESOLVED_sfixed; r : integer)

    return UNRESOLVED_sfixed;

  function minimum (l : integer; r : UNRESOLVED_sfixed)

    return UNRESOLVED_sfixed;

  ----------------------------------------------------------------------------

  -- In these compare functions a real is converted into a

  -- fixed point number of the bounds "l'high+1 downto l'low"

  ----------------------------------------------------------------------------



  function "=" (l : UNRESOLVED_sfixed; r : real) return boolean;

  function "/=" (l : UNRESOLVED_sfixed; r : real) return boolean;

  function ">=" (l : UNRESOLVED_sfixed; r : real) return boolean;

  function "<=" (l : UNRESOLVED_sfixed; r : real) return boolean;

  function ">" (l : UNRESOLVED_sfixed; r : real) return boolean;

  function "<" (l : UNRESOLVED_sfixed; r : real) return boolean;



  function "=" (l : real; r : UNRESOLVED_sfixed) return boolean;

  function "/=" (l : real; r : UNRESOLVED_sfixed) return boolean;

  function ">=" (l : real; r : UNRESOLVED_sfixed) return boolean;

  function "<=" (l : real; r : UNRESOLVED_sfixed) return boolean;

  function ">" (l : real; r : UNRESOLVED_sfixed) return boolean;

  function "<" (l : real; r : UNRESOLVED_sfixed) return boolean;



  function \?=\ (l : UNRESOLVED_sfixed; r : real) return std_ulogic;

  function \?/=\ (l : UNRESOLVED_sfixed; r : real) return std_ulogic;

  function \?>=\ (l : UNRESOLVED_sfixed; r : real) return std_ulogic;

  function \?<=\ (l : UNRESOLVED_sfixed; r : real) return std_ulogic;

  function \?>\ (l : UNRESOLVED_sfixed; r : real) return std_ulogic;

  function \?<\ (l : UNRESOLVED_sfixed; r : real) return std_ulogic;



  function \?=\ (l : real; r : UNRESOLVED_sfixed) return std_ulogic;

  function \?/=\ (l : real; r : UNRESOLVED_sfixed) return std_ulogic;

  function \?>=\ (l : real; r : UNRESOLVED_sfixed) return std_ulogic;

  function \?<=\ (l : real; r : UNRESOLVED_sfixed) return std_ulogic;

  function \?>\ (l : real; r : UNRESOLVED_sfixed) return std_ulogic;

  function \?<\ (l : real; r : UNRESOLVED_sfixed) return std_ulogic;



  function maximum (l : UNRESOLVED_sfixed; r : real) return UNRESOLVED_sfixed;

  function maximum (l : real; r : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;

  function minimum (l : UNRESOLVED_sfixed; r : real) return UNRESOLVED_sfixed;

  function minimum (l : real; r : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;

  --===========================================================================

  -- Shift and Rotate Functions.

  -- Note that sra and sla are not the same as the BIT_VECTOR version

  --===========================================================================



  function "sll" (ARG : UNRESOLVED_ufixed; COUNT : integer)

    return UNRESOLVED_ufixed;

  function "srl" (ARG : UNRESOLVED_ufixed; COUNT : integer)

    return UNRESOLVED_ufixed;

  function "rol" (ARG : UNRESOLVED_ufixed; COUNT : integer)

    return UNRESOLVED_ufixed;

  function "ror" (ARG : UNRESOLVED_ufixed; COUNT : integer)

    return UNRESOLVED_ufixed;

  function "sla" (ARG : UNRESOLVED_ufixed; COUNT : integer)

    return UNRESOLVED_ufixed;

  function "sra" (ARG : UNRESOLVED_ufixed; COUNT : integer)

    return UNRESOLVED_ufixed;

  function "sll" (ARG : UNRESOLVED_sfixed; COUNT : integer)

    return UNRESOLVED_sfixed;

  function "srl" (ARG : UNRESOLVED_sfixed; COUNT : integer)

    return UNRESOLVED_sfixed;

  function "rol" (ARG : UNRESOLVED_sfixed; COUNT : integer)

    return UNRESOLVED_sfixed;

  function "ror" (ARG : UNRESOLVED_sfixed; COUNT : integer)

    return UNRESOLVED_sfixed;

  function "sla" (ARG : UNRESOLVED_sfixed; COUNT : integer)

    return UNRESOLVED_sfixed;

  function "sra" (ARG : UNRESOLVED_sfixed; COUNT : integer)

    return UNRESOLVED_sfixed;

  function SHIFT_LEFT (ARG : UNRESOLVED_ufixed; COUNT : natural)

    return UNRESOLVED_ufixed;

  function SHIFT_RIGHT (ARG : UNRESOLVED_ufixed; COUNT : natural)

    return UNRESOLVED_ufixed;

  function SHIFT_LEFT (ARG : UNRESOLVED_sfixed; COUNT : natural)

    return UNRESOLVED_sfixed;

  function SHIFT_RIGHT (ARG : UNRESOLVED_sfixed; COUNT : natural)

    return UNRESOLVED_sfixed;



  ----------------------------------------------------------------------------

  -- logical functions

  ----------------------------------------------------------------------------



  function "not" (l : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;

  function "and" (l, r : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;

  function "or" (l, r : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;

  function "nand" (l, r : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;

  function "nor" (l, r : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;

  function "xor" (l, r : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;

  function "xnor" (l, r : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;

  function "not" (l : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;

  function "and" (l, r : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;

  function "or" (l, r : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;

  function "nand" (l, r : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;

  function "nor" (l, r : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;

  function "xor" (l, r : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;

  function "xnor" (l, r : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;



  -- Vector and std_ulogic functions, same as functions in numeric_std

  function "and" (l : std_ulogic; r : UNRESOLVED_ufixed)

    return UNRESOLVED_ufixed;

  function "and" (l : UNRESOLVED_ufixed; r : std_ulogic)

    return UNRESOLVED_ufixed;

  function "or" (l : std_ulogic; r : UNRESOLVED_ufixed)

    return UNRESOLVED_ufixed;

  function "or" (l : UNRESOLVED_ufixed; r : std_ulogic)

    return UNRESOLVED_ufixed;

  function "nand" (l : std_ulogic; r : UNRESOLVED_ufixed)

    return UNRESOLVED_ufixed;

  function "nand" (l : UNRESOLVED_ufixed; r : std_ulogic)

    return UNRESOLVED_ufixed;

  function "nor" (l : std_ulogic; r : UNRESOLVED_ufixed)

    return UNRESOLVED_ufixed;

  function "nor" (l : UNRESOLVED_ufixed; r : std_ulogic)

    return UNRESOLVED_ufixed;

  function "xor" (l : std_ulogic; r : UNRESOLVED_ufixed)

    return UNRESOLVED_ufixed;

  function "xor" (l : UNRESOLVED_ufixed; r : std_ulogic)

    return UNRESOLVED_ufixed;

  function "xnor" (l : std_ulogic; r : UNRESOLVED_ufixed)

    return UNRESOLVED_ufixed;

  function "xnor" (l : UNRESOLVED_ufixed; r : std_ulogic)

    return UNRESOLVED_ufixed;

  function "and" (l : std_ulogic; r : UNRESOLVED_sfixed)

    return UNRESOLVED_sfixed;

  function "and" (l : UNRESOLVED_sfixed; r : std_ulogic)

    return UNRESOLVED_sfixed;

  function "or" (l : std_ulogic; r : UNRESOLVED_sfixed)

    return UNRESOLVED_sfixed;

  function "or" (l : UNRESOLVED_sfixed; r : std_ulogic)

    return UNRESOLVED_sfixed;

  function "nand" (l : std_ulogic; r : UNRESOLVED_sfixed)

    return UNRESOLVED_sfixed;

  function "nand" (l : UNRESOLVED_sfixed; r : std_ulogic)

    return UNRESOLVED_sfixed;

  function "nor" (l : std_ulogic; r : UNRESOLVED_sfixed)

    return UNRESOLVED_sfixed;

  function "nor" (l : UNRESOLVED_sfixed; r : std_ulogic)

    return UNRESOLVED_sfixed;

  function "xor" (l : std_ulogic; r : UNRESOLVED_sfixed)

    return UNRESOLVED_sfixed;

  function "xor" (l : UNRESOLVED_sfixed; r : std_ulogic)

    return UNRESOLVED_sfixed;

  function "xnor" (l : std_ulogic; r : UNRESOLVED_sfixed)

    return UNRESOLVED_sfixed;

  function "xnor" (l : UNRESOLVED_sfixed; r : std_ulogic)

    return UNRESOLVED_sfixed;



  -- Reduction operators, same as numeric_std functions

  function and_reduce (l : UNRESOLVED_ufixed) return std_ulogic;

  function nand_reduce (l : UNRESOLVED_ufixed) return std_ulogic;

  function or_reduce (l : UNRESOLVED_ufixed) return std_ulogic;

  function nor_reduce (l : UNRESOLVED_ufixed) return std_ulogic;

  function xor_reduce (l : UNRESOLVED_ufixed) return std_ulogic;

  function xnor_reduce (l : UNRESOLVED_ufixed) return std_ulogic;

  function and_reduce (l : UNRESOLVED_sfixed) return std_ulogic;

  function nand_reduce (l : UNRESOLVED_sfixed) return std_ulogic;

  function or_reduce (l : UNRESOLVED_sfixed) return std_ulogic;

  function nor_reduce (l : UNRESOLVED_sfixed) return std_ulogic;

  function xor_reduce (l : UNRESOLVED_sfixed) return std_ulogic;

  function xnor_reduce (l : UNRESOLVED_sfixed) return std_ulogic;



  -- returns arg'low-1 if not found

  function find_leftmost (arg : UNRESOLVED_ufixed; y : std_ulogic)

    return integer;

  function find_leftmost (arg : UNRESOLVED_sfixed; y : std_ulogic)

    return integer;



  -- returns arg'high+1 if not found

  function find_rightmost (arg : UNRESOLVED_ufixed; y : std_ulogic)

    return integer;

  function find_rightmost (arg : UNRESOLVED_sfixed; y : std_ulogic)

    return integer;



  --===========================================================================

  --   RESIZE Functions

  --===========================================================================

  -- resizes the number (larger or smaller)

  -- The returned result will be ufixed (left_index downto right_index)

  -- If "round_style" is fixed_round, then the result will be rounded.

  -- If the MSB of the remainder is a "1" AND the LSB of the unrounded result

  -- is a '1' or the lower bits of the remainder include a '1' then the result

  -- will be increased by the smallest representable number for that type.

  -- "overflow_style" can be fixed_saturate or fixed_wrap.

  -- In saturate mode, if the number overflows then the largest possible

  -- representable number is returned.  If wrap mode, then the upper bits

  -- of the number are truncated.



  function resize (

    arg : UNRESOLVED_ufixed;            -- input

    constant left_index : integer;      -- integer portion

    constant right_index : integer;     -- size of fraction

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return UNRESOLVED_ufixed;



  -- "size_res" functions create the size of the output from the indices

  -- of the "size_res" input.  The actual value of "size_res" is not used.

  function resize (

    arg : UNRESOLVED_ufixed;            -- input

    size_res : UNRESOLVED_ufixed;       -- for size only

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return UNRESOLVED_ufixed;



  -- Note that in "wrap" mode the sign bit is not replicated.  Thus the

  -- resize of a negative number can have a positive result in wrap mode.

  function resize (

    arg : UNRESOLVED_sfixed;            -- input

    constant left_index : integer;      -- integer portion

    constant right_index : integer;     -- size of fraction

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return UNRESOLVED_sfixed;



  function resize (

    arg : UNRESOLVED_sfixed;            -- input

    size_res : UNRESOLVED_sfixed;       -- for size only

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return UNRESOLVED_sfixed;



  --===========================================================================

  -- Conversion Functions

  --===========================================================================



  -- integer (natural) to unsigned fixed point.

  -- arguments are the upper and lower bounds of the number, thus

  -- ufixed (7 downto -3) <= to_ufixed (int, 7, -3);

  function to_ufixed (

    arg : natural;                      -- integer

    constant left_index : integer;      -- left index (high index)

    constant right_index : integer := 0;  -- right index

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return UNRESOLVED_ufixed;



  function to_ufixed (

    arg : natural;                      -- integer

    size_res : UNRESOLVED_ufixed;       -- for size only

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return UNRESOLVED_ufixed;



  -- real to unsigned fixed point

  function to_ufixed (

    arg : real;                         -- real

    constant left_index : integer;      -- left index (high index)

    constant right_index : integer;     -- right index

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style;

    constant guard_bits : natural := fixed_guard_bits)

    return UNRESOLVED_ufixed;



  function to_ufixed (

    arg : real;                         -- real

    size_res : UNRESOLVED_ufixed;       -- for size only

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style;

    constant guard_bits : natural := fixed_guard_bits)

    return UNRESOLVED_ufixed;



  -- unsigned to unsigned fixed point

  function to_ufixed (

    arg : unsigned;                     -- unsigned

    constant left_index : integer;      -- left index (high index)

    constant right_index : integer := 0;  -- right index

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return UNRESOLVED_ufixed;



  function to_ufixed (

    arg : unsigned;                     -- unsigned

    size_res : UNRESOLVED_ufixed;       -- for size only

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return UNRESOLVED_ufixed;



  -- Performs a conversion.  ufixed (arg'range) is returned

  function to_ufixed (

    arg : unsigned)                     -- unsigned

    return UNRESOLVED_ufixed;



  -- unsigned fixed point to unsigned

  function to_unsigned (

    arg : UNRESOLVED_ufixed;            -- fixed point input

    constant size : natural;            -- length of output

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return unsigned;



  -- unsigned fixed point to unsigned

  function to_unsigned (

    arg : UNRESOLVED_ufixed;            -- fixed point input

    size_res : unsigned;                -- used for length of output

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return unsigned;



  -- unsigned fixed point to real

  function to_real (

    arg : UNRESOLVED_ufixed)            -- fixed point input

    return real;



  -- unsigned fixed point to integer

  function to_integer (

    arg : UNRESOLVED_ufixed;            -- fixed point input

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return natural;



  -- Integer to UNRESOLVED_sfixed

  function to_sfixed (

    arg : integer;                      -- integer

    constant left_index : integer;      -- left index (high index)

    constant right_index : integer := 0;  -- right index

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return UNRESOLVED_sfixed;



  function to_sfixed (

    arg : integer;                      -- integer

    size_res : UNRESOLVED_sfixed;       -- for size only

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return UNRESOLVED_sfixed;



  -- Real to sfixed

  function to_sfixed (

    arg : real;                         -- real

    constant left_index : integer;      -- left index (high index)

    constant right_index : integer;     -- right index

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style;

    constant guard_bits : natural := fixed_guard_bits)

    return UNRESOLVED_sfixed;



  function to_sfixed (

    arg : real;                         -- real

    size_res : UNRESOLVED_sfixed;       -- for size only

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style;

    constant guard_bits : natural := fixed_guard_bits)

    return UNRESOLVED_sfixed;



  -- signed to sfixed

  function to_sfixed (

    arg : signed;                       -- signed

    constant left_index : integer;      -- left index (high index)

    constant right_index : integer := 0;  -- right index

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return UNRESOLVED_sfixed;



  function to_sfixed (

    arg : signed;                       -- signed

    size_res : UNRESOLVED_sfixed;       -- for size only

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return UNRESOLVED_sfixed;



  -- signed to sfixed (output assumed to be size of signed input)

  function to_sfixed (

    arg : signed)                       -- signed

    return UNRESOLVED_sfixed;



  -- Conversion from ufixed to sfixed

  function to_sfixed (

    arg : UNRESOLVED_ufixed)

    return UNRESOLVED_sfixed;



  -- signed fixed point to signed

  function to_signed (

    arg : UNRESOLVED_sfixed;            -- fixed point input

    constant size : natural;            -- length of output

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return signed;



  -- signed fixed point to signed

  function to_signed (

    arg : UNRESOLVED_sfixed;            -- fixed point input

    size_res : signed;                  -- used for length of output

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return signed;



  -- signed fixed point to real

  function to_real (

    arg : UNRESOLVED_sfixed)            -- fixed point input

    return real;



  -- signed fixed point to integer

  function to_integer (

    arg : UNRESOLVED_sfixed;            -- fixed point input

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return integer;



  -- Because of the fairly complicated sizing rules in the fixed point

  -- packages these functions are provided to compute the result ranges

  -- Example:

  -- signal uf1 : ufixed (3 downto -3);

  -- signal uf2 : ufixed (4 downto -2);

  -- signal uf1multuf2 : ufixed (ufixed_high (3, -3, '*', 4, -2) downto

  --                             ufixed_low (3, -3, '*', 4, -2));

  -- uf1multuf2 <= uf1 * uf2;

  -- Valid characters: '+', '-', '*', '/', 'r' or 'R' (rem), 'm' or 'M' (mod),

  --                   '1' (reciprocal), 'a' or 'A' (abs), 'n' or 'N' (unary -)

  function ufixed_high (left_index, right_index : integer;

                        operation : character := 'X';

                        left_index2, right_index2 : integer := 0)

    return integer;



  function ufixed_low (left_index, right_index : integer;

                       operation : character := 'X';

                       left_index2, right_index2 : integer := 0)

    return integer;



  function sfixed_high (left_index, right_index : integer;

                        operation : character := 'X';

                        left_index2, right_index2 : integer := 0)

    return integer;



  function sfixed_low (left_index, right_index : integer;

                       operation : character := 'X';

                       left_index2, right_index2 : integer := 0)

    return integer;



  -- Same as above, but using the "size_res" input only for their ranges:

  -- signal uf1multuf2 : ufixed (ufixed_high (uf1, '*', uf2) downto

  --                             ufixed_low (uf1, '*', uf2));

  -- uf1multuf2 <= uf1 * uf2;

  -- 

  function ufixed_high (size_res : UNRESOLVED_ufixed;

                        operation : character := 'X';

                        size_res2 : UNRESOLVED_ufixed)

    return integer;



  function ufixed_low (size_res : UNRESOLVED_ufixed;

                       operation : character := 'X';

                       size_res2 : UNRESOLVED_ufixed)

    return integer;



  function sfixed_high (size_res : UNRESOLVED_sfixed;

                        operation : character := 'X';

                        size_res2 : UNRESOLVED_sfixed)

    return integer;



  function sfixed_low (size_res : UNRESOLVED_sfixed;

                       operation : character := 'X';

                       size_res2 : UNRESOLVED_sfixed)

    return integer;



  -- purpose: returns a saturated number

  function saturate (

    constant left_index : integer;

    constant right_index : integer)

    return UNRESOLVED_ufixed;



  -- purpose: returns a saturated number

  function saturate (

    constant left_index : integer;

    constant right_index : integer)

    return UNRESOLVED_sfixed;



  function saturate (

    size_res : UNRESOLVED_ufixed)       -- only the size of this is used

    return UNRESOLVED_ufixed;



  function saturate (

    size_res : UNRESOLVED_sfixed)       -- only the size of this is used

    return UNRESOLVED_sfixed;



  --===========================================================================

  -- Translation Functions

  --===========================================================================



  -- maps meta-logical values

  function to_01 (

    s : UNRESOLVED_ufixed;              -- fixed point input

    constant XMAP : std_ulogic := '0')  -- Map x to

    return UNRESOLVED_ufixed;



  -- maps meta-logical values

  function to_01 (

    s : UNRESOLVED_sfixed;              -- fixed point input

    constant XMAP : std_ulogic := '0')  -- Map x to

    return UNRESOLVED_sfixed;



  function Is_X (arg : UNRESOLVED_ufixed) return boolean;

  function Is_X (arg : UNRESOLVED_sfixed) return boolean;

  function to_X01 (arg : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;

  function to_X01 (arg : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;

  function to_X01Z (arg : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;

  function to_X01Z (arg : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;

  function to_UX01 (arg : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;

  function to_UX01 (arg : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;



  -- straight vector conversion routines, needed for synthesis.

  -- These functions are here so that a std_logic_vector can be

  -- converted to and from sfixed and ufixed.  Note that you can

  -- not convert these vectors because of their negative index.



  function to_slv (

    arg : UNRESOLVED_ufixed)            -- fixed point vector

    return std_logic_vector;

  alias to_StdLogicVector is to_slv [UNRESOLVED_ufixed

                                     return std_logic_vector];

  alias to_Std_Logic_Vector is to_slv [UNRESOLVED_ufixed

                                       return std_logic_vector];



  function to_slv (

    arg : UNRESOLVED_sfixed)            -- fixed point vector

    return std_logic_vector;

  alias to_StdLogicVector is to_slv [UNRESOLVED_sfixed

                                     return std_logic_vector];

  alias to_Std_Logic_Vector is to_slv [UNRESOLVED_sfixed

                                       return std_logic_vector];



  function to_sulv (

    arg : UNRESOLVED_ufixed)            -- fixed point vector

    return std_ulogic_vector;

  alias to_StdULogicVector is to_sulv [UNRESOLVED_ufixed

                                       return std_ulogic_vector];

  alias to_Std_ULogic_Vector is to_sulv [UNRESOLVED_ufixed

                                         return std_ulogic_vector];



  function to_sulv (

    arg : UNRESOLVED_sfixed)            -- fixed point vector

    return std_ulogic_vector;

  alias to_StdULogicVector is to_sulv [UNRESOLVED_sfixed

                                       return std_ulogic_vector];

  alias to_Std_ULogic_Vector is to_sulv [UNRESOLVED_sfixed

                                         return std_ulogic_vector];



  function to_ufixed (

    arg : std_ulogic_vector;            -- shifted vector

    constant left_index : integer;

    constant right_index : integer)

    return UNRESOLVED_ufixed;



  function to_ufixed (

    arg : std_ulogic_vector;            -- shifted vector

    size_res : UNRESOLVED_ufixed)       -- for size only

    return UNRESOLVED_ufixed;



  function to_sfixed (

    arg : std_ulogic_vector;            -- shifted vector

    constant left_index : integer;

    constant right_index : integer)

    return UNRESOLVED_sfixed;



  function to_sfixed (

    arg : std_ulogic_vector;            -- shifted vector

    size_res : UNRESOLVED_sfixed)       -- for size only

    return UNRESOLVED_sfixed;



  -- As a concession to those who use a graphical DSP environment,

  -- these functions take parameters in those tools format and create

  -- fixed point numbers.  These functions are designed to convert from

  -- a std_logic_vector to the VHDL fixed point format using the conventions

  -- of these packages.  In a pure VHDL environment you should use the

  -- "to_ufixed" and "to_sfixed" routines.



  -- unsigned fixed point

  function to_UFix (

    arg : std_ulogic_vector;

    width : natural;                    -- width of vector

    fraction : natural)                 -- width of fraction

    return UNRESOLVED_ufixed;



  -- signed fixed point

  function to_SFix (

    arg : std_ulogic_vector;

    width : natural;                    -- width of vector

    fraction : natural)                 -- width of fraction

    return UNRESOLVED_sfixed;



  -- finding the bounds of a number.  These functions can be used like this:

  -- signal xxx : ufixed (7 downto -3);

  -- -- Which is the same as "ufixed (UFix_high (11,3) downto UFix_low(11,3))"

  -- signal yyy : ufixed (UFix_high (11, 3, "+", 11, 3)

  --               downto UFix_low(11, 3, "+", 11, 3));

  -- Where "11" is the width of xxx (xxx'length),

  -- and 3 is the lower bound (abs (xxx'low))

  -- In a pure VHDL environment use "ufixed_high" and "ufixed_low"



  function UFix_high (width, fraction : natural;

                      operation : character := 'X';

                      width2, fraction2 : natural := 0)

    return integer;



  function UFix_low (width, fraction : natural;

                     operation : character := 'X';

                     width2, fraction2 : natural := 0)

    return integer;



  -- Same as above but for signed fixed point.  Note that the width

  -- of a signed fixed point number ignores the sign bit, thus

  -- width = sxxx'length-1



  function SFix_high (width, fraction : natural;

                      operation : character := 'X';

                      width2, fraction2 : natural := 0)

    return integer;



  function SFix_low (width, fraction : natural;

                     operation : character := 'X';

                     width2, fraction2 : natural := 0)

    return integer;

-- rtl_synthesis off

-- pragma synthesis_off

  --===========================================================================

  -- string and textio Functions

  --===========================================================================



  -- purpose: writes fixed point into a line

  procedure WRITE (

    L : inout line;                     -- input line

    VALUE : in UNRESOLVED_ufixed;       -- fixed point input

    JUSTIFIED : in side := right;

    FIELD : in WIDTH := 0);



  -- purpose: writes fixed point into a line

  procedure WRITE (

    L : inout line;                     -- input line

    VALUE : in UNRESOLVED_sfixed;       -- fixed point input

    JUSTIFIED : in side := right;

    FIELD : in WIDTH := 0);



  procedure READ(L : inout line;

                 VALUE : out UNRESOLVED_ufixed);



  procedure READ(L : inout line;

                 VALUE : out UNRESOLVED_ufixed;

                 GOOD : out boolean);



  procedure READ(L : inout line;

                 VALUE : out UNRESOLVED_sfixed);



  procedure READ(L : inout line;

                 VALUE : out UNRESOLVED_sfixed;

                 GOOD : out boolean);



  alias bwrite is WRITE [line, UNRESOLVED_ufixed, side, width];

  alias bwrite is WRITE [line, UNRESOLVED_sfixed, side, width];

  alias bread is READ [line, UNRESOLVED_ufixed];

  alias bread is READ [line, UNRESOLVED_ufixed, boolean];

  alias bread is READ [line, UNRESOLVED_sfixed];

  alias bread is READ [line, UNRESOLVED_sfixed, boolean];

  alias BINARY_WRITE is WRITE [line, UNRESOLVED_ufixed, side, width];

  alias BINARY_WRITE is WRITE [line, UNRESOLVED_sfixed, side, width];

  alias BINARY_READ is READ [line, UNRESOLVED_ufixed, boolean];

  alias BINARY_READ is READ [line, UNRESOLVED_ufixed];

  alias BINARY_READ is READ [line, UNRESOLVED_sfixed, boolean];

  alias BINARY_READ is READ [line, UNRESOLVED_sfixed];



  -- octal read and write

  procedure OWRITE (

    L : inout line;                     -- input line

    VALUE : in UNRESOLVED_ufixed;       -- fixed point input

    JUSTIFIED : in side := right;

    FIELD : in WIDTH := 0);



  procedure OWRITE (

    L : inout line;                     -- input line

    VALUE : in UNRESOLVED_sfixed;       -- fixed point input

    JUSTIFIED : in side := right;

    FIELD : in WIDTH := 0);



  procedure OREAD(L : inout line;

                  VALUE : out UNRESOLVED_ufixed);



  procedure OREAD(L : inout line;

                  VALUE : out UNRESOLVED_ufixed;

                  GOOD : out boolean);



  procedure OREAD(L : inout line;

                  VALUE : out UNRESOLVED_sfixed);



  procedure OREAD(L : inout line;

                  VALUE : out UNRESOLVED_sfixed;

                  GOOD : out boolean);

  alias OCTAL_READ is OREAD [line, UNRESOLVED_ufixed, boolean];

  alias OCTAL_READ is OREAD [line, UNRESOLVED_ufixed];

  alias OCTAL_READ is OREAD [line, UNRESOLVED_sfixed, boolean];

  alias OCTAL_READ is OREAD [line, UNRESOLVED_sfixed];

  alias OCTAL_WRITE is OWRITE [line, UNRESOLVED_ufixed, side, WIDTH];

  alias OCTAL_WRITE is OWRITE [line, UNRESOLVED_sfixed, side, WIDTH];



  -- hex read and write

  procedure HWRITE (

    L : inout line;                     -- input line

    VALUE : in UNRESOLVED_ufixed;       -- fixed point input

    JUSTIFIED : in side := right;

    FIELD : in WIDTH := 0);



  -- purpose: writes fixed point into a line

  procedure HWRITE (

    L : inout line;                     -- input line

    VALUE : in UNRESOLVED_sfixed;       -- fixed point input

    JUSTIFIED : in side := right;

    FIELD : in WIDTH := 0);



  procedure HREAD(L : inout line;

                  VALUE : out UNRESOLVED_ufixed);



  procedure HREAD(L : inout line;

                  VALUE : out UNRESOLVED_ufixed;

                  GOOD : out boolean);



  procedure HREAD(L : inout line;

                  VALUE : out UNRESOLVED_sfixed);



  procedure HREAD(L : inout line;

                  VALUE : out UNRESOLVED_sfixed;

                  GOOD : out boolean);

  alias HEX_READ is HREAD [line, UNRESOLVED_ufixed, boolean];

  alias HEX_READ is HREAD [line, UNRESOLVED_sfixed, boolean];

  alias HEX_READ is HREAD [line, UNRESOLVED_ufixed];

  alias HEX_READ is HREAD [line, UNRESOLVED_sfixed];

  alias HEX_WRITE is HWRITE [line, UNRESOLVED_ufixed, side, WIDTH];

  alias HEX_WRITE is HWRITE [line, UNRESOLVED_sfixed, side, WIDTH];



  -- returns a string, useful for:

  -- assert (x = y) report "error found " & to_string(x) severity error;

  function to_string (value : UNRESOLVED_ufixed) return string;

  alias to_bstring is to_string [UNRESOLVED_ufixed return string];

  alias TO_BINARY_STRING is TO_STRING [UNRESOLVED_ufixed return string];



  function to_ostring (value : UNRESOLVED_ufixed) return string;

  alias TO_OCTAL_STRING is TO_OSTRING [UNRESOLVED_ufixed return string];



  function to_hstring (value : UNRESOLVED_ufixed) return string;

  alias TO_HEX_STRING is TO_HSTRING [UNRESOLVED_ufixed return string];



  function to_string (value : UNRESOLVED_sfixed) return string;

  alias to_bstring is to_string [UNRESOLVED_sfixed return string];

  alias TO_BINARY_STRING is TO_STRING [UNRESOLVED_sfixed return string];



  function to_ostring (value : UNRESOLVED_sfixed) return string;

  alias TO_OCTAL_STRING is TO_OSTRING [UNRESOLVED_sfixed return string];



  function to_hstring (value : UNRESOLVED_sfixed) return string;

  alias TO_HEX_STRING is TO_HSTRING [UNRESOLVED_sfixed return string];



  -- From string functions allow you to convert a string into a fixed

  -- point number.  Example:

  --  signal uf1 : ufixed (3 downto -3);

  --  uf1 <= from_string ("0110.100", uf1'high, uf1'low); -- 6.5

  -- The "." is optional in this syntax, however it exist and is

  -- in the wrong location an error is produced.  Overflow will

  -- result in saturation.



  function from_string (

    bstring : string;                   -- binary string

    constant left_index : integer;

    constant right_index : integer)

    return UNRESOLVED_ufixed;

  alias from_bstring is from_string [string, integer, integer

                                     return UNRESOLVED_ufixed];

  alias from_binary_string is from_string [string, integer, integer

                                           return UNRESOLVED_ufixed];



  -- Octal and hex conversions work as follows:

  -- uf1 <= from_hstring ("6.8", 3, -3); -- 6.5 (bottom zeros dropped)

  -- uf1 <= from_ostring ("06.4", 3, -3); -- 6.5 (top zeros dropped)



  function from_ostring (

    ostring : string;                   -- Octal string

    constant left_index : integer;

    constant right_index : integer)

    return UNRESOLVED_ufixed;

  alias from_octal_string is from_ostring [string, integer, integer

                                           return UNRESOLVED_ufixed];



  function from_hstring (

    hstring : string;                   -- hex string

    constant left_index : integer;

    constant right_index : integer)

    return UNRESOLVED_ufixed;

  alias from_hex_string is from_hstring [string, integer, integer

                                         return UNRESOLVED_ufixed];



  function from_string (

    bstring : string;                   -- binary string

    constant left_index : integer;

    constant right_index : integer)

    return UNRESOLVED_sfixed;

  alias from_bstring is from_string [string, integer, integer

                                     return UNRESOLVED_sfixed];

  alias from_binary_string is from_string [string, integer, integer

                                           return UNRESOLVED_sfixed];



  function from_ostring (

    ostring : string;                   -- Octal string

    constant left_index : integer;

    constant right_index : integer)

    return UNRESOLVED_sfixed;

  alias from_octal_string is from_ostring [string, integer, integer

                                           return UNRESOLVED_sfixed];



  function from_hstring (

    hstring : string;                   -- hex string

    constant left_index : integer;

    constant right_index : integer)

    return UNRESOLVED_sfixed;

  alias from_hex_string is from_hstring [string, integer, integer

                                         return UNRESOLVED_sfixed];



  -- Same as above, "size_res" is used for it's range only.

  function from_string (

    bstring : string;                   -- binary string

    size_res : UNRESOLVED_ufixed)

    return UNRESOLVED_ufixed;

  alias from_bstring is from_string [string, UNRESOLVED_ufixed

                                     return UNRESOLVED_ufixed];

  alias from_binary_string is from_string [string, UNRESOLVED_ufixed

                                           return UNRESOLVED_ufixed];



  function from_ostring (

    ostring : string;                   -- Octal string

    size_res : UNRESOLVED_ufixed)

    return UNRESOLVED_ufixed;

  alias from_octal_string is from_ostring [string, UNRESOLVED_ufixed

                                           return UNRESOLVED_ufixed];



  function from_hstring (

    hstring : string;                   -- hex string

    size_res : UNRESOLVED_ufixed)

    return UNRESOLVED_ufixed;

  alias from_hex_string is from_hstring [string, UNRESOLVED_ufixed

                                         return UNRESOLVED_ufixed];



  function from_string (

    bstring : string;                   -- binary string

    size_res : UNRESOLVED_sfixed)

    return UNRESOLVED_sfixed;

  alias from_bstring is from_string [string, UNRESOLVED_sfixed

                                     return UNRESOLVED_sfixed];

  alias from_binary_string is from_string [string, UNRESOLVED_sfixed

                                           return UNRESOLVED_sfixed];



  function from_ostring (

    ostring : string;                   -- Octal string

    size_res : UNRESOLVED_sfixed)

    return UNRESOLVED_sfixed;

  alias from_octal_string is from_ostring [string, UNRESOLVED_sfixed

                                           return UNRESOLVED_sfixed];



  function from_hstring (

    hstring : string;                   -- hex string

    size_res : UNRESOLVED_sfixed)

    return UNRESOLVED_sfixed;

  alias from_hex_string is from_hstring [string, UNRESOLVED_sfixed

                                         return UNRESOLVED_sfixed];



  -- Direct conversion functions.  Example:

  --  signal uf1 : ufixed (3 downto -3);

  --  uf1 <= from_string ("0110.100"); -- 6.5

  -- In this case the "." is not optional, and the size of

  -- the output must match exactly.



  function from_string (

    bstring : string)                   -- binary string

    return UNRESOLVED_ufixed;

  alias from_bstring is from_string [string return UNRESOLVED_ufixed];

  alias from_binary_string is from_string [string return UNRESOLVED_ufixed];



  -- Direct octal and hex conversion functions.  In this case

  -- the string lengths must match.  Example:

  -- signal sf1 := sfixed (5 downto -3);

  -- sf1 <= from_ostring ("71.4") -- -6.5



  function from_ostring (

    ostring : string)                   -- Octal string

    return UNRESOLVED_ufixed;

  alias from_octal_string is from_ostring [string return UNRESOLVED_ufixed];



  function from_hstring (

    hstring : string)                   -- hex string

    return UNRESOLVED_ufixed;

  alias from_hex_string is from_hstring [string return UNRESOLVED_ufixed];



  function from_string (

    bstring : string)                   -- binary string

    return UNRESOLVED_sfixed;

  alias from_bstring is from_string [string return UNRESOLVED_sfixed];

  alias from_binary_string is from_string [string return UNRESOLVED_sfixed];



  function from_ostring (

    ostring : string)                   -- Octal string

    return UNRESOLVED_sfixed;

  alias from_octal_string is from_ostring [string return UNRESOLVED_sfixed];



  function from_hstring (

    hstring : string)                   -- hex string

    return UNRESOLVED_sfixed;

  alias from_hex_string is from_hstring [string return UNRESOLVED_sfixed];

-- rtl_synthesis on

-- pragma synthesis_on



  -- IN VHDL-2006 std_logic_vector is a subtype of std_ulogic_vector, so these

  -- extra functions are needed for compatability.

  function to_ufixed (

    arg : std_logic_vector;             -- shifted vector

    constant left_index : integer;

    constant right_index : integer)

    return UNRESOLVED_ufixed;



  function to_ufixed (

    arg : std_logic_vector;             -- shifted vector

    size_res : UNRESOLVED_ufixed)       -- for size only

    return UNRESOLVED_ufixed;



  function to_sfixed (

    arg : std_logic_vector;             -- shifted vector

    constant left_index : integer;

    constant right_index : integer)

    return UNRESOLVED_sfixed;



  function to_sfixed (

    arg : std_logic_vector;             -- shifted vector

    size_res : UNRESOLVED_sfixed)       -- for size only

    return UNRESOLVED_sfixed;



  -- unsigned fixed point

  function to_UFix (

    arg : std_logic_vector;

    width : natural;                    -- width of vector

    fraction : natural)                 -- width of fraction

    return UNRESOLVED_ufixed;



  -- signed fixed point

  function to_SFix (

    arg : std_logic_vector;

    width : natural;                    -- width of vector

    fraction : natural)                 -- width of fraction

    return UNRESOLVED_sfixed;



end package fixed_pkg;

-------------------------------------------------------------------------------

-- Proposed package body for the VHDL-200x-FT fixed_pkg package

-- (Fixed point math package)

-- This package body supplies a recommended implementation of these functions

-- Version    : $Revision: 414 $

-- Date       : $Date: 2015-09-23 17:12:41 +0200 (Wed, 23 Sep 2015) $

--

--  Created for VHDL-200X-ft, David Bishop (dbishop@vhdl.org)

-------------------------------------------------------------------------------

library IEEE;

use IEEE.MATH_REAL.all;



package body fixed_pkg is

  -- Author David Bishop (dbishop@vhdl.org)

  -- Other contributers: Jim Lewis, Yannick Grugni, Ryan W. Hilton

  -- null array constants

  constant NAUF : UNRESOLVED_ufixed (0 downto 1) := (others => '0');

  constant NASF : UNRESOLVED_sfixed (0 downto 1) := (others => '0');

  constant NSLV : std_ulogic_vector (0 downto 1) := (others => '0');



  -- This differed constant will tell you if the package body is synthesizable

  -- or implemented as real numbers, set to "true" if synthesizable.

  constant fixedsynth_or_real : boolean := true;



  -- %%% Replicated functions

  function maximum (

    l, r : integer)                     -- inputs

    return integer is

  begin  -- function max

    if l > r then return l;

    else return r;

    end if;

  end function maximum;



  function minimum (

    l, r : integer)                     -- inputs

    return integer is

  begin  -- function min

    if l > r then return r;

    else return l;

    end if;

  end function minimum;



  function "sra" (arg : signed; count : integer)

    return signed is

  begin

    if (COUNT >= 0) then

      return SHIFT_RIGHT(arg, count);

    else

      return SHIFT_LEFT(arg, -count);

    end if;

  end function "sra";



  function or_reduce (arg : std_ulogic_vector)

    return std_logic is

    variable Upper, Lower : std_ulogic;

    variable Half : integer;

    variable BUS_int : std_ulogic_vector (arg'length - 1 downto 0);

    variable Result : std_ulogic;

  begin

    if (arg'length < 1) then            -- In the case of a NULL range

      Result := '0';

    else

      BUS_int := to_ux01 (arg);

      if (BUS_int'length = 1) then

        Result := BUS_int (BUS_int'left);

      elsif (BUS_int'length = 2) then

        Result := BUS_int (BUS_int'right) or BUS_int (BUS_int'left);

      else

        Half := (BUS_int'length + 1) / 2 + BUS_int'right;

        Upper := or_reduce (BUS_int (BUS_int'left downto Half));

        Lower := or_reduce (BUS_int (Half - 1 downto BUS_int'right));

        Result := Upper or Lower;

      end if;

    end if;

    return Result;

  end function or_reduce;



  -- purpose: AND all of the bits in a vector together

  -- This is a copy of the proposed "and_reduce" from 1076.3

  function and_reduce (arg : std_ulogic_vector)

    return std_logic is

    variable Upper, Lower : std_ulogic;

    variable Half : integer;

    variable BUS_int : std_ulogic_vector (arg'length - 1 downto 0);

    variable Result : std_ulogic;

  begin

    if (arg'length < 1) then            -- In the case of a NULL range

      Result := '1';

    else

      BUS_int := to_ux01 (arg);

      if (BUS_int'length = 1) then

        Result := BUS_int (BUS_int'left);

      elsif (BUS_int'length = 2) then

        Result := BUS_int (BUS_int'right) and BUS_int (BUS_int'left);

      else

        Half := (BUS_int'length + 1) / 2 + BUS_int'right;

        Upper := and_reduce (BUS_int (BUS_int'left downto Half));

        Lower := and_reduce (BUS_int (Half - 1 downto BUS_int'right));

        Result := Upper and Lower;

      end if;

    end if;

    return Result;

  end function and_reduce;



  function xor_reduce (arg : std_ulogic_vector) return std_ulogic is

    variable Upper, Lower : std_ulogic;

    variable Half : integer;

    variable BUS_int : std_ulogic_vector (arg'length - 1 downto 0);

    variable Result : std_ulogic := '0';  -- In the case of a NULL range

  begin

    if (arg'length >= 1) then

      BUS_int := to_ux01 (arg);

      if (BUS_int'length = 1) then

        Result := BUS_int (BUS_int'left);

      elsif (BUS_int'length = 2) then

        Result := BUS_int(BUS_int'right) xor BUS_int(BUS_int'left);

      else

        Half := (BUS_int'length + 1) / 2 + BUS_int'right;

        Upper := xor_reduce (BUS_int (BUS_int'left downto Half));

        Lower := xor_reduce (BUS_int (Half - 1 downto BUS_int'right));

        Result := Upper xor Lower;

      end if;

    end if;

    return Result;

  end function xor_reduce;



  function nand_reduce(arg : std_ulogic_vector) return std_ulogic is

  begin

    return not and_reduce (arg);

  end function nand_reduce;

  function nor_reduce(arg : std_ulogic_vector) return std_ulogic is

  begin

    return not or_reduce (arg);

  end function nor_reduce;

  function xnor_reduce(arg : std_ulogic_vector) return std_ulogic is

  begin

    return not xor_reduce (arg);

  end function xnor_reduce;

  -- Match table, copied form new std_logic_1164

  type stdlogic_table is array(std_ulogic, std_ulogic) of std_ulogic;

  constant match_logic_table : stdlogic_table := (

    -----------------------------------------------------

    -- U    X    0    1    Z    W    L    H    -         |   |  

    -----------------------------------------------------

    ('U', 'U', 'U', 'U', 'U', 'U', 'U', 'U', '1'),  -- | U |

    ('U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', '1'),  -- | X |

    ('U', 'X', '1', '0', 'X', 'X', '1', '0', '1'),  -- | 0 |

    ('U', 'X', '0', '1', 'X', 'X', '0', '1', '1'),  -- | 1 |

    ('U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', '1'),  -- | Z |

    ('U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', '1'),  -- | W |

    ('U', 'X', '1', '0', 'X', 'X', '1', '0', '1'),  -- | L |

    ('U', 'X', '0', '1', 'X', 'X', '0', '1', '1'),  -- | H |

    ('1', '1', '1', '1', '1', '1', '1', '1', '1')  -- | - |

    );



  constant no_match_logic_table : stdlogic_table := (

    -----------------------------------------------------

    -- U    X    0    1    Z    W    L    H    -         |   |  

    -----------------------------------------------------

    ('U', 'U', 'U', 'U', 'U', 'U', 'U', 'U', '0'),  -- | U |

    ('U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', '0'),  -- | X |

    ('U', 'X', '0', '1', 'X', 'X', '0', '1', '0'),  -- | 0 |

    ('U', 'X', '1', '0', 'X', 'X', '1', '0', '0'),  -- | 1 |

    ('U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', '0'),  -- | Z |

    ('U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', '0'),  -- | W |

    ('U', 'X', '0', '1', 'X', 'X', '0', '1', '0'),  -- | L |

    ('U', 'X', '1', '0', 'X', 'X', '1', '0', '0'),  -- | H |

    ('0', '0', '0', '0', '0', '0', '0', '0', '0')  -- | - |

    );



  -------------------------------------------------------------------

  -- ?= functions, Similar to "std_match", but returns "std_ulogic".

  -------------------------------------------------------------------

  function \?=\ (l, r : std_ulogic) return std_ulogic is

  begin

    return match_logic_table (l, r);

  end function \?=\;

  function \?/=\ (l, r : std_ulogic) return std_ulogic is

  begin

    return no_match_logic_table (l, r);

  end function \?/=\;

  -- "?=" operator is similar to "std_match", but returns a std_ulogic..

  -- Id: M.2B

  function \?=\ (L, R : unsigned) return std_ulogic is

    constant L_LEFT : integer := L'length-1;

    constant R_LEFT : integer := R'length-1;

    alias XL : unsigned(L_LEFT downto 0) is L;

    alias XR : unsigned(R_LEFT downto 0) is R;

    constant SIZE : natural := MAXIMUM(L'length, R'length);

    variable LX : unsigned(SIZE-1 downto 0);

    variable RX : unsigned(SIZE-1 downto 0);

    variable result, result1 : std_ulogic;  -- result

  begin

    -- Logically identical to an "=" operator.

    if ((L'length < 1) or (R'length < 1)) then

      assert NO_WARNING

        report "NUMERIC_STD.""?="": null detected, returning X"

        severity warning;

      return 'X';

    else

      LX := RESIZE(XL, SIZE);

      RX := RESIZE(XR, SIZE);

      result := '1';

      for i in LX'low to LX'high loop

        result1 := \?=\(LX(i), RX(i));

        if result1 = 'U' then

          return 'U';

        elsif result1 = 'X' or result = 'X' then

          result := 'X';

        else

          result := result and result1;

        end if;

      end loop;

      return result;

    end if;

  end function \?=\;



  -- Id: M.3B

  function \?=\ (L, R : signed) return std_ulogic is

    constant L_LEFT : integer := L'length-1;

    constant R_LEFT : integer := R'length-1;

    alias XL : signed(L_LEFT downto 0) is L;

    alias XR : signed(R_LEFT downto 0) is R;

    constant SIZE : natural := MAXIMUM(L'length, R'length);

    variable LX : signed(SIZE-1 downto 0);

    variable RX : signed(SIZE-1 downto 0);

    variable result, result1 : std_ulogic;  -- result

  begin  -- ?=

    if ((L'length < 1) or (R'length < 1)) then

      assert NO_WARNING

        report "NUMERIC_STD.""?="": null detected, returning X"

        severity warning;

      return 'X';

    else

      LX := RESIZE(XL, SIZE);

      RX := RESIZE(XR, SIZE);

      result := '1';

      for i in LX'low to LX'high loop

        result1 := \?=\ (LX(i), RX(i));

        if result1 = 'U' then

          return 'U';

        elsif result1 = 'X' or result = 'X' then

          result := 'X';

        else

          result := result and result1;

        end if;

      end loop;

      return result;

    end if;

  end function \?=\;



  function \?/=\ (L, R : unsigned) return std_ulogic is

    constant L_LEFT : integer := L'length-1;

    constant R_LEFT : integer := R'length-1;

    alias XL : unsigned(L_LEFT downto 0) is L;

    alias XR : unsigned(R_LEFT downto 0) is R;

    constant SIZE : natural := MAXIMUM(L'length, R'length);

    variable LX : unsigned(SIZE-1 downto 0);

    variable RX : unsigned(SIZE-1 downto 0);

    variable result, result1 : std_ulogic;  -- result

  begin  -- ?=

    if ((L'length < 1) or (R'length < 1)) then

      assert NO_WARNING

        report "NUMERIC_STD.""?/="": null detected, returning X"

        severity warning;

      return 'X';

    else

      LX := RESIZE(XL, SIZE);

      RX := RESIZE(XR, SIZE);

      result := '0';

      for i in LX'low to LX'high loop

        result1 := \?/=\ (LX(i), RX(i));

        if result1 = 'U' then

          result := 'U';

        elsif result1 = 'X' or result = 'X' then

          result := 'X';

        else

          result := result or result1;

        end if;

      end loop;

      return result;

    end if;

  end function \?/=\;



  function \?/=\ (L, R : signed) return std_ulogic is

    constant L_LEFT : integer := L'length-1;

    constant R_LEFT : integer := R'length-1;

    alias XL : signed(L_LEFT downto 0) is L;

    alias XR : signed(R_LEFT downto 0) is R;

    constant SIZE : natural := MAXIMUM(L'length, R'length);

    variable LX : signed(SIZE-1 downto 0);

    variable RX : signed(SIZE-1 downto 0);

    variable result, result1 : std_ulogic;  -- result

  begin  -- ?=

    if ((L'length < 1) or (R'length < 1)) then

      assert NO_WARNING

        report "NUMERIC_STD.""?/="": null detected, returning X"

        severity warning;

      return 'X';

    else

      LX := RESIZE(XL, SIZE);

      RX := RESIZE(XR, SIZE);

      result := '0';

      for i in LX'low to LX'high loop

        result1 := \?/=\ (LX(i), RX(i));

        if result1 = 'U' then

          return 'U';

        elsif result1 = 'X' or result = 'X' then

          result := 'X';

        else

          result := result or result1;

        end if;

      end loop;

      return result;

    end if;

  end function \?/=\;

  function Is_X (s : unsigned) return boolean is

  begin

    return Is_X (std_logic_vector (s));

  end function Is_X;



  function Is_X (s : signed) return boolean is

  begin

    return Is_X (std_logic_vector (s));

  end function Is_X;

  function \?>\ (L, R : unsigned) return std_ulogic is

  begin

    if ((l'length < 1) or (r'length < 1)) then

      assert NO_WARNING

        report "NUMERIC_STD.""?>"": null detected, returning X"

        severity warning;

      return 'X';

    else

      for i in L'range loop

        if L(i) = '-' then

          report "NUMERIC_STD.""?>"": '-' found in compare string"

            severity error;

          return 'X';

        end if;

      end loop;

      for i in R'range loop

        if R(i) = '-' then

          report "NUMERIC_STD.""?>"": '-' found in compare string"

            severity error;

          return 'X';

        end if;

      end loop;

      if is_x(l) or is_x(r) then

        return 'X';

      elsif l > r then

        return '1';

      else

        return '0';

      end if;

    end if;

  end function \?>\;

  -- %%% function "?>" (L, R : UNSIGNED) return std_ulogic is

  -- %%% end function "?>"\;

  function \?>\ (L, R : signed) return std_ulogic is

  begin

    if ((l'length < 1) or (r'length < 1)) then

      assert NO_WARNING

        report "NUMERIC_STD.""?>"": null detected, returning X"

        severity warning;

      return 'X';

    else

      for i in L'range loop

        if L(i) = '-' then

          report "NUMERIC_STD.""?>"": '-' found in compare string"

            severity error;

          return 'X';

        end if;

      end loop;

      for i in R'range loop

        if R(i) = '-' then

          report "NUMERIC_STD.""?>"": '-' found in compare string"

            severity error;

          return 'X';

        end if;

      end loop;

      if is_x(l) or is_x(r) then

        return 'X';

      elsif l > r then

        return '1';

      else

        return '0';

      end if;

    end if;

  end function \?>\;

  function \?>=\ (L, R : unsigned) return std_ulogic is

  begin

    if ((l'length < 1) or (r'length < 1)) then

      assert NO_WARNING

        report "NUMERIC_STD.""?>="": null detected, returning X"

        severity warning;

      return 'X';

    else

      for i in L'range loop

        if L(i) = '-' then

          report "NUMERIC_STD.""?>="": '-' found in compare string"

            severity error;

          return 'X';

        end if;

      end loop;

      for i in R'range loop

        if R(i) = '-' then

          report "NUMERIC_STD.""?>="": '-' found in compare string"

            severity error;

          return 'X';

        end if;

      end loop;

      if is_x(l) or is_x(r) then

        return 'X';

      elsif l >= r then

        return '1';

      else

        return '0';

      end if;

    end if;

  end function \?>=\;

  -- %%% function "?>=" (L, R : UNSIGNED) return std_ulogic is

  -- %%% end function "?>=";

  function \?>=\ (L, R : signed) return std_ulogic is

  begin

    if ((l'length < 1) or (r'length < 1)) then

      assert NO_WARNING

        report "NUMERIC_STD.""?>="": null detected, returning X"

        severity warning;

      return 'X';

    else

      for i in L'range loop

        if L(i) = '-' then

          report "NUMERIC_STD.""?>="": '-' found in compare string"

            severity error;

          return 'X';

        end if;

      end loop;

      for i in R'range loop

        if R(i) = '-' then

          report "NUMERIC_STD.""?>="": '-' found in compare string"

            severity error;

          return 'X';

        end if;

      end loop;

      if is_x(l) or is_x(r) then

        return 'X';

      elsif l >= r then

        return '1';

      else

        return '0';

      end if;

    end if;

  end function \?>=\;

  function \?<\ (L, R : unsigned) return std_ulogic is

  begin

    if ((l'length < 1) or (r'length < 1)) then

      assert NO_WARNING

        report "NUMERIC_STD.""?<"": null detected, returning X"

        severity warning;

      return 'X';

    else

      for i in L'range loop

        if L(i) = '-' then

          report "NUMERIC_STD.""?<"": '-' found in compare string"

            severity error;

          return 'X';

        end if;

      end loop;

      for i in R'range loop

        if R(i) = '-' then

          report "NUMERIC_STD.""?<"": '-' found in compare string"

            severity error;

          return 'X';

        end if;

      end loop;

      if is_x(l) or is_x(r) then

        return 'X';

      elsif l < r then

        return '1';

      else

        return '0';

      end if;

    end if;

  end function \?<\;

  -- %%% function "?<" (L, R : UNSIGNED) return std_ulogic is

  -- %%% end function "?<";

  function \?<\ (L, R : signed) return std_ulogic is

  begin

    if ((l'length < 1) or (r'length < 1)) then

      assert NO_WARNING

        report "NUMERIC_STD.""?<"": null detected, returning X"

        severity warning;

      return 'X';

    else

      for i in L'range loop

        if L(i) = '-' then

          report "NUMERIC_STD.""?<"": '-' found in compare string"

            severity error;

          return 'X';

        end if;

      end loop;

      for i in R'range loop

        if R(i) = '-' then

          report "NUMERIC_STD.""?<"": '-' found in compare string"

            severity error;

          return 'X';

        end if;

      end loop;

      if is_x(l) or is_x(r) then

        return 'X';

      elsif l < r then

        return '1';

      else

        return '0';

      end if;

    end if;

  end function \?<\;

  function \?<=\ (L, R : unsigned) return std_ulogic is

  begin

    if ((l'length < 1) or (r'length < 1)) then

      assert NO_WARNING

        report "NUMERIC_STD.""?<="": null detected, returning X"

        severity warning;

      return 'X';

    else

      for i in L'range loop

        if L(i) = '-' then

          report "NUMERIC_STD.""?<="": '-' found in compare string"

            severity error;

          return 'X';

        end if;

      end loop;

      for i in R'range loop

        if R(i) = '-' then

          report "NUMERIC_STD.""?<="": '-' found in compare string"

            severity error;

          return 'X';

        end if;

      end loop;

      if is_x(l) or is_x(r) then

        return 'X';

      elsif l <= r then

        return '1';

      else

        return '0';

      end if;

    end if;

  end function \?<=\;

  -- %%% function "?<=" (L, R : UNSIGNED) return std_ulogic is

  -- %%% end function "?<=";

  function \?<=\ (L, R : signed) return std_ulogic is

  begin

    if ((l'length < 1) or (r'length < 1)) then

      assert NO_WARNING

        report "NUMERIC_STD.""?<="": null detected, returning X"

        severity warning;

      return 'X';

    else

      for i in L'range loop

        if L(i) = '-' then

          report "NUMERIC_STD.""?<="": '-' found in compare string"

            severity error;

          return 'X';

        end if;

      end loop;

      for i in R'range loop

        if R(i) = '-' then

          report "NUMERIC_STD.""?<="": '-' found in compare string"

            severity error;

          return 'X';

        end if;

      end loop;

      if is_x(l) or is_x(r) then

        return 'X';

      elsif l <= r then

        return '1';

      else

        return '0';

      end if;

    end if;

  end function \?<=\;



-- %%% END replicated functions

  -- Special version of "minimum" to do some boundary checking without errors

  function mins (l, r : integer)

    return integer is

  begin  -- function mins

    if (L = integer'low or R = integer'low) then

      return 0;                         -- error condition, silent

    end if;

    return minimum (L, R);

  end function mins;



  -- Special version of "minimum" to do some boundary checking with errors

  function mine (l, r : integer)

    return integer is

  begin  -- function mine

    if (L = integer'low or R = integer'low) then

      report fixed_pkg'instance_name

        & " Unbounded number passed, was a literal used?"

        severity error;

      return 0;

    end if;

    return minimum (L, R);

  end function mine;



  -- The following functions are used only internally.  Every function

  -- calls "cleanvec" either directly or indirectly.

  -- purpose: Fixes "downto" problem and resolves meta states

  function cleanvec (

    arg : UNRESOLVED_sfixed)            -- input

    return UNRESOLVED_sfixed is

    constant left_index : integer := maximum(arg'left, arg'right);

    constant right_index : integer := mins(arg'left, arg'right);

    variable result : UNRESOLVED_sfixed (arg'range);

  begin  -- function cleanvec

    assert not (arg'ascending and (arg'low /= integer'low))

      report fixed_pkg'instance_name

      & " Vector passed using a ""to"" range, expected is ""downto"""

      severity error;

    return arg;

  end function cleanvec;



  -- purpose: Fixes "downto" problem and resolves meta states

  function cleanvec (

    arg : UNRESOLVED_ufixed)            -- input

    return UNRESOLVED_ufixed is

    constant left_index : integer := maximum(arg'left, arg'right);

    constant right_index : integer := mins(arg'left, arg'right);

    variable result : UNRESOLVED_ufixed (arg'range);

  begin  -- function cleanvec

    assert not (arg'ascending and (arg'low /= integer'low))

      report fixed_pkg'instance_name

      & " Vector passed using a ""to"" range, expected is ""downto"""

      severity error;

    return arg;

  end function cleanvec;



  -- Type convert a "unsigned" into a "ufixed", used internally

  function to_fixed (

    arg : unsigned;                     -- shifted vector

    constant left_index : integer;

    constant right_index : integer)

    return UNRESOLVED_ufixed is

    variable result : UNRESOLVED_ufixed (left_index downto right_index);

  begin  -- function to_fixed

    result := UNRESOLVED_ufixed(arg);

    return result;

  end function to_fixed;



  -- Type convert a "signed" into an "sfixed", used internally

  function to_fixed (

    arg : signed;                       -- shifted vector

    constant left_index : integer;

    constant right_index : integer)

    return UNRESOLVED_sfixed is

    variable result : UNRESOLVED_sfixed (left_index downto right_index);

  begin  -- function to_fixed

    result := UNRESOLVED_sfixed(arg);

    return result;

  end function to_fixed;



  -- Type convert a "ufixed" into an "unsigned", used internally

  function to_uns (

    arg : UNRESOLVED_ufixed)            -- fp vector

    return unsigned is

    subtype t is unsigned(arg'high - arg'low downto 0);

    variable slv : t;

  begin  -- function to_uns

    slv := t(arg);

    return slv;

  end function to_uns;



  -- Type convert an "sfixed" into a "signed", used internally

  function to_s (

    arg : UNRESOLVED_sfixed)            -- fp vector

    return signed is

    subtype t is signed(arg'high - arg'low downto 0);

    variable slv : t;

  begin  -- function to_s

    slv := t(arg);

    return slv;

  end function to_s;



  -- adds 1 to the LSB of the number

  procedure round_up (arg : in UNRESOLVED_ufixed;

                      result : out UNRESOLVED_ufixed;

                      overflowx : out boolean) is

    variable arguns, resuns : unsigned (arg'high-arg'low+1 downto 0)

      := (others => '0');

  begin  -- round_up

    arguns (arguns'high-1 downto 0) := to_uns (arg);

    resuns := arguns + 1;

    result := to_fixed(resuns(arg'high-arg'low

                              downto 0), arg'high, arg'low);

    overflowx := (resuns(resuns'high) = '1');

  end procedure round_up;



  -- adds 1 to the LSB of the number

  procedure round_up (arg : in UNRESOLVED_sfixed;

                      result : out UNRESOLVED_sfixed;

                      overflowx : out boolean) is

    variable args, ress : signed (arg'high-arg'low+1 downto 0);

  begin  -- round_up

    args (args'high-1 downto 0) := to_s (arg);

    args(args'high) := arg(arg'high);   -- sign extend

    ress := args + 1;

    result := to_fixed(ress (ress'high-1

                             downto 0), arg'high, arg'low);

    overflowx := ((arg(arg'high) /= ress(ress'high-1))

                  and (or_reduce (std_ulogic_vector(ress)) /= '0'));

  end procedure round_up;



  -- Rounding - Performs a "round_nearest" (IEEE 754) which rounds up

  -- when the remainder is > 0.5.  If the remainder IS 0.5 then if the

  -- bottom bit is a "1" it is rounded, otherwise it remains the same.

  function round_fixed (arg : UNRESOLVED_ufixed;

                        remainder : UNRESOLVED_ufixed;

                        overflow_style : fixed_overflow_style_type := fixed_overflow_style)

    return UNRESOLVED_ufixed is

    variable rounds : boolean;

    variable round_overflow : boolean;

    variable result : UNRESOLVED_ufixed (arg'range);

  begin

    rounds := false;

    if (remainder'length > 1) then

      if (remainder (remainder'high) = '1') then

        rounds := (arg(arg'low) = '1')

                  or (or_reduce (to_sulv(remainder(remainder'high-1 downto

                                                   remainder'low))) = '1');

      end if;

    else

      rounds := (arg(arg'low) = '1') and (remainder (remainder'high) = '1');

    end if;

    if rounds then

      round_up(arg => arg,

               result => result,

               overflowx => round_overflow);

    else

      result := arg;

    end if;

    if (overflow_style = fixed_saturate) and round_overflow then

      result := saturate (result'high, result'low);

    end if;

    return result;

  end function round_fixed;



  -- Rounding case statement

  function round_fixed (arg : UNRESOLVED_sfixed;

                        remainder : UNRESOLVED_sfixed;

                        overflow_style : fixed_overflow_style_type := fixed_overflow_style)

    return UNRESOLVED_sfixed is

    variable rounds : boolean;

    variable round_overflow : boolean;

    variable result : UNRESOLVED_sfixed (arg'range);

  begin

    rounds := false;

    if (remainder'length > 1) then

      if (remainder (remainder'high) = '1') then

        rounds := (arg(arg'low) = '1')

                  or (or_reduce (to_sulv(remainder(remainder'high-1 downto

                                                   remainder'low))) = '1');

      end if;

    else

      rounds := (arg(arg'low) = '1') and (remainder (remainder'high) = '1');

    end if;

    if rounds then

      round_up(arg => arg,

               result => result,

               overflowx => round_overflow);

    else

      result := arg;

    end if;

    if round_overflow then

      if (overflow_style = fixed_saturate) then

        if arg(arg'high) = '0' then

          result := saturate (result'high, result'low);

        else

          result := not saturate (result'high, result'low);

        end if;

        -- Sign bit not fixed when wrapping

      end if;

    end if;

    return result;

  end function round_fixed;



  -- converts an sfixed into a ufixed.  The output is the same length as the

  -- input, because abs("1000") = "1000" = 8.

  function to_ufixed (

    arg : UNRESOLVED_sfixed)

    return UNRESOLVED_ufixed

  is

    constant left_index : integer := arg'high;

    constant right_index : integer := mine(arg'low, arg'low);

    variable xarg : UNRESOLVED_sfixed(left_index+1 downto right_index);

    variable result : UNRESOLVED_ufixed(left_index downto right_index);

  begin

    if arg'length < 1 then

      return NAUF;

    end if;

    xarg := abs(arg);

    result := UNRESOLVED_ufixed (xarg (left_index downto right_index));

    return result;

  end function to_ufixed;



-----------------------------------------------------------------------------

-- Visible functions

-----------------------------------------------------------------------------



  -- Conversion functions.  These are needed for synthesis where typically

  -- the only input and output type is a std_logic_vector.

  function to_sulv (

    arg : UNRESOLVED_ufixed)            -- fixed point vector

    return std_ulogic_vector is

    variable result : std_ulogic_vector (arg'length-1 downto 0);

  begin

    if arg'length < 1 then

      return NSLV;

    end if;

    result := std_ulogic_vector (arg);

    return result;

  end function to_sulv;



  function to_sulv (

    arg : UNRESOLVED_sfixed)            -- fixed point vector

    return std_ulogic_vector is

    subtype aCONSTRAINED_STD_ULOGIC_VECTOR is std_ulogic_vector(arg'length-1 downto 0);

    variable result : aCONSTRAINED_STD_ULOGIC_VECTOR;

  begin

    if arg'length < 1 then

      return NSLV;

    end if;

    result := aCONSTRAINED_STD_ULOGIC_VECTOR (arg);

    return result;

  end function to_sulv;



  function to_slv (

    arg : UNRESOLVED_ufixed)            -- fixed point vector

    return std_logic_vector is

  begin

    return to_stdlogicvector(to_sulv(arg));

  end function to_slv;



  function to_slv (

    arg : UNRESOLVED_sfixed)            -- fixed point vector

    return std_logic_vector is

  begin

    return to_stdlogicvector(to_sulv(arg));

  end function to_slv;



  function to_ufixed (

    arg : std_ulogic_vector;            -- shifted vector

    constant left_index : integer;

    constant right_index : integer)

    return unresolved_ufixed is

    variable result : UNRESOLVED_ufixed (left_index downto right_index);

  begin

    if (arg'length < 1 or right_index > left_index) then

      return NAUF;

    end if;

    if (arg'length /= result'length) then

      report fixed_pkg'instance_name & "TO_UFIXED(SLV) "

        & "Vector lengths do not match.  Input length is "

        & integer'image(arg'length) & " and output will be "

        & integer'image(result'length) & " wide."

        severity error;

      return NAUF;

    else

      result := to_fixed (arg => unsigned(arg),

                          left_index => left_index,

                          right_index => right_index);

      return result;

    end if;

  end function to_ufixed;



  function to_sfixed (

    arg : std_ulogic_vector;            -- shifted vector

    constant left_index : integer;

    constant right_index : integer)

    return unresolved_sfixed is

    variable result : UNRESOLVED_sfixed (left_index downto right_index);

  begin

    if (arg'length < 1 or right_index > left_index) then

      return NASF;

    end if;

    if (arg'length /= result'length) then

      report fixed_pkg'instance_name & "TO_SFIXED(SLV) "

        & "Vector lengths do not match.  Input length is "

        & integer'image(arg'length) & " and output will be "

        & integer'image(result'length) & " wide."

        severity error;

      return NASF;

    else

      result := to_fixed (arg => signed(arg),

                          left_index => left_index,

                          right_index => right_index);

      return result;

    end if;

  end function to_sfixed;



  -- Two's complement number, Grows the vector by 1 bit.

  -- because "abs (1000.000) = 01000.000" or abs(-16) = 16.

  function "abs" (

    arg : UNRESOLVED_sfixed)            -- fixed point input

    return UNRESOLVED_sfixed is

    constant left_index : integer := arg'high;

    constant right_index : integer := mine(arg'low, arg'low);

    variable ressns : signed (arg'length downto 0);

    variable result : UNRESOLVED_sfixed (left_index+1 downto right_index);

  begin

    if (arg'length < 1 or result'length < 1) then

      return NASF;

    end if;

    ressns (arg'length-1 downto 0) := to_s (cleanvec (arg));

    ressns (arg'length) := ressns (arg'length-1);  -- expand sign bit

    result := to_fixed (abs(ressns), left_index+1, right_index);

    return result;

  end function "abs";



  -- also grows the vector by 1 bit.

  function "-" (

    arg : UNRESOLVED_sfixed)            -- fixed point input

    return UNRESOLVED_sfixed is

    constant left_index : integer := arg'high+1;

    constant right_index : integer := mine(arg'low, arg'low);

    variable ressns : signed (arg'length downto 0);

    variable result : UNRESOLVED_sfixed (left_index downto right_index);

  begin

    if (arg'length < 1 or result'length < 1) then

      return NASF;

    end if;

    ressns (arg'length-1 downto 0) := to_s (cleanvec(arg));

    ressns (arg'length) := ressns (arg'length-1);  -- expand sign bit

    result := to_fixed (-ressns, left_index, right_index);

    return result;

  end function "-";



  -- Addition

  function "+" (

    l, r : UNRESOLVED_ufixed)  -- ufixed(a downto b) + ufixed(c downto d) =

    return UNRESOLVED_ufixed is         -- ufixed(max(a,c)+1 downto min(b,d))

    constant left_index : integer := maximum(l'high, r'high)+1;

    constant right_index : integer := mine(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_ufixed (left_index downto right_index);

    variable result : UNRESOLVED_ufixed (left_index downto right_index);

    variable lslv, rslv : unsigned (left_index-right_index

                                    downto 0);

    variable result_slv : unsigned (left_index-right_index

                                    downto 0);

  begin

    if (l'length < 1 or r'length < 1 or result'length < 1) then

      return NAUF;

    end if;

    lresize := resize (l, left_index, right_index);

    rresize := resize (r, left_index, right_index);

    lslv := to_uns (lresize);

    rslv := to_uns (rresize);

    result_slv := lslv + rslv;

    result := to_fixed(result_slv, left_index, right_index);

    return result;

  end function "+";



  function "+" (

    l, r : UNRESOLVED_sfixed)  -- sfixed(a downto b) + sfixed(c downto d) = 

    return UNRESOLVED_sfixed is         -- sfixed(max(a,c)+1 downto min(b,d))

    constant left_index : integer := maximum(l'high, r'high)+1;

    constant right_index : integer := mine(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_sfixed (left_index downto right_index);

    variable result : UNRESOLVED_sfixed (left_index downto right_index);

    variable lslv, rslv : signed (left_index-right_index downto 0);

    variable result_slv : signed (left_index-right_index downto 0);

  begin

    if (l'length < 1 or r'length < 1 or result'length < 1) then

      return NASF;

    end if;

    lresize := resize (l, left_index, right_index);

    rresize := resize (r, left_index, right_index);

    lslv := to_s (lresize);

    rslv := to_s (rresize);

    result_slv := lslv + rslv;

    result := to_fixed(result_slv, left_index, right_index);

    return result;

  end function "+";



  -- Subtraction

  function "-" (

    l, r : UNRESOLVED_ufixed)  -- ufixed(a downto b) - ufixed(c downto d) =

    return UNRESOLVED_ufixed is         -- ufixed(max(a,c)+1 downto min(b,d))

    constant left_index : integer := maximum(l'high, r'high)+1;

    constant right_index : integer := mine(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_ufixed (left_index downto right_index);

    variable result : UNRESOLVED_ufixed (left_index downto right_index);

    variable lslv, rslv : unsigned (left_index-right_index

                                    downto 0);

    variable result_slv : unsigned (left_index-right_index

                                    downto 0);

  begin

    if (l'length < 1 or r'length < 1 or result'length < 1) then

      return NAUF;

    end if;

    lresize := resize (l, left_index, right_index);

    rresize := resize (r, left_index, right_index);

    lslv := to_uns (lresize);

    rslv := to_uns (rresize);

    result_slv := lslv - rslv;

    result := to_fixed(result_slv, left_index, right_index);

    return result;

  end function "-";



  function "-" (

    l, r : UNRESOLVED_sfixed)  -- sfixed(a downto b) - sfixed(c downto d) = 

    return UNRESOLVED_sfixed is         -- sfixed(max(a,c)+1 downto min(b,d))

    constant left_index : integer := maximum(l'high, r'high)+1;

    constant right_index : integer := mine(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_sfixed (left_index downto right_index);

    variable result : UNRESOLVED_sfixed (left_index downto right_index);

    variable lslv, rslv : signed (left_index-right_index downto 0);

    variable result_slv : signed (left_index-right_index downto 0);

  begin

    if (l'length < 1 or r'length < 1 or result'length < 1) then

      return NASF;

    end if;

    lresize := resize (l, left_index, right_index);

    rresize := resize (r, left_index, right_index);

    lslv := to_s (lresize);

    rslv := to_s (rresize);

    result_slv := lslv - rslv;

    result := to_fixed(result_slv, left_index, right_index);

    return result;

  end function "-";



  function "*" (

    l, r : UNRESOLVED_ufixed)  -- ufixed(a downto b) * ufixed(c downto d) =

    return UNRESOLVED_ufixed is         -- ufixed(a+c+1 downto b+d)

    variable lslv : unsigned (l'length-1 downto 0);

    variable rslv : unsigned (r'length-1 downto 0);

    variable result_slv : unsigned (r'length+l'length-1 downto 0);

    variable result : UNRESOLVED_ufixed (l'high + r'high+1 downto

                                         mine(l'low, l'low) + mine(r'low, r'low));

  begin

    if (l'length < 1 or r'length < 1 or

        result'length /= result_slv'length) then

      return NAUF;

    end if;

    lslv := to_uns (cleanvec(l));

    rslv := to_uns (cleanvec(r));

    result_slv := lslv * rslv;

    result := to_fixed (result_slv, result'high, result'low);

    return result;

  end function "*";



  function "*" (

    l, r : UNRESOLVED_sfixed)  -- sfixed(a downto b) * sfixed(c downto d) = 

    return UNRESOLVED_sfixed is         --  sfixed(a+c+1 downto b+d)

    variable lslv : signed (l'length-1 downto 0);

    variable rslv : signed (r'length-1 downto 0);

    variable result_slv : signed (r'length+l'length-1 downto 0);

    variable result : UNRESOLVED_sfixed (l'high + r'high+1 downto

                                         mine(l'low, l'low) + mine(r'low, r'low));

  begin

    if (l'length < 1 or r'length < 1 or

        result'length /= result_slv'length) then

      return NASF;

    end if;

    lslv := to_s (cleanvec(l));

    rslv := to_s (cleanvec(r));

    result_slv := lslv * rslv;

    result := to_fixed (result_slv, result'high, result'low);

    return result;

  end function "*";



  function "/" (

    l, r : UNRESOLVED_ufixed)  -- ufixed(a downto b) / ufixed(c downto d) = 

    return UNRESOLVED_ufixed is         --  ufixed(a-d downto b-c-1)

  begin

    return divide (l, r);

  end function "/";



  function "/" (

    l, r : UNRESOLVED_sfixed)  -- sfixed(a downto b) / sfixed(c downto d) = 

    return UNRESOLVED_sfixed is         -- sfixed(a-d+1 downto b-c)

  begin

    return divide (l, r);

  end function "/";



  -- This version of divide gives the user more control

  -- ufixed(a downto b) / ufixed(c downto d) = ufixed(a-d downto b-c-1)

  function divide (

    l, r : UNRESOLVED_ufixed;

    constant round_style : fixed_round_style_type := fixed_round_style;

    constant guard_bits : natural := fixed_guard_bits)

    return UNRESOLVED_ufixed is

    variable result : UNRESOLVED_ufixed (l'high - mine(r'low, r'low) downto

                                         mine (l'low, l'low) - r'high -1);

    variable dresult : UNRESOLVED_ufixed (result'high downto result'low -guard_bits);

    variable lresize : UNRESOLVED_ufixed (l'high downto l'high - dresult'length+1);

    variable lslv : unsigned (lresize'length-1 downto 0);

    variable rslv : unsigned (r'length-1 downto 0);

    variable result_slv : unsigned (lresize'length-1 downto 0);

  begin

    if (l'length < 1 or r'length < 1 or

        mins(r'low, r'low) /= r'low or mins(l'low, l'low) /= l'low) then

      return NAUF;

    end if;

    lresize := resize (arg => l,

                       left_index => lresize'high,

                       right_index => lresize'low,

                       overflow_style => fixed_wrap,  -- vector only grows

                       round_style => fixed_truncate);

    lslv := to_uns (cleanvec (lresize));

    rslv := to_uns (cleanvec (r));

    if (rslv = 0) then

      report fixed_pkg'instance_name

        & "DIVIDE(ufixed) Division by zero" severity error;

      result := saturate (result'high, result'low);  -- saturate

    else

      result_slv := lslv / rslv;

      dresult := to_fixed (result_slv, dresult'high, dresult'low);

      result := resize (arg => dresult,

                        left_index => result'high,

                        right_index => result'low,

                        overflow_style => fixed_wrap,  -- overflow impossible

                        round_style => round_style);

    end if;

    return result;

  end function divide;



  -- sfixed(a downto b) / sfixed(c downto d) = sfixed(a-d+1 downto b-c)

  function divide (

    l, r : UNRESOLVED_sfixed;

    constant round_style : fixed_round_style_type := fixed_round_style;

    constant guard_bits : natural := fixed_guard_bits)

    return UNRESOLVED_sfixed is

    variable result : UNRESOLVED_sfixed (l'high - mine(r'low, r'low) + 1 downto

                                         mine (l'low, l'low) - r'high);

    variable dresult : UNRESOLVED_sfixed (result'high downto result'low-guard_bits);

    variable lresize : UNRESOLVED_sfixed (l'high+1 downto l'high+1 -dresult'length+1);

    variable lslv : signed (lresize'length-1 downto 0);

    variable rslv : signed (r'length-1 downto 0);

    variable result_slv : signed (lresize'length-1 downto 0);

  begin

    if (l'length < 1 or r'length < 1 or

        mins(r'low, r'low) /= r'low or mins(l'low, l'low) /= l'low) then

      return NASF;

    end if;

    lresize := resize (arg => l,

                       left_index => lresize'high,

                       right_index => lresize'low,

                       overflow_style => fixed_wrap,  -- vector only grows

                       round_style => fixed_truncate);

    lslv := to_s (cleanvec (lresize));

    rslv := to_s (cleanvec (r));

    if (rslv = 0) then

      report fixed_pkg'instance_name

        & "DIVIDE(sfixed) Division by zero" severity error;

      result := saturate (result'high, result'low);

    else

      result_slv := lslv / rslv;

      dresult := to_fixed (result_slv, dresult'high, dresult'low);

      result := resize (arg => dresult,

                        left_index => result'high,

                        right_index => result'low,

                        overflow_style => fixed_wrap,  -- overflow impossible

                        round_style => round_style);

    end if;

    return result;

  end function divide;



  -- 1 / ufixed(a downto b) = ufixed(-b downto -a-1)

  function reciprocal (

    arg : UNRESOLVED_ufixed;            -- fixed point input

    constant round_style : fixed_round_style_type := fixed_round_style;

    constant guard_bits : natural := fixed_guard_bits)

    return UNRESOLVED_ufixed is

    constant one : UNRESOLVED_ufixed (0 downto 0) := "1";

  begin

    return divide (l => one,

                   r => arg,

                   round_style => round_style,

                   guard_bits => guard_bits);

  end function reciprocal;



  -- 1 / sfixed(a downto b) = sfixed(-b+1 downto -a)

  function reciprocal (

    arg : UNRESOLVED_sfixed;            -- fixed point input

    constant round_style : fixed_round_style_type := fixed_round_style;

    constant guard_bits : natural := fixed_guard_bits)

    return UNRESOLVED_sfixed is

    constant one : UNRESOLVED_sfixed (1 downto 0) := "01";  -- extra bit.

    variable resultx : UNRESOLVED_sfixed (-mine(arg'low, arg'low)+2 downto -arg'high);

  begin

    if (arg'length < 1 or resultx'length < 1) then

      return NASF;

    else

      resultx := divide (l => one,

                         r => arg,

                         round_style => round_style,

                         guard_bits => guard_bits);

      return resultx (resultx'high-1 downto resultx'low);  -- remove extra bit

    end if;

  end function reciprocal;



  -- ufixed (a downto b) rem ufixed (c downto d)

  --        = ufixed (min(a,c) downto min(b,d))

  function "rem" (

    l, r : UNRESOLVED_ufixed)           -- fixed point input

    return UNRESOLVED_ufixed is

  begin

    return remainder (l, r);

  end function "rem";



  -- remainder

  -- sfixed (a downto b) rem sfixed (c downto d)

  --        = sfixed (min(a,c) downto min(b,d))

  function "rem" (

    l, r : UNRESOLVED_sfixed)           -- fixed point input

    return UNRESOLVED_sfixed is

  begin

    return remainder (l, r);

  end function "rem";



  -- ufixed (a downto b) rem ufixed (c downto d)

  --        = ufixed (min(a,c) downto min(b,d))

  function remainder (

    l, r : UNRESOLVED_ufixed;           -- fixed point input

    constant round_style : fixed_round_style_type := fixed_round_style;

    constant guard_bits : natural := fixed_guard_bits)

    return UNRESOLVED_ufixed is

    variable result : UNRESOLVED_ufixed (minimum(l'high, r'high) downto

                                         mine(l'low, r'low));

    variable lresize : UNRESOLVED_ufixed (maximum(l'high, r'low) downto

                                          mins(r'low, r'low)-guard_bits);

    variable rresize : UNRESOLVED_ufixed (r'high downto r'low-guard_bits);

    variable dresult : UNRESOLVED_ufixed (rresize'range);

    variable lslv : unsigned (lresize'length-1 downto 0);

    variable rslv : unsigned (rresize'length-1 downto 0);

    variable result_slv : unsigned (rslv'range);

  begin

    if (l'length < 1 or r'length < 1 or

        mins(r'low, r'low) /= r'low or mins(l'low, l'low) /= l'low) then

      return NAUF;

    end if;

    lresize := resize (arg => l,

                       left_index => lresize'high,

                       right_index => lresize'low,

                       overflow_style => fixed_wrap,  -- vector only grows

                       round_style => fixed_truncate);

    lslv := to_uns (lresize);

    rresize := resize (arg => r,

                       left_index => rresize'high,

                       right_index => rresize'low,

                       overflow_style => fixed_wrap,  -- vector only grows

                       round_style => fixed_truncate);

    rslv := to_uns (rresize);

    if (rslv = 0) then

      report fixed_pkg'instance_name

        & "remainder(ufixed) Division by zero" severity error;

      result := saturate (result'high, result'low);  -- saturate

    else

      if (r'low <= l'high) then

        result_slv := lslv rem rslv;

        dresult := to_fixed (result_slv, dresult'high, dresult'low);

        result := resize (arg => dresult,

                          left_index => result'high,

                          right_index => result'low,

                          overflow_style => fixed_wrap,  -- can't overflow

                          round_style => round_style);

      end if;

      if l'low < r'low then

        result(mins(r'low-1, l'high) downto l'low) :=

          cleanvec(l(mins(r'low-1, l'high) downto l'low));

      end if;

    end if;

    return result;

  end function remainder;



  -- remainder

  -- sfixed (a downto b) rem sfixed (c downto d)

  --        = sfixed (min(a,c) downto min(b,d))

  function remainder (

    l, r : UNRESOLVED_sfixed;           -- fixed point input

    constant round_style : fixed_round_style_type := fixed_round_style;

    constant guard_bits : natural := fixed_guard_bits)

    return UNRESOLVED_sfixed is

    variable l_abs : UNRESOLVED_ufixed (l'range);

    variable r_abs : UNRESOLVED_ufixed (r'range);

    variable result : UNRESOLVED_sfixed (minimum(r'high, l'high) downto

                                         mine(r'low, l'low));

    variable neg_result : UNRESOLVED_sfixed (minimum(r'high, l'high)+1 downto

                                             mins(r'low, l'low));

  begin

    if (l'length < 1 or r'length < 1 or

        mins(r'low, r'low) /= r'low or mins(l'low, l'low) /= l'low) then

      return NASF;

    end if;

    l_abs := to_ufixed (l);

    r_abs := to_ufixed (r);

    result := UNRESOLVED_sfixed (remainder (

      l => l_abs,

      r => r_abs,

      round_style => round_style));

    neg_result := -result;

    if l(l'high) = '1' then

      result := neg_result(result'range);

    end if;

    return result;

  end function remainder;



  -- modulo

  -- ufixed (a downto b) mod ufixed (c downto d)

  --        = ufixed (min(a,c) downto min(b, d))

  function "mod" (

    l, r : UNRESOLVED_ufixed)           -- fixed point input

    return UNRESOLVED_ufixed is

  begin

    return modulo (l, r);

  end function "mod";



  -- sfixed (a downto b) mod sfixed (c downto d)

  --        = sfixed (c downto min(b, d))

  function "mod" (

    l, r : UNRESOLVED_sfixed)           -- fixed point input

    return UNRESOLVED_sfixed is

  begin

    return modulo(l, r);

  end function "mod";



  -- modulo

  -- ufixed (a downto b) mod ufixed (c downto d)

  --        = ufixed (min(a,c) downto min(b, d))

  function modulo (

    l, r : UNRESOLVED_ufixed;           -- fixed point input

    constant round_style : fixed_round_style_type := fixed_round_style;

    constant guard_bits : natural := fixed_guard_bits)

    return UNRESOLVED_ufixed is

  begin

    return remainder(l => l,

                     r => r,

                     round_style => round_style,

                     guard_bits => guard_bits);

  end function modulo;



  -- sfixed (a downto b) mod sfixed (c downto d)

  --        = sfixed (c downto min(b, d))

  function modulo (

    l, r : UNRESOLVED_sfixed;           -- fixed point input

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style;

    constant guard_bits : natural := fixed_guard_bits)

    return UNRESOLVED_sfixed is

    variable l_abs : UNRESOLVED_ufixed (l'range);

    variable r_abs : UNRESOLVED_ufixed (r'range);

    variable result : UNRESOLVED_sfixed (r'high downto

                                         mine(r'low, l'low));

    variable dresult : UNRESOLVED_sfixed (minimum(r'high, l'high)+1 downto

                                          mins(r'low, l'low));

    variable dresult_not_zero : boolean;

  begin

    if (l'length < 1 or r'length < 1 or

        mins(r'low, r'low) /= r'low or mins(l'low, l'low) /= l'low) then

      return NASF;

    end if;

    l_abs := to_ufixed (l);

    r_abs := to_ufixed (r);

    dresult := "0" & UNRESOLVED_sfixed(remainder (l => l_abs,

                                                  r => r_abs,

                                                  round_style => round_style));

    if (to_s(dresult) = 0) then

      dresult_not_zero := false;

    else

      dresult_not_zero := true;

    end if;

    if to_x01(l(l'high)) = '1' and to_x01(r(r'high)) = '0'

      and dresult_not_zero then

      result := resize (arg => r - dresult,

                        left_index => result'high,

                        right_index => result'low,

                        overflow_style => overflow_style,

                        round_style => round_style);

    elsif to_x01(l(l'high)) = '1' and to_x01(r(r'high)) = '1' then

      result := resize (arg => -dresult,

                        left_index => result'high,

                        right_index => result'low,

                        overflow_style => overflow_style,

                        round_style => round_style);

    elsif to_x01(l(l'high)) = '0' and to_x01(r(r'high)) = '1'

      and dresult_not_zero then

      result := resize (arg => dresult + r,

                        left_index => result'high,

                        right_index => result'low,

                        overflow_style => overflow_style,

                        round_style => round_style);

    else

      result := resize (arg => dresult,

                        left_index => result'high,

                        right_index => result'low,

                        overflow_style => overflow_style,

                        round_style => round_style);

    end if;

    return result;

  end function modulo;



  -- Procedure for those who need an "accumulator" function

  procedure add_carry (

    L, R : in UNRESOLVED_ufixed;

    c_in : in std_ulogic;

    result : out UNRESOLVED_ufixed;

    c_out : out std_ulogic) is

    constant left_index : integer := maximum(l'high, r'high)+1;

    constant right_index : integer := mins(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_ufixed (left_index downto right_index);

    variable lslv, rslv : unsigned (left_index-right_index

                                    downto 0);

    variable result_slv : unsigned (left_index-right_index

                                    downto 0);

    variable cx : unsigned (0 downto 0);  -- Carry in

  begin

    if (l'length < 1 or r'length < 1) then

      result := NAUF;

      c_out := '0';

    else

      cx (0) := c_in;

      lresize := resize (l, left_index, right_index);

      rresize := resize (r, left_index, right_index);

      lslv := to_uns (lresize);

      rslv := to_uns (rresize);

      result_slv := lslv + rslv + cx;

      c_out := result_slv(left_index-right_index);

      result := to_fixed(result_slv (left_index-right_index-1 downto 0),

                         left_index-1, right_index);

    end if;

  end procedure add_carry;



  procedure add_carry (

    L, R : in UNRESOLVED_sfixed;

    c_in : in std_ulogic;

    result : out UNRESOLVED_sfixed;

    c_out : out std_ulogic) is

    constant left_index : integer := maximum(l'high, r'high)+1;

    constant right_index : integer := mins(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_sfixed (left_index downto right_index);

    variable lslv, rslv : signed (left_index-right_index

                                  downto 0);

    variable result_slv : signed (left_index-right_index

                                  downto 0);

    variable cx : signed (1 downto 0);  -- Carry in

  begin

    if (l'length < 1 or r'length < 1) then

      result := NASF;

      c_out := '0';

    else

      cx (1) := '0';

      cx (0) := c_in;

      lresize := resize (l, left_index, right_index);

      rresize := resize (r, left_index, right_index);

      lslv := to_s (lresize);

      rslv := to_s (rresize);

      result_slv := lslv + rslv + cx;

      c_out := result_slv(left_index-right_index);

      result := to_fixed(result_slv (left_index-right_index-1 downto 0),

                         left_index-1, right_index);

    end if;

  end procedure add_carry;



  -- Scales the result by a power of 2.  Width of input = width of output with

  -- the decimal point moved.

  function scalb (y : UNRESOLVED_ufixed; N : integer)

    return UNRESOLVED_ufixed is

    variable result : UNRESOLVED_ufixed (y'high+N downto y'low+N);

  begin

    if y'length < 1 then

      return NAUF;

    else

      result := y;

      return result;

    end if;

  end function scalb;



  function scalb (y : UNRESOLVED_ufixed; N : signed)

    return UNRESOLVED_ufixed is

  begin

    return scalb (y => y,

                  N => to_integer(N));

  end function scalb;



  function scalb (y : UNRESOLVED_sfixed; N : integer)

    return UNRESOLVED_sfixed is

    variable result : UNRESOLVED_sfixed (y'high+N downto y'low+N);

  begin

    if y'length < 1 then

      return NASF;

    else

      result := y;

      return result;

    end if;

  end function scalb;



  function scalb (y : UNRESOLVED_sfixed; N : signed)

    return UNRESOLVED_sfixed is

  begin

    return scalb (y => y,

                  N => to_integer(N));

  end function scalb;



  function Is_Negative (arg : UNRESOLVED_sfixed) return boolean is

  begin

    if to_X01(arg(arg'high)) = '1' then

      return true;

    else

      return false;

    end if;

  end function Is_Negative;



  function find_rightmost (arg : UNRESOLVED_ufixed; y : std_ulogic)

    return integer is

  begin

    for_loop : for i in arg'reverse_range loop

      if \?=\ (arg(i), y) = '1' then

        return i;

      end if;

    end loop;

    return arg'high+1;                  -- return out of bounds 'high

  end function find_rightmost;



  function find_leftmost (arg : UNRESOLVED_ufixed; y : std_ulogic)

    return integer is

  begin

    for_loop : for i in arg'range loop

      if \?=\ (arg(i), y) = '1' then

        return i;

      end if;

    end loop;

    return arg'low-1;                   -- return out of bounds 'low

  end function find_leftmost;



  function find_rightmost (arg : UNRESOLVED_sfixed; y : std_ulogic)

    return integer is

  begin

    for_loop : for i in arg'reverse_range loop

      if \?=\ (arg(i), y) = '1' then

        return i;

      end if;

    end loop;

    return arg'high+1;                  -- return out of bounds 'high

  end function find_rightmost;



  function find_leftmost (arg : UNRESOLVED_sfixed; y : std_ulogic)

    return integer is

  begin

    for_loop : for i in arg'range loop

      if \?=\ (arg(i), y) = '1' then

        return i;

      end if;

    end loop;

    return arg'low-1;                   -- return out of bounds 'low

  end function find_leftmost;



  function "sll" (ARG : UNRESOLVED_ufixed; COUNT : integer)

    return UNRESOLVED_ufixed is

    variable argslv : unsigned (arg'length-1 downto 0);

    variable result : UNRESOLVED_ufixed (arg'range);

  begin

    argslv := to_uns (arg);

    argslv := argslv sll COUNT;

    result := to_fixed (argslv, result'high, result'low);

    return result;

  end function "sll";



  function "srl" (ARG : UNRESOLVED_ufixed; COUNT : integer)

    return UNRESOLVED_ufixed is

    variable argslv : unsigned (arg'length-1 downto 0);

    variable result : UNRESOLVED_ufixed (arg'range);

  begin

    argslv := to_uns (arg);

    argslv := argslv srl COUNT;

    result := to_fixed (argslv, result'high, result'low);

    return result;

  end function "srl";



  function "rol" (ARG : UNRESOLVED_ufixed; COUNT : integer)

    return UNRESOLVED_ufixed is

    variable argslv : unsigned (arg'length-1 downto 0);

    variable result : UNRESOLVED_ufixed (arg'range);

  begin

    argslv := to_uns (arg);

    argslv := argslv rol COUNT;

    result := to_fixed (argslv, result'high, result'low);

    return result;

  end function "rol";



  function "ror" (ARG : UNRESOLVED_ufixed; COUNT : integer)

    return UNRESOLVED_ufixed is

    variable argslv : unsigned (arg'length-1 downto 0);

    variable result : UNRESOLVED_ufixed (arg'range);

  begin

    argslv := to_uns (arg);

    argslv := argslv ror COUNT;

    result := to_fixed (argslv, result'high, result'low);

    return result;

  end function "ror";



  function "sla" (ARG : UNRESOLVED_ufixed; COUNT : integer)

    return UNRESOLVED_ufixed is

    variable argslv : unsigned (arg'length-1 downto 0);

    variable result : UNRESOLVED_ufixed (arg'range);

  begin

    argslv := to_uns (arg);

    -- Arithmetic shift on an unsigned is a logical shift

    argslv := argslv sll COUNT;

    result := to_fixed (argslv, result'high, result'low);

    return result;

  end function "sla";



  function "sra" (ARG : UNRESOLVED_ufixed; COUNT : integer)

    return UNRESOLVED_ufixed is

    variable argslv : unsigned (arg'length-1 downto 0);

    variable result : UNRESOLVED_ufixed (arg'range);

  begin

    argslv := to_uns (arg);

    -- Arithmetic shift on an unsigned is a logical shift

    argslv := argslv srl COUNT;

    result := to_fixed (argslv, result'high, result'low);

    return result;

  end function "sra";



  function "sll" (ARG : UNRESOLVED_sfixed; COUNT : integer)

    return UNRESOLVED_sfixed is

    variable argslv : signed (arg'length-1 downto 0);

    variable result : UNRESOLVED_sfixed (arg'range);

  begin

    argslv := to_s (arg);

    argslv := argslv sll COUNT;

    result := to_fixed (argslv, result'high, result'low);

    return result;

  end function "sll";



  function "srl" (ARG : UNRESOLVED_sfixed; COUNT : integer)

    return UNRESOLVED_sfixed is

    variable argslv : signed (arg'length-1 downto 0);

    variable result : UNRESOLVED_sfixed (arg'range);

  begin

    argslv := to_s (arg);

    argslv := argslv srl COUNT;

    result := to_fixed (argslv, result'high, result'low);

    return result;

  end function "srl";



  function "rol" (ARG : UNRESOLVED_sfixed; COUNT : integer)

    return UNRESOLVED_sfixed is

    variable argslv : signed (arg'length-1 downto 0);

    variable result : UNRESOLVED_sfixed (arg'range);

  begin

    argslv := to_s (arg);

    argslv := argslv rol COUNT;

    result := to_fixed (argslv, result'high, result'low);

    return result;

  end function "rol";



  function "ror" (ARG : UNRESOLVED_sfixed; COUNT : integer)

    return UNRESOLVED_sfixed is

    variable argslv : signed (arg'length-1 downto 0);

    variable result : UNRESOLVED_sfixed (arg'range);

  begin

    argslv := to_s (arg);

    argslv := argslv ror COUNT;

    result := to_fixed (argslv, result'high, result'low);

    return result;

  end function "ror";



  function "sla" (ARG : UNRESOLVED_sfixed; COUNT : integer)

    return UNRESOLVED_sfixed is

    variable argslv : signed (arg'length-1 downto 0);

    variable result : UNRESOLVED_sfixed (arg'range);

  begin

    argslv := to_s (arg);

    if COUNT > 0 then

      -- Arithmetic shift left on a 2's complement number is a logic shift

      argslv := argslv sll COUNT;

    else

      argslv := argslv sra -COUNT;

    end if;

    result := to_fixed (argslv, result'high, result'low);

    return result;

  end function "sla";



  function "sra" (ARG : UNRESOLVED_sfixed; COUNT : integer)

    return UNRESOLVED_sfixed is

    variable argslv : signed (arg'length-1 downto 0);

    variable result : UNRESOLVED_sfixed (arg'range);

  begin

    argslv := to_s (arg);

    if COUNT > 0 then

      argslv := argslv sra COUNT;

    else

      -- Arithmetic shift left on a 2's complement number is a logic shift

      argslv := argslv sll -COUNT;

    end if;

    result := to_fixed (argslv, result'high, result'low);

    return result;

  end function "sra";



  -- Because some people want the older functions.

  function SHIFT_LEFT (ARG : UNRESOLVED_ufixed; COUNT : natural)

    return UNRESOLVED_ufixed is

  begin

    if (ARG'length < 1) then

      return NAUF;

    end if;

    return ARG sla COUNT;

  end function SHIFT_LEFT;



  function SHIFT_RIGHT (ARG : UNRESOLVED_ufixed; COUNT : natural)

    return UNRESOLVED_ufixed is

  begin

    if (ARG'length < 1) then

      return NAUF;

    end if;

    return ARG sra COUNT;

  end function SHIFT_RIGHT;



  function SHIFT_LEFT (ARG : UNRESOLVED_sfixed; COUNT : natural)

    return UNRESOLVED_sfixed is

  begin

    if (ARG'length < 1) then

      return NASF;

    end if;

    return ARG sla COUNT;

  end function SHIFT_LEFT;



  function SHIFT_RIGHT (ARG : UNRESOLVED_sfixed; COUNT : natural)

    return UNRESOLVED_sfixed is

  begin

    if (ARG'length < 1) then

      return NASF;

    end if;

    return ARG sra COUNT;

  end function SHIFT_RIGHT;



  ----------------------------------------------------------------------------

  -- logical functions

  ----------------------------------------------------------------------------

  function "not" (L : UNRESOLVED_ufixed) return UNRESOLVED_ufixed is

    variable RESULT : std_ulogic_vector(L'length-1 downto 0);  -- force downto

  begin

    RESULT := not to_sulv(L);

    return to_ufixed(RESULT, L'high, L'low);

  end function "not";



  function "and" (L, R : UNRESOLVED_ufixed) return UNRESOLVED_ufixed is

    variable RESULT : std_ulogic_vector(L'length-1 downto 0);  -- force downto

  begin

    if (L'high = R'high and L'low = R'low) then

      RESULT := to_sulv(L) and to_sulv(R);

    else

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """and"": Range error L'RANGE /= R'RANGE"

        severity warning;

      RESULT := (others => 'X');

    end if;

    return to_ufixed(RESULT, L'high, L'low);

  end function "and";



  function "or" (L, R : UNRESOLVED_ufixed) return UNRESOLVED_ufixed is

    variable RESULT : std_ulogic_vector(L'length-1 downto 0);  -- force downto

  begin

    if (L'high = R'high and L'low = R'low) then

      RESULT := to_sulv(L) or to_sulv(R);

    else

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """or"": Range error L'RANGE /= R'RANGE"

        severity warning;

      RESULT := (others => 'X');

    end if;

    return to_ufixed(RESULT, L'high, L'low);

  end function "or";



  function "nand" (L, R : UNRESOLVED_ufixed) return UNRESOLVED_ufixed is

    variable RESULT : std_ulogic_vector(L'length-1 downto 0);  -- force downto

  begin

    if (L'high = R'high and L'low = R'low) then

      RESULT := to_sulv(L) nand to_sulv(R);

    else

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """nand"": Range error L'RANGE /= R'RANGE"

        severity warning;

      RESULT := (others => 'X');

    end if;

    return to_ufixed(RESULT, L'high, L'low);

  end function "nand";



  function "nor" (L, R : UNRESOLVED_ufixed) return UNRESOLVED_ufixed is

    variable RESULT : std_ulogic_vector(L'length-1 downto 0);  -- force downto

  begin

    if (L'high = R'high and L'low = R'low) then

      RESULT := to_sulv(L) nor to_sulv(R);

    else

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """nor"": Range error L'RANGE /= R'RANGE"

        severity warning;

      RESULT := (others => 'X');

    end if;

    return to_ufixed(RESULT, L'high, L'low);

  end function "nor";



  function "xor" (L, R : UNRESOLVED_ufixed) return UNRESOLVED_ufixed is

    variable RESULT : std_ulogic_vector(L'length-1 downto 0);  -- force downto

  begin

    if (L'high = R'high and L'low = R'low) then

      RESULT := to_sulv(L) xor to_sulv(R);

    else

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """xor"": Range error L'RANGE /= R'RANGE"

        severity warning;

      RESULT := (others => 'X');

    end if;

    return to_ufixed(RESULT, L'high, L'low);

  end function "xor";



  function "xnor" (L, R : UNRESOLVED_ufixed) return UNRESOLVED_ufixed is

    variable RESULT : std_ulogic_vector(L'length-1 downto 0);  -- force downto

  begin

    if (L'high = R'high and L'low = R'low) then

      RESULT := to_sulv(L) xnor to_sulv(R);

    else

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """xnor"": Range error L'RANGE /= R'RANGE"

        severity warning;

      RESULT := (others => 'X');

    end if;

    return to_ufixed(RESULT, L'high, L'low);

  end function "xnor";



  function "not" (L : UNRESOLVED_sfixed) return UNRESOLVED_sfixed is

    variable RESULT : std_ulogic_vector(L'length-1 downto 0);  -- force downto

  begin

    RESULT := not to_sulv(L);

    return to_sfixed(RESULT, L'high, L'low);

  end function "not";



  function "and" (L, R : UNRESOLVED_sfixed) return UNRESOLVED_sfixed is

    variable RESULT : std_ulogic_vector(L'length-1 downto 0);  -- force downto

  begin

    if (L'high = R'high and L'low = R'low) then

      RESULT := to_sulv(L) and to_sulv(R);

    else

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """and"": Range error L'RANGE /= R'RANGE"

        severity warning;

      RESULT := (others => 'X');

    end if;

    return to_sfixed(RESULT, L'high, L'low);

  end function "and";



  function "or" (L, R : UNRESOLVED_sfixed) return UNRESOLVED_sfixed is

    variable RESULT : std_ulogic_vector(L'length-1 downto 0);  -- force downto

  begin

    if (L'high = R'high and L'low = R'low) then

      RESULT := to_sulv(L) or to_sulv(R);

    else

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """or"": Range error L'RANGE /= R'RANGE"

        severity warning;

      RESULT := (others => 'X');

    end if;

    return to_sfixed(RESULT, L'high, L'low);

  end function "or";



  function "nand" (L, R : UNRESOLVED_sfixed) return UNRESOLVED_sfixed is

    variable RESULT : std_ulogic_vector(L'length-1 downto 0);  -- force downto

  begin

    if (L'high = R'high and L'low = R'low) then

      RESULT := to_sulv(L) nand to_sulv(R);

    else

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """nand"": Range error L'RANGE /= R'RANGE"

        severity warning;

      RESULT := (others => 'X');

    end if;

    return to_sfixed(RESULT, L'high, L'low);

  end function "nand";



  function "nor" (L, R : UNRESOLVED_sfixed) return UNRESOLVED_sfixed is

    variable RESULT : std_ulogic_vector(L'length-1 downto 0);  -- force downto

  begin

    if (L'high = R'high and L'low = R'low) then

      RESULT := to_sulv(L) nor to_sulv(R);

    else

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """nor"": Range error L'RANGE /= R'RANGE"

        severity warning;

      RESULT := (others => 'X');

    end if;

    return to_sfixed(RESULT, L'high, L'low);

  end function "nor";



  function "xor" (L, R : UNRESOLVED_sfixed) return UNRESOLVED_sfixed is

    variable RESULT : std_ulogic_vector(L'length-1 downto 0);  -- force downto

  begin

    if (L'high = R'high and L'low = R'low) then

      RESULT := to_sulv(L) xor to_sulv(R);

    else

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """xor"": Range error L'RANGE /= R'RANGE"

        severity warning;

      RESULT := (others => 'X');

    end if;

    return to_sfixed(RESULT, L'high, L'low);

  end function "xor";



  function "xnor" (L, R : UNRESOLVED_sfixed) return UNRESOLVED_sfixed is

    variable RESULT : std_ulogic_vector(L'length-1 downto 0);  -- force downto

  begin

    if (L'high = R'high and L'low = R'low) then

      RESULT := to_sulv(L) xnor to_sulv(R);

    else

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """xnor"": Range error L'RANGE /= R'RANGE"

        severity warning;

      RESULT := (others => 'X');

    end if;

    return to_sfixed(RESULT, L'high, L'low);

  end function "xnor";



  -- Vector and std_ulogic functions, same as functions in numeric_std

  function "and" (L : std_ulogic; R : UNRESOLVED_ufixed)

    return UNRESOLVED_ufixed is

    variable result : UNRESOLVED_ufixed (R'range);

  begin

    for i in result'range loop

      result(i) := L and R(i);

    end loop;

    return result;

  end function "and";



  function "and" (L : UNRESOLVED_ufixed; R : std_ulogic)

    return UNRESOLVED_ufixed is

    variable result : UNRESOLVED_ufixed (L'range);

  begin

    for i in result'range loop

      result(i) := L(i) and R;

    end loop;

    return result;

  end function "and";



  function "or" (L : std_ulogic; R : UNRESOLVED_ufixed)

    return UNRESOLVED_ufixed is

    variable result : UNRESOLVED_ufixed (R'range);

  begin

    for i in result'range loop

      result(i) := L or R(i);

    end loop;

    return result;

  end function "or";



  function "or" (L : UNRESOLVED_ufixed; R : std_ulogic)

    return UNRESOLVED_ufixed is

    variable result : UNRESOLVED_ufixed (L'range);

  begin

    for i in result'range loop

      result(i) := L(i) or R;

    end loop;

    return result;

  end function "or";



  function "nand" (L : std_ulogic; R : UNRESOLVED_ufixed)

    return UNRESOLVED_ufixed is

    variable result : UNRESOLVED_ufixed (R'range);

  begin

    for i in result'range loop

      result(i) := L nand R(i);

    end loop;

    return result;

  end function "nand";



  function "nand" (L : UNRESOLVED_ufixed; R : std_ulogic)

    return UNRESOLVED_ufixed is

    variable result : UNRESOLVED_ufixed (L'range);

  begin

    for i in result'range loop

      result(i) := L(i) nand R;

    end loop;

    return result;

  end function "nand";



  function "nor" (L : std_ulogic; R : UNRESOLVED_ufixed)

    return UNRESOLVED_ufixed is

    variable result : UNRESOLVED_ufixed (R'range);

  begin

    for i in result'range loop

      result(i) := L nor R(i);

    end loop;

    return result;

  end function "nor";



  function "nor" (L : UNRESOLVED_ufixed; R : std_ulogic)

    return UNRESOLVED_ufixed is

    variable result : UNRESOLVED_ufixed (L'range);

  begin

    for i in result'range loop

      result(i) := L(i) nor R;

    end loop;

    return result;

  end function "nor";



  function "xor" (L : std_ulogic; R : UNRESOLVED_ufixed)

    return UNRESOLVED_ufixed is

    variable result : UNRESOLVED_ufixed (R'range);

  begin

    for i in result'range loop

      result(i) := L xor R(i);

    end loop;

    return result;

  end function "xor";



  function "xor" (L : UNRESOLVED_ufixed; R : std_ulogic)

    return UNRESOLVED_ufixed is

    variable result : UNRESOLVED_ufixed (L'range);

  begin

    for i in result'range loop

      result(i) := L(i) xor R;

    end loop;

    return result;

  end function "xor";



  function "xnor" (L : std_ulogic; R : UNRESOLVED_ufixed)

    return UNRESOLVED_ufixed is

    variable result : UNRESOLVED_ufixed (R'range);

  begin

    for i in result'range loop

      result(i) := L xnor R(i);

    end loop;

    return result;

  end function "xnor";



  function "xnor" (L : UNRESOLVED_ufixed; R : std_ulogic)

    return UNRESOLVED_ufixed is

    variable result : UNRESOLVED_ufixed (L'range);

  begin

    for i in result'range loop

      result(i) := L(i) xnor R;

    end loop;

    return result;

  end function "xnor";



  function "and" (L : std_ulogic; R : UNRESOLVED_sfixed)

    return UNRESOLVED_sfixed is

    variable result : UNRESOLVED_sfixed (R'range);

  begin

    for i in result'range loop

      result(i) := L and R(i);

    end loop;

    return result;

  end function "and";



  function "and" (L : UNRESOLVED_sfixed; R : std_ulogic)

    return UNRESOLVED_sfixed is

    variable result : UNRESOLVED_sfixed (L'range);

  begin

    for i in result'range loop

      result(i) := L(i) and R;

    end loop;

    return result;

  end function "and";



  function "or" (L : std_ulogic; R : UNRESOLVED_sfixed)

    return UNRESOLVED_sfixed is

    variable result : UNRESOLVED_sfixed (R'range);

  begin

    for i in result'range loop

      result(i) := L or R(i);

    end loop;

    return result;

  end function "or";



  function "or" (L : UNRESOLVED_sfixed; R : std_ulogic)

    return UNRESOLVED_sfixed is

    variable result : UNRESOLVED_sfixed (L'range);

  begin

    for i in result'range loop

      result(i) := L(i) or R;

    end loop;

    return result;

  end function "or";



  function "nand" (L : std_ulogic; R : UNRESOLVED_sfixed)

    return UNRESOLVED_sfixed is

    variable result : UNRESOLVED_sfixed (R'range);

  begin

    for i in result'range loop

      result(i) := L nand R(i);

    end loop;

    return result;

  end function "nand";



  function "nand" (L : UNRESOLVED_sfixed; R : std_ulogic)

    return UNRESOLVED_sfixed is

    variable result : UNRESOLVED_sfixed (L'range);

  begin

    for i in result'range loop

      result(i) := L(i) nand R;

    end loop;

    return result;

  end function "nand";



  function "nor" (L : std_ulogic; R : UNRESOLVED_sfixed)

    return UNRESOLVED_sfixed is

    variable result : UNRESOLVED_sfixed (R'range);

  begin

    for i in result'range loop

      result(i) := L nor R(i);

    end loop;

    return result;

  end function "nor";



  function "nor" (L : UNRESOLVED_sfixed; R : std_ulogic)

    return UNRESOLVED_sfixed is

    variable result : UNRESOLVED_sfixed (L'range);

  begin

    for i in result'range loop

      result(i) := L(i) nor R;

    end loop;

    return result;

  end function "nor";



  function "xor" (L : std_ulogic; R : UNRESOLVED_sfixed)

    return UNRESOLVED_sfixed is

    variable result : UNRESOLVED_sfixed (R'range);

  begin

    for i in result'range loop

      result(i) := L xor R(i);

    end loop;

    return result;

  end function "xor";



  function "xor" (L : UNRESOLVED_sfixed; R : std_ulogic)

    return UNRESOLVED_sfixed is

    variable result : UNRESOLVED_sfixed (L'range);

  begin

    for i in result'range loop

      result(i) := L(i) xor R;

    end loop;

    return result;

  end function "xor";



  function "xnor" (L : std_ulogic; R : UNRESOLVED_sfixed)

    return UNRESOLVED_sfixed is

    variable result : UNRESOLVED_sfixed (R'range);

  begin

    for i in result'range loop

      result(i) := L xnor R(i);

    end loop;

    return result;

  end function "xnor";



  function "xnor" (L : UNRESOLVED_sfixed; R : std_ulogic)

    return UNRESOLVED_sfixed is

    variable result : UNRESOLVED_sfixed (L'range);

  begin

    for i in result'range loop

      result(i) := L(i) xnor R;

    end loop;

    return result;

  end function "xnor";



  -- Reduction operator_reduces

  function and_reduce (l : UNRESOLVED_ufixed) return std_ulogic is

  begin

    return and_reduce (to_sulv(l));

  end function and_reduce;



  function nand_reduce (l : UNRESOLVED_ufixed) return std_ulogic is

  begin

    return nand_reduce (to_sulv(l));

  end function nand_reduce;



  function or_reduce (l : UNRESOLVED_ufixed) return std_ulogic is

  begin

    return or_reduce (to_sulv(l));

  end function or_reduce;



  function nor_reduce (l : UNRESOLVED_ufixed) return std_ulogic is

  begin

    return nor_reduce (to_sulv(l));

  end function nor_reduce;



  function xor_reduce (l : UNRESOLVED_ufixed) return std_ulogic is

  begin

    return xor_reduce (to_sulv(l));

  end function xor_reduce;



  function xnor_reduce (l : UNRESOLVED_ufixed) return std_ulogic is

  begin

    return xnor_reduce (to_sulv(l));

  end function xnor_reduce;



  function and_reduce (l : UNRESOLVED_sfixed) return std_ulogic is

  begin

    return and_reduce (to_sulv(l));

  end function and_reduce;



  function nand_reduce (l : UNRESOLVED_sfixed) return std_ulogic is

  begin

    return nand_reduce (to_sulv(l));

  end function nand_reduce;



  function or_reduce (l : UNRESOLVED_sfixed) return std_ulogic is

  begin

    return or_reduce (to_sulv(l));

  end function or_reduce;



  function nor_reduce (l : UNRESOLVED_sfixed) return std_ulogic is

  begin

    return nor_reduce (to_sulv(l));

  end function nor_reduce;



  function xor_reduce (l : UNRESOLVED_sfixed) return std_ulogic is

  begin

    return xor_reduce (to_sulv(l));

  end function xor_reduce;



  function xnor_reduce (l : UNRESOLVED_sfixed) return std_ulogic is

  begin

    return xnor_reduce (to_sulv(l));

  end function xnor_reduce;

  -- End reduction operator_reduces



  function \?=\ (L, R : UNRESOLVED_ufixed) return std_ulogic is

    constant left_index : integer := maximum(l'high, r'high);

    constant right_index : integer := mins(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_ufixed (left_index downto right_index);

    variable lslv, rslv : unsigned (lresize'length-1 downto 0);

  begin  -- ?=

    if ((L'length < 1) or (R'length < 1)) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """?="": null detected, returning X"

        severity warning;

      return 'X';

    else

      lresize := resize (l, left_index, right_index);

      rresize := resize (r, left_index, right_index);

      lslv := to_uns (lresize);

      rslv := to_uns (rresize);

      return \?=\ (lslv, rslv);

    end if;

  end function \?=\;



  function \?/=\ (L, R : UNRESOLVED_ufixed) return std_ulogic is

    constant left_index : integer := maximum(l'high, r'high);

    constant right_index : integer := mins(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_ufixed (left_index downto right_index);

    variable lslv, rslv : unsigned (lresize'length-1 downto 0);

  begin  -- ?/=

    if ((L'length < 1) or (R'length < 1)) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """?/="": null detected, returning X"

        severity warning;

      return 'X';

    else

      lresize := resize (l, left_index, right_index);

      rresize := resize (r, left_index, right_index);

      lslv := to_uns (lresize);

      rslv := to_uns (rresize);

      return \?/=\ (lslv, rslv);

    end if;

  end function \?/=\;



  function \?>\ (L, R : UNRESOLVED_ufixed) return std_ulogic is

    constant left_index : integer := maximum(l'high, r'high);

    constant right_index : integer := mins(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_ufixed (left_index downto right_index);

    variable lslv, rslv : unsigned (lresize'length-1 downto 0);

  begin  -- ?>

    if ((l'length < 1) or (r'length < 1)) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """?>"": null detected, returning X"

        severity warning;

      return 'X';

    else

      lresize := resize (l, left_index, right_index);

      rresize := resize (r, left_index, right_index);

      lslv := to_uns (lresize);

      rslv := to_uns (rresize);

      return \?>\ (lslv, rslv);

    end if;

  end function \?>\;



  function \?>=\ (L, R : UNRESOLVED_ufixed) return std_ulogic is

    constant left_index : integer := maximum(l'high, r'high);

    constant right_index : integer := mins(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_ufixed (left_index downto right_index);

    variable lslv, rslv : unsigned (lresize'length-1 downto 0);

  begin  -- ?>=

    if ((l'length < 1) or (r'length < 1)) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """?>="": null detected, returning X"

        severity warning;

      return 'X';

    else

      lresize := resize (l, left_index, right_index);

      rresize := resize (r, left_index, right_index);

      lslv := to_uns (lresize);

      rslv := to_uns (rresize);

      return \?>=\ (lslv, rslv);

    end if;

  end function \?>=\;



  function \?<\ (L, R : UNRESOLVED_ufixed) return std_ulogic is

    constant left_index : integer := maximum(l'high, r'high);

    constant right_index : integer := mins(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_ufixed (left_index downto right_index);

    variable lslv, rslv : unsigned (lresize'length-1 downto 0);

  begin  -- ?<

    if ((l'length < 1) or (r'length < 1)) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """?<"": null detected, returning X"

        severity warning;

      return 'X';

    else

      lresize := resize (l, left_index, right_index);

      rresize := resize (r, left_index, right_index);

      lslv := to_uns (lresize);

      rslv := to_uns (rresize);

      return \?<\ (lslv, rslv);

    end if;

  end function \?<\;



  function \?<=\ (L, R : UNRESOLVED_ufixed) return std_ulogic is

    constant left_index : integer := maximum(l'high, r'high);

    constant right_index : integer := mins(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_ufixed (left_index downto right_index);

    variable lslv, rslv : unsigned (lresize'length-1 downto 0);

  begin  -- ?<=

    if ((l'length < 1) or (r'length < 1)) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """?<="": null detected, returning X"

        severity warning;

      return 'X';

    else

      lresize := resize (l, left_index, right_index);

      rresize := resize (r, left_index, right_index);

      lslv := to_uns (lresize);

      rslv := to_uns (rresize);

      return \?<=\ (lslv, rslv);

    end if;

  end function \?<=\;



  function \?=\ (L, R : UNRESOLVED_sfixed) return std_ulogic is

    constant left_index : integer := maximum(l'high, r'high);

    constant right_index : integer := mins(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_sfixed (left_index downto right_index);

    variable lslv, rslv : signed (lresize'length-1 downto 0);

  begin  -- ?=

    if ((L'length < 1) or (R'length < 1)) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """?="": null detected, returning X"

        severity warning;

      return 'X';

    else

      lresize := resize (l, left_index, right_index);

      rresize := resize (r, left_index, right_index);

      lslv := to_s (lresize);

      rslv := to_s (rresize);

      return \?=\ (lslv, rslv);

    end if;

  end function \?=\;



  function \?/=\ (L, R : UNRESOLVED_sfixed) return std_ulogic is

    constant left_index : integer := maximum(l'high, r'high);

    constant right_index : integer := mins(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_sfixed (left_index downto right_index);

    variable lslv, rslv : signed (lresize'length-1 downto 0);

  begin  -- ?/=

    if ((L'length < 1) or (R'length < 1)) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """?/="": null detected, returning X"

        severity warning;

      return 'X';

    else

      lresize := resize (l, left_index, right_index);

      rresize := resize (r, left_index, right_index);

      lslv := to_s (lresize);

      rslv := to_s (rresize);

      return \?/=\ (lslv, rslv);

    end if;

  end function \?/=\;



  function \?>\ (L, R : UNRESOLVED_sfixed) return std_ulogic is

    constant left_index : integer := maximum(l'high, r'high);

    constant right_index : integer := mins(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_sfixed (left_index downto right_index);

    variable lslv, rslv : signed (lresize'length-1 downto 0);

  begin  -- ?>

    if ((l'length < 1) or (r'length < 1)) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """?>"": null detected, returning X"

        severity warning;

      return 'X';

    else

      lresize := resize (l, left_index, right_index);

      rresize := resize (r, left_index, right_index);

      lslv := to_s (lresize);

      rslv := to_s (rresize);

      return \?>\ (lslv, rslv);

    end if;

  end function \?>\;



  function \?>=\ (L, R : UNRESOLVED_sfixed) return std_ulogic is

    constant left_index : integer := maximum(l'high, r'high);

    constant right_index : integer := mins(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_sfixed (left_index downto right_index);

    variable lslv, rslv : signed (lresize'length-1 downto 0);

  begin  -- ?>=

    if ((l'length < 1) or (r'length < 1)) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """?>="": null detected, returning X"

        severity warning;

      return 'X';

    else

      lresize := resize (l, left_index, right_index);

      rresize := resize (r, left_index, right_index);

      lslv := to_s (lresize);

      rslv := to_s (rresize);

      return \?>=\ (lslv, rslv);

    end if;

  end function \?>=\;



  function \?<\ (L, R : UNRESOLVED_sfixed) return std_ulogic is

    constant left_index : integer := maximum(l'high, r'high);

    constant right_index : integer := mins(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_sfixed (left_index downto right_index);

    variable lslv, rslv : signed (lresize'length-1 downto 0);

  begin  -- ?<

    if ((l'length < 1) or (r'length < 1)) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """?<"": null detected, returning X"

        severity warning;

      return 'X';

    else

      lresize := resize (l, left_index, right_index);

      rresize := resize (r, left_index, right_index);

      lslv := to_s (lresize);

      rslv := to_s (rresize);

      return \?<\ (lslv, rslv);

    end if;

  end function \?<\;



  function \?<=\ (L, R : UNRESOLVED_sfixed) return std_ulogic is

    constant left_index : integer := maximum(l'high, r'high);

    constant right_index : integer := mins(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_sfixed (left_index downto right_index);

    variable lslv, rslv : signed (lresize'length-1 downto 0);

  begin  -- ?<=

    if ((l'length < 1) or (r'length < 1)) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """?<="": null detected, returning X"

        severity warning;

      return 'X';

    else

      lresize := resize (l, left_index, right_index);

      rresize := resize (r, left_index, right_index);

      lslv := to_s (lresize);

      rslv := to_s (rresize);

      return \?<=\ (lslv, rslv);

    end if;

  end function \?<=\;



  -- Match function, similar to "std_match" from numeric_std

  function std_match (L, R : UNRESOLVED_ufixed) return boolean is

  begin

    if (L'high = R'high and L'low = R'low) then

      return std_match(to_sulv(L), to_sulv(R));

    else

      assert NO_WARNING

        report fixed_pkg'instance_name

        & "STD_MATCH: L'RANGE /= R'RANGE, returning FALSE"

        severity warning;

      return false;

    end if;

  end function std_match;



  function std_match (L, R : UNRESOLVED_sfixed) return boolean is

  begin

    if (L'high = R'high and L'low = R'low) then

      return std_match(to_sulv(L), to_sulv(R));

    else

      assert NO_WARNING

        report fixed_pkg'instance_name

        & "STD_MATCH: L'RANGE /= R'RANGE, returning FALSE"

        severity warning;

      return false;

    end if;

  end function std_match;



  -- compare functions

  function "=" (

    l, r : UNRESOLVED_ufixed)           -- fixed point input

    return boolean is

    constant left_index : integer := maximum(l'high, r'high);

    constant right_index : integer := mins(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_ufixed (left_index downto right_index);

    variable lslv, rslv : unsigned (lresize'length-1 downto 0);

  begin

    if (l'length < 1 or r'length < 1) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """="": null argument detected, returning FALSE"

        severity warning;

      return false;

    elsif (Is_X(l) or Is_X(r)) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """="": metavalue detected, returning FALSE"

        severity warning;

      return false;

    end if;

    lresize := resize (l, left_index, right_index);

    rresize := resize (r, left_index, right_index);

    lslv := to_uns (lresize);

    rslv := to_uns (rresize);

    return lslv = rslv;

  end function "=";



  function "=" (

    l, r : UNRESOLVED_sfixed)           -- fixed point input

    return boolean is

    constant left_index : integer := maximum(l'high, r'high);

    constant right_index : integer := mins(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_sfixed (left_index downto right_index);

    variable lslv, rslv : signed (lresize'length-1 downto 0);

  begin

    if (l'length < 1 or r'length < 1) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """="": null argument detected, returning FALSE"

        severity warning;

      return false;

    elsif (Is_X(l) or Is_X(r)) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """="": metavalue detected, returning FALSE"

        severity warning;

      return false;

    end if;

    lresize := resize (l, left_index, right_index);

    rresize := resize (r, left_index, right_index);

    lslv := to_s (lresize);

    rslv := to_s (rresize);

    return lslv = rslv;

  end function "=";



  function "/=" (

    l, r : UNRESOLVED_ufixed)           -- fixed point input

    return boolean is

    constant left_index : integer := maximum(l'high, r'high);

    constant right_index : integer := mins(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_ufixed (left_index downto right_index);

    variable lslv, rslv : unsigned (lresize'length-1 downto 0);

  begin

    if (l'length < 1 or r'length < 1) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """/="": null argument detected, returning TRUE"

        severity warning;

      return true;

    elsif (Is_X(l) or Is_X(r)) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """/="": metavalue detected, returning TRUE"

        severity warning;

      return true;

    end if;

    lresize := resize (l, left_index, right_index);

    rresize := resize (r, left_index, right_index);

    lslv := to_uns (lresize);

    rslv := to_uns (rresize);

    return lslv /= rslv;

  end function "/=";



  function "/=" (

    l, r : UNRESOLVED_sfixed)           -- fixed point input

    return boolean is

    constant left_index : integer := maximum(l'high, r'high);

    constant right_index : integer := mins(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_sfixed (left_index downto right_index);

    variable lslv, rslv : signed (lresize'length-1 downto 0);

  begin

    if (l'length < 1 or r'length < 1) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """/="": null argument detected, returning TRUE"

        severity warning;

      return true;

    elsif (Is_X(l) or Is_X(r)) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """/="": metavalue detected, returning TRUE"

        severity warning;

      return true;

    end if;

    lresize := resize (l, left_index, right_index);

    rresize := resize (r, left_index, right_index);

    lslv := to_s (lresize);

    rslv := to_s (rresize);

    return lslv /= rslv;

  end function "/=";



  function ">" (

    l, r : UNRESOLVED_ufixed)           -- fixed point input

    return boolean is

    constant left_index : integer := maximum(l'high, r'high);

    constant right_index : integer := mins(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_ufixed (left_index downto right_index);

    variable lslv, rslv : unsigned (lresize'length-1 downto 0);

  begin

    if (l'length < 1 or r'length < 1) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """>"": null argument detected, returning FALSE"

        severity warning;

      return false;

    elsif (Is_X(l) or Is_X(r)) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """>"": metavalue detected, returning FALSE"

        severity warning;

      return false;

    end if;

    lresize := resize (l, left_index, right_index);

    rresize := resize (r, left_index, right_index);

    lslv := to_uns (lresize);

    rslv := to_uns (rresize);

    return lslv > rslv;

  end function ">";



  function ">" (

    l, r : UNRESOLVED_sfixed)           -- fixed point input

    return boolean is

    constant left_index : integer := maximum(l'high, r'high);

    constant right_index : integer := mins(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_sfixed (left_index downto right_index);

    variable lslv, rslv : signed (lresize'length-1 downto 0);

  begin

    if (l'length < 1 or r'length < 1) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """>"": null argument detected, returning FALSE"

        severity warning;

      return false;

    elsif (Is_X(l) or Is_X(r)) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """>"": metavalue detected, returning FALSE"

        severity warning;

      return false;

    end if;

    lresize := resize (l, left_index, right_index);

    rresize := resize (r, left_index, right_index);

    lslv := to_s (lresize);

    rslv := to_s (rresize);

    return lslv > rslv;

  end function ">";



  function "<" (

    l, r : UNRESOLVED_ufixed)           -- fixed point input

    return boolean is

    constant left_index : integer := maximum(l'high, r'high);

    constant right_index : integer := mins(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_ufixed (left_index downto right_index);

    variable lslv, rslv : unsigned (lresize'length-1 downto 0);

  begin

    if (l'length < 1 or r'length < 1) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """<"": null argument detected, returning FALSE"

        severity warning;

      return false;

    elsif (Is_X(l) or Is_X(r)) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """<"": metavalue detected, returning FALSE"

        severity warning;

      return false;

    end if;

    lresize := resize (l, left_index, right_index);

    rresize := resize (r, left_index, right_index);

    lslv := to_uns (lresize);

    rslv := to_uns (rresize);

    return lslv < rslv;

  end function "<";



  function "<" (

    l, r : UNRESOLVED_sfixed)           -- fixed point input

    return boolean is

    constant left_index : integer := maximum(l'high, r'high);

    constant right_index : integer := mins(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_sfixed (left_index downto right_index);

    variable lslv, rslv : signed (lresize'length-1 downto 0);

  begin

    if (l'length < 1 or r'length < 1) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """<"": null argument detected, returning FALSE"

        severity warning;

      return false;

    elsif (Is_X(l) or Is_X(r)) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """<"": metavalue detected, returning FALSE"

        severity warning;

      return false;

    end if;

    lresize := resize (l, left_index, right_index);

    rresize := resize (r, left_index, right_index);

    lslv := to_s (lresize);

    rslv := to_s (rresize);

    return lslv < rslv;

  end function "<";



  function ">=" (

    l, r : UNRESOLVED_ufixed)           -- fixed point input

    return boolean is

    constant left_index : integer := maximum(l'high, r'high);

    constant right_index : integer := mins(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_ufixed (left_index downto right_index);

    variable lslv, rslv : unsigned (lresize'length-1 downto 0);

  begin

    if (l'length < 1 or r'length < 1) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """>="": null argument detected, returning FALSE"

        severity warning;

      return false;

    elsif (Is_X(l) or Is_X(r)) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """>="": metavalue detected, returning FALSE"

        severity warning;

      return false;

    end if;

    lresize := resize (l, left_index, right_index);

    rresize := resize (r, left_index, right_index);

    lslv := to_uns (lresize);

    rslv := to_uns (rresize);

    return lslv >= rslv;

  end function ">=";



  function ">=" (

    l, r : UNRESOLVED_sfixed)           -- fixed point input

    return boolean is

    constant left_index : integer := maximum(l'high, r'high);

    constant right_index : integer := mins(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_sfixed (left_index downto right_index);

    variable lslv, rslv : signed (lresize'length-1 downto 0);

  begin

    if (l'length < 1 or r'length < 1) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """>="": null argument detected, returning FALSE"

        severity warning;

      return false;

    elsif (Is_X(l) or Is_X(r)) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """>="": metavalue detected, returning FALSE"

        severity warning;

      return false;

    end if;

    lresize := resize (l, left_index, right_index);

    rresize := resize (r, left_index, right_index);

    lslv := to_s (lresize);

    rslv := to_s (rresize);

    return lslv >= rslv;

  end function ">=";



  function "<=" (

    l, r : UNRESOLVED_ufixed)           -- fixed point input

    return boolean is

    constant left_index : integer := maximum(l'high, r'high);

    constant right_index : integer := mins(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_ufixed (left_index downto right_index);

    variable lslv, rslv : unsigned (lresize'length-1 downto 0);

  begin

    if (l'length < 1 or r'length < 1) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """<="": null argument detected, returning FALSE"

        severity warning;

      return false;

    elsif (Is_X(l) or Is_X(r)) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """<="": metavalue detected, returning FALSE"

        severity warning;

      return false;

    end if;

    lresize := resize (l, left_index, right_index);

    rresize := resize (r, left_index, right_index);

    lslv := to_uns (lresize);

    rslv := to_uns (rresize);

    return lslv <= rslv;

  end function "<=";



  function "<=" (

    l, r : UNRESOLVED_sfixed)           -- fixed point input

    return boolean is

    constant left_index : integer := maximum(l'high, r'high);

    constant right_index : integer := mins(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_sfixed (left_index downto right_index);

    variable lslv, rslv : signed (lresize'length-1 downto 0);

  begin

    if (l'length < 1 or r'length < 1) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """<="": null argument detected, returning FALSE"

        severity warning;

      return false;

    elsif (Is_X(l) or Is_X(r)) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & """<="": metavalue detected, returning FALSE"

        severity warning;

      return false;

    end if;

    lresize := resize (l, left_index, right_index);

    rresize := resize (r, left_index, right_index);

    lslv := to_s (lresize);

    rslv := to_s (rresize);

    return lslv <= rslv;

  end function "<=";



  -- overloads of the default maximum and minimum functions

  function maximum (l, r : UNRESOLVED_ufixed) return UNRESOLVED_ufixed is

    constant left_index : integer := maximum(l'high, r'high);

    constant right_index : integer := mins(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_ufixed (left_index downto right_index);

  begin

    if (l'length < 1 or r'length < 1) then

      return NAUF;

    end if;

    lresize := resize (l, left_index, right_index);

    rresize := resize (r, left_index, right_index);

    if lresize > rresize then return lresize;

    else return rresize;

    end if;

  end function maximum;



  function maximum (l, r : UNRESOLVED_sfixed) return UNRESOLVED_sfixed is

    constant left_index : integer := maximum(l'high, r'high);

    constant right_index : integer := mins(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_sfixed (left_index downto right_index);

  begin

    if (l'length < 1 or r'length < 1) then

      return NASF;

    end if;

    lresize := resize (l, left_index, right_index);

    rresize := resize (r, left_index, right_index);

    if lresize > rresize then return lresize;

    else return rresize;

    end if;

  end function maximum;



  function minimum (l, r : UNRESOLVED_ufixed) return UNRESOLVED_ufixed is

    constant left_index : integer := maximum(l'high, r'high);

    constant right_index : integer := mins(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_ufixed (left_index downto right_index);

  begin

    if (l'length < 1 or r'length < 1) then

      return NAUF;

    end if;

    lresize := resize (l, left_index, right_index);

    rresize := resize (r, left_index, right_index);

    if lresize > rresize then return rresize;

    else return lresize;

    end if;

  end function minimum;



  function minimum (l, r : UNRESOLVED_sfixed) return UNRESOLVED_sfixed is

    constant left_index : integer := maximum(l'high, r'high);

    constant right_index : integer := mins(l'low, r'low);

    variable lresize, rresize : UNRESOLVED_sfixed (left_index downto right_index);

  begin

    if (l'length < 1 or r'length < 1) then

      return NASF;

    end if;

    lresize := resize (l, left_index, right_index);

    rresize := resize (r, left_index, right_index);

    if lresize > rresize then return rresize;

    else return lresize;

    end if;

  end function minimum;



  function to_ufixed (

    arg : natural;                      -- integer

    constant left_index : integer;      -- left index (high index)

    constant right_index : integer := 0;  -- right index

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return UNRESOLVED_ufixed is

    constant fw : integer := mins (right_index, right_index);  -- catch literals

    variable result : UNRESOLVED_ufixed (left_index downto fw);

    variable sresult : UNRESOLVED_ufixed (left_index downto 0) :=

      (others => '0');                  -- integer portion

    variable argx : natural;            -- internal version of arg

  begin

    if (result'length < 1) then

      return NAUF;

    end if;

    if arg /= 0 then

      argx := arg;

      for I in 0 to sresult'left loop

        if (argx mod 2) = 0 then

          sresult(I) := '0';

        else

          sresult(I) := '1';

        end if;

        argx := argx/2;

      end loop;

      if argx /= 0 then

        assert NO_WARNING

          report fixed_pkg'instance_name

          & "TO_UFIXED(NATURAL): vector truncated"

          severity warning;

        if overflow_style = fixed_saturate then

          return saturate (left_index, right_index);

        end if;

      end if;

      result := resize (arg => sresult,

                        left_index => left_index,

                        right_index => right_index,

                        round_style => round_style,

                        overflow_style => overflow_style);

    else

      result := (others => '0');

    end if;

    return result;

  end function to_ufixed;



  function to_sfixed (

    arg : integer;                      -- integer

    constant left_index : integer;      -- left index (high index)

    constant right_index : integer := 0;  -- right index

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return UNRESOLVED_sfixed is

    constant fw : integer := mins (right_index, right_index);  -- catch literals

    variable result : UNRESOLVED_sfixed (left_index downto fw);

    variable sresult : UNRESOLVED_sfixed (left_index downto 0) :=

      (others => '0');                  -- integer portion

    variable argx : integer;            -- internal version of arg

    variable sign : std_ulogic;         -- sign of input

  begin

    if (result'length < 1) then         -- null range

      return NASF;

    end if;

    if arg /= 0 then

      if (arg < 0) then

        sign := '1';

        argx := -(arg + 1);

      else

        sign := '0';

        argx := arg;

      end if;

      for I in 0 to sresult'left loop

        if (argx mod 2) = 0 then

          sresult(I) := sign;

        else

          sresult(I) := not sign;

        end if;

        argx := argx/2;

      end loop;

      if argx /= 0 or left_index < 0 or sign /= sresult(sresult'left) then

        assert NO_WARNING

          report fixed_pkg'instance_name

          & "TO_SFIXED(INTEGER): vector truncated"

          severity warning;

        if overflow_style = fixed_saturate then  -- saturate

          if arg < 0 then

            result := not saturate (result'high, result'low);  -- underflow

          else

            result := saturate (result'high, result'low);  -- overflow

          end if;

          return result;

        end if;

      end if;

      result := resize (arg => sresult,

                        left_index => left_index,

                        right_index => right_index,

                        round_style => round_style,

                        overflow_style => overflow_style);

    else

      result := (others => '0');

    end if;

    return result;

  end function to_sfixed;



  function to_ufixed (

    arg : real;                         -- real

    constant left_index : integer;      -- left index (high index)

    constant right_index : integer;     -- right index

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style;

    constant guard_bits : natural := fixed_guard_bits)  -- # of guard bits

    return UNRESOLVED_ufixed is

    constant fw : integer := mins (right_index, right_index);  -- catch literals

    variable result : UNRESOLVED_ufixed (left_index downto fw) :=

      (others => '0');

    variable Xresult : UNRESOLVED_ufixed (left_index downto

                                          fw-guard_bits) :=

      (others => '0');

    variable presult : real;

--    variable overflow_needed : BOOLEAN;

  begin

    -- If negative or null range, return.

    if (left_index < fw) then

      return NAUF;

    end if;

    if (arg < 0.0) then

      report fixed_pkg'instance_name

        & "TO_UFIXED: Negative argument passed "

        & real'image(arg) severity error;

      return result;

    end if;

    presult := arg;

    if presult >= (2.0**(left_index+1)) then

      assert NO_WARNING report fixed_pkg'instance_name

        & "TO_UFIXED(REAL): vector truncated"

        severity warning;

      if overflow_style = fixed_wrap then

        presult := presult mod (2.0**(left_index+1));  -- wrap

      else

        return saturate (result'high, result'low);

      end if;

    end if;

    for i in Xresult'range loop

      if presult >= 2.0**i then

        Xresult(i) := '1';

        presult := presult - 2.0**i;

      else

        Xresult(i) := '0';

      end if;

    end loop;

    if guard_bits > 0 and round_style = fixed_round then

      result := round_fixed (arg => Xresult (left_index

                                             downto right_index),

                             remainder => Xresult (right_index-1 downto

                                                   right_index-guard_bits),

                             overflow_style => overflow_style);

    else

      result := Xresult (result'range);

    end if;

    return result;

  end function to_ufixed;



  function to_sfixed (

    arg : real;                         -- real

    constant left_index : integer;      -- left index (high index)

    constant right_index : integer;     -- right index

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style;

    constant guard_bits : natural := fixed_guard_bits)  -- # of guard bits

    return UNRESOLVED_sfixed is

    constant fw : integer := mins (right_index, right_index);  -- catch literals

    variable result : UNRESOLVED_sfixed (left_index downto fw) :=

      (others => '0');

    variable Xresult : UNRESOLVED_sfixed (left_index+1 downto fw-guard_bits) :=

      (others => '0');

    variable presult : real;

  begin

    if (left_index < fw) then           -- null range

      return NASF;

    end if;

    if (arg >= (2.0**left_index) or arg < -(2.0**left_index)) then

      assert NO_WARNING report fixed_pkg'instance_name

        & "TO_SFIXED(REAL): vector truncated"

        severity warning;

      if overflow_style = fixed_saturate then

        if arg < 0.0 then               -- saturate

          result := not saturate (result'high, result'low);  -- underflow

        else

          result := saturate (result'high, result'low);  -- overflow

        end if;

        return result;

      else

        presult := abs(arg) mod (2.0**(left_index+1));  -- wrap

      end if;

    else

      presult := abs(arg);

    end if;

    for i in Xresult'range loop

      if presult >= 2.0**i then

        Xresult(i) := '1';

        presult := presult - 2.0**i;

      else

        Xresult(i) := '0';

      end if;

    end loop;

    if arg < 0.0 then

      Xresult := to_fixed(-to_s(Xresult), Xresult'high, Xresult'low);

    end if;

    if guard_bits > 0 and round_style = fixed_round then

      result := round_fixed (arg => Xresult (left_index

                                             downto right_index),

                             remainder => Xresult (right_index-1 downto

                                                   right_index-guard_bits),

                             overflow_style => overflow_style);

    else

      result := Xresult (result'range);

    end if;

    return result;

  end function to_sfixed;



  function to_ufixed (

    arg : unsigned;                     -- unsigned

    constant left_index : integer;      -- left index (high index)

    constant right_index : integer := 0;  -- right index

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return UNRESOLVED_ufixed is

    constant ARG_LEFT : integer := ARG'length-1;

    alias XARG : unsigned(ARG_LEFT downto 0) is ARG;

    variable result : UNRESOLVED_ufixed (left_index downto right_index);

  begin

    if arg'length < 1 or (left_index < right_index) then

      return NAUF;

    end if;

    result := resize (arg => UNRESOLVED_ufixed (XARG),

                      left_index => left_index,

                      right_index => right_index,

                      round_style => round_style,

                      overflow_style => overflow_style);

    return result;

  end function to_ufixed;



  -- converted version

  function to_ufixed (

    arg : unsigned)                     -- unsigned

    return UNRESOLVED_ufixed is

    constant ARG_LEFT : integer := ARG'length-1;

    alias XARG : unsigned(ARG_LEFT downto 0) is ARG;

  begin

    if arg'length < 1 then

      return NAUF;

    end if;

    return UNRESOLVED_ufixed(xarg);

  end function to_ufixed;



  function to_sfixed (

    arg : signed;                       -- signed

    constant left_index : integer;      -- left index (high index)

    constant right_index : integer := 0;  -- right index

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return UNRESOLVED_sfixed is

    constant ARG_LEFT : integer := ARG'length-1;

    alias XARG : signed(ARG_LEFT downto 0) is ARG;

    variable result : UNRESOLVED_sfixed (left_index downto right_index);

  begin

    if arg'length < 1 or (left_index < right_index) then

      return NASF;

    end if;

    result := resize (arg => UNRESOLVED_sfixed (XARG),

                      left_index => left_index,

                      right_index => right_index,

                      round_style => round_style,

                      overflow_style => overflow_style);

    return result;

  end function to_sfixed;



  -- converted version

  function to_sfixed (

    arg : signed)                       -- signed

    return UNRESOLVED_sfixed is

    constant ARG_LEFT : integer := ARG'length-1;

    alias XARG : signed(ARG_LEFT downto 0) is ARG;

  begin

    if arg'length < 1 then

      return NASF;

    end if;

    return UNRESOLVED_sfixed(xarg);

  end function to_sfixed;



  function to_sfixed (arg : UNRESOLVED_ufixed) return UNRESOLVED_sfixed is

    variable result : UNRESOLVED_sfixed (arg'high+1 downto arg'low);

  begin

    if arg'length < 1 then

      return NASF;

    end if;

    result (arg'high downto arg'low) := UNRESOLVED_sfixed(cleanvec(arg));

    result (arg'high+1) := '0';

    return result;

  end function to_sfixed;



  -- Because of the fairly complicated sizing rules in the fixed point

  -- packages these functions are provided to compute the result ranges

  -- Example:

  -- signal uf1 : ufixed (3 downto -3);

  -- signal uf2 : ufixed (4 downto -2);

  -- signal uf1multuf2 : ufixed (ufixed_high (3, -3, '*', 4, -2) downto

  --                             ufixed_low (3, -3, '*', 4, -2));

  -- uf1multuf2 <= uf1 * uf2;

  -- Valid characters: '+', '-', '*', '/', 'r' or 'R' (rem), 'm' or 'M' (mod),

  -- '1' (reciprocal), 'A', 'a' (abs), 'N', 'n' (-sfixed)

  function ufixed_high (left_index, right_index : integer;

                        operation : character := 'X';

                        left_index2, right_index2 : integer := 0)

    return integer is

  begin

    case operation is

      when '+'| '-' => return maximum (left_index, left_index2) + 1;

      when '*' => return left_index + left_index2 + 1;

      when '/' => return left_index - right_index2;

      when '1' => return -right_index;  -- reciprocal

      when 'R'|'r' => return mins (left_index, left_index2);  -- "rem"

      when 'M'|'m' => return mins (left_index, left_index2);  -- "mod"

      when others => return left_index;  -- For abs and default

    end case;

  end function ufixed_high;



  function ufixed_low (left_index, right_index : integer;

                       operation : character := 'X';

                       left_index2, right_index2 : integer := 0)

    return integer is

  begin

    case operation is

      when '+'| '-' => return mins (right_index, right_index2);

      when '*' => return right_index + right_index2;

      when '/' => return right_index - left_index2 - 1;

      when '1' => return -left_index - 1;  -- reciprocal

      when 'R'|'r' => return mins (right_index, right_index2);  -- "rem"

      when 'M'|'m' => return mins (right_index, right_index2);  -- "mod"

      when others => return right_index;  -- for abs and default

    end case;

  end function ufixed_low;



  function sfixed_high (left_index, right_index : integer;

                        operation : character := 'X';

                        left_index2, right_index2 : integer := 0)

    return integer is

  begin

    case operation is

      when '+'| '-' => return maximum (left_index, left_index2) + 1;

      when '*' => return left_index + left_index2 + 1;

      when '/' => return left_index - right_index2 + 1;

      when '1' => return -right_index + 1;  -- reciprocal

      when 'R'|'r' => return mins (left_index, left_index2);  -- "rem"

      when 'M'|'m' => return left_index2;  -- "mod"

      when 'A'|'a' => return left_index + 1;  -- "abs"

      when 'N'|'n' => return left_index + 1;  -- -sfixed

      when others => return left_index;

    end case;

  end function sfixed_high;



  function sfixed_low (left_index, right_index : integer;

                       operation : character := 'X';

                       left_index2, right_index2 : integer := 0)

    return integer is

  begin

    case operation is

      when '+'| '-' => return mins (right_index, right_index2);

      when '*' => return right_index + right_index2;

      when '/' => return right_index - left_index2;

      when '1' => return -left_index;   -- reciprocal

      when 'R'|'r' => return mins (right_index, right_index2);  -- "rem"

      when 'M'|'m' => return mins (right_index, right_index2);  -- "mod"

      when others => return right_index;  -- default for abs, neg and default

    end case;

  end function sfixed_low;



  -- Same as above, but using the "size_res" input only for their ranges:

  -- signal uf1multuf2 : ufixed (ufixed_high (uf1, '*', uf2) downto

  --                             ufixed_low (uf1, '*', uf2));

  -- uf1multuf2 <= uf1 * uf2;  

  function ufixed_high (size_res : UNRESOLVED_ufixed;

                        operation : character := 'X';

                        size_res2 : UNRESOLVED_ufixed)

    return integer is

  begin

    return ufixed_high (left_index => size_res'high,

                        right_index => size_res'low,

                        operation => operation,

                        left_index2 => size_res2'high,

                        right_index2 => size_res2'low);

  end function ufixed_high;



  function ufixed_low (size_res : UNRESOLVED_ufixed;

                       operation : character := 'X';

                       size_res2 : UNRESOLVED_ufixed)

    return integer is

  begin

    return ufixed_low (left_index => size_res'high,

                       right_index => size_res'low,

                       operation => operation,

                       left_index2 => size_res2'high,

                       right_index2 => size_res2'low);

  end function ufixed_low;



  function sfixed_high (size_res : UNRESOLVED_sfixed;

                        operation : character := 'X';

                        size_res2 : UNRESOLVED_sfixed)

    return integer is

  begin

    return sfixed_high (left_index => size_res'high,

                        right_index => size_res'low,

                        operation => operation,

                        left_index2 => size_res2'high,

                        right_index2 => size_res2'low);

  end function sfixed_high;



  function sfixed_low (size_res : UNRESOLVED_sfixed;

                       operation : character := 'X';

                       size_res2 : UNRESOLVED_sfixed)

    return integer is

  begin

    return sfixed_low (left_index => size_res'high,

                       right_index => size_res'low,

                       operation => operation,

                       left_index2 => size_res2'high,

                       right_index2 => size_res2'low);

  end function sfixed_low;



  -- purpose: returns a saturated number

  function saturate (

    constant left_index : integer;

    constant right_index : integer)

    return UNRESOLVED_ufixed is

    constant sat : UNRESOLVED_ufixed (left_index downto right_index) :=

      (others => '1');

  begin

    return sat;

  end function saturate;



  -- purpose: returns a saturated number

  function saturate (

    constant left_index : integer;

    constant right_index : integer)

    return UNRESOLVED_sfixed is

    variable sat : UNRESOLVED_sfixed (left_index downto right_index) :=

      (others => '1');

  begin

    -- saturate positive, to saturate negative, just do "not saturate()"

    sat (left_index) := '0';

    return sat;

  end function saturate;



  function saturate (

    size_res : UNRESOLVED_ufixed)       -- only the size of this is used

    return UNRESOLVED_ufixed is

  begin

    return saturate (size_res'high, size_res'low);

  end function saturate;



  function saturate (

    size_res : UNRESOLVED_sfixed)       -- only the size of this is used

    return UNRESOLVED_sfixed is

  begin

    return saturate (size_res'high, size_res'low);

  end function saturate;



  -- As a concession to those who use a graphical DSP environment,

  -- these functions take parameters in those tools format and create

  -- fixed point numbers.  These functions are designed to convert from

  -- a std_logic_vector to the VHDL fixed point format using the conventions

  -- of these packages.  In a pure VHDL environment you should use the

  -- "to_ufixed" and "to_sfixed" routines.

  -- Unsigned fixed point

  function to_UFix (

    arg : std_ulogic_vector;

    width : natural;                    -- width of vector

    fraction : natural)                 -- width of fraction

    return UNRESOLVED_ufixed is

    variable result : UNRESOLVED_ufixed (width-fraction-1 downto -fraction);

  begin

    if (arg'length /= result'length) then

      report fixed_pkg'instance_name

        & "TO_UFIX (STD_ULOGIC_VECTOR) "

        & "Vector lengths do not match.  Input length is "

        & integer'image(arg'length) & " and output will be "

        & integer'image(result'length) & " wide."

        severity error;

      return NAUF;

    else

      result := to_ufixed (arg, result'high, result'low);

      return result;

    end if;

  end function to_UFix;



  -- signed fixed point

  function to_SFix (

    arg : std_ulogic_vector;

    width : natural;                    -- width of vector

    fraction : natural)                 -- width of fraction

    return UNRESOLVED_sfixed is

    variable result : UNRESOLVED_sfixed (width-fraction-1 downto -fraction);

  begin

    if (arg'length /= result'length) then

      report fixed_pkg'instance_name

        & "TO_SFIX (STD_ULOGIC_VECTOR) "

        & "Vector lengths do not match.  Input length is "

        & integer'image(arg'length) & " and output will be "

        & integer'image(result'length) & " wide."

        severity error;

      return NASF;

    else

      result := to_sfixed (arg, result'high, result'low);

      return result;

    end if;

  end function to_SFix;



  -- finding the bounds of a number.  These functions can be used like this:

  -- signal xxx : ufixed (7 downto -3);

  -- -- Which is the same as "ufixed (UFix_high (11,3) downto UFix_low(11,3))"

  -- signal yyy : ufixed (UFix_high (11, 3, "+", 11, 3)

  --               downto UFix_low(11, 3, "+", 11, 3));

  -- Where "11" is the width of xxx (xxx'length),

  -- and 3 is the lower bound (abs (xxx'low))

  -- In a pure VHDL environment use "ufixed_high" and "ufixed_low"

  function ufix_high (

    width, fraction : natural;

    operation : character := 'X';

    width2, fraction2 : natural := 0)

    return integer is

  begin

    return ufixed_high (left_index => width - 1 - fraction,

                        right_index => -fraction,

                        operation => operation,

                        left_index2 => width2 - 1 - fraction2,

                        right_index2 => -fraction2);

  end function ufix_high;



  function ufix_low (

    width, fraction : natural;

    operation : character := 'X';

    width2, fraction2 : natural := 0)

    return integer is

  begin

    return ufixed_low (left_index => width - 1 - fraction,

                       right_index => -fraction,

                       operation => operation,

                       left_index2 => width2 - 1 - fraction2,

                       right_index2 => -fraction2);

  end function ufix_low;



  function sfix_high (

    width, fraction : natural;

    operation : character := 'X';

    width2, fraction2 : natural := 0)

    return integer is

  begin

    return sfixed_high (left_index => width - fraction,

                        right_index => -fraction,

                        operation => operation,

                        left_index2 => width2 - fraction2,

                        right_index2 => -fraction2);

  end function sfix_high;



  function sfix_low (

    width, fraction : natural;

    operation : character := 'X';

    width2, fraction2 : natural := 0)

    return integer is

  begin

    return sfixed_low (left_index => width - fraction,

                       right_index => -fraction,

                       operation => operation,

                       left_index2 => width2 - fraction2,

                       right_index2 => -fraction2);

  end function sfix_low;



  function to_unsigned (

    arg : UNRESOLVED_ufixed;            -- ufixed point input

    constant size : natural;            -- length of output

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return unsigned is

  begin

    return to_uns(resize (arg => arg,

                          left_index => size-1,

                          right_index => 0,

                          round_style => round_style,

                          overflow_style => overflow_style));

  end function to_unsigned;



  function to_unsigned (

    arg : UNRESOLVED_ufixed;            -- ufixed point input

    size_res : unsigned;                -- length of output

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return unsigned is

  begin

    return to_unsigned (arg => arg,

                        size => size_res'length,

                        round_style => round_style,

                        overflow_style => overflow_style);

  end function to_unsigned;



  function to_signed (

    arg : UNRESOLVED_sfixed;            -- sfixed point input

    constant size : natural;            -- length of output

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return signed is

  begin

    return to_s(resize (arg => arg,

                        left_index => size-1,

                        right_index => 0,

                        round_style => round_style,

                        overflow_style => overflow_style));

  end function to_signed;



  function to_signed (

    arg : UNRESOLVED_sfixed;            -- sfixed point input

    size_res : signed;                  -- used for length of output

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return signed is

  begin

    return to_signed (arg => arg,

                      size => size_res'length,

                      round_style => round_style,

                      overflow_style => overflow_style);

  end function to_signed;



  function to_real (

    arg : UNRESOLVED_ufixed)            -- ufixed point input

    return real is

    constant left_index : integer := arg'high;

    constant right_index : integer := arg'low;

    variable result : real;             -- result

    variable arg_int : UNRESOLVED_ufixed (left_index downto right_index);

  begin

    if (arg'length < 1) then

      return 0.0;

    end if;

    arg_int := to_x01(cleanvec(arg));

    if (Is_X(arg_int)) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & "TO_REAL (ufixed): metavalue detected, returning 0.0"

        severity warning;

      return 0.0;

    end if;

    result := 0.0;

    for i in arg_int'range loop

      if (arg_int(i) = '1') then

        result := result + (2.0**i);

      end if;

    end loop;

    return result;

  end function to_real;



  function to_real (

    arg : UNRESOLVED_sfixed)            -- ufixed point input

    return real is

    constant left_index : integer := arg'high;

    constant right_index : integer := arg'low;

    variable result : real;             -- result

    variable arg_int : UNRESOLVED_sfixed (left_index downto right_index);

    -- unsigned version of argument

    variable arg_uns : UNRESOLVED_ufixed (left_index downto right_index);

    -- absolute of argument

  begin

    if (arg'length < 1) then

      return 0.0;

    end if;

    arg_int := to_x01(cleanvec(arg));

    if (Is_X(arg_int)) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & "TO_REAL (sfixed): metavalue detected, returning 0.0"

        severity warning;

      return 0.0;

    end if;

    arg_uns := to_ufixed (arg_int);

    result := to_real (arg_uns);

    if (arg_int(arg_int'high) = '1') then

      result := -result;

    end if;

    return result;

  end function to_real;



  function to_integer (

    arg : UNRESOLVED_ufixed;            -- fixed point input

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return natural is

    constant left_index : integer := arg'high;

    variable arg_uns : unsigned (left_index+1 downto 0)

      := (others => '0');

  begin

    if (arg'length < 1) then

      return 0;

    end if;

    if (Is_X (arg)) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & "TO_INTEGER (ufixed): metavalue detected, returning 0"

        severity warning;

      return 0;

    end if;

    if (left_index < -1) then

      return 0;

    end if;

    arg_uns := to_uns(resize (arg => arg,

                              left_index => arg_uns'high,

                              right_index => 0,

                              round_style => round_style,

                              overflow_style => overflow_style));

    return to_integer (arg_uns);

  end function to_integer;



  function to_integer (

    arg : UNRESOLVED_sfixed;            -- fixed point input

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return integer is

    constant left_index : integer := arg'high;

    constant right_index : integer := arg'low;

    variable arg_s : signed (left_index+1 downto 0);

  begin

    if (arg'length < 1) then

      return 0;

    end if;

    if (Is_X (arg)) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & "TO_INTEGER (sfixed): metavalue detected, returning 0"

        severity warning;

      return 0;

    end if;

    if (left_index < -1) then

      return 0;

    end if;

    arg_s := to_s(resize (arg => arg,

                          left_index => arg_s'high,

                          right_index => 0,

                          round_style => round_style,

                          overflow_style => overflow_style));

    return to_integer (arg_s);

  end function to_integer;



  function to_01 (

    s : UNRESOLVED_ufixed;              -- ufixed point input

    constant XMAP : std_ulogic := '0')  -- Map x to

    return UNRESOLVED_ufixed is

    variable result : UNRESOLVED_ufixed (s'range);  -- result

  begin

    if (s'length < 1) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & "TO_01(ufixed): null detected, returning NULL"

        severity warning;

      return NAUF;

    end if;

    return to_fixed (to_01(to_uns(s), XMAP), s'high, s'low);

  end function to_01;



  function to_01 (

    s : UNRESOLVED_sfixed;              -- sfixed point input

    constant XMAP : std_ulogic := '0')  -- Map x to

    return UNRESOLVED_sfixed is

    variable result : UNRESOLVED_sfixed (s'range);

  begin

    if (s'length < 1) then

      assert NO_WARNING

        report fixed_pkg'instance_name

        & "TO_01(sfixed): null detected, returning NULL"

        severity warning;

      return NASF;

    end if;

    return to_fixed (to_01(to_s(s), XMAP), s'high, s'low);

  end function to_01;



  function Is_X (

    arg : UNRESOLVED_ufixed)

    return boolean is

    variable argslv : std_ulogic_vector (arg'length-1 downto 0);  -- slv

  begin

    argslv := to_sulv(arg);

    return Is_X (argslv);

  end function Is_X;



  function Is_X (

    arg : UNRESOLVED_sfixed)

    return boolean is

    variable argslv : std_ulogic_vector (arg'length-1 downto 0);  -- slv

  begin

    argslv := to_sulv(arg);

    return Is_X (argslv);

  end function Is_X;



  function To_X01 (

    arg : UNRESOLVED_ufixed)

    return UNRESOLVED_ufixed is

  begin

    return to_ufixed (To_X01(to_sulv(arg)), arg'high, arg'low);

  end function To_X01;



  function to_X01 (

    arg : UNRESOLVED_sfixed)

    return UNRESOLVED_sfixed is

  begin

    return to_sfixed (To_X01(to_sulv(arg)), arg'high, arg'low);

  end function To_X01;



  function To_X01Z (

    arg : UNRESOLVED_ufixed)

    return UNRESOLVED_ufixed is

  begin

    return to_ufixed (To_X01Z(to_sulv(arg)), arg'high, arg'low);

  end function To_X01Z;



  function to_X01Z (

    arg : UNRESOLVED_sfixed)

    return UNRESOLVED_sfixed is

  begin

    return to_sfixed (To_X01Z(to_sulv(arg)), arg'high, arg'low);

  end function To_X01Z;



  function To_UX01 (

    arg : UNRESOLVED_ufixed)

    return UNRESOLVED_ufixed is

  begin

    return to_ufixed (To_UX01(to_sulv(arg)), arg'high, arg'low);

  end function To_UX01;



  function to_UX01 (

    arg : UNRESOLVED_sfixed)

    return UNRESOLVED_sfixed is

  begin

    return to_sfixed (To_UX01(to_sulv(arg)), arg'high, arg'low);

  end function To_UX01;



  function resize (

    arg : UNRESOLVED_ufixed;            -- input

    constant left_index : integer;      -- integer portion

    constant right_index : integer;     -- size of fraction

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return UNRESOLVED_ufixed is

    constant arghigh : integer := maximum (arg'high, arg'low);

    constant arglow : integer := mine (arg'high, arg'low);

    variable invec : UNRESOLVED_ufixed (arghigh downto arglow);

    variable result : UNRESOLVED_ufixed(left_index downto right_index) :=

      (others => '0');

    variable needs_rounding : boolean := false;

  begin  -- resize

    if (arg'length < 1) or (result'length < 1) then

      return NAUF;

    elsif (invec'length < 1) then

      return result;                    -- string literal value

    else

      invec := cleanvec(arg);

      if (right_index > arghigh) then   -- return top zeros

        needs_rounding := (round_style = fixed_round) and

                          (right_index = arghigh+1);

      elsif (left_index < arglow) then  -- return overflow

        if (overflow_style = fixed_saturate) and

          (or_reduce(to_sulv(invec)) = '1') then

          result := saturate (result'high, result'low);  -- saturate

        end if;

      elsif (arghigh > left_index) then

        -- wrap or saturate?

        if (overflow_style = fixed_saturate and

            or_reduce (to_sulv(invec(arghigh downto left_index+1))) = '1')

        then

          result := saturate (result'high, result'low);  -- saturate

        else

          if (arglow >= right_index) then

            result (left_index downto arglow) :=

              invec(left_index downto arglow);

          else

            result (left_index downto right_index) :=

              invec (left_index downto right_index);

            needs_rounding := (round_style = fixed_round);  -- round

          end if;

        end if;

      else                              -- arghigh <= integer width

        if (arglow >= right_index) then

          result (arghigh downto arglow) := invec;

        else

          result (arghigh downto right_index) :=

            invec (arghigh downto right_index);

          needs_rounding := (round_style = fixed_round);  -- round

        end if;

      end if;

      -- Round result

      if needs_rounding then

        result := round_fixed (arg => result,

                               remainder => invec (right_index-1

                                                   downto arglow),

                               overflow_style => overflow_style);

      end if;

      return result;

    end if;

  end function resize;



  function resize (

    arg : UNRESOLVED_sfixed;            -- input

    constant left_index : integer;      -- integer portion

    constant right_index : integer;     -- size of fraction

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return UNRESOLVED_sfixed is

    constant arghigh : integer := maximum (arg'high, arg'low);

    constant arglow : integer := mine (arg'high, arg'low);

    variable invec : UNRESOLVED_sfixed (arghigh downto arglow);

    variable result : UNRESOLVED_sfixed(left_index downto right_index) :=

      (others => '0');

    variable reduced : std_ulogic;

    variable needs_rounding : boolean := false;  -- rounding

  begin  -- resize

    if (arg'length < 1) or (result'length < 1) then

      return NASF;

    elsif (invec'length < 1) then

      return result;                    -- string literal value

    else

      invec := cleanvec(arg);

      if (right_index > arghigh) then   -- return top zeros

        if (arg'low /= integer'low) then  -- check for a literal

          result := (others => arg(arghigh));  -- sign extend

        end if;

        needs_rounding := (round_style = fixed_round) and

                          (right_index = arghigh+1);

      elsif (left_index < arglow) then  -- return overflow

        if (overflow_style = fixed_saturate) then

          reduced := or_reduce (to_sulv(invec));

          if (reduced = '1') then

            if (invec(arghigh) = '0') then

              -- saturate POSITIVE

              result := saturate (result'high, result'low);

            else

              -- saturate negative

              result := not saturate (result'high, result'low);

            end if;

            -- else return 0 (input was 0)

          end if;

          -- else return 0 (wrap)

        end if;

      elsif (arghigh > left_index) then

        if (invec(arghigh) = '0') then

          reduced := or_reduce (to_sulv(invec(arghigh-1 downto

                                              left_index)));

          if overflow_style = fixed_saturate and reduced = '1' then

            -- saturate positive

            result := saturate (result'high, result'low);

          else

            if (right_index > arglow) then

              result := invec (left_index downto right_index);

              needs_rounding := (round_style = fixed_round);

            else

              result (left_index downto arglow) :=

                invec (left_index downto arglow);

            end if;

          end if;

        else

          reduced := and_reduce (to_sulv(invec(arghigh-1 downto

                                               left_index)));

          if overflow_style = fixed_saturate and reduced = '0' then

            result := not saturate (result'high, result'low);

          else

            if (right_index > arglow) then

              result := invec (left_index downto right_index);

              needs_rounding := (round_style = fixed_round);

            else

              result (left_index downto arglow) :=

                invec (left_index downto arglow);

            end if;

          end if;

        end if;

      else                              -- arghigh <= integer width

        if (arglow >= right_index) then

          result (arghigh downto arglow) := invec;

        else

          result (arghigh downto right_index) :=

            invec (arghigh downto right_index);

          needs_rounding := (round_style = fixed_round);  -- round

        end if;

        if (left_index > arghigh) then  -- sign extend

          result(left_index downto arghigh+1) := (others => invec(arghigh));

        end if;

      end if;

      -- Round result

      if (needs_rounding) then

        result := round_fixed (arg => result,

                               remainder => invec (right_index-1

                                                   downto arglow),

                               overflow_style => overflow_style);

      end if;

      return result;

    end if;

  end function resize;



  -- size_res functions

  -- These functions compute the size from a passed variable named "size_res"

  -- The only part of this variable used it it's size, it is never passed

  -- to a lower level routine.

  function to_ufixed (

    arg : std_ulogic_vector;            -- shifted vector

    size_res : UNRESOLVED_ufixed)       -- for size only

    return UNRESOLVED_ufixed is

    constant fw : integer := mine (size_res'low, size_res'low);  -- catch literals

    variable result : UNRESOLVED_ufixed (size_res'left downto fw);

  begin

    if (result'length < 1 or arg'length < 1) then

      return NAUF;

    else

      result := to_ufixed (arg => arg,

                           left_index => size_res'high,

                           right_index => size_res'low);

      return result;

    end if;

  end function to_ufixed;



  function to_sfixed (

    arg : std_ulogic_vector;            -- shifted vector

    size_res : UNRESOLVED_sfixed)       -- for size only

    return UNRESOLVED_sfixed is

    constant fw : integer := mine (size_res'low, size_res'low);  -- catch literals

    variable result : UNRESOLVED_sfixed (size_res'left downto fw);

  begin

    if (result'length < 1 or arg'length < 1) then

      return NASF;

    else

      result := to_sfixed (arg => arg,

                           left_index => size_res'high,

                           right_index => size_res'low);

      return result;

    end if;

  end function to_sfixed;



  function to_ufixed (

    arg : natural;                      -- integer

    size_res : UNRESOLVED_ufixed;       -- for size only

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return UNRESOLVED_ufixed is

    constant fw : integer := mine (size_res'low, size_res'low);  -- catch literals

    variable result : UNRESOLVED_ufixed (size_res'left downto fw);

  begin

    if (result'length < 1) then

      return NAUF;

    else

      result := to_ufixed (arg => arg,

                           left_index => size_res'high,

                           right_index => size_res'low,

                           round_style => round_style,

                           overflow_style => overflow_style);

      return result;

    end if;

  end function to_ufixed;



  function to_sfixed (

    arg : integer;                      -- integer

    size_res : UNRESOLVED_sfixed;       -- for size only

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return UNRESOLVED_sfixed is

    constant fw : integer := mine (size_res'low, size_res'low);  -- catch literals

    variable result : UNRESOLVED_sfixed (size_res'left downto fw);

  begin

    if (result'length < 1) then

      return NASF;

    else

      result := to_sfixed (arg => arg,

                           left_index => size_res'high,

                           right_index => size_res'low,

                           round_style => round_style,

                           overflow_style => overflow_style);

      return result;

    end if;

  end function to_sfixed;



  function to_ufixed (

    arg : real;                         -- real

    size_res : UNRESOLVED_ufixed;       -- for size only

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style;

    constant guard_bits : natural := fixed_guard_bits)  -- # of guard bits

    return UNRESOLVED_ufixed is

    constant fw : integer := mine (size_res'low, size_res'low);  -- catch literals

    variable result : UNRESOLVED_ufixed (size_res'left downto fw);

  begin

    if (result'length < 1) then

      return NAUF;

    else

      result := to_ufixed (arg => arg,

                           left_index => size_res'high,

                           right_index => size_res'low,

                           guard_bits => guard_bits,

                           round_style => round_style,

                           overflow_style => overflow_style);

      return result;

    end if;

  end function to_ufixed;



  function to_sfixed (

    arg : real;                         -- real

    size_res : UNRESOLVED_sfixed;       -- for size only

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style;

    constant guard_bits : natural := fixed_guard_bits)  -- # of guard bits

    return UNRESOLVED_sfixed is

    constant fw : integer := mine (size_res'low, size_res'low);  -- catch literals

    variable result : UNRESOLVED_sfixed (size_res'left downto fw);

  begin

    if (result'length < 1) then

      return NASF;

    else

      result := to_sfixed (arg => arg,

                           left_index => size_res'high,

                           right_index => size_res'low,

                           guard_bits => guard_bits,

                           round_style => round_style,

                           overflow_style => overflow_style);

      return result;

    end if;

  end function to_sfixed;



  function to_ufixed (

    arg : unsigned;                     -- unsigned

    size_res : UNRESOLVED_ufixed;       -- for size only

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return UNRESOLVED_ufixed is

    constant fw : integer := mine (size_res'low, size_res'low);  -- catch literals

    variable result : UNRESOLVED_ufixed (size_res'left downto fw);

  begin

    if (result'length < 1 or arg'length < 1) then

      return NAUF;

    else

      result := to_ufixed (arg => arg,

                           left_index => size_res'high,

                           right_index => size_res'low,

                           round_style => round_style,

                           overflow_style => overflow_style);

      return result;

    end if;

  end function to_ufixed;



  function to_sfixed (

    arg : signed;                       -- signed

    size_res : UNRESOLVED_sfixed;       -- for size only

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return UNRESOLVED_sfixed is

    constant fw : integer := mine (size_res'low, size_res'low);  -- catch literals

    variable result : UNRESOLVED_sfixed (size_res'left downto fw);

  begin

    if (result'length < 1 or arg'length < 1) then

      return NASF;

    else

      result := to_sfixed (arg => arg,

                           left_index => size_res'high,

                           right_index => size_res'low,

                           round_style => round_style,

                           overflow_style => overflow_style);

      return result;

    end if;

  end function to_sfixed;



  function resize (

    arg : UNRESOLVED_ufixed;            -- input

    size_res : UNRESOLVED_ufixed;       -- for size only

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return UNRESOLVED_ufixed is

    constant fw : integer := mine (size_res'low, size_res'low);  -- catch literals

    variable result : UNRESOLVED_ufixed (size_res'high downto fw);

  begin

    if (result'length < 1 or arg'length < 1) then

      return NAUF;

    else

      result := resize (arg => arg,

                        left_index => size_res'high,

                        right_index => size_res'low,

                        round_style => round_style,

                        overflow_style => overflow_style);

      return result;

    end if;

  end function resize;



  function resize (

    arg : UNRESOLVED_sfixed;            -- input

    size_res : UNRESOLVED_sfixed;       -- for size only

    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;

    constant round_style : fixed_round_style_type := fixed_round_style)

    return UNRESOLVED_sfixed is

    constant fw : integer := mine (size_res'low, size_res'low);  -- catch literals

    variable result : UNRESOLVED_sfixed (size_res'high downto fw);

  begin

    if (result'length < 1 or arg'length < 1) then

      return NASF;

    else

      result := resize (arg => arg,

                        left_index => size_res'high,

                        right_index => size_res'low,

                        round_style => round_style,

                        overflow_style => overflow_style);

      return result;

    end if;

  end function resize;



  -- Overloaded math functions for real

  function "+" (

    l : UNRESOLVED_ufixed;              -- fixed point input

    r : real)

    return UNRESOLVED_ufixed is

  begin

    return (l + to_ufixed (r, l'high, l'low));

  end function "+";



  function "+" (

    l : real;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return UNRESOLVED_ufixed is

  begin

    return (to_ufixed (l, r'high, r'low) + r);

  end function "+";



  function "+" (

    l : UNRESOLVED_sfixed;              -- fixed point input

    r : real)

    return UNRESOLVED_sfixed is

  begin

    return (l + to_sfixed (r, l'high, l'low));

  end function "+";



  function "+" (

    l : real;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return UNRESOLVED_sfixed is

  begin

    return (to_sfixed (l, r'high, r'low) + r);

  end function "+";



  function "-" (

    l : UNRESOLVED_ufixed;              -- fixed point input

    r : real)

    return UNRESOLVED_ufixed is

  begin

    return (l - to_ufixed (r, l'high, l'low));

  end function "-";



  function "-" (

    l : real;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return UNRESOLVED_ufixed is

  begin

    return (to_ufixed (l, r'high, r'low) - r);

  end function "-";



  function "-" (

    l : UNRESOLVED_sfixed;              -- fixed point input

    r : real)

    return UNRESOLVED_sfixed is

  begin

    return (l - to_sfixed (r, l'high, l'low));

  end function "-";



  function "-" (

    l : real;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return UNRESOLVED_sfixed is

  begin

    return (to_sfixed (l, r'high, r'low) - r);

  end function "-";



  function "*" (

    l : UNRESOLVED_ufixed;              -- fixed point input

    r : real)

    return UNRESOLVED_ufixed is

  begin

    return (l * to_ufixed (r, l'high, l'low));

  end function "*";



  function "*" (

    l : real;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return UNRESOLVED_ufixed is

  begin

    return (to_ufixed (l, r'high, r'low) * r);

  end function "*";



  function "*" (

    l : UNRESOLVED_sfixed;              -- fixed point input

    r : real)

    return UNRESOLVED_sfixed is

  begin

    return (l * to_sfixed (r, l'high, l'low));

  end function "*";



  function "*" (

    l : real;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return UNRESOLVED_sfixed is

  begin

    return (to_sfixed (l, r'high, r'low) * r);

  end function "*";



  function "/" (

    l : UNRESOLVED_ufixed;              -- fixed point input

    r : real)

    return UNRESOLVED_ufixed is

  begin

    return (l / to_ufixed (r, l'high, l'low));

  end function "/";



  function "/" (

    l : real;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return UNRESOLVED_ufixed is

  begin

    return (to_ufixed (l, r'high, r'low) / r);

  end function "/";



  function "/" (

    l : UNRESOLVED_sfixed;              -- fixed point input

    r : real)

    return UNRESOLVED_sfixed is

  begin

    return (l / to_sfixed (r, l'high, l'low));

  end function "/";



  function "/" (

    l : real;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return UNRESOLVED_sfixed is

  begin

    return (to_sfixed (l, r'high, r'low) / r);

  end function "/";



  function "rem" (

    l : UNRESOLVED_ufixed;              -- fixed point input

    r : real)

    return UNRESOLVED_ufixed is

  begin

    return (l rem to_ufixed (r, l'high, l'low));

  end function "rem";



  function "rem" (

    l : real;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return UNRESOLVED_ufixed is

  begin

    return (to_ufixed (l, r'high, r'low) rem r);

  end function "rem";



  function "rem" (

    l : UNRESOLVED_sfixed;              -- fixed point input

    r : real)

    return UNRESOLVED_sfixed is

  begin

    return (l rem to_sfixed (r, l'high, l'low));

  end function "rem";



  function "rem" (

    l : real;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return UNRESOLVED_sfixed is

  begin

    return (to_sfixed (l, r'high, r'low) rem r);

  end function "rem";



  function "mod" (

    l : UNRESOLVED_ufixed;              -- fixed point input

    r : real)

    return UNRESOLVED_ufixed is

  begin

    return (l mod to_ufixed (r, l'high, l'low));

  end function "mod";



  function "mod" (

    l : real;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return UNRESOLVED_ufixed is

  begin

    return (to_ufixed (l, r'high, r'low) mod r);

  end function "mod";



  function "mod" (

    l : UNRESOLVED_sfixed;              -- fixed point input

    r : real)

    return UNRESOLVED_sfixed is

  begin

    return (l mod to_sfixed (r, l'high, l'low));

  end function "mod";



  function "mod" (

    l : real;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return UNRESOLVED_sfixed is

  begin

    return (to_sfixed (l, r'high, r'low) mod r);

  end function "mod";



  -- Overloaded math functions for integers

  function "+" (

    l : UNRESOLVED_ufixed;              -- fixed point input

    r : natural)

    return UNRESOLVED_ufixed is

  begin

    return (l + to_ufixed (r, l'high, 0));

  end function "+";



  function "+" (

    l : natural;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return UNRESOLVED_ufixed is

  begin

    return (to_ufixed (l, r'high, 0) + r);

  end function "+";



  function "+" (

    l : UNRESOLVED_sfixed;              -- fixed point input

    r : integer)

    return UNRESOLVED_sfixed is

  begin

    return (l + to_sfixed (r, l'high, 0));

  end function "+";



  function "+" (

    l : integer;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return UNRESOLVED_sfixed is

  begin

    return (to_sfixed (l, r'high, 0) + r);

  end function "+";



  -- Overloaded functions

  function "-" (

    l : UNRESOLVED_ufixed;              -- fixed point input

    r : natural)

    return UNRESOLVED_ufixed is

  begin

    return (l - to_ufixed (r, l'high, 0));

  end function "-";



  function "-" (

    l : natural;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return UNRESOLVED_ufixed is

  begin

    return (to_ufixed (l, r'high, 0) - r);

  end function "-";



  function "-" (

    l : UNRESOLVED_sfixed;              -- fixed point input

    r : integer)

    return UNRESOLVED_sfixed is

  begin

    return (l - to_sfixed (r, l'high, 0));

  end function "-";



  function "-" (

    l : integer;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return UNRESOLVED_sfixed is

  begin

    return (to_sfixed (l, r'high, 0) - r);

  end function "-";



  -- Overloaded functions

  function "*" (

    l : UNRESOLVED_ufixed;              -- fixed point input

    r : natural)

    return UNRESOLVED_ufixed is

  begin

    return (l * to_ufixed (r, l'high, 0));

  end function "*";



  function "*" (

    l : natural;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return UNRESOLVED_ufixed is

  begin

    return (to_ufixed (l, r'high, 0) * r);

  end function "*";



  function "*" (

    l : UNRESOLVED_sfixed;              -- fixed point input

    r : integer)

    return UNRESOLVED_sfixed is

  begin

    return (l * to_sfixed (r, l'high, 0));

  end function "*";



  function "*" (

    l : integer;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return UNRESOLVED_sfixed is

  begin

    return (to_sfixed (l, r'high, 0) * r);

  end function "*";



  -- Overloaded functions

  function "/" (

    l : UNRESOLVED_ufixed;              -- fixed point input

    r : natural)

    return UNRESOLVED_ufixed is

  begin

    return (l / to_ufixed (r, l'high, 0));

  end function "/";



  function "/" (

    l : natural;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return UNRESOLVED_ufixed is

  begin

    return (to_ufixed (l, r'high, 0) / r);

  end function "/";



  function "/" (

    l : UNRESOLVED_sfixed;              -- fixed point input

    r : integer)

    return UNRESOLVED_sfixed is

  begin

    return (l / to_sfixed (r, l'high, 0));

  end function "/";



  function "/" (

    l : integer;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return UNRESOLVED_sfixed is

  begin

    return (to_sfixed (l, r'high, 0) / r);

  end function "/";



  function "rem" (

    l : UNRESOLVED_ufixed;              -- fixed point input

    r : natural)

    return UNRESOLVED_ufixed is

  begin

    return (l rem to_ufixed (r, l'high, 0));

  end function "rem";



  function "rem" (

    l : natural;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return UNRESOLVED_ufixed is

  begin

    return (to_ufixed (l, r'high, 0) rem r);

  end function "rem";



  function "rem" (

    l : UNRESOLVED_sfixed;              -- fixed point input

    r : integer)

    return UNRESOLVED_sfixed is

  begin

    return (l rem to_sfixed (r, l'high, 0));

  end function "rem";



  function "rem" (

    l : integer;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return UNRESOLVED_sfixed is

  begin

    return (to_sfixed (l, r'high, 0) rem r);

  end function "rem";



  function "mod" (

    l : UNRESOLVED_ufixed;              -- fixed point input

    r : natural)

    return UNRESOLVED_ufixed is

  begin

    return (l mod to_ufixed (r, l'high, 0));

  end function "mod";



  function "mod" (

    l : natural;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return UNRESOLVED_ufixed is

  begin

    return (to_ufixed (l, r'high, 0) mod r);

  end function "mod";



  function "mod" (

    l : UNRESOLVED_sfixed;              -- fixed point input

    r : integer)

    return UNRESOLVED_sfixed is

  begin

    return (l mod to_sfixed (r, l'high, 0));

  end function "mod";



  function "mod" (

    l : integer;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return UNRESOLVED_sfixed is

  begin

    return (to_sfixed (l, r'high, 0) mod r);

  end function "mod";



  -- overloaded ufixed compare functions with integer

  function "=" (

    l : UNRESOLVED_ufixed;

    r : natural)                        -- fixed point input

    return boolean is

  begin

    return (l = to_ufixed (r, l'high, l'low));

  end function "=";



  function "/=" (

    l : UNRESOLVED_ufixed;

    r : natural)                        -- fixed point input

    return boolean is

  begin

    return (l /= to_ufixed (r, l'high, l'low));

  end function "/=";



  function ">=" (

    l : UNRESOLVED_ufixed;

    r : natural)                        -- fixed point input

    return boolean is

  begin

    return (l >= to_ufixed (r, l'high, l'low));

  end function ">=";



  function "<=" (

    l : UNRESOLVED_ufixed;

    r : natural)                        -- fixed point input

    return boolean is

  begin

    return (l <= to_ufixed (r, l'high, l'low));

  end function "<=";



  function ">" (

    l : UNRESOLVED_ufixed;

    r : natural)                        -- fixed point input

    return boolean is

  begin

    return (l > to_ufixed (r, l'high, l'low));

  end function ">";



  function "<" (

    l : UNRESOLVED_ufixed;

    r : natural)                        -- fixed point input

    return boolean is

  begin

    return (l < to_ufixed (r, l'high, l'low));

  end function "<";



  function \?=\ (

    l : UNRESOLVED_ufixed;

    r : natural)                        -- fixed point input

    return std_ulogic is

  begin

    return \?=\ (l, to_ufixed (r, l'high, l'low));

  end function \?=\;



  function \?/=\ (

    l : UNRESOLVED_ufixed;

    r : natural)                        -- fixed point input

    return std_ulogic is

  begin

    return \?/=\ (l, to_ufixed (r, l'high, l'low));

  end function \?/=\;



  function \?>=\ (

    l : UNRESOLVED_ufixed;

    r : natural)                        -- fixed point input

    return std_ulogic is

  begin

    return \?>=\ (l, to_ufixed (r, l'high, l'low));

  end function \?>=\;



  function \?<=\ (

    l : UNRESOLVED_ufixed;

    r : natural)                        -- fixed point input

                 return std_ulogic is

  begin

    return \?<=\ (l, to_ufixed (r, l'high, l'low));

  end function \?<=\;



  function \?>\ (

    l : UNRESOLVED_ufixed;

    r : natural)                        -- fixed point input

    return std_ulogic is

  begin

    return \?>\ (l, to_ufixed (r, l'high, l'low));

  end function \?>\;



  function \?<\ (

    l : UNRESOLVED_ufixed;

    r : natural)                        -- fixed point input

    return std_ulogic is

  begin

    return \?<\ (l, to_ufixed (r, l'high, l'low));

  end function \?<\;



  function maximum (

    l : UNRESOLVED_ufixed;              -- fixed point input

    r : natural)

    return UNRESOLVED_ufixed is

  begin

    return maximum (l, to_ufixed (r, l'high, l'low));

  end function maximum;



  function minimum (

    l : UNRESOLVED_ufixed;              -- fixed point input

    r : natural)

    return UNRESOLVED_ufixed is

  begin

    return minimum (l, to_ufixed (r, l'high, l'low));

  end function minimum;



  -- NATURAL to ufixed

  function "=" (

    l : natural;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return boolean is

  begin

    return (to_ufixed (l, r'high, r'low) = r);

  end function "=";



  function "/=" (

    l : natural;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return boolean is

  begin

    return (to_ufixed (l, r'high, r'low) /= r);

  end function "/=";



  function ">=" (

    l : natural;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return boolean is

  begin

    return (to_ufixed (l, r'high, r'low) >= r);

  end function ">=";



  function "<=" (

    l : natural;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return boolean is

  begin

    return (to_ufixed (l, r'high, r'low) <= r);

  end function "<=";



  function ">" (

    l : natural;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return boolean is

  begin

    return (to_ufixed (l, r'high, r'low) > r);

  end function ">";



  function "<" (

    l : natural;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return boolean is

  begin

    return (to_ufixed (l, r'high, r'low) < r);

  end function "<";



  function \?=\ (

    l : natural;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return std_ulogic is

  begin

    return \?=\ (to_ufixed (l, r'high, r'low), r);

  end function \?=\;



  function \?/=\ (

    l : natural;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return std_ulogic is

  begin

    return \?/=\ (to_ufixed (l, r'high, r'low), r);

  end function \?/=\;



  function \?>=\ (

    l : natural;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return std_ulogic is

  begin

    return \?>=\ (to_ufixed (l, r'high, r'low), r);

  end function \?>=\;



  function \?<=\ (

    l : natural;

    r : UNRESOLVED_ufixed)              -- fixed point input

                 return std_ulogic is

  begin

    return \?<=\ (to_ufixed (l, r'high, r'low), r);

  end function \?<=\;



  function \?>\ (

    l : natural;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return std_ulogic is

  begin

    return \?>\ (to_ufixed (l, r'high, r'low), r);

  end function \?>\;



  function \?<\ (

    l : natural;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return std_ulogic is

  begin

    return \?<\ (to_ufixed (l, r'high, r'low), r);

  end function \?<\;



  function maximum (

    l : natural;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return UNRESOLVED_ufixed is

  begin

    return maximum (to_ufixed (l, r'high, r'low), r);

  end function maximum;



  function minimum (

    l : natural;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return UNRESOLVED_ufixed is

  begin

    return minimum (to_ufixed (l, r'high, r'low), r);

  end function minimum;



  -- overloaded ufixed compare functions with real

  function "=" (

    l : UNRESOLVED_ufixed;

    r : real)

    return boolean is

  begin

    return (l = to_ufixed (r, l'high, l'low));

  end function "=";



  function "/=" (

    l : UNRESOLVED_ufixed;

    r : real)

    return boolean is

  begin

    return (l /= to_ufixed (r, l'high, l'low));

  end function "/=";



  function ">=" (

    l : UNRESOLVED_ufixed;

    r : real)

    return boolean is

  begin

    return (l >= to_ufixed (r, l'high, l'low));

  end function ">=";



  function "<=" (

    l : UNRESOLVED_ufixed;

    r : real)

    return boolean is

  begin

    return (l <= to_ufixed (r, l'high, l'low));

  end function "<=";



  function ">" (

    l : UNRESOLVED_ufixed;

    r : real)

    return boolean is

  begin

    return (l > to_ufixed (r, l'high, l'low));

  end function ">";



  function "<" (

    l : UNRESOLVED_ufixed;

    r : real)

    return boolean is

  begin

    return (l < to_ufixed (r, l'high, l'low));

  end function "<";



  function \?=\ (

    l : UNRESOLVED_ufixed;

    r : real)

    return std_ulogic is

  begin

    return \?=\ (l, to_ufixed (r, l'high, l'low));

  end function \?=\;



  function \?/=\ (

    l : UNRESOLVED_ufixed;

    r : real)

    return std_ulogic is

  begin

    return \?/=\ (l, to_ufixed (r, l'high, l'low));

  end function \?/=\;



  function \?>=\ (

    l : UNRESOLVED_ufixed;

    r : real)

    return std_ulogic is

  begin

    return \?>=\ (l, to_ufixed (r, l'high, l'low));

  end function \?>=\;



  function \?<=\ (

    l : UNRESOLVED_ufixed;

    r : real)

                 return std_ulogic is

  begin

    return \?<=\ (l, to_ufixed (r, l'high, l'low));

  end function \?<=\;



  function \?>\ (

    l : UNRESOLVED_ufixed;

    r : real)

    return std_ulogic is

  begin

    return \?>\ (l, to_ufixed (r, l'high, l'low));

  end function \?>\;



  function \?<\ (

    l : UNRESOLVED_ufixed;

    r : real)

    return std_ulogic is

  begin

    return \?<\ (l, to_ufixed (r, l'high, l'low));

  end function \?<\;



  function maximum (

    l : UNRESOLVED_ufixed;

    r : real)

    return UNRESOLVED_ufixed is

  begin

    return maximum (l, to_ufixed (r, l'high, l'low));

  end function maximum;



  function minimum (

    l : UNRESOLVED_ufixed;

    r : real)

    return UNRESOLVED_ufixed is

  begin

    return minimum (l, to_ufixed (r, l'high, l'low));

  end function minimum;



  -- real and ufixed

  function "=" (

    l : real;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return boolean is

  begin

    return (to_ufixed (l, r'high, r'low) = r);

  end function "=";



  function "/=" (

    l : real;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return boolean is

  begin

    return (to_ufixed (l, r'high, r'low) /= r);

  end function "/=";



  function ">=" (

    l : real;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return boolean is

  begin

    return (to_ufixed (l, r'high, r'low) >= r);

  end function ">=";



  function "<=" (

    l : real;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return boolean is

  begin

    return (to_ufixed (l, r'high, r'low) <= r);

  end function "<=";



  function ">" (

    l : real;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return boolean is

  begin

    return (to_ufixed (l, r'high, r'low) > r);

  end function ">";



  function "<" (

    l : real;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return boolean is

  begin

    return (to_ufixed (l, r'high, r'low) < r);

  end function "<";



  function \?=\ (

    l : real;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return std_ulogic is

  begin

    return \?=\ (to_ufixed (l, r'high, r'low), r);

  end function \?=\;



  function \?/=\ (

    l : real;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return std_ulogic is

  begin

    return \?/=\ (to_ufixed (l, r'high, r'low), r);

  end function \?/=\;



  function \?>=\ (

    l : real;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return std_ulogic is

  begin

    return \?>=\ (to_ufixed (l, r'high, r'low), r);

  end function \?>=\;



  function \?<=\ (

    l : real;

    r : UNRESOLVED_ufixed)              -- fixed point input

                 return std_ulogic is

  begin

    return \?<=\ (to_ufixed (l, r'high, r'low), r);

  end function \?<=\;



  function \?>\ (

    l : real;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return std_ulogic is

  begin

    return \?>\ (to_ufixed (l, r'high, r'low), r);

  end function \?>\;



  function \?<\ (

    l : real;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return std_ulogic is

  begin

    return \?<\ (to_ufixed (l, r'high, r'low), r);

  end function \?<\;



  function maximum (

    l : real;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return UNRESOLVED_ufixed is

  begin

    return maximum (to_ufixed (l, r'high, r'low), r);

  end function maximum;



  function minimum (

    l : real;

    r : UNRESOLVED_ufixed)              -- fixed point input

    return UNRESOLVED_ufixed is

  begin

    return minimum (to_ufixed (l, r'high, r'low), r);

  end function minimum;



  -- overloaded sfixed compare functions with integer

  function "=" (

    l : UNRESOLVED_sfixed;

    r : integer)

    return boolean is

  begin

    return (l = to_sfixed (r, l'high, l'low));

  end function "=";



  function "/=" (

    l : UNRESOLVED_sfixed;

    r : integer)

    return boolean is

  begin

    return (l /= to_sfixed (r, l'high, l'low));

  end function "/=";



  function ">=" (

    l : UNRESOLVED_sfixed;

    r : integer)

    return boolean is

  begin

    return (l >= to_sfixed (r, l'high, l'low));

  end function ">=";



  function "<=" (

    l : UNRESOLVED_sfixed;

    r : integer)

    return boolean is

  begin

    return (l <= to_sfixed (r, l'high, l'low));

  end function "<=";



  function ">" (

    l : UNRESOLVED_sfixed;

    r : integer)

    return boolean is

  begin

    return (l > to_sfixed (r, l'high, l'low));

  end function ">";



  function "<" (

    l : UNRESOLVED_sfixed;

    r : integer)

    return boolean is

  begin

    return (l < to_sfixed (r, l'high, l'low));

  end function "<";



  function \?=\ (

    l : UNRESOLVED_sfixed;

    r : integer)

    return std_ulogic is

  begin

    return \?=\ (l, to_sfixed (r, l'high, l'low));

  end function \?=\;



  function \?/=\ (

    l : UNRESOLVED_sfixed;

    r : integer)

    return std_ulogic is

  begin

    return \?/=\ (l, to_sfixed (r, l'high, l'low));

  end function \?/=\;



  function \?>=\ (

    l : UNRESOLVED_sfixed;

    r : integer)

    return std_ulogic is

  begin

    return \?>=\ (l, to_sfixed (r, l'high, l'low));

  end function \?>=\;



  function \?<=\ (

    l : UNRESOLVED_sfixed;

    r : integer)

                 return std_ulogic is

  begin

    return \?<=\ (l, to_sfixed (r, l'high, l'low));

  end function \?<=\;



  function \?>\ (

    l : UNRESOLVED_sfixed;

    r : integer)

    return std_ulogic is

  begin

    return \?>\ (l, to_sfixed (r, l'high, l'low));

  end function \?>\;



  function \?<\ (

    l : UNRESOLVED_sfixed;

    r : integer)

    return std_ulogic is

  begin

    return \?<\ (l, to_sfixed (r, l'high, l'low));

  end function \?<\;



  function maximum (

    l : UNRESOLVED_sfixed;

    r : integer)

    return UNRESOLVED_sfixed is

  begin

    return maximum (l, to_sfixed (r, l'high, l'low));

  end function maximum;



  function minimum (

    l : UNRESOLVED_sfixed;

    r : integer)

    return UNRESOLVED_sfixed is

  begin

    return minimum (l, to_sfixed (r, l'high, l'low));

  end function minimum;



  -- integer and sfixed

  function "=" (

    l : integer;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return boolean is

  begin

    return (to_sfixed (l, r'high, r'low) = r);

  end function "=";



  function "/=" (

    l : integer;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return boolean is

  begin

    return (to_sfixed (l, r'high, r'low) /= r);

  end function "/=";



  function ">=" (

    l : integer;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return boolean is

  begin

    return (to_sfixed (l, r'high, r'low) >= r);

  end function ">=";



  function "<=" (

    l : integer;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return boolean is

  begin

    return (to_sfixed (l, r'high, r'low) <= r);

  end function "<=";



  function ">" (

    l : integer;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return boolean is

  begin

    return (to_sfixed (l, r'high, r'low) > r);

  end function ">";



  function "<" (

    l : integer;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return boolean is

  begin

    return (to_sfixed (l, r'high, r'low) < r);

  end function "<";



  function \?=\ (

    l : integer;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return std_ulogic is

  begin

    return \?=\ (to_sfixed (l, r'high, r'low), r);

  end function \?=\;



  function \?/=\ (

    l : integer;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return std_ulogic is

  begin

    return \?/=\ (to_sfixed (l, r'high, r'low), r);

  end function \?/=\;



  function \?>=\ (

    l : integer;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return std_ulogic is

  begin

    return \?>=\ (to_sfixed (l, r'high, r'low), r);

  end function \?>=\;



  function \?<=\ (

    l : integer;

    r : UNRESOLVED_sfixed)              -- fixed point input

                 return std_ulogic is

  begin

    return \?<=\ (to_sfixed (l, r'high, r'low), r);

  end function \?<=\;



  function \?>\ (

    l : integer;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return std_ulogic is

  begin

    return \?>\ (to_sfixed (l, r'high, r'low), r);

  end function \?>\;



  function \?<\ (

    l : integer;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return std_ulogic is

  begin

    return \?<\ (to_sfixed (l, r'high, r'low), r);

  end function \?<\;



  function maximum (

    l : integer;

    r : UNRESOLVED_sfixed)

    return UNRESOLVED_sfixed is

  begin

    return maximum (to_sfixed (l, r'high, r'low), r);

  end function maximum;



  function minimum (

    l : integer;

    r : UNRESOLVED_sfixed)

    return UNRESOLVED_sfixed is

  begin

    return minimum (to_sfixed (l, r'high, r'low), r);

  end function minimum;



  -- overloaded sfixed compare functions with real

  function "=" (

    l : UNRESOLVED_sfixed;

    r : real)

    return boolean is

  begin

    return (l = to_sfixed (r, l'high, l'low));

  end function "=";



  function "/=" (

    l : UNRESOLVED_sfixed;

    r : real)

    return boolean is

  begin

    return (l /= to_sfixed (r, l'high, l'low));

  end function "/=";



  function ">=" (

    l : UNRESOLVED_sfixed;

    r : real)

    return boolean is

  begin

    return (l >= to_sfixed (r, l'high, l'low));

  end function ">=";



  function "<=" (

    l : UNRESOLVED_sfixed;

    r : real)

    return boolean is

  begin

    return (l <= to_sfixed (r, l'high, l'low));

  end function "<=";



  function ">" (

    l : UNRESOLVED_sfixed;

    r : real)

    return boolean is

  begin

    return (l > to_sfixed (r, l'high, l'low));

  end function ">";



  function "<" (

    l : UNRESOLVED_sfixed;

    r : real)

    return boolean is

  begin

    return (l < to_sfixed (r, l'high, l'low));

  end function "<";



  function \?=\ (

    l : UNRESOLVED_sfixed;

    r : real)

    return std_ulogic is

  begin

    return \?=\ (l, to_sfixed (r, l'high, l'low));

  end function \?=\;



  function \?/=\ (

    l : UNRESOLVED_sfixed;

    r : real)

    return std_ulogic is

  begin

    return \?/=\ (l, to_sfixed (r, l'high, l'low));

  end function \?/=\;



  function \?>=\ (

    l : UNRESOLVED_sfixed;

    r : real)

    return std_ulogic is

  begin

    return \?>=\ (l, to_sfixed (r, l'high, l'low));

  end function \?>=\;



  function \?<=\ (

    l : UNRESOLVED_sfixed;

    r : real)

                 return std_ulogic is

  begin

    return \?<=\ (l, to_sfixed (r, l'high, l'low));

  end function \?<=\;



  function \?>\ (

    l : UNRESOLVED_sfixed;

    r : real)

    return std_ulogic is

  begin

    return \?>\ (l, to_sfixed (r, l'high, l'low));

  end function \?>\;



  function \?<\ (

    l : UNRESOLVED_sfixed;

    r : real)

    return std_ulogic is

  begin

    return \?<\ (l, to_sfixed (r, l'high, l'low));

  end function \?<\;



  function maximum (

    l : UNRESOLVED_sfixed;

    r : real)

    return UNRESOLVED_sfixed is

  begin

    return maximum (l, to_sfixed (r, l'high, l'low));

  end function maximum;



  function minimum (

    l : UNRESOLVED_sfixed;

    r : real)

    return UNRESOLVED_sfixed is

  begin

    return minimum (l, to_sfixed (r, l'high, l'low));

  end function minimum;



  -- REAL and sfixed

  function "=" (

    l : real;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return boolean is

  begin

    return (to_sfixed (l, r'high, r'low) = r);

  end function "=";



  function "/=" (

    l : real;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return boolean is

  begin

    return (to_sfixed (l, r'high, r'low) /= r);

  end function "/=";



  function ">=" (

    l : real;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return boolean is

  begin

    return (to_sfixed (l, r'high, r'low) >= r);

  end function ">=";



  function "<=" (

    l : real;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return boolean is

  begin

    return (to_sfixed (l, r'high, r'low) <= r);

  end function "<=";



  function ">" (

    l : real;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return boolean is

  begin

    return (to_sfixed (l, r'high, r'low) > r);

  end function ">";



  function "<" (

    l : real;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return boolean is

  begin

    return (to_sfixed (l, r'high, r'low) < r);

  end function "<";



  function \?=\ (

    l : real;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return std_ulogic is

  begin

    return \?=\ (to_sfixed (l, r'high, r'low), r);

  end function \?=\;



  function \?/=\ (

    l : real;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return std_ulogic is

  begin

    return \?/=\ (to_sfixed (l, r'high, r'low), r);

  end function \?/=\;



  function \?>=\ (

    l : real;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return std_ulogic is

  begin

    return \?>=\ (to_sfixed (l, r'high, r'low), r);

  end function \?>=\;



  function \?<=\ (

    l : real;

    r : UNRESOLVED_sfixed)              -- fixed point input

                 return std_ulogic is

  begin

    return \?<=\ (to_sfixed (l, r'high, r'low), r);

  end function \?<=\;



  function \?>\ (

    l : real;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return std_ulogic is

  begin

    return \?>\ (to_sfixed (l, r'high, r'low), r);

  end function \?>\;



  function \?<\ (

    l : real;

    r : UNRESOLVED_sfixed)              -- fixed point input

    return std_ulogic is

  begin

    return \?<\ (to_sfixed (l, r'high, r'low), r);

  end function \?<\;



  function maximum (

    l : real;

    r : UNRESOLVED_sfixed)

    return UNRESOLVED_sfixed is

  begin

    return maximum (to_sfixed (l, r'high, r'low), r);

  end function maximum;



  function minimum (

    l : real;

    r : UNRESOLVED_sfixed)

    return UNRESOLVED_sfixed is

  begin

    return minimum (to_sfixed (l, r'high, r'low), r);

  end function minimum;

-- rtl_synthesis off

-- pragma synthesis_off

  -- copied from std_logic_textio

  type MVL9plus is ('U', 'X', '0', '1', 'Z', 'W', 'L', 'H', '-', error);

  type char_indexed_by_MVL9 is array (std_ulogic) of character;

  type MVL9_indexed_by_char is array (character) of std_ulogic;

  type MVL9plus_indexed_by_char is array (character) of MVL9plus;



  constant MVL9_to_char : char_indexed_by_MVL9 := "UX01ZWLH-";

  constant char_to_MVL9 : MVL9_indexed_by_char :=

    ('U' => 'U', 'X' => 'X', '0' => '0', '1' => '1', 'Z' => 'Z',

     'W' => 'W', 'L' => 'L', 'H' => 'H', '-' => '-', others => 'U');

  constant char_to_MVL9plus : MVL9plus_indexed_by_char :=

    ('U' => 'U', 'X' => 'X', '0' => '0', '1' => '1', 'Z' => 'Z',

     'W' => 'W', 'L' => 'L', 'H' => 'H', '-' => '-', others => error);

  constant NBSP : character := character'val(160);  -- space character

  constant NUS : string(2 to 1) := (others => ' ');



  -- %%% Replicated Textio functions

  procedure Char2TriBits (C : character;

                          RESULT : out std_ulogic_vector(2 downto 0);

                          GOOD : out boolean;

                          ISSUE_ERROR : in boolean) is

  begin

    case c is

      when '0' => result := o"0"; good := true;

      when '1' => result := o"1"; good := true;

      when '2' => result := o"2"; good := true;

      when '3' => result := o"3"; good := true;

      when '4' => result := o"4"; good := true;

      when '5' => result := o"5"; good := true;

      when '6' => result := o"6"; good := true;

      when '7' => result := o"7"; good := true;

      when 'Z' => result := "ZZZ"; good := true;

      when 'X' => result := "XXX"; good := true;

      when others =>

        assert not ISSUE_ERROR

          report fixed_pkg'instance_name

          & "OREAD Error: Read a '" & c &

          "', expected an Octal character (0-7)."

          severity error;

        result := "UUU";

        good := false;

    end case;

  end procedure Char2TriBits;

  -- Hex Read and Write procedures for STD_ULOGIC_VECTOR.

  -- Modified from the original to be more forgiving.



  procedure Char2QuadBits (C : character;

                           RESULT : out std_ulogic_vector(3 downto 0);

                           GOOD : out boolean;

                           ISSUE_ERROR : in boolean) is

  begin

    case c is

      when '0' => result := x"0"; good := true;

      when '1' => result := x"1"; good := true;

      when '2' => result := x"2"; good := true;

      when '3' => result := x"3"; good := true;

      when '4' => result := x"4"; good := true;

      when '5' => result := x"5"; good := true;

      when '6' => result := x"6"; good := true;

      when '7' => result := x"7"; good := true;

      when '8' => result := x"8"; good := true;

      when '9' => result := x"9"; good := true;

      when 'A' | 'a' => result := x"A"; good := true;

      when 'B' | 'b' => result := x"B"; good := true;

      when 'C' | 'c' => result := x"C"; good := true;

      when 'D' | 'd' => result := x"D"; good := true;

      when 'E' | 'e' => result := x"E"; good := true;

      when 'F' | 'f' => result := x"F"; good := true;

      when 'Z' => result := "ZZZZ"; good := true;

      when 'X' => result := "XXXX"; good := true;

      when others =>

        assert not ISSUE_ERROR

          report fixed_pkg'instance_name

          & "HREAD Error: Read a '" & c &

          "', expected a Hex character (0-F)."

          severity error;

        result := "UUUU";

        good := false;

    end case;

  end procedure Char2QuadBits;



  -- purpose: Skips white space

  procedure skip_whitespace (

    L : inout line) is

    variable readOk : boolean;

    variable c : character;

  begin

    while L /= null and L.all'length /= 0 loop

      if (L.all(1) = ' ' or L.all(1) = NBSP or L.all(1) = HT) then

        read (l, c, readOk);

      else

        exit;

      end if;

    end loop;

  end procedure skip_whitespace;



  function to_ostring (value : std_ulogic_vector) return string is

    constant ne : integer := (value'length+2)/3;

    variable pad : std_ulogic_vector(0 to (ne*3 - value'length) - 1);

    variable ivalue : std_ulogic_vector(0 to ne*3 - 1);

    variable result : string(1 to ne);

    variable tri : std_ulogic_vector(0 to 2);

  begin

    if value'length < 1 then

      return NUS;

    else

      if value (value'left) = 'Z' then

        pad := (others => 'Z');

      else

        pad := (others => '0');

      end if;

      ivalue := pad & value;

      for i in 0 to ne-1 loop

        tri := To_X01Z(ivalue(3*i to 3*i+2));

        case tri is

          when o"0" => result(i+1) := '0';

          when o"1" => result(i+1) := '1';

          when o"2" => result(i+1) := '2';

          when o"3" => result(i+1) := '3';

          when o"4" => result(i+1) := '4';

          when o"5" => result(i+1) := '5';

          when o"6" => result(i+1) := '6';

          when o"7" => result(i+1) := '7';

          when "ZZZ" => result(i+1) := 'Z';

          when others => result(i+1) := 'X';

        end case;

      end loop;

      return result;

    end if;

  end function to_ostring;

  -------------------------------------------------------------------   

  function to_hstring (value : std_ulogic_vector) return string is

    constant ne : integer := (value'length+3)/4;

    variable pad : std_ulogic_vector(0 to (ne*4 - value'length) - 1);

    variable ivalue : std_ulogic_vector(0 to ne*4 - 1);

    variable result : string(1 to ne);

    variable quad : std_ulogic_vector(0 to 3);

  begin

    if value'length < 1 then

      return NUS;

    else

      if value (value'left) = 'Z' then

        pad := (others => 'Z');

      else

        pad := (others => '0');

      end if;

      ivalue := pad & value;

      for i in 0 to ne-1 loop

        quad := To_X01Z(ivalue(4*i to 4*i+3));

        case quad is

          when x"0" => result(i+1) := '0';

          when x"1" => result(i+1) := '1';

          when x"2" => result(i+1) := '2';

          when x"3" => result(i+1) := '3';

          when x"4" => result(i+1) := '4';

          when x"5" => result(i+1) := '5';

          when x"6" => result(i+1) := '6';

          when x"7" => result(i+1) := '7';

          when x"8" => result(i+1) := '8';

          when x"9" => result(i+1) := '9';

          when x"A" => result(i+1) := 'A';

          when x"B" => result(i+1) := 'B';

          when x"C" => result(i+1) := 'C';

          when x"D" => result(i+1) := 'D';

          when x"E" => result(i+1) := 'E';

          when x"F" => result(i+1) := 'F';

          when "ZZZZ" => result(i+1) := 'Z';

          when others => result(i+1) := 'X';

        end case;

      end loop;

      return result;

    end if;

  end function to_hstring;





-- %%% END replicated textio functions



  -- purpose: writes fixed point into a line

  procedure write (

    L : inout line;                     -- input line

    VALUE : in UNRESOLVED_ufixed;       -- fixed point input

    JUSTIFIED : in side := right;

    FIELD : in WIDTH := 0) is

    variable s : string(1 to value'length +1) := (others => ' ');

    variable sindx : integer;

  begin  -- function write   Example: 0011.1100

    sindx := 1;

    for i in value'high downto value'low loop

      if i = -1 then

        s(sindx) := '.';

        sindx := sindx + 1;

      end if;

      s(sindx) := MVL9_to_char(std_ulogic(value(i)));

      sindx := sindx + 1;

    end loop;

    write(l, s, justified, field);

  end procedure write;



  -- purpose: writes fixed point into a line

  procedure write (

    L : inout line;                     -- input line

    VALUE : in UNRESOLVED_sfixed;       -- fixed point input

    JUSTIFIED : in side := right;

    FIELD : in WIDTH := 0) is

    variable s : string(1 to value'length +1);

    variable sindx : integer;

  begin  -- function write   Example: 0011.1100

    sindx := 1;

    for i in value'high downto value'low loop

      if i = -1 then

        s(sindx) := '.';

        sindx := sindx + 1;

      end if;

      s(sindx) := MVL9_to_char(std_ulogic(value(i)));

      sindx := sindx + 1;

    end loop;

    write(l, s, justified, field);

  end procedure write;



  procedure READ(L : inout line;

                 VALUE : out UNRESOLVED_ufixed) is

    -- Possible data:  00000.0000000

    --                 000000000000

    variable c : character;

    variable readOk : boolean;

    variable i : integer;               -- index variable

    variable mv : ufixed (VALUE'range);

    variable lastu : boolean := false;  -- last character was an "_"

    variable founddot : boolean := false;  -- found a "."

  begin  -- READ

    VALUE := (VALUE'range => 'U');

    Skip_whitespace (L);

    if VALUE'length > 0 then            -- non Null input string

      read (l, c, readOk);

      i := value'high;

      while i >= VALUE'low loop

        if readOk = false then          -- Bail out if there was a bad read

          report fixed_pkg'instance_name & "READ(ufixed) "

            & "End of string encountered"

            severity error;

          return;

        elsif c = '_' then

          if i = value'high then

            report fixed_pkg'instance_name & "READ(ufixed) "

              & "String begins with an ""_""" severity error;

            return;

          elsif lastu then

            report fixed_pkg'instance_name & "READ(ufixed) "

              & "Two underscores detected in input string ""__"""

              severity error;

            return;

          else

            lastu := true;

          end if;

        elsif c = '.' then              -- binary point

          if founddot then

            report fixed_pkg'instance_name & "READ(ufixed) "

              & "Two binary points found in input string" severity error;

            return;

          elsif i /= -1 then            -- Seperator in the wrong spot

            report fixed_pkg'instance_name & "READ(ufixed) "

              & "Decimal point does not match number format "

              severity error;

            return;

          end if;

          founddot := true;

          lastu := false;

        elsif c = ' ' or c = NBSP or c = HT then  -- reading done.

          report fixed_pkg'instance_name & "READ(ufixed) "

            & "Short read, Space encounted in input string"

            severity error;

          return;

        elsif char_to_MVL9plus(c) = error then

          report fixed_pkg'instance_name & "READ(ufixed) "

            & "Character '" &

            c & "' read, expected STD_ULOGIC literal."

            severity error;

          return;

        else

          mv(i) := char_to_MVL9(c);

          i := i - 1;

          if i < mv'low then

            VALUE := mv;

            return;

          end if;

          lastu := false;

        end if;

        read(L, c, readOk);

      end loop;

    end if;

  end procedure READ;



  procedure READ(L : inout line;

                 VALUE : out UNRESOLVED_ufixed;

                 GOOD : out boolean) is

    -- Possible data:  00000.0000000

    --                 000000000000

    variable c : character;

    variable readOk : boolean;

    variable mv : ufixed (VALUE'range);

    variable i : integer;               -- index variable

    variable lastu : boolean := false;  -- last character was an "_"

    variable founddot : boolean := false;  -- found a "."

  begin  -- READ

    VALUE := (VALUE'range => 'U');

    Skip_whitespace (L);

    if VALUE'length > 0 then

      read (l, c, readOk);

      i := value'high;

      GOOD := false;

      while i >= VALUE'low loop

        if not readOk then              -- Bail out if there was a bad read

          return;

        elsif c = '_' then

          if i = value'high then        -- Begins with an "_"

            return;

          elsif lastu then              -- "__" detected

            return;

          else

            lastu := true;

          end if;

        elsif c = '.' then              -- binary point

          if founddot then

            return;

          elsif i /= -1 then            -- Seperator in the wrong spot

            return;

          end if;

          founddot := true;

          lastu := false;

        elsif (char_to_MVL9plus(c) = error) then  -- Illegal character/short read

          return;

        else

          mv(i) := char_to_MVL9(c);

          i := i - 1;

          if i < mv'low then            -- reading done

            GOOD := true;

            VALUE := mv;

            return;

          end if;

          lastu := false;

        end if;

        read(L, c, readOk);

      end loop;

    else

      GOOD := true;                     -- read into a null array

    end if;

  end procedure READ;



  procedure READ(L : inout line;

                 VALUE : out UNRESOLVED_sfixed) is

    variable c : character;

    variable readOk : boolean;

    variable i : integer;               -- index variable

    variable mv : sfixed (VALUE'range);

    variable lastu : boolean := false;  -- last character was an "_"

    variable founddot : boolean := false;  -- found a "."

  begin  -- READ

    VALUE := (VALUE'range => 'U');

    Skip_whitespace (L);

    if VALUE'length > 0 then            -- non Null input string

      read (l, c, readOk);

      i := value'high;

      while i >= VALUE'low loop

        if readOk = false then          -- Bail out if there was a bad read

          report fixed_pkg'instance_name & "READ(sfixed) "

            & "End of string encountered"

            severity error;

          return;

        elsif c = '_' then

          if i = value'high then

            report fixed_pkg'instance_name & "READ(sfixed) "

              & "String begins with an ""_""" severity error;

            return;

          elsif lastu then

            report fixed_pkg'instance_name & "READ(sfixed) "

              & "Two underscores detected in input string ""__"""

              severity error;

            return;

          else

            lastu := true;

          end if;

        elsif c = '.' then              -- binary point

          if founddot then

            report fixed_pkg'instance_name & "READ(sfixed) "

              & "Two binary points found in input string" severity error;

            return;

          elsif i /= -1 then            -- Seperator in the wrong spot

            report fixed_pkg'instance_name & "READ(sfixed) "

              & "Decimal point does not match number format "

              severity error;

            return;

          end if;

          founddot := true;

          lastu := false;

        elsif c = ' ' or c = NBSP or c = HT then  -- reading done.

          report fixed_pkg'instance_name & "READ(sfixed) "

            & "Short read, Space encounted in input string"

            severity error;

          return;

        elsif char_to_MVL9plus(c) = error then

          report fixed_pkg'instance_name & "READ(sfixed) "

            & "Character '" &

            c & "' read, expected STD_ULOGIC literal."

            severity error;

          return;

        else

          mv(i) := char_to_MVL9(c);

          i := i - 1;

          if i < mv'low then

            VALUE := mv;

            return;

          end if;

          lastu := false;

        end if;

        read(L, c, readOk);

      end loop;

    end if;

  end procedure READ;



  procedure READ(L : inout line;

                 VALUE : out UNRESOLVED_sfixed;

                 GOOD : out boolean) is

    variable value_ufixed : UNRESOLVED_ufixed (VALUE'range);

  begin  -- READ

    READ (L => L, VALUE => value_ufixed, GOOD => GOOD);

    VALUE := UNRESOLVED_sfixed (value_ufixed);

  end procedure READ;



  -- octal read and write

  procedure owrite (

    L : inout line;                     -- input line

    VALUE : in UNRESOLVED_ufixed;       -- fixed point input

    JUSTIFIED : in side := right;

    FIELD : in WIDTH := 0) is

  begin  -- Example 03.30

    write (L => L,

           VALUE => to_ostring (VALUE),

           JUSTIFIED => JUSTIFIED,

           FIELD => FIELD);

  end procedure owrite;



  procedure owrite (

    L : inout line;                     -- input line

    VALUE : in UNRESOLVED_sfixed;       -- fixed point input

    JUSTIFIED : in side := right;

    FIELD : in WIDTH := 0) is

  begin  -- Example 03.30

    write (L => L,

           VALUE => to_ostring (VALUE),

           JUSTIFIED => JUSTIFIED,

           FIELD => FIELD);

  end procedure owrite;



  -- purpose: Routines common to the OREAD routines

  procedure OREAD_common (

    L : inout line;

    slv : out std_ulogic_vector;

    igood : out boolean;

    idex : out integer;

    constant bpoint : in integer;       -- binary point

    constant message : in boolean;

    constant smath : in boolean) is



    -- purpose: error message routine

    procedure errmes (

      constant mess : in string) is     -- error message

    begin

      if message then

        if smath then

          report fixed_pkg'instance_name

            & "OREAD(sfixed) "

            & mess

            severity error;

        else

          report fixed_pkg'instance_name

            & "OREAD(ufixed) "

            & mess

            severity error;

        end if;

      end if;

    end procedure errmes;

    variable xgood : boolean;

    variable nybble : std_ulogic_vector (2 downto 0);  -- 3 bits

    variable c : character;

    variable i : integer;

    variable lastu : boolean := false;  -- last character was an "_"

    variable founddot : boolean := false;  -- found a dot.

  begin

    Skip_whitespace (L);

    if slv'length > 0 then

      i := slv'high;

      read (l, c, xgood);

      while i > 0 loop

        if xgood = false then

          errmes ("Error: end of string encountered");

          exit;

        elsif c = '_' then

          if i = slv'length then

            errmes ("Error: String begins with an ""_""");

            xgood := false;

            exit;

          elsif lastu then

            errmes ("Error: Two underscores detected in input string ""__""");

            xgood := false;

            exit;

          else

            lastu := true;

          end if;

        elsif (c = '.') then

          if (i + 1 /= bpoint) then

            errmes ("encountered ""."" at wrong index");

            xgood := false;

            exit;

          elsif i = slv'length then

            errmes ("encounted a ""."" at the beginning of the line");

            xgood := false;

            exit;

          elsif founddot then

            errmes ("Two ""."" encounted in input string");

            xgood := false;

            exit;

          end if;

          founddot := true;

          lastu := false;

        else

          Char2triBits(c, nybble, xgood, message);

          if not xgood then

            exit;

          end if;

          slv (i downto i-2) := nybble;

          i := i - 3;

          lastu := false;

        end if;

        if i > 0 then

          read (L, c, xgood);

        end if;

      end loop;

      idex := i;

      igood := xgood;

    else

      igood := true;                    -- read into a null array

      idex := -1;

    end if;

  end procedure OREAD_common;



  -- Note that for Octal and Hex read, you can not start with a ".",

  -- the read is for numbers formatted "A.BC".  These routines go to

  -- the nearest bounds, so "F.E" will fit into an sfixed (2 downto -3).

  procedure OREAD (L : inout line;

                   VALUE : out UNRESOLVED_ufixed) is

    constant hbv : integer := (((maximum(3, (VALUE'high+1))+2)/3)*3)-1;

    constant lbv : integer := ((mine(0, VALUE'low)-2)/3)*3;

    variable slv : std_ulogic_vector (hbv-lbv downto 0);  -- high bits

    variable valuex : UNRESOLVED_ufixed (hbv downto lbv);

    variable igood : boolean;

    variable i : integer;

  begin

    VALUE := (VALUE'range => 'U');

    OREAD_common (L => L,

                  slv => slv,

                  igood => igood,

                  idex => i,

                  bpoint => -lbv,

                  message => true,

                  smath => false);

    if igood then                       -- We did not get another error

      if not ((i = -1) and              -- We read everything, and high bits 0

              (or_reduce (slv(hbv-lbv downto VALUE'high+1-lbv)) = '0')) then

        report fixed_pkg'instance_name

          & "OREAD(ufixed): Vector truncated."

          severity error;

      else

        if (or_reduce (slv(VALUE'low-lbv-1 downto 0)) = '1') then

          assert NO_WARNING

            report fixed_pkg'instance_name

            & "OREAD(ufixed): Vector truncated"

            severity warning;

        end if;

        valuex := to_ufixed (slv, hbv, lbv);

        VALUE := valuex (VALUE'range);

      end if;

    end if;

  end procedure OREAD;



  procedure OREAD(L : inout line;

                  VALUE : out UNRESOLVED_ufixed;

                  GOOD : out boolean) is

    constant hbv : integer := (((maximum(3, (VALUE'high+1))+2)/3)*3)-1;

    constant lbv : integer := ((mine(0, VALUE'low)-2)/3)*3;

    variable slv : std_ulogic_vector (hbv-lbv downto 0);  -- high bits

    variable valuex : UNRESOLVED_ufixed (hbv downto lbv);

    variable igood : boolean;

    variable i : integer;

  begin

    VALUE := (VALUE'range => 'U');

    OREAD_common (L => L,

                  slv => slv,

                  igood => igood,

                  idex => i,

                  bpoint => -lbv,

                  message => false,

                  smath => false);

    if (igood and                       -- We did not get another error

        (i = -1) and                    -- We read everything, and high bits 0

        (or_reduce (slv(hbv-lbv downto VALUE'high+1-lbv)) = '0')) then

      valuex := to_ufixed (slv, hbv, lbv);

      VALUE := valuex (VALUE'range);

      good := true;

    else

      good := false;

    end if;

  end procedure OREAD;



  procedure OREAD(L : inout line;

                  VALUE : out UNRESOLVED_sfixed) is

    constant hbv : integer := (((maximum(3, (VALUE'high+1))+2)/3)*3)-1;

    constant lbv : integer := ((mine(0, VALUE'low)-2)/3)*3;

    variable slv : std_ulogic_vector (hbv-lbv downto 0);  -- high bits

    variable valuex : UNRESOLVED_sfixed (hbv downto lbv);

    variable igood : boolean;

    variable i : integer;

  begin

    VALUE := (VALUE'range => 'U');

    OREAD_common (L => L,

                  slv => slv,

                  igood => igood,

                  idex => i,

                  bpoint => -lbv,

                  message => true,

                  smath => true);

    if igood then                       -- We did not get another error

      if not ((i = -1) and              -- We read everything

              ((slv(VALUE'high-lbv) = '0' and  -- sign bits = extra bits

                or_reduce (slv(hbv-lbv downto VALUE'high+1-lbv)) = '0') or

               (slv(VALUE'high-lbv) = '1' and

                and_reduce (slv(hbv-lbv downto VALUE'high+1-lbv)) = '1'))) then

        report fixed_pkg'instance_name

          & "OREAD(sfixed): Vector truncated."

          severity error;

      else

        if (or_reduce (slv(VALUE'low-lbv-1 downto 0)) = '1') then

          assert NO_WARNING

            report fixed_pkg'instance_name

            & "OREAD(sfixed): Vector truncated"

            severity warning;

        end if;

        valuex := to_sfixed (slv, hbv, lbv);

        VALUE := valuex (VALUE'range);

      end if;

    end if;

  end procedure OREAD;



  procedure OREAD(L : inout line;

                  VALUE : out UNRESOLVED_sfixed;

                  GOOD : out boolean) is

    constant hbv : integer := (((maximum(3, (VALUE'high+1))+2)/3)*3)-1;

    constant lbv : integer := ((mine(0, VALUE'low)-2)/3)*3;

    variable slv : std_ulogic_vector (hbv-lbv downto 0);  -- high bits

    variable valuex : UNRESOLVED_sfixed (hbv downto lbv);

    variable igood : boolean;

    variable i : integer;

  begin

    VALUE := (VALUE'range => 'U');

    OREAD_common (L => L,

                  slv => slv,

                  igood => igood,

                  idex => i,

                  bpoint => -lbv,

                  message => false,

                  smath => true);

    if (igood                           -- We did not get another error

        and (i = -1)                    -- We read everything

        and ((slv(VALUE'high-lbv) = '0' and  -- sign bits = extra bits

              or_reduce (slv(hbv-lbv downto VALUE'high+1-lbv)) = '0') or

             (slv(VALUE'high-lbv) = '1' and

              and_reduce (slv(hbv-lbv downto VALUE'high+1-lbv)) = '1'))) then

      valuex := to_sfixed (slv, hbv, lbv);

      VALUE := valuex (VALUE'range);

      good := true;

    else

      good := false;

    end if;

  end procedure OREAD;



  -- hex read and write

  procedure hwrite (

    L : inout line;                     -- input line

    VALUE : in UNRESOLVED_ufixed;       -- fixed point input

    JUSTIFIED : in side := right;

    FIELD : in WIDTH := 0) is

  begin  -- Example 03.30

    write (L => L,

           VALUE => to_hstring (VALUE),

           JUSTIFIED => JUSTIFIED,

           FIELD => FIELD);

  end procedure hwrite;



  -- purpose: writes fixed point into a line

  procedure hwrite (

    L : inout line;                     -- input line

    VALUE : in UNRESOLVED_sfixed;       -- fixed point input

    JUSTIFIED : in side := right;

    FIELD : in WIDTH := 0) is

  begin  -- Example 03.30

    write (L => L,

           VALUE => to_hstring (VALUE),

           JUSTIFIED => JUSTIFIED,

           FIELD => FIELD);

  end procedure hwrite;



  -- purpose: Routines common to the OREAD routines

  procedure HREAD_common (

    L : inout line;

    slv : out std_ulogic_vector;

    igood : out boolean;

    idex : out integer;

    constant bpoint : in integer;       -- binary point

    constant message : in boolean;

    constant smath : in boolean) is



    -- purpose: error message routine

    procedure errmes (

      constant mess : in string) is     -- error message

    begin

      if message then

        if smath then

          report fixed_pkg'instance_name

            & "HREAD(sfixed) "

            & mess

            severity error;

        else

          report fixed_pkg'instance_name

            & "HREAD(ufixed) "

            & mess

            severity error;

        end if;

      end if;

    end procedure errmes;

    variable xgood : boolean;

    variable nybble : std_ulogic_vector (3 downto 0);  -- 4 bits

    variable c : character;

    variable i : integer;

    variable lastu : boolean := false;  -- last character was an "_"

    variable founddot : boolean := false;  -- found a dot.

  begin

    Skip_whitespace (L);

    if slv'length > 0 then

      i := slv'high;

      read (l, c, xgood);

      while i > 0 loop

        if xgood = false then

          errmes ("Error: end of string encountered");

          exit;

        elsif c = '_' then

          if i = slv'length then

            errmes ("Error: String begins with an ""_""");

            xgood := false;

            exit;

          elsif lastu then

            errmes ("Error: Two underscores detected in input string ""__""");

            xgood := false;

            exit;

          else

            lastu := true;

          end if;

        elsif (c = '.') then

          if (i + 1 /= bpoint) then

            errmes ("encountered ""."" at wrong index");

            xgood := false;

            exit;

          elsif i = slv'length then

            errmes ("encounted a ""."" at the beginning of the line");

            xgood := false;

            exit;

          elsif founddot then

            errmes ("Two ""."" encounted in input string");

            xgood := false;

            exit;

          end if;

          founddot := true;

          lastu := false;

        else

          Char2QuadBits(c, nybble, xgood, message);

          if not xgood then

            exit;

          end if;

          slv (i downto i-3) := nybble;

          i := i - 4;

          lastu := false;

        end if;

        if i > 0 then

          read (L, c, xgood);

        end if;

      end loop;

      idex := i;

      igood := xgood;

    else

      idex := -1;

      igood := true;                    -- read null string

    end if;

  end procedure HREAD_common;



  procedure HREAD(L : inout line;

                  VALUE : out UNRESOLVED_ufixed) is

    constant hbv : integer := (((maximum(4, (VALUE'high+1))+3)/4)*4)-1;

    constant lbv : integer := ((mine(0, VALUE'low)-3)/4)*4;

    variable slv : std_ulogic_vector (hbv-lbv downto 0);  -- high bits

    variable valuex : UNRESOLVED_ufixed (hbv downto lbv);

    variable igood : boolean;

    variable i : integer;

  begin

    VALUE := (VALUE'range => 'U');

    HREAD_common (L => L,

                  slv => slv,

                  igood => igood,

                  idex => i,

                  bpoint => -lbv,

                  message => false,

                  smath => false);

    if igood then

      if not ((i = -1) and              -- We read everything, and high bits 0

              (or_reduce (slv(hbv-lbv downto VALUE'high+1-lbv)) = '0')) then

        report fixed_pkg'instance_name

          & "HREAD(ufixed): Vector truncated."

          severity error;

      else

        if (or_reduce (slv(VALUE'low-lbv-1 downto 0)) = '1') then

          assert NO_WARNING

            report fixed_pkg'instance_name

            & "HREAD(ufixed): Vector truncated"

            severity warning;

        end if;

        valuex := to_ufixed (slv, hbv, lbv);

        VALUE := valuex (VALUE'range);

      end if;

    end if;

  end procedure HREAD;



  procedure HREAD(L : inout line;

                  VALUE : out UNRESOLVED_ufixed;

                  GOOD : out boolean) is

    constant hbv : integer := (((maximum(4, (VALUE'high+1))+3)/4)*4)-1;

    constant lbv : integer := ((mine(0, VALUE'low)-3)/4)*4;

    variable slv : std_ulogic_vector (hbv-lbv downto 0);  -- high bits

    variable valuex : UNRESOLVED_ufixed (hbv downto lbv);

    variable igood : boolean;

    variable i : integer;

  begin

    VALUE := (VALUE'range => 'U');

    HREAD_common (L => L,

                  slv => slv,

                  igood => igood,

                  idex => i,

                  bpoint => -lbv,

                  message => false,

                  smath => false);

    if (igood and                       -- We did not get another error

        (i = -1) and                    -- We read everything, and high bits 0

        (or_reduce (slv(hbv-lbv downto VALUE'high+1-lbv)) = '0')) then

      valuex := to_ufixed (slv, hbv, lbv);

      VALUE := valuex (VALUE'range);

      good := true;

    else

      good := false;

    end if;

  end procedure HREAD;



  procedure HREAD(L : inout line;

                  VALUE : out UNRESOLVED_sfixed) is

    constant hbv : integer := (((maximum(4, (VALUE'high+1))+3)/4)*4)-1;

    constant lbv : integer := ((mine(0, VALUE'low)-3)/4)*4;

    variable slv : std_ulogic_vector (hbv-lbv downto 0);  -- high bits

    variable valuex : UNRESOLVED_sfixed (hbv downto lbv);

    variable igood : boolean;

    variable i : integer;

  begin

    VALUE := (VALUE'range => 'U');

    HREAD_common (L => L,

                  slv => slv,

                  igood => igood,

                  idex => i,

                  bpoint => -lbv,

                  message => true,

                  smath => true);

    if igood then                       -- We did not get another error

      if not ((i = -1)                  -- We read everything

              and ((slv(VALUE'high-lbv) = '0' and  -- sign bits = extra bits

                    or_reduce (slv(hbv-lbv downto VALUE'high+1-lbv)) = '0') or

                   (slv(VALUE'high-lbv) = '1' and

                    and_reduce (slv(hbv-lbv downto VALUE'high+1-lbv)) = '1'))) then

        report fixed_pkg'instance_name

          & "HREAD(sfixed): Vector truncated."

          severity error;

      else

        if (or_reduce (slv(VALUE'low-lbv-1 downto 0)) = '1') then

          assert NO_WARNING

            report fixed_pkg'instance_name

            & "HREAD(sfixed): Vector truncated"

            severity warning;

        end if;

        valuex := to_sfixed (slv, hbv, lbv);

        VALUE := valuex (VALUE'range);

      end if;

    end if;

  end procedure HREAD;



  procedure HREAD(L : inout line;

                  VALUE : out UNRESOLVED_sfixed;

                  GOOD : out boolean) is

    constant hbv : integer := (((maximum(4, (VALUE'high+1))+3)/4)*4)-1;

    constant lbv : integer := ((mine(0, VALUE'low)-3)/4)*4;

    variable slv : std_ulogic_vector (hbv-lbv downto 0);  -- high bits

    variable valuex : UNRESOLVED_sfixed (hbv downto lbv);

    variable igood : boolean;

    variable i : integer;

  begin

    VALUE := (VALUE'range => 'U');

    HREAD_common (L => L,

                  slv => slv,

                  igood => igood,

                  idex => i,

                  bpoint => -lbv,

                  message => false,

                  smath => true);

    if (igood and                       -- We did not get another error

        (i = -1) and                    -- We read everything

        ((slv(VALUE'high-lbv) = '0' and  -- sign bits = extra bits

          or_reduce (slv(hbv-lbv downto VALUE'high+1-lbv)) = '0') or

         (slv(VALUE'high-lbv) = '1' and

          and_reduce (slv(hbv-lbv downto VALUE'high+1-lbv)) = '1'))) then

      valuex := to_sfixed (slv, hbv, lbv);

      VALUE := valuex (VALUE'range);

      good := true;

    else

      good := false;

    end if;

  end procedure HREAD;



  function to_string (value : UNRESOLVED_ufixed) return string is

    variable s : string(1 to value'length +1) := (others => ' ');

    variable subval : UNRESOLVED_ufixed (value'high downto -1);

    variable sindx : integer;

  begin

    if value'length < 1 then

      return NUS;

    else

      if value'high < 0 then

        if value(value'high) = 'Z' then

          return to_string (resize (sfixed(value), 0, value'low));

        else

          return to_string (resize (value, 0, value'low));

        end if;

      elsif value'low >= 0 then

        if Is_X (value(value'low)) then

          subval := (others => value(value'low));

          subval (value'range) := value;

          return to_string(subval);

        else

          return to_string (resize (value, value'high, -1));

        end if;

      else

        sindx := 1;

        for i in value'high downto value'low loop

          if i = -1 then

            s(sindx) := '.';

            sindx := sindx + 1;

          end if;

          s(sindx) := MVL9_to_char(std_ulogic(value(i)));

          sindx := sindx + 1;

        end loop;

        return s;

      end if;

    end if;

  end function to_string;



  function to_string (value : UNRESOLVED_sfixed) return string is

    variable s : string(1 to value'length + 1) := (others => ' ');

    variable subval : UNRESOLVED_sfixed (value'high downto -1);

    variable sindx : integer;

  begin

    if value'length < 1 then

      return NUS;

    else

      if value'high < 0 then

        return to_string (resize (value, 0, value'low));

      elsif value'low >= 0 then

        if Is_X (value(value'low)) then

          subval := (others => value(value'low));

          subval (value'range) := value;

          return to_string(subval);

        else

          return to_string (resize (value, value'high, -1));

        end if;

      else

        sindx := 1;

        for i in value'high downto value'low loop

          if i = -1 then

            s(sindx) := '.';

            sindx := sindx + 1;

          end if;

          s(sindx) := MVL9_to_char(std_ulogic(value(i)));

          sindx := sindx + 1;

        end loop;

        return s;

      end if;

    end if;

  end function to_string;



  function to_ostring (value : UNRESOLVED_ufixed) return string is

    constant lne : integer := (-VALUE'low+2)/3;

    variable subval : UNRESOLVED_ufixed (value'high downto -3);

    variable lpad : std_ulogic_vector (0 to (lne*3 + VALUE'low) -1);

    variable slv : std_ulogic_vector (value'length-1 downto 0);

  begin

    if value'length < 1 then

      return NUS;

    else

      if value'high < 0 then

        if value(value'high) = 'Z' then

          return to_ostring (resize (sfixed(value), 2, value'low));

        else

          return to_ostring (resize (value, 2, value'low));

        end if;

      elsif value'low >= 0 then

        if Is_X (value(value'low)) then

          subval := (others => value(value'low));

          subval (value'range) := value;

          return to_ostring(subval);

        else

          return to_ostring (resize (value, value'high, -3));

        end if;

      else

        slv := to_sulv (value);

        if Is_X (value (value'low)) then

          lpad := (others => value (value'low));

        else

          lpad := (others => '0');

        end if;

        return to_ostring(slv(slv'high downto slv'high-VALUE'high))

          & "."

          & to_ostring(slv(slv'high-VALUE'high-1 downto 0) & lpad);

      end if;

    end if;

  end function to_ostring;



  function to_hstring (value : UNRESOLVED_ufixed) return string is

    constant lne : integer := (-VALUE'low+3)/4;

    variable subval : UNRESOLVED_ufixed (value'high downto -4);

    variable lpad : std_ulogic_vector (0 to (lne*4 + VALUE'low) -1);

    variable slv : std_ulogic_vector (value'length-1 downto 0);

  begin

    if value'length < 1 then

      return NUS;

    else

      if value'high < 0 then

        if value(value'high) = 'Z' then

          return to_hstring (resize (sfixed(value), 3, value'low));

        else

          return to_hstring (resize (value, 3, value'low));

        end if;

      elsif value'low >= 0 then

        if Is_X (value(value'low)) then

          subval := (others => value(value'low));

          subval (value'range) := value;

          return to_hstring(subval);

        else

          return to_hstring (resize (value, value'high, -4));

        end if;

      else

        slv := to_sulv (value);

        if Is_X (value (value'low)) then

          lpad := (others => value(value'low));

        else

          lpad := (others => '0');

        end if;

        return to_hstring(slv(slv'high downto slv'high-VALUE'high))

          & "."

          & to_hstring(slv(slv'high-VALUE'high-1 downto 0)&lpad);

      end if;

    end if;

  end function to_hstring;



  function to_ostring (value : UNRESOLVED_sfixed) return string is

    constant ne : integer := ((value'high+1)+2)/3;

    variable pad : std_ulogic_vector(0 to (ne*3 - (value'high+1)) - 1);

    constant lne : integer := (-VALUE'low+2)/3;

    variable subval : UNRESOLVED_sfixed (value'high downto -3);

    variable lpad : std_ulogic_vector (0 to (lne*3 + VALUE'low) -1);

    variable slv : std_ulogic_vector (VALUE'high - VALUE'low downto 0);

  begin

    if value'length < 1 then

      return NUS;

    else

      if value'high < 0 then

        return to_ostring (resize (value, 2, value'low));

      elsif value'low >= 0 then

        if Is_X (value(value'low)) then

          subval := (others => value(value'low));

          subval (value'range) := value;

          return to_ostring(subval);

        else

          return to_ostring (resize (value, value'high, -3));

        end if;

      else

        pad := (others => value(value'high));

        slv := to_sulv (value);

        if Is_X (value (value'low)) then

          lpad := (others => value(value'low));

        else

          lpad := (others => '0');

        end if;

        return to_ostring(pad & slv(slv'high downto slv'high-VALUE'high))

          & "."

          & to_ostring(slv(slv'high-VALUE'high-1 downto 0) & lpad);

      end if;

    end if;

  end function to_ostring;



  function to_hstring (value : UNRESOLVED_sfixed) return string is

    constant ne : integer := ((value'high+1)+3)/4;

    variable pad : std_ulogic_vector(0 to (ne*4 - (value'high+1)) - 1);

    constant lne : integer := (-VALUE'low+3)/4;

    variable subval : UNRESOLVED_sfixed (value'high downto -4);

    variable lpad : std_ulogic_vector (0 to (lne*4 + VALUE'low) -1);

    variable slv : std_ulogic_vector (value'length-1 downto 0);

  begin

    if value'length < 1 then

      return NUS;

    else

      if value'high < 0 then

        return to_hstring (resize (value, 3, value'low));

      elsif value'low >= 0 then

        if Is_X (value(value'low)) then

          subval := (others => value(value'low));

          subval (value'range) := value;

          return to_hstring(subval);

        else

          return to_hstring (resize (value, value'high, -4));

        end if;

      else

        slv := to_sulv (value);

        pad := (others => value(value'high));

        if Is_X (value (value'low)) then

          lpad := (others => value(value'low));

        else

          lpad := (others => '0');

        end if;

        return to_hstring(pad & slv(slv'high downto slv'high-VALUE'high))

          & "."

          & to_hstring(slv(slv'high-VALUE'high-1 downto 0) & lpad);

      end if;

    end if;

  end function to_hstring;



  -- From string functions allow you to convert a string into a fixed

  -- point number.  Example:

  --  signal uf1 : ufixed (3 downto -3);

  --  uf1 <= from_string ("0110.100", uf1'high, uf1'low); -- 6.5

  -- The "." is optional in this syntax, however it exist and is

  -- in the wrong location an error is produced.  Overflow will

  -- result in saturation.



  function from_string (

    bstring : string;                   -- binary string

    constant left_index : integer;

    constant right_index : integer)

    return UNRESOLVED_ufixed is

    variable result : UNRESOLVED_ufixed (left_index downto right_index);

    variable L : line;

    variable good : boolean;

  begin

    L := new string'(bstring);

    read (L, result, good);

    deallocate (L);

    assert (good)

      report fixed_pkg'instance_name

      & "from_string: Bad string "& bstring severity error;

    return result;

  end function from_string;



  -- Octal and hex conversions work as follows:

  -- uf1 <= from_hstring ("6.8", 3, -3); -- 6.5 (bottom zeros dropped)

  -- uf1 <= from_ostring ("06.4", 3, -3); -- 6.5 (top zeros dropped)

  function from_ostring (

    ostring : string;                   -- Octal string

    constant left_index : integer;

    constant right_index : integer)

    return UNRESOLVED_ufixed is

    variable result : UNRESOLVED_ufixed (left_index downto right_index);

    variable L : line;

    variable good : boolean;

  begin

    L := new string'(ostring);

    oread (L, result, good);

    deallocate (L);

    assert (good)

      report fixed_pkg'instance_name

      & "from_ostring: Bad string "& ostring severity error;

    return result;

  end function from_ostring;



  function from_hstring (

    hstring : string;                   -- hex string

    constant left_index : integer;

    constant right_index : integer)

    return UNRESOLVED_ufixed is

    variable result : UNRESOLVED_ufixed (left_index downto right_index);

    variable L : line;

    variable good : boolean;

  begin

    L := new string'(hstring);

    hread (L, result, good);

    deallocate (L);

    assert (good)

      report fixed_pkg'instance_name

      & "from_hstring: Bad string "& hstring severity error;

    return result;

  end function from_hstring;



  function from_string (

    bstring : string;                   -- binary string

    constant left_index : integer;

    constant right_index : integer)

    return UNRESOLVED_sfixed is

    variable result : UNRESOLVED_sfixed (left_index downto right_index);

    variable L : line;

    variable good : boolean;

  begin

    L := new string'(bstring);

    read (L, result, good);

    deallocate (L);

    assert (good)

      report fixed_pkg'instance_name

      & "from_string: Bad string "& bstring severity error;

    return result;

  end function from_string;



  function from_ostring (

    ostring : string;                   -- Octal string

    constant left_index : integer;

    constant right_index : integer)

    return UNRESOLVED_sfixed is

    variable result : UNRESOLVED_sfixed (left_index downto right_index);

    variable L : line;

    variable good : boolean;

  begin

    L := new string'(ostring);

    oread (L, result, good);

    deallocate (L);

    assert (good)

      report fixed_pkg'instance_name

      & "from_ostring: Bad string "& ostring severity error;

    return result;

  end function from_ostring;



  function from_hstring (

    hstring : string;                   -- hex string

    constant left_index : integer;

    constant right_index : integer)

    return UNRESOLVED_sfixed is

    variable result : UNRESOLVED_sfixed (left_index downto right_index);

    variable L : line;

    variable good : boolean;

  begin

    L := new string'(hstring);

    hread (L, result, good);

    deallocate (L);

    assert (good)

      report fixed_pkg'instance_name

      & "from_hstring: Bad string "& hstring severity error;

    return result;

  end function from_hstring;



  -- Same as above, "size_res" is used for it's range only.

  function from_string (

    bstring : string;                   -- binary string

    size_res : UNRESOLVED_ufixed)

    return UNRESOLVED_ufixed is

  begin

    return from_string (bstring, size_res'high, size_res'low);

  end function from_string;



  function from_ostring (

    ostring : string;                   -- Octal string

    size_res : UNRESOLVED_ufixed)

    return UNRESOLVED_ufixed is

  begin

    return from_ostring (ostring, size_res'high, size_res'low);

  end function from_ostring;



  function from_hstring (

    hstring : string;                   -- hex string

    size_res : UNRESOLVED_ufixed)

    return UNRESOLVED_ufixed is

  begin

    return from_hstring(hstring, size_res'high, size_res'low);

  end function from_hstring;



  function from_string (

    bstring : string;                   -- binary string

    size_res : UNRESOLVED_sfixed)

    return UNRESOLVED_sfixed is

  begin

    return from_string (bstring, size_res'high, size_res'low);

  end function from_string;



  function from_ostring (

    ostring : string;                   -- Octal string

    size_res : UNRESOLVED_sfixed)

    return UNRESOLVED_sfixed is

  begin

    return from_ostring (ostring, size_res'high, size_res'low);

  end function from_ostring;



  function from_hstring (

    hstring : string;                   -- hex string

    size_res : UNRESOLVED_sfixed)

    return UNRESOLVED_sfixed is

  begin

    return from_hstring (hstring, size_res'high, size_res'low);

  end function from_hstring;



  -- purpose: Calculate the string boundaries

  procedure calculate_string_boundry (

    arg : in string;                    -- input string

    left_index : out integer;           -- left

    right_index : out integer) is       -- right

    -- examples "10001.111" would return +4, -3

    -- "07X.44" would return +2, -2 (then the octal routine would multiply)

    -- "A_B_._C" would return +1, -1 (then the hex routine would multiply)

    alias xarg : string (arg'length downto 1) is arg;  -- make it downto range

    variable l, r : integer;            -- internal indexes

    variable founddot : boolean := false;

  begin

    if arg'length > 0 then

      l := xarg'high - 1;

      r := 0;

      for i in xarg'range loop

        if xarg(i) = '_' then

          if r = 0 then

            l := l - 1;

          else

            r := r + 1;

          end if;

        elsif xarg(i) = ' ' or xarg(i) = NBSP or xarg(i) = HT then

          report fixed_pkg'instance_name

            & "Found a space in the input STRING " & xarg

            severity error;

        elsif xarg(i) = '.' then

          if founddot then

            report fixed_pkg'instance_name

              & "Found two binary points in input string " & xarg

              severity error;

          else

            l := l - i;

            r := -i + 1;

            founddot := true;

          end if;

        end if;

      end loop;

      left_index := l;

      right_index := r;

    else

      left_index := 0;

      right_index := 0;

    end if;

  end procedure calculate_string_boundry;



  -- Direct conversion functions.  Example:

  --  signal uf1 : ufixed (3 downto -3);

  --  uf1 <= from_string ("0110.100"); -- 6.5

  -- In this case the "." is not optional, and the size of

  -- the output must match exactly.

  function from_string (

    bstring : string)                   -- binary string

    return UNRESOLVED_ufixed is

    variable left_index, right_index : integer;

  begin

    calculate_string_boundry (bstring, left_index, right_index);

    return from_string (bstring, left_index, right_index);

  end function from_string;



  -- Direct octal and hex conversion functions.  In this case

  -- the string lengths must match.  Example:

  -- signal sf1 := sfixed (5 downto -3);

  -- sf1 <= from_ostring ("71.4") -- -6.5

  function from_ostring (

    ostring : string)                   -- Octal string

    return UNRESOLVED_ufixed is

    variable left_index, right_index : integer;

  begin

    calculate_string_boundry (ostring, left_index, right_index);

    return from_ostring (ostring, ((left_index+1)*3)-1, right_index*3);

  end function from_ostring;



  function from_hstring (

    hstring : string)                   -- hex string

    return UNRESOLVED_ufixed is

    variable left_index, right_index : integer;

  begin

    calculate_string_boundry (hstring, left_index, right_index);

    return from_hstring (hstring, ((left_index+1)*4)-1, right_index*4);

  end function from_hstring;



  function from_string (

    bstring : string)                   -- binary string

    return UNRESOLVED_sfixed is

    variable left_index, right_index : integer;

  begin

    calculate_string_boundry (bstring, left_index, right_index);

    return from_string (bstring, left_index, right_index);

  end function from_string;



  function from_ostring (

    ostring : string)                   -- Octal string

    return UNRESOLVED_sfixed is

    variable left_index, right_index : integer;

  begin

    calculate_string_boundry (ostring, left_index, right_index);

    return from_ostring (ostring, ((left_index+1)*3)-1, right_index*3);

  end function from_ostring;



  function from_hstring (

    hstring : string)                   -- hex string

    return UNRESOLVED_sfixed is

    variable left_index, right_index : integer;

  begin

    calculate_string_boundry (hstring, left_index, right_index);

    return from_hstring (hstring, ((left_index+1)*4)-1, right_index*4);

  end function from_hstring;

-- pragma synthesis_on

-- rtl_synthesis on

  -- IN VHDL-2006 std_logic_vector is a subtype of std_ulogic_vector, so these

  -- extra functions are needed for compatability.

  function to_ufixed (

    arg : std_logic_vector;             -- shifted vector

    constant left_index : integer;

    constant right_index : integer)

    return UNRESOLVED_ufixed is

  begin

    return to_ufixed (

      arg => to_stdulogicvector (arg),

      left_index => left_index,

      right_index => right_index);

  end function to_ufixed;



  function to_ufixed (

    arg : std_logic_vector;             -- shifted vector

    size_res : UNRESOLVED_ufixed)       -- for size only

    return UNRESOLVED_ufixed is

  begin

    return to_ufixed (

      arg => to_stdulogicvector (arg),

      size_res => size_res);

  end function to_ufixed;



  function to_sfixed (

    arg : std_logic_vector;             -- shifted vector

    constant left_index : integer;

    constant right_index : integer)

    return UNRESOLVED_sfixed is

  begin

    return to_sfixed (

      arg => to_stdulogicvector (arg),

      left_index => left_index,

      right_index => right_index);

  end function to_sfixed;



  function to_sfixed (

    arg : std_logic_vector;             -- shifted vector

    size_res : UNRESOLVED_sfixed)       -- for size only

    return UNRESOLVED_sfixed is

  begin

    return to_sfixed (

      arg => to_stdulogicvector (arg),

      size_res => size_res);

  end function to_sfixed;



  -- unsigned fixed point

  function to_UFix (

    arg : std_logic_vector;

    width : natural;                    -- width of vector

    fraction : natural)                 -- width of fraction

    return UNRESOLVED_ufixed is

  begin

    return to_UFix (

      arg => to_stdulogicvector (arg),

      width => width,

      fraction => fraction);

  end function to_UFix;



  -- signed fixed point

  function to_SFix (

    arg : std_logic_vector;

    width : natural;                    -- width of vector

    fraction : natural)                 -- width of fraction

    return UNRESOLVED_sfixed is

  begin

    return to_SFix (

      arg => to_stdulogicvector (arg),

      width => width,

      fraction => fraction);

  end function to_SFix;



end package body fixed_pkg;

