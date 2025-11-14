# Get the Delayed Discharges file path

Get the Delayed Discharges file path

## Usage

``` r
get_dd_path(..., dd_period = NULL)
```

## Arguments

- ...:

  additional arguments passed to
  [`get_file_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_file_path.md)

- dd_period:

  The period to use for reading the file, defaults to
  [`get_dd_period()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_dd_period.md)

## Value

The path to the latest Delayed Discharges file as a
[`fs::path()`](https://fs.r-lib.org/reference/path.html)

## See also

[`get_file_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_file_path.md)
for the generic function.

get_dd_period

Other file path functions:
[`get_demographic_cohorts_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_demographic_cohorts_path.md),
[`get_file_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_file_path.md),
[`get_homelessness_completeness_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_homelessness_completeness_path.md),
[`get_ltcs_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_ltcs_path.md),
[`get_nsu_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_nsu_path.md),
[`get_practice_details_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_practice_details_path.md),
[`get_readcode_lookup_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_readcode_lookup_path.md),
[`get_service_use_cohorts_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_service_use_cohorts_path.md),
[`get_sg_homelessness_pub_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_sg_homelessness_pub_path.md)
