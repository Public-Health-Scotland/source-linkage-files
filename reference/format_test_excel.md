# Format Excel Worksheets of test results

Format structured comparison data

## Usage

``` r
format_test_excel(comparison_data, wb, sheet_name_dated)
```

## Arguments

- comparison_data:

  produced by
  [`produce_test_comparison()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_test_comparison.md)

- wb:

  the excel file which is an openxlsx object

- sheet_name_dated:

  the name of the dataset

## See also

Other test functions:
[`get_existing_data_for_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_existing_data_for_tests.md),
[`produce_test_comparison()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_test_comparison.md),
[`write_tests_xlsx()`](https://public-health-scotland.github.io/source-linkage-files/reference/write_tests_xlsx.md)
