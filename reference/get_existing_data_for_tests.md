# SLF Data for Testing

Get the relevant data from the SLFs use, the year, recid and variable
names from the 'new' data to make it as efficient as possible.

## Usage

``` r
get_existing_data_for_tests(new_data, file_version = "episode")
```

## Arguments

- new_data:

  a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)
  of the new data which the SLF data will be compared to.

- file_version:

  whether to test against the "episode" file (the default) or the
  "individual" file.

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)
from the SLF with the relevant recids and variables.

## See also

produce_source_extract_tests

Other test functions:
[`format_test_excel()`](https://public-health-scotland.github.io/source-linkage-files/reference/format_test_excel.md),
[`produce_test_comparison()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_test_comparison.md),
[`write_tests_xlsx()`](https://public-health-scotland.github.io/source-linkage-files/reference/write_tests_xlsx.md)
