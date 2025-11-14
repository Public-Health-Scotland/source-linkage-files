# Write out Tests

Write test output as an xlsx workbook, with a specific sheet for each
extract. The extract sheet will be dated with the current month and day,
which allows us to run the tests multiple times in the same update.

## Usage

``` r
write_tests_xlsx(
  comparison_data,
  sheet_name,
  year = NULL,
  workbook_name = c("ep_file", "indiv_file", "lookup", "extract", "sandpit",
    "cross_year")
)
```

## Arguments

- comparison_data:

  produced by
  [`produce_test_comparison()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_test_comparison.md)

- sheet_name:

  the name of the dataset, which will be used to create the sheet name

- year:

  If applicable, the financial year of the data in '1920' format this
  will be prepended to the sheet name. The default is `NULL`.

- workbook_name:

  Split up tests into 4 different workbooks for ease of interpreting.
  Episode file, individual file, lookup and extract tests.

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)
containing a test comparison.

## See also

produce_test_comparison

Other test functions:
[`format_test_excel()`](https://public-health-scotland.github.io/source-linkage-files/reference/format_test_excel.md),
[`get_existing_data_for_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_existing_data_for_tests.md),
[`produce_test_comparison()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_test_comparison.md)
