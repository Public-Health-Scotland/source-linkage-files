# SLF death dates File Path

Get the full path to the BOXI NRS Deaths lookup file for all financial
years Note this name is very similar to the existing
slf_deaths_lookup_path which returns the path for the refined_death with
deceased flag for each financial year. This function will return the
combined financial years lookup i.e. all years put together.

## Usage

``` r
get_combined_slf_deaths_lookup_path(update = latest_update(), ...)
```

## Arguments

- update:

  the update month (defaults to use
  [`latest_update()`](https://public-health-scotland.github.io/source-linkage-files/reference/latest_update.md))

- ...:

  additional arguments passed to
  [`get_file_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_file_path.md)

## See also

[`get_file_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_file_path.md)
for the generic function.

Other slf lookup file path:
[`get_slf_ch_name_lookup_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_slf_ch_name_lookup_path.md),
[`get_slf_chi_deaths_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_slf_chi_deaths_path.md),
[`get_slf_deaths_lookup_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_slf_deaths_lookup_path.md),
[`get_slf_gpprac_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_slf_gpprac_path.md),
[`get_slf_postcode_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_slf_postcode_path.md)
