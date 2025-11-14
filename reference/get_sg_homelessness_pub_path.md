# Homelessness Completeness SG publication figures

Get the path to the Excel workbook with Homelessness Completeness
figures from the SG. These are similar to the figures published by the
SG but we have to request it specifically as they don't publish at
financial year or quarterly level, which is needed to properly compare.

## Usage

``` r
get_sg_homelessness_pub_path(...)
```

## Arguments

- ...:

  additional arguments passed to
  [`get_file_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_file_path.md)

## Value

The path to the Homelessness Completeness SG publication figures as an
[`fs::path()`](https://fs.r-lib.org/reference/path.html).

## See also

[`get_file_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_file_path.md)
for the generic function.

Other file path functions:
[`get_dd_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_dd_path.md),
[`get_demographic_cohorts_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_demographic_cohorts_path.md),
[`get_file_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_file_path.md),
[`get_homelessness_completeness_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_homelessness_completeness_path.md),
[`get_ltcs_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_ltcs_path.md),
[`get_nsu_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_nsu_path.md),
[`get_practice_details_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_practice_details_path.md),
[`get_readcode_lookup_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_readcode_lookup_path.md),
[`get_service_use_cohorts_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_service_use_cohorts_path.md)
