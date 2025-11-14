# set up file names for tests

set up file names for tests

## Usage

``` r
setup_tests_file_name(
  sheet_name,
  year = NULL,
  workbook_name = c("ep_file", "indiv_file", "lookup", "extract", "sandpit",
    "cross_year"),
  to_combine = TRUE
)
```

## Arguments

- sheet_name:

  the name of the dataset, which will be used to create the sheet name

- year:

  If applicable, the financial year of the data in '1920' format this
  will be prepended to the sheet name. The default is `NULL`.

- workbook_name:

  Split up tests into 4 different workbooks for ease of interpreting.
  Episode file, individual file, lookup and extract tests.

- to_combine:

  boolean type, whether to produce to-combine file path
