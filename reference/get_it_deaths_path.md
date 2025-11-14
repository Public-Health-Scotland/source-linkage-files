# IT Deaths File Path

Get the full path to the IT Deaths extract

## Usage

``` r
get_it_deaths_path(it_reference = NULL, ...)
```

## Arguments

- it_reference:

  Optional argument for the seven-digit code in the IT extract file name

- ...:

  additional arguments passed to
  [`get_file_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_file_path.md)

## Value

The path to the IT Deaths extract as an
[`fs::path()`](https://fs.r-lib.org/reference/path.html)

## See also

[`get_file_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_file_path.md)
for the generic function.

Other extract file paths:
[`get_boxi_extract_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_boxi_extract_path.md),
[`get_hhg_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_hhg_path.md),
[`get_it_ltc_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_it_ltc_path.md),
[`get_it_prescribing_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_it_prescribing_path.md),
[`get_source_extract_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_source_extract_path.md),
[`get_sparra_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_sparra_path.md)
