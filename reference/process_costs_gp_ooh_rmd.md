# Process GP ooh cost lookup Rmd file

This will read and process the GP ooh cost lookup, it will return the
final data and write it to disk.

## Usage

``` r
process_costs_gp_ooh_rmd(file_path = get_gp_ooh_costs_path())
```

## Arguments

- file_path:

  Path to the cost lookup.

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)
containing the final cost data.
