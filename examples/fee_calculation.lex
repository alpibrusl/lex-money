# lex-money — fee calculation example
#
# Demonstrates the key use case: computing a percentage fee on a
# monetary amount using exact decimal arithmetic.
#
# USD 1250.00 traded at 0.05% commission:
#   fee = 1250.00 * 0.0005 = 0.625 → rounds to USD 0.63 (HalfUp)
#
# With floating-point arithmetic, 1250.0 * 0.0005 == 0.625 — this
# particular case is exact in IEEE 754, but the substrate cannot
# guarantee it for all possible inputs. Scaled-integer arithmetic
# is exact by construction.

import "std.str" as str

import "../src/currency" as currency

import "../src/decimal" as d

import "../src/rounding" as r

import "../src/money" as m

fn run() -> Str {
  let notional := m.money(125000, Usd, -2)
  let rate := { coefficient: 5, exponent: -4 }
  let fee := m.scale(notional, rate, HalfUp(()))
  if fee.amount == 63 {
    "fee calculation correct: USD 0.63"
  } else {
    "unexpected fee amount"
  }
}

fn currency_mismatch_example() -> Str {
  let usd := m.from_major(100, Usd)
  let eur := m.from_major(100, Eur)
  match m.add(usd, eur) {
    Ok(_) => "unexpected: different currencies should not add",
    Err(e) => str.concat("correctly rejected: ", e),
  }
}

