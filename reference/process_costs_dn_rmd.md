# Process District Nursing cost lookup Rmd file

This will read and process the District Nursing cost lookup, it will
return the final data and write it to disk.

## Usage

``` r
process_costs_dn_rmd(file_path = get_dn_costs_path())
```

## Arguments

- file_path:

  Path to the cost lookup.

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)
containing the final cost data.
