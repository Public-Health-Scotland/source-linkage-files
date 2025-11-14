# Fill postcode and GP practice geographies

First improve the completion if possible then use the lookups to match
on additional variables.

## Usage

``` r
fill_geographies(
  data,
  slf_pc_lookup = read_file(get_slf_postcode_path()),
  slf_gpprac_lookup = read_file(get_slf_gpprac_path(), col_select = c("gpprac",
    "cluster", "hbpraccode"))
)
```

## Arguments

- data:

  the SLF

- slf_pc_lookup:

  The SLF Postcode lookup

- slf_gpprac_lookup:

  The SLF GP Practice lookup

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)
of the SLF with improved Postcode and GP Practice details.
