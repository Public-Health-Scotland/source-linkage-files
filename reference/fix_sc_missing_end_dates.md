# Fix sc missing end dates

Fix social care end dates when the end date is earlier than the start
date. Set this to the end of the fyear

## Usage

``` r
fix_sc_missing_end_dates(end_date, period_end)
```

## Arguments

- end_date:

  A vector containing dates.

- period_end:

  the last date of Social care latest submission period.

## Value

A date vector with replaced end dates
