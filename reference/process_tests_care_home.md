# Process Care Home tests

This script takes the processed Care home extract and produces a test
comparison with the previous data. This is written to disk as an xlsx.

## Usage

``` r
process_tests_care_home(data, year)
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
