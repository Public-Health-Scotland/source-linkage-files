# Match on LTC DoB and dates of LTC incidence

Match on LTC changed_dob and dates of LTC incidence (based on hospital
incidence only).

## Usage

``` r
match_on_ltcs(data, year, ltc_data = read_file(get_ltcs_path(year)))
```

## Arguments

- data:

  episode files

- year:

  financial year, e.g. '1920'

- ltc_data:

  The LTC data for the year

## Value

data matched with long term conditions
