# lex-money — rounding modes
#
# Effects: none.

import "./decimal" as d

type RoundingMode =
    HalfUp
  | HalfDown
  | HalfEven
  | Down
  | Up
  | Ceiling
  | Floor

# Round `dec` so its exponent equals `target_exponent`.
#
# If dec.exponent == target_exponent: no-op.
# If dec.exponent < target_exponent (more precision than needed): round.
# If dec.exponent > target_exponent (less precision): scale up.
fn round_to(dec :: d.Decimal, target_exponent :: Int, mode :: RoundingMode) -> d.Decimal {
  if dec.exponent == target_exponent {
    dec
  } else if dec.exponent > target_exponent {
    let shift := dec.exponent - target_exponent
    let scaled := dec.coefficient * d.pow10(shift)
    { coefficient: scaled, exponent: target_exponent }
  } else {
    let shift   := target_exponent - dec.exponent
    let divisor := d.pow10(shift)
    let q       := dec.coefficient / divisor
    let r       := dec.coefficient % divisor
    let half    := divisor / 2
    let abs_r   := if r < 0 { 0 - r } else { r }
    let rounded_q := match mode {
      Down     => q,
      Up       => if r != 0 {
                    if dec.coefficient > 0 { q + 1 } else { q - 1 }
                  } else {
                    q
                  },
      Ceiling  => if r > 0 { q + 1 } else { q },
      Floor    => if r < 0 { q - 1 } else { q },
      HalfUp   => if abs_r * 2 >= divisor {
                    if dec.coefficient > 0 { q + 1 } else { q - 1 }
                  } else {
                    q
                  },
      HalfDown => if abs_r * 2 > divisor {
                    if dec.coefficient > 0 { q + 1 } else { q - 1 }
                  } else {
                    q
                  },
      HalfEven => if abs_r * 2 == divisor {
                    if q % 2 != 0 {
                      if dec.coefficient > 0 { q + 1 } else { q - 1 }
                    } else {
                      q
                    }
                  } else if abs_r * 2 > divisor {
                    if dec.coefficient > 0 { q + 1 } else { q - 1 }
                  } else {
                    q
                  },
    }
    { coefficient: rounded_q, exponent: target_exponent }
  }
}
