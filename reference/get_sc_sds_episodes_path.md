# SDS Episodes File Path

Get the file path for Home Care all episodes file

## Usage

``` r
get_sc_sds_episodes_path(update = latest_update(), ...)
```

## Arguments

- update:

  The update month to use, defaults to
  [`latest_update()`](https://public-health-scotland.github.io/source-linkage-files/reference/latest_update.md)

- ...:

  additional arguments passed to
  [`get_file_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_file_path.md)

## Value

The path to the care home episodes file as an
[`fs::path()`](https://fs.r-lib.org/reference/path.html)

## See also

[`get_file_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_file_path.md)
for the generic function.
