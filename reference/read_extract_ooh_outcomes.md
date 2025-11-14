# Read GP OOH Outcomes extract

Read GP OOH Outcomes extract

## Usage

``` r
read_extract_ooh_outcomes(
  year,
  file_path = get_boxi_extract_path(year = year, type = "gp_ooh-o")
)
```

## Arguments

- year:

  Financial year for the BOXI extract.

- file_path:

  BOXI extract location

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)
with OOH Outcomes extract data
