# Source Extract Tests

Produce a LTCs test counting total number of each LTC flag with distinct
anon_chi.

## Usage

``` r
produce_episode_file_ltc_tests(
  data,
  old_data = slfhelper::read_slf_episode(year, col_select = dplyr::all_of(ltc_col2)),
  year
)
```

## Arguments

- data:

  a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)
  of the processed data extract.

- old_data:

  old episode file data

- year:

  the financial year of the extract in the format '1718'.

## Value

a dataframe with a count of total numbers of LTCs flag.

## See also

Other extract test functions:
[`calculate_measures()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_measures.md),
[`produce_episode_file_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_episode_file_tests.md),
[`produce_source_ch_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_source_ch_tests.md),
[`produce_source_cmh_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_source_cmh_tests.md),
[`produce_source_dn_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_source_dn_tests.md),
[`produce_source_extract_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_source_extract_tests.md),
[`produce_source_hc_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_source_hc_tests.md),
[`produce_source_nrs_tests()`](https://public-health-scotland.github.io/source-linkage-files/reference/produce_source_nrs_tests.md)
