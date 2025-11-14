# Order SLF Individual File Columns

Reorders an SLF individual file dataframe so that its columns appear in
the standard schema order used by the `createslf` package.

## Usage

``` r
order_indiv_cols(individual_file)
```

## Arguments

- individual_file:

  A dataframe representing the SLF individual file. Must contain the
  expected variables; any extra columns will be dropped.

## Value

The input dataframe with its columns reordered into the standard SLF
individual file order.

## Details

This ensures a consistent column structure across all years of data.

New variables added to SLFs should also be added here to maintain
consistency across years.

## See also

Other createslf schema functions:
[`order_ep_cols()`](https://public-health-scotland.github.io/source-linkage-files/reference/order_ep_cols.md)

## Examples

``` r
if (FALSE) { # \dontrun{
df <- read.csv("my_episode_file.csv")
df_ordered <- order_ep_cols(df)
} # }
```
