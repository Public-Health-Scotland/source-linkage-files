# Sandpit Extract File Path

Get the file path for sandpit extracts

## Usage

``` r
get_sandpit_extract_path(
  type = c("at", "ch", "hc", "sds", "client", "demographics"),
  year = NULL,
  update = latest_update(),
  ...
)
```

## Arguments

- type:

  sandpit extract type at, ch, hc, sds, client, or demographics

- year:

  financial year in string class

- update:

  The update month to use, defaults to
  [`latest_update()`](https://public-health-scotland.github.io/source-linkage-files/reference/latest_update.md)

- ...:

  additional arguments passed to
  [`get_file_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_file_path.md)

## Value

The path to the sandpit extracts as an
[`fs::path()`](https://fs.r-lib.org/reference/path.html)

## See also

[`get_file_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_file_path.md)
for the generic function.
