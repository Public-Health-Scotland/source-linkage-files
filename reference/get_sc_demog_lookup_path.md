# Social Care Demographic Lookup File Path

Get the file path for the Social Care Demographic lookup file

## Usage

``` r
get_sc_demog_lookup_path(update = latest_update(), ...)
```

## Arguments

- update:

  The update month to use, defaults to
  [`latest_update()`](https://public-health-scotland.github.io/source-linkage-files/reference/latest_update.md)

- ...:

  additional arguments passed to
  [`get_file_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_file_path.md)

## Value

The path to the social care demographic file as an
[`fs::path()`](https://fs.r-lib.org/reference/path.html)

## See also

[`get_file_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_file_path.md)
for the generic function.

Other social care lookup file paths:
[`get_sc_client_lookup_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_sc_client_lookup_path.md)
