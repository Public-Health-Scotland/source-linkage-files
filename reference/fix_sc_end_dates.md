# Fix sc end dates

Fix social care end dates when the end date is earlier than the start
date. Set this to the end of the fyear

## Usage

``` r
fix_sc_end_dates(start_date, end_date, period_end_date)
```

## Arguments

- start_date:

  A vector containing dates.

- end_date:

  A vector containing dates.

- period_end_date:

  the last date of Social care latest submission period.

## Value

A date vector with replaced end dates
