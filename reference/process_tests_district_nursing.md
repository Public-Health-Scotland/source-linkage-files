# Process District Nursing tests

This script takes the processed district nursing extract and produces a
test comparison with the previous data. This is written to disk as a
CSV.

## Usage

``` r
process_tests_district_nursing(data, year)
```

## Arguments

- data:

  a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)
  of the processed data extract.

- year:

  the financial year of the extract in the format '1718'.

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)
containing a test comparison.
