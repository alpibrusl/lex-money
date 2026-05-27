# lex-money — ISO 4217 currency codes
#
# Effects: none.

import "std.str" as str

type Currency =
    Usd | Eur | Gbp | Jpy | Chf | Cad | Aud | Hkd | Sgd
  | Nok | Sek | Dkk | Pln | Czk | Huf | Ron | Bgn | Hrk
  | Rub | Cny | Inr | Brl | Mxn | Zar | Unknown(Str)

fn code(c :: Currency) -> Str
  examples {
    code(Usd) => "USD",
    code(Eur) => "EUR",
    code(Jpy) => "JPY",
  }
{
  match c {
    Usd        => "USD",
    Eur        => "EUR",
    Gbp        => "GBP",
    Jpy        => "JPY",
    Chf        => "CHF",
    Cad        => "CAD",
    Aud        => "AUD",
    Hkd        => "HKD",
    Sgd        => "SGD",
    Nok        => "NOK",
    Sek        => "SEK",
    Dkk        => "DKK",
    Pln        => "PLN",
    Czk        => "CZK",
    Huf        => "HUF",
    Ron        => "RON",
    Bgn        => "BGN",
    Hrk        => "HRK",
    Rub        => "RUB",
    Cny        => "CNY",
    Inr        => "INR",
    Brl        => "BRL",
    Mxn        => "MXN",
    Zar        => "ZAR",
    Unknown(s) => s,
  }
}

# Number of decimal places in the minor unit.
# JPY = 0, most major currencies = 2, KWD/BHD/OMR = 3.
fn minor_units(c :: Currency) -> Int
  examples {
    minor_units(Usd) => 2,
    minor_units(Eur) => 2,
    minor_units(Jpy) => 0,
  }
{
  match c {
    Jpy        => 0,
    Unknown(_) => 2,
    _          => 2,
  }
}

fn from_code(s :: Str) -> Option[Currency] {
  if s == "USD"      { Some(Usd) }
  else if s == "EUR" { Some(Eur) }
  else if s == "GBP" { Some(Gbp) }
  else if s == "JPY" { Some(Jpy) }
  else if s == "CHF" { Some(Chf) }
  else if s == "CAD" { Some(Cad) }
  else if s == "AUD" { Some(Aud) }
  else if s == "HKD" { Some(Hkd) }
  else if s == "SGD" { Some(Sgd) }
  else if s == "NOK" { Some(Nok) }
  else if s == "SEK" { Some(Sek) }
  else if s == "DKK" { Some(Dkk) }
  else if s == "PLN" { Some(Pln) }
  else if s == "CZK" { Some(Czk) }
  else if s == "HUF" { Some(Huf) }
  else if s == "RON" { Some(Ron) }
  else if s == "BGN" { Some(Bgn) }
  else if s == "HRK" { Some(Hrk) }
  else if s == "RUB" { Some(Rub) }
  else if s == "CNY" { Some(Cny) }
  else if s == "INR" { Some(Inr) }
  else if s == "BRL" { Some(Brl) }
  else if s == "MXN" { Some(Mxn) }
  else if s == "ZAR" { Some(Zar) }
  else               { None }
}
