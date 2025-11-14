# NSU File Path

Get the NSU file path for the given year

## Usage

``` r
get_nsu_path(year, ...)
```

## Arguments

- year:

  Year of extract

- ...:

  additional arguments passed to
  [`get_file_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_file_path.md)

## Value

The path to the NSU file as an
[`fs::path()`](https://fs.r-lib.org/reference/path.html)

## See also

[`get_file_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_file_path.md)
for the generic function.

Other file path functions:
[`get_dd_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_dd_path.md),
[`get_demographic_cohorts_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_demographic_cohorts_path.md),
[`get_file_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_file_path.md),
[`get_homelessness_completeness_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_homelessness_completeness_path.md),
[`get_ltcs_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_ltcs_path.md),
[`get_practice_details_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_practice_details_path.md),
[`get_readcode_lookup_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_readcode_lookup_path.md),
[`get_service_use_cohorts_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_service_use_cohorts_path.md),
[`get_sg_homelessness_pub_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_sg_homelessness_pub_path.md)
