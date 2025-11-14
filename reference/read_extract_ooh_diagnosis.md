# Read GP OOH Diagnosis extract

Read GP OOH Diagnosis extract

## Usage

``` r
read_extract_ooh_diagnosis(
  year,
  file_path = get_boxi_extract_path(year = year, type = "gp_ooh-d")
)
```

## Arguments

- year:

  Financial year for the BOXI extract.

- file_path:

  BOXI extract location

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)
with OOH Diagnosis extract data
