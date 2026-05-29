# lex-money — exact decimal arithmetic
#
# Delegates to std.decimal (shipped in lex 0.9.5, lex-lang #574).
# Decimal = { coefficient :: Int, exponent :: Int }
# represents coefficient × 10^exponent — no behavioral change for callers.
#
# Effects: none.

import "std.decimal" as std_d

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

