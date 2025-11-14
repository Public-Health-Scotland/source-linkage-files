# Test Comparison

Produce a comparison test between the new processed data and the
existing data

## Usage

``` r
produce_test_comparison(old_data, new_data, recid = FALSE)
```

## Arguments

- old_data:

  dataframe containing the old data test flags

- new_data:

  dataframe containing the new file data test flags

- recid:

  Logical True/False. Use True when comparing the ep file.

## Value

a dataframe with a comparison of new and old data

## See also

write_tests_xlsx

Other test functions:
[`format_test_excel()`](https://public-health-scotland.github.io/source-linkage-files/reference/format_test_excel.md),
[`get_existing_data_for_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_existing_data_for_tests.md),
[`write_tests_xlsx()`](https://public-health-scotland.github.io/source-linkage-files/reference/write_tests_xlsx.md)
