# lex-money — exact decimal arithmetic
#
# Delegates to std.decimal (shipped in lex 0.9.5, lex-lang #574).
# Decimal = { coefficient :: Int, exponent :: Int }
# represents coefficient × 10^exponent — no behavioral change for callers.
#
# Effects: none.

import "std.decimal" as std_d

import "std.str" as str

import "std.list" as list

type Decimal = { coefficient :: Int, exponent :: Int }

fn decimal(coefficient :: Int, exponent :: Int) -> Decimal {
  std_d.decimal(coefficient, exponent)
}

fn zero() -> Decimal {
  std_d.zero()
}

fn one() -> Decimal {
  std_d.one()
}

fn from_int(n :: Int) -> Decimal {
  std_d.from_int(n)
}

fn is_zero(d :: Decimal) -> Bool {
  std_d.is_zero(d)
}

fn is_positive(d :: Decimal) -> Bool {
  std_d.is_positive(d)
}

fn is_negative(d :: Decimal) -> Bool {
  std_d.is_negative(d)
}

fn negate(d :: Decimal) -> Decimal
  examples {
    negate({ coefficient: 123, exponent: -2 }) => { coefficient: -123, exponent: -2 }
  }
{
  std_d.negate(d)
}

fn abs(d :: Decimal) -> Decimal {
  std_d.abs(d)
}

fn pow10(n :: Int) -> Int
  examples {
    pow10(0) => 1,
    pow10(1) => 10,
    pow10(3) => 1000
  }
{
  std_d.pow10(n)
}

fn normalize(d :: Decimal) -> Decimal
  examples {
    normalize({ coefficient: 120, exponent: -3 }) => { coefficient: 12, exponent: -2 },
    normalize({ coefficient: 100, exponent: 0 }) => { coefficient: 1, exponent: 2 },
    normalize({ coefficient: 0, exponent: -5 }) => { coefficient: 0, exponent: 0 }
  }
{
  std_d.normalize(d)
}

fn add(a :: Decimal, b :: Decimal) -> Decimal
  examples {
    add({ coefficient: 12, exponent: -1 }, { coefficient: 5, exponent: -2 }) => { coefficient: 125, exponent: -2 }
  }
{
  std_d.add(a, b)
}

fn sub(a :: Decimal, b :: Decimal) -> Decimal
  examples {
    sub({ coefficient: 150, exponent: -2 }, { coefficient: 50, exponent: -2 }) => { coefficient: 100, exponent: -2 }
  }
{
  std_d.sub(a, b)
}

fn mul(a :: Decimal, b :: Decimal) -> Decimal
  examples {
    mul({ coefficient: 12, exponent: -1 }, { coefficient: 3, exponent: 0 }) => { coefficient: 36, exponent: -1 }
  }
{
  std_d.mul(a, b)
}

fn compare(a :: Decimal, b :: Decimal) -> Int {
  std_d.compare(a, b)
}

fn eq(a :: Decimal, b :: Decimal) -> Bool {
  compare(a, b) == 0
}

fn lt(a :: Decimal, b :: Decimal) -> Bool {
  compare(a, b) == 0 - 1
}

fn gt(a :: Decimal, b :: Decimal) -> Bool {
  compare(a, b) == 1
}

fn lte(a :: Decimal, b :: Decimal) -> Bool {
  not gt(a, b)
}

fn gte(a :: Decimal, b :: Decimal) -> Bool {
  not lt(a, b)
}

# ── Wire representation ───────────────────────────────────────────────────────
# Decimals cross process boundaries as STRINGS ("66.10", "-0.05") — floats on
# the wire would defeat the whole package. to_str delegates to std.decimal;
# parse is strict: optional sign, digits, optional fraction. Anything else
# (exponents, spaces, thousands separators, empty parts) is None, not a guess.
fn to_str(dec :: Decimal) -> Str {
  std_d.to_str(dec)
}

fn digits_value(s :: Str) -> Option[Int] {
  if str.is_empty(s) {
    None
  } else {
    match str.to_int(s) {
      Some(n) => if n < 0 {
        None
      } else {
        Some(n)
      },
      None => None,
    }
  }
}

fn parse(s :: Str) -> Option[Decimal] {
  let neg := str.starts_with(s, "-")
  let body := if neg {
    str.slice(s, 1, str.len(s))
  } else {
    s
  }
  let parts := str.split(body, ".")
  let n_parts := list.len(parts)
  if n_parts < 1 or n_parts > 2 or str.is_empty(body) {
    None
  } else {
    let int_part := match list.head(parts) {
      Some(p) => p,
      None => "",
    }
    let frac_part := if n_parts == 2 {
      match list.head(list.tail(parts)) {
        Some(p) => p,
        None => "",
      }
    } else {
      ""
    }
    match digits_value(int_part) {
      None => None,
      Some(whole) => {
        if str.is_empty(frac_part) {
          if n_parts == 2 {
            None
          } else {
            let c := if neg {
              0 - whole
            } else {
              whole
            }
            Some(decimal(c, 0))
          }
        } else {
          match digits_value(frac_part) {
            None => None,
            Some(frac) => {
              let scale := str.len(frac_part)
              let coeff := whole * pow10(scale) + frac
              let c := if neg {
                0 - coeff
              } else {
                coeff
              }
              Some(decimal(c, 0 - scale))
            },
          }
        }
      },
    }
  }
}

