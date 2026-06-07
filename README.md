# lex-money

Exact decimal monetary arithmetic for the [Lex language](https://github.com/alpibrusl/lex-lang).

lex-lang provides only `Int` (arbitrary-precision integer) and `Float` (IEEE 754 double). Floating-point arithmetic is unsuitable for money: `0.1 + 0.2 != 0.3` in binary floating-point, and rounding errors accumulate across trade legs, fee calculations, and settlement flows. lex-money fills this gap using scaled-integer representation — the same approach used by financial industry libraries and SQL `DECIMAL` types.

A `Decimal` is a `coefficient × 10^exponent` pair. A `Money` wraps a `Decimal` with an ISO 4217 currency code and enforces that arithmetic operations stay within the same currency. All rounding is explicit: callers name a `RoundingMode` at every site where precision is reduced.

## What it ships

- **`src/currency.lex`** — ISO 4217 currency ADT (`Usd`, `Eur`, `Gbp`, `Jpy`, …), `code/1`, `minor_units/1`, `from_code/1`.
- **`src/decimal.lex`** — `Decimal` type, `add`, `sub`, `mul`, `compare`, `normalize`, `align`, `pow10`.
- **`src/rounding.lex`** — `RoundingMode` ADT (`HalfUp`, `HalfDown`, `HalfEven`, `Down`, `Up`, `Ceiling`, `Floor`) and `round_to/3`.
- **`src/money.lex`** — `Money` type, `add`, `sub`, `scale`, `compare`, `zero`, `from_major`, `negate`, `abs`.

## Usage

```lex
import "lex-money/src/currency" as currency
import "lex-money/src/decimal"  as d
import "lex-money/src/money"    as m
import "lex-money/src/rounding" as r

# USD 12.50
let price    := m.money(1250, Usd, -2)

# USD 5.00
let discount := m.from_major(5, Usd)

# USD 17.50  (add returns Result[Money, Str] — currencies must match)
let total    := m.add(price, discount)

# Apply 10% fee, round half-up
let factor   := d.decimal(1, -1)               # 0.1  (Decimal from lex-money/decimal)
let fee      := m.scale(price, factor, HalfUp(()))  # USD 1.25
```

## Design note

Making catastrophic money errors a **type error** rather than a runtime surprise is exactly the kind of property an agent-native substrate should enforce. An agent that generates a monetary computation either produces a well-typed `Money` value — verified by the type system to carry a currency and a precision — or the substrate rejects it. No float-to-decimal silent coercion, no implicit currency conversion.

---

Built under the principles of [Trust Without Comprehension](https://alpibru.com/manifesto).
