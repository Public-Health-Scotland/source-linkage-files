# Social care client lookup tests

This script takes the processed social care client lookup and produces a
test comparison with the previous data. This is written to disk in the
tests workbook.

## Usage

``` r
process_tests_sc_client_lookup(data, year)
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
