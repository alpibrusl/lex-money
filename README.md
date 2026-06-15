# lex-money

[![CI](https://github.com/alpibrusl/lex-money/actions/workflows/ci.yml/badge.svg)](https://github.com/alpibrusl/lex-money/actions/workflows/ci.yml)

**Part of the [Lex](https://lexlang.org) project** — Library · [Manifesto](https://lexlang.org/manifesto) · [All packages](https://lexlang.org)

Exact decimal monetary arithmetic for Lex. No floating point. No silent rounding.

`0.1 + 0.2` is not `0.3` in IEEE 754 — in a trading system that error compounds across thousands of fills. Every value here is `coefficient × 10^exponent` (e.g. `$175.00` = `decimal(17500, -2)`), so arithmetic is exact, round-trips are lossless, and every rounding decision is an explicit call with a named mode.

This is the foundation of the stack. Every price, notional, margin, PnL, and fee in every upstream package is a `Decimal` or `Money` from here.

---

## Modules

### `decimal` — scaled-integer arithmetic

```lex
import "lex-money/src/decimal" as d

let price    := d.decimal(17500, -2)   # $175.00
let qty      := d.from_int(200000)
let notional := d.mul(price, qty)      # $35,000,000.00 — exact
```

`add`, `sub`, `mul`, `compare`, `normalize`, `abs`, `negate`, `pow10`, `is_zero`, `is_positive`.

### `money` — currency-typed values

```lex
import "lex-money/src/money"    as money
import "lex-money/src/currency" as ccy

let price := money.from_major(Usd, d.from_int(175))
let zero  := money.zero(Eur)
let total := money.add(price, price)   # Ok(...)
# money.add(price, zero)               # type error — mismatched currencies
```

`Money = (Decimal, Currency)`. Arithmetic on mismatched currencies is a type error.

### `currency` — ISO 4217

25 currencies: `Usd`, `Eur`, `Gbp`, `Chf`, `Jpy`, `Cad`, `Aud`, `Hkd`, `Sgd`, `Nok`, `Sek`, `Dkk`, `Pln`, `Czk`, `Huf`, `Ron`, `Bgn`, `Rub`, `Cny`, `Inr`, `Brl`, `Mxn`, `Zar`.

```lex
ccy.code(Chf)          # "CHF"
ccy.minor_units(Jpy)   # 0  (yen has no minor units)
ccy.from_code("USD")   # Some(Usd)
```

### `rounding` — explicit modes

```lex
import "lex-money/src/rounding" as round
round.round_to(d.decimal(175499, -3), d.decimal(1, -2), HalfEven)  # $175.50
```

`HalfUp`, `HalfDown`, `HalfEven` (banker's), `Up`, `Down`, `Ceiling`, `Floor`. Every rounding site names its mode — there is no default.

---

## In the stack

```
lex-money  ←  no dependencies
    ↓
lex-fix · lex-positions · lex-risk · lex-trade · lex-marketdata · lex-sor · lex-finance · lex-oms
```

---

## Install

```toml
[dependencies]
"lex-money" = { git = "https://github.com/alpibrusl/lex-money" }
```
