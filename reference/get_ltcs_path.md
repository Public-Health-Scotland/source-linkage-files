# Long Term Conditions File Path

Get the full path to the LTC Reference File in this quarterly update

## Usage

``` r
get_ltcs_path(year, update = latest_update(), ...)
```

## Arguments

- year:

  financial year e.g. "1920"

- update:

  which update. Can use
  [`latest_update()`](https://public-health-scotland.github.io/source-linkage-files/reference/latest_update.md)
  or
  [`previous_update()`](https://public-health-scotland.github.io/source-linkage-files/reference/previous_update.md)

- ...:

  additional arguments passed to
  [`get_file_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_file_path.md)

## Value

The path to the costs lookup as an
[`fs::path()`](https://fs.r-lib.org/reference/path.html)

## See also

[`get_file_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_file_path.md)
for the generic function.

Other file path functions:
[`get_dd_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_dd_path.md),
[`get_demographic_cohorts_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_demographic_cohorts_path.md),
[`get_file_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_file_path.md),
[`get_homelessness_completeness_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_homelessness_completeness_path.md),
[`get_nsu_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_nsu_path.md),
[`get_practice_details_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_practice_details_path.md),
[`get_readcode_lookup_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_readcode_lookup_path.md),
[`get_service_use_cohorts_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_service_use_cohorts_path.md),
[`get_sg_homelessness_pub_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_sg_homelessness_pub_path.md)
