# Process cross year tests

Process high level tests (e.g the number of records in each recid)
across years.

## Usage

``` r
process_tests_cross_year(year)
```

## Arguments

- year:

  Year of the file to be read, you can specify multiple years which will
  then be returned as one file. See SLFhelper for more info.

## Value

a tibble with a test summary across years
