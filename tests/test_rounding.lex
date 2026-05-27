# tests for lex-money/src/rounding.lex

import "std.str"  as str
import "std.list" as list
import "../src/decimal"  as d
import "../src/rounding" as r

fn pass() -> Result[Unit, Str] { Ok(()) }
fn fail(why :: Str) -> Result[Unit, Str] { Err(why) }
fn assert_true(cond :: Bool, label :: Str) -> Result[Unit, Str] {
  if cond { pass() } else { fail(label) }
}

# 1.255 rounded to 2 decimals
fn make_1255() -> d.Decimal { { coefficient: 1255, exponent: -3 } }

fn test_round_half_up() -> Result[Unit, Str] {
  let x := r.round_to(make_1255(), -2, HalfUp)
  assert_true(x.coefficient == 126 and x.exponent == -2, "HalfUp 1.255 => 1.26")
}

fn test_round_half_down() -> Result[Unit, Str] {
  let x := r.round_to(make_1255(), -2, HalfDown)
  assert_true(x.coefficient == 125 and x.exponent == -2, "HalfDown 1.255 => 1.25")
}

fn test_round_down() -> Result[Unit, Str] {
  let x := r.round_to(make_1255(), -2, Down)
  assert_true(x.coefficient == 125 and x.exponent == -2, "Down truncates")
}

fn test_round_up() -> Result[Unit, Str] {
  let x := r.round_to(make_1255(), -2, Up)
  assert_true(x.coefficient == 126 and x.exponent == -2, "Up rounds away from zero")
}

fn test_round_ceiling() -> Result[Unit, Str] {
  let x := r.round_to(make_1255(), -2, Ceiling)
  assert_true(x.coefficient == 126 and x.exponent == -2, "Ceiling positive")
}

fn test_round_floor() -> Result[Unit, Str] {
  let neg := { coefficient: -1255, exponent: -3 }
  let x   := r.round_to(neg, -2, Floor)
  assert_true(x.coefficient == -13 and x.exponent == -2, "Floor negative => -1.30")
}

fn test_no_op_same_exponent() -> Result[Unit, Str] {
  let x := { coefficient: 125, exponent: -2 }
  let r2 := r.round_to(x, -2, HalfUp)
  assert_true(r2.coefficient == 125, "no-op same exponent")
}

fn test_scale_up() -> Result[Unit, Str] {
  let x  := { coefficient: 1, exponent: 0 }
  let r2 := r.round_to(x, -2, HalfUp)
  assert_true(r2.coefficient == 100 and r2.exponent == -2, "scale up 1 => 1.00")
}

fn test_half_even_round_to_even() -> Result[Unit, Str] {
  # 1.245 → should round to 1.24 (banker's rounding, 4 is even)
  let x  := { coefficient: 1245, exponent: -3 }
  let r2 := r.round_to(x, -2, HalfEven)
  assert_true(r2.coefficient == 124 and r2.exponent == -2, "HalfEven 1.245 => 1.24")
}

fn test_half_even_round_up() -> Result[Unit, Str] {
  # 1.255 → should round to 1.26 (5 is odd, round up)
  let r2 := r.round_to(make_1255(), -2, HalfEven)
  assert_true(r2.coefficient == 126 and r2.exponent == -2, "HalfEven 1.255 => 1.26")
}

fn suite() -> List[Result[Unit, Str]] {
  [
    test_round_half_up(),
    test_round_half_down(),
    test_round_down(),
    test_round_up(),
    test_round_ceiling(),
    test_round_floor(),
    test_no_op_same_exponent(),
    test_scale_up(),
    test_half_even_round_to_even(),
    test_half_even_round_up(),
  ]
}

fn run_all() -> Int {
  list.fold(suite(), 0,
    fn (n :: Int, r :: Result[Unit, Str]) -> Int {
      match r { Ok(_) => n, Err(_) => n + 1 }
    })
}
