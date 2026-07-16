# tests for lex-money/src/decimal.lex

import "std.str" as str

import "std.list" as list

import "../src/decimal" as d

fn pass() -> Result[Unit, Str] {
  Ok(())
}

fn fail(why :: Str) -> Result[Unit, Str] {
  Err(why)
}

fn assert_true(cond :: Bool, label :: Str) -> Result[Unit, Str] {
  if cond {
    pass()
  } else {
    fail(label)
  }
}

fn test_from_int() -> Result[Unit, Str] {
  let x := d.from_int(42)
  assert_true(x.coefficient == 42 and x.exponent == 0, "from_int")
}

fn test_zero() -> Result[Unit, Str] {
  assert_true(d.is_zero(d.zero()), "zero is_zero")
}

fn test_one() -> Result[Unit, Str] {
  let o := d.one()
  assert_true(o.coefficient == 1 and o.exponent == 0, "one")
}

fn test_is_positive() -> Result[Unit, Str] {
  assert_true(d.is_positive(d.from_int(5)), "positive 5")
}

fn test_is_negative() -> Result[Unit, Str] {
  assert_true(d.is_negative(d.from_int(0 - 5)), "negative -5")
}

fn test_negate() -> Result[Unit, Str] {
  let x := d.negate(d.from_int(7))
  assert_true(x.coefficient == 0 - 7, "negate")
}

fn test_abs() -> Result[Unit, Str] {
  let x := d.abs({ coefficient: 0 - 10, exponent: -2 })
  assert_true(x.coefficient == 10, "abs")
}

fn test_pow10() -> Result[Unit, Str] {
  assert_true(d.pow10(0) == 1 and d.pow10(3) == 1000, "pow10")
}

fn test_add_same_exponent() -> Result[Unit, Str] {
  let a := { coefficient: 100, exponent: -2 }
  let b := { coefficient: 200, exponent: -2 }
  let r := d.add(a, b)
  assert_true(r.coefficient == 300 and r.exponent == -2, "add same exp")
}

fn test_add_different_exponent() -> Result[Unit, Str] {
  let a := { coefficient: 12, exponent: -1 }
  let b := { coefficient: 5, exponent: -2 }
  let r := d.add(a, b)
  assert_true(r.coefficient == 125 and r.exponent == -2, "add diff exp")
}

fn test_sub() -> Result[Unit, Str] {
  let a := { coefficient: 150, exponent: -2 }
  let b := { coefficient: 50, exponent: -2 }
  let r := d.sub(a, b)
  assert_true(r.coefficient == 100 and r.exponent == -2, "sub")
}

fn test_mul() -> Result[Unit, Str] {
  let a := { coefficient: 12, exponent: -1 }
  let b := { coefficient: 3, exponent: 0 }
  let r := d.mul(a, b)
  assert_true(r.coefficient == 36 and r.exponent == -1, "mul")
}

fn test_compare_eq() -> Result[Unit, Str] {
  let a := { coefficient: 100, exponent: -2 }
  let b := { coefficient: 1, exponent: 0 }
  assert_true(d.eq(a, b), "compare eq: 1.00 == 1")
}

fn test_compare_lt() -> Result[Unit, Str] {
  let a := d.from_int(1)
  let b := d.from_int(2)
  assert_true(d.lt(a, b), "lt")
}

fn test_compare_gt() -> Result[Unit, Str] {
  let a := d.from_int(5)
  let b := d.from_int(3)
  assert_true(d.gt(a, b), "gt")
}

fn test_normalize() -> Result[Unit, Str] {
  let x := d.normalize({ coefficient: 120, exponent: -3 })
  assert_true(x.coefficient == 12 and x.exponent == -2, "normalize")
}

fn test_normalize_zero() -> Result[Unit, Str] {
  let x := d.normalize({ coefficient: 0, exponent: -5 })
  assert_true(x.coefficient == 0 and x.exponent == 0, "normalize zero")
}

fn suite() -> List[Result[Unit, Str]] {
  [test_from_int(), test_zero(), test_one(), test_is_positive(), test_is_negative(), test_negate(), test_abs(), test_pow10(), test_add_same_exponent(), test_add_different_exponent(), test_sub(), test_mul(), test_compare_eq(), test_compare_lt(), test_compare_gt(), test_normalize(), test_normalize_zero()]
}

fn run_all() -> Int {
  list.fold(suite(), 0, fn (n :: Int, r :: Result[Unit, Str]) -> Int {
    match r {
      Ok(_) => n,
      Err(_) => n + 1,
    }
  })
}


fn test_parse_plain_and_fraction() -> Result[Unit, Str] {
  match d.parse("66.10") {
    None => fail("66.10 should parse"),
    Some(x) => match assert_true(x.coefficient == 6610 and x.exponent == -2, "66.10 -> 6610e-2") {
      Err(e) => Err(e),
      Ok(_) => match d.parse("-0.05") {
        None => fail("-0.05 should parse"),
        Some(y) => match assert_true(y.coefficient == -5 and y.exponent == -2, "-0.05 -> -5e-2") {
          Err(e) => Err(e),
          Ok(_) => match d.parse("42") {
            None => fail("42 should parse"),
            Some(z) => assert_true(z.coefficient == 42 and z.exponent == 0, "42 -> 42e0"),
          },
        },
      },
    },
  }
}

fn none_rejected(s :: Str) -> Bool {
  match d.parse(s) {
    None => true,
    Some(_) => false,
  }
}

fn test_parse_rejects_garbage() -> Result[Unit, Str] {
  assert_true(none_rejected("") and none_rejected("1.2.3") and none_rejected("1,50") and none_rejected("abc") and none_rejected("1."), "garbage rejected")
}

fn test_to_str_round_trips() -> Result[Unit, Str] {
  match d.parse("11399.99") {
    None => fail("11399.99 should parse"),
    Some(x) => assert_true(d.to_str(x) == "11399.99", str.concat("round trip got ", d.to_str(x))),
  }
}
