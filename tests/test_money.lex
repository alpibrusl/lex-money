# tests for lex-money/src/money.lex

import "std.str"       as str
import "std.list"      as list
import "../src/currency" as currency
import "../src/decimal"  as d
import "../src/rounding" as r
import "../src/money"    as m

fn pass() -> Result[Unit, Str] { Ok(()) }
fn fail(why :: Str) -> Result[Unit, Str] { Err(why) }
fn assert_true(cond :: Bool, label :: Str) -> Result[Unit, Str] {
  if cond { pass() } else { fail(label) }
}

fn test_zero_usd() -> Result[Unit, Str] {
  let z := m.zero(Usd)
  assert_true(z.amount == 0 and z.exponent == -2, "zero USD")
}

fn test_zero_jpy() -> Result[Unit, Str] {
  let z := m.zero(Jpy)
  assert_true(z.amount == 0 and z.exponent == 0, "zero JPY")
}

fn test_from_major_usd() -> Result[Unit, Str] {
  let v := m.from_major(12, Usd)
  assert_true(v.amount == 1200 and v.exponent == -2, "from_major USD")
}

fn test_from_major_jpy() -> Result[Unit, Str] {
  let v := m.from_major(100, Jpy)
  assert_true(v.amount == 100 and v.exponent == 0, "from_major JPY")
}

fn test_add_usd() -> Result[Unit, Str] {
  let a  := { amount: 1000, currency: Usd, exponent: -2 }
  let b  := { amount:  500, currency: Usd, exponent: -2 }
  let r  := m.add(a, b)
  match r {
    Err(_)  => fail("unexpected Err"),
    Ok(res) => assert_true(res.amount == 1500, "add USD"),
  }
}

fn test_add_currency_mismatch() -> Result[Unit, Str] {
  let a := { amount: 1000, currency: Usd, exponent: -2 }
  let b := { amount: 1000, currency: Eur, exponent: -2 }
  let r := m.add(a, b)
  match r {
    Ok(_)  => fail("expected Err on mismatch"),
    Err(_) => pass(),
  }
}

fn test_sub_usd() -> Result[Unit, Str] {
  let a := { amount: 2000, currency: Usd, exponent: -2 }
  let b := { amount:  500, currency: Usd, exponent: -2 }
  let r := m.sub(a, b)
  match r {
    Err(_)  => fail("unexpected Err"),
    Ok(res) => assert_true(res.amount == 1500, "sub USD"),
  }
}

fn test_is_zero() -> Result[Unit, Str] {
  assert_true(m.is_zero(m.zero(Usd)), "is_zero")
}

fn test_is_positive() -> Result[Unit, Str] {
  let v := m.from_major(10, Usd)
  assert_true(m.is_positive(v), "is_positive")
}

fn test_negate() -> Result[Unit, Str] {
  let v := m.from_major(10, Usd)
  let n := m.negate(v)
  assert_true(m.is_negative(n), "negate")
}

fn test_scale_by_half() -> Result[Unit, Str] {
  # USD 10.00 * 0.5 = USD 5.00
  let v      := m.from_major(10, Usd)
  let factor := { coefficient: 5, exponent: -1 }
  let result := m.scale(v, factor, HalfUp)
  assert_true(result.amount == 500 and result.exponent == -2, "scale half")
}

fn test_compare_usd() -> Result[Unit, Str] {
  let a := m.from_major(10, Usd)
  let b := m.from_major(20, Usd)
  let r := m.compare(a, b)
  match r {
    Err(_)  => fail("unexpected Err"),
    Ok(cmp) => assert_true(cmp == (0 - 1), "compare less"),
  }
}

fn suite() -> List[Result[Unit, Str]] {
  [
    test_zero_usd(),
    test_zero_jpy(),
    test_from_major_usd(),
    test_from_major_jpy(),
    test_add_usd(),
    test_add_currency_mismatch(),
    test_sub_usd(),
    test_is_zero(),
    test_is_positive(),
    test_negate(),
    test_scale_by_half(),
    test_compare_usd(),
  ]
}

fn run_all() -> Int {
  list.fold(suite(), 0,
    fn (n :: Int, r :: Result[Unit, Str]) -> Int {
      match r { Ok(_) => n, Err(_) => n + 1 }
    })
}
