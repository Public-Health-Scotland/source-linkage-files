# Alarms and Telecare Episodes File Path

Get the file path for Alarms and Telecare all episodes file

## Usage

``` r
get_sc_at_episodes_path(update = latest_update(), ...)
```

## Arguments

- update:

  The update month to use, defaults to
  [`latest_update()`](https://public-health-scotland.github.io/source-linkage-files/reference/latest_update.md)

- ...:

  additional arguments passed to
  [`get_file_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_file_path.md)

## Value

The path to the alarms and telecare episodes file as an
[`fs::path()`](https://fs.r-lib.org/reference/path.html)

## See also

[`get_file_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_file_path.md)
for the generic function.

Other social care episodes file paths:
[`get_sc_ch_episodes_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_sc_ch_episodes_path.md),
[`get_sc_hc_episodes_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_sc_hc_episodes_path.md)
