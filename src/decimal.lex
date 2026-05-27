# lex-money — exact decimal arithmetic
#
# Decimal = { coefficient :: Int, exponent :: Int }
# represents coefficient × 10^exponent.
#
# Examples:
#   1.23  →  { coefficient: 123, exponent: -2 }
#   1000  →  { coefficient: 1,   exponent:  3 }
#   0.001 →  { coefficient: 1,   exponent: -3 }
#
# Effects: none.

type Decimal = {
  coefficient :: Int,
  exponent    :: Int,
}

fn decimal(coefficient :: Int, exponent :: Int) -> Decimal {
  { coefficient: coefficient, exponent: exponent }
}

fn zero() -> Decimal { { coefficient: 0, exponent: 0 } }
fn one()  -> Decimal { { coefficient: 1, exponent: 0 } }

fn from_int(n :: Int) -> Decimal { { coefficient: n, exponent: 0 } }

fn is_zero(d :: Decimal) -> Bool { d.coefficient == 0 }

fn is_positive(d :: Decimal) -> Bool { d.coefficient > 0 }

fn is_negative(d :: Decimal) -> Bool { d.coefficient < 0 }

fn negate(d :: Decimal) -> Decimal
  examples {
    negate({ coefficient: 123, exponent: -2 }) => { coefficient: -123, exponent: -2 },
  }
{
  { coefficient: 0 - d.coefficient, exponent: d.exponent }
}

fn abs(d :: Decimal) -> Decimal {
  if d.coefficient < 0 {
    negate(d)
  } else {
    d
  }
}

# 10^n — computed recursively (only for n >= 0).
fn pow10(n :: Int) -> Int
  examples {
    pow10(0) => 1,
    pow10(1) => 10,
    pow10(3) => 1000,
  }
{
  if n <= 0 {
    1
  } else {
    10 * pow10(n - 1)
  }
}

# Remove trailing zeros from coefficient by increasing exponent.
# { coefficient: 120, exponent: -3 } → { coefficient: 12, exponent: -2 }
fn normalize(d :: Decimal) -> Decimal
  examples {
    normalize({ coefficient: 120, exponent: -3 }) => { coefficient: 12, exponent: -2 },
    normalize({ coefficient: 100, exponent: 0  }) => { coefficient: 1,  exponent:  2 },
    normalize({ coefficient: 0,   exponent: -5 }) => { coefficient: 0,  exponent:  0 },
  }
{
  if d.coefficient == 0 {
    zero()
  } else if d.coefficient % 10 == 0 {
    normalize({ coefficient: d.coefficient / 10, exponent: d.exponent + 1 })
  } else {
    d
  }
}

# Bring two decimals to the same (more negative) exponent so coefficients
# can be added or compared directly.
fn align(a :: Decimal, b :: Decimal) -> (Decimal, Decimal)
  examples {
    align({ coefficient: 12, exponent: -1 },
          { coefficient: 5,  exponent: -2 }) =>
      ({ coefficient: 120, exponent: -2 },
       { coefficient: 5,   exponent: -2 }),
  }
{
  if a.exponent == b.exponent {
    (a, b)
  } else if a.exponent > b.exponent {
    let shift := a.exponent - b.exponent
    let a2    := { coefficient: a.coefficient * pow10(shift), exponent: b.exponent }
    (a2, b)
  } else {
    let shift := b.exponent - a.exponent
    let b2    := { coefficient: b.coefficient * pow10(shift), exponent: a.exponent }
    (a, b2)
  }
}

fn add(a :: Decimal, b :: Decimal) -> Decimal
  examples {
    add({ coefficient: 12, exponent: -1 },
        { coefficient:  5, exponent: -2 }) =>
      { coefficient: 125, exponent: -2 },
  }
{
  let (a2, b2) := align(a, b)
  { coefficient: a2.coefficient + b2.coefficient, exponent: a2.exponent }
}

fn sub(a :: Decimal, b :: Decimal) -> Decimal
  examples {
    sub({ coefficient: 150, exponent: -2 },
        { coefficient:  50, exponent: -2 }) =>
      { coefficient: 100, exponent: -2 },
  }
{
  add(a, negate(b))
}

fn mul(a :: Decimal, b :: Decimal) -> Decimal
  examples {
    mul({ coefficient: 12, exponent: -1 },
        { coefficient:  3, exponent:  0 }) =>
      { coefficient: 36, exponent: -1 },
  }
{
  { coefficient: a.coefficient * b.coefficient,
    exponent:    a.exponent    + b.exponent }
}

# Returns -1, 0, or 1.
fn compare(a :: Decimal, b :: Decimal) -> Int {
  let (a2, b2) := align(a, b)
  if a2.coefficient < b2.coefficient { 0 - 1 }
  else if a2.coefficient > b2.coefficient { 1 }
  else { 0 }
}

fn eq(a :: Decimal, b :: Decimal) -> Bool { compare(a, b) == 0 }
fn lt(a :: Decimal, b :: Decimal) -> Bool { compare(a, b) == (0 - 1) }
fn gt(a :: Decimal, b :: Decimal) -> Bool { compare(a, b) == 1 }
fn lte(a :: Decimal, b :: Decimal) -> Bool { not (gt(a, b)) }
fn gte(a :: Decimal, b :: Decimal) -> Bool { not (lt(a, b)) }
