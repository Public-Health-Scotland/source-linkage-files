# Read Outpatients extract

Read Outpatients extract

## Usage

``` r
read_extract_outpatients(
  year,
  file_path = get_boxi_extract_path(year = year, type = "outpatient")
)
```

## Arguments

- year:

  Financial year for the BOXI extract.

- file_path:

  BOXI extract location

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html).
