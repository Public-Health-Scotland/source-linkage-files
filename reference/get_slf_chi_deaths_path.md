# SLF CHI Deaths File Path

Get the full path to the CHI deaths file

## Usage

``` r
get_slf_chi_deaths_path(update = latest_update(), ...)
```

## Arguments

- update:

  The update month to use, defaults to
  [`latest_update()`](https://public-health-scotland.github.io/source-linkage-files/reference/latest_update.md)

- ...:

  additional arguments passed to
  [`get_file_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_file_path.md)

## Value

The path to the costs lookup as an
[`fs::path()`](https://fs.r-lib.org/reference/path.html)

## See also

[`get_file_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_file_path.md)
for the generic function.

Other slf lookup file path:
[`get_combined_slf_deaths_lookup_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_combined_slf_deaths_lookup_path.md),
[`get_slf_ch_name_lookup_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_slf_ch_name_lookup_path.md),
[`get_slf_deaths_lookup_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_slf_deaths_lookup_path.md),
[`get_slf_gpprac_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_slf_gpprac_path.md),
[`get_slf_postcode_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_slf_postcode_path.md)
