# lex-money — rounding modes
#
# Keeps the typed RoundingMode ADT for callers; delegates the actual
# rounding arithmetic to std.decimal.round_to via mode_to_str.
#
# Effects: none.

import "std.decimal" as std_d

import "./decimal" as d

type RoundingMode =
    HalfUp
  | HalfDown
  | HalfEven
  | Down
  | Up
  | Ceiling
  | Floor

fn mode_to_str(m :: RoundingMode) -> Str
  examples {
    mode_to_str(HalfUp)   => "HalfUp",
    mode_to_str(HalfEven) => "HalfEven",
    mode_to_str(Floor)    => "Floor",
  }
{
  match m {
    HalfUp   => "HalfUp",
    HalfDown => "HalfDown",
    HalfEven => "HalfEven",
    Down     => "Down",
    Up       => "Up",
    Ceiling  => "Ceiling",
    Floor    => "Floor",
  }
}

fn round_to(dec :: d.Decimal, target_exponent :: Int, mode :: RoundingMode) -> d.Decimal {
  std_d.round_to(dec, target_exponent, mode_to_str(mode))
}
