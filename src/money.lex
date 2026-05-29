# lex-money — Money type and arithmetic
#
# Money = { amount :: Int, currency :: Currency, exponent :: Int }
# represents  amount × 10^exponent  in the given currency.
#
# For USD (2 minor units): exponent = -2, so 1250 cents = USD 12.50.
# For JPY (0 minor units): exponent =  0, so   500 yen  = JPY 500.
#
# Effects: none.

import "std.str" as str

import "./currency" as currency

import "./decimal" as d

import "./rounding" as r

type Money = { amount :: Int, currency :: currency.Currency, exponent :: Int }

fn money(amount :: Int, cur :: currency.Currency, exponent :: Int) -> Money {
  { amount: amount, currency: cur, exponent: exponent }
}

# Construct zero in a given currency, using its canonical minor-unit exponent.
fn zero(cur :: currency.Currency) -> Money
  examples {
    zero(Usd) => { amount: 0, currency: Usd, exponent: -2 },
    zero(Jpy) => { amount: 0, currency: Jpy, exponent: 0 }
  }
{
  { amount: 0, currency: cur, exponent: 0 - currency.minor_units(cur) }
}

# From a whole-unit amount. from_major(12, Usd) = USD 12.00 = 1200 cents.
fn from_major(major :: Int, cur :: currency.Currency) -> Money
  examples {
    from_major(12, Usd) => { amount: 1200, currency: Usd, exponent: -2 },
    from_major(100, Jpy) => { amount: 100, currency: Jpy, exponent: 0 }
  }
{
  let exp := 0 - currency.minor_units(cur)
  let scaled := major * d.pow10(currency.minor_units(cur))
  { amount: scaled, currency: cur, exponent: exp }
}

fn to_decimal(m :: Money) -> d.Decimal {
  { coefficient: m.amount, exponent: m.exponent }
}

fn from_decimal(dec :: d.Decimal, cur :: currency.Currency) -> Money {
  { amount: dec.coefficient, currency: cur, exponent: dec.exponent }
}

fn canonical_exponent(cur :: currency.Currency) -> Int {
  0 - currency.minor_units(cur)
}

fn add(a :: Money, b :: Money) -> Result[Money, Str] {
  if currency.code(a.currency) != currency.code(b.currency) {
    Err(str.concat("currency mismatch: ", str.concat(currency.code(a.currency), str.concat(" vs ", currency.code(b.currency)))))
  } else {
    let da := to_decimal(a)
    let db := to_decimal(b)
    let result := d.add(da, db)
    Ok({ amount: result.coefficient, currency: a.currency, exponent: result.exponent })
  }
}

fn sub(a :: Money, b :: Money) -> Result[Money, Str] {
  if currency.code(a.currency) != currency.code(b.currency) {
    Err(str.concat("currency mismatch: ", str.concat(currency.code(a.currency), str.concat(" vs ", currency.code(b.currency)))))
  } else {
    let da := to_decimal(a)
    let db := to_decimal(b)
    let result := d.sub(da, db)
    Ok({ amount: result.coefficient, currency: a.currency, exponent: result.exponent })
  }
}

fn scale(m :: Money, factor :: d.Decimal, mode :: r.RoundingMode) -> Money {
  let dm := to_decimal(m)
  let product := d.mul(dm, factor)
  let target := canonical_exponent(m.currency)
  let rounded := r.round_to(product, target, mode)
  { amount: rounded.coefficient, currency: m.currency, exponent: rounded.exponent }
}

fn compare(a :: Money, b :: Money) -> Result[Int, Str] {
  if currency.code(a.currency) != currency.code(b.currency) {
    Err(str.concat("currency mismatch: ", str.concat(currency.code(a.currency), str.concat(" vs ", currency.code(b.currency)))))
  } else {
    Ok(d.compare(to_decimal(a), to_decimal(b)))
  }
}

fn is_zero(m :: Money) -> Bool {
  m.amount == 0
}

fn is_positive(m :: Money) -> Bool {
  m.amount > 0
}

fn is_negative(m :: Money) -> Bool {
  m.amount < 0
}

fn negate(m :: Money) -> Money {
  { amount: 0 - m.amount, currency: m.currency, exponent: m.exponent }
}

fn abs(m :: Money) -> Money {
  if m.amount < 0 {
    negate(m)
  } else {
    m
  }
}

