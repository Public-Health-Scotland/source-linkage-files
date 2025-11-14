# Read A&E extract

Read A&E extract

## Usage

``` r
read_extract_ae(
  year,
  file_path = get_boxi_extract_path(year = year, type = "ae")
)
```

## Arguments

- year:

  Financial year for the BOXI extract.

- file_path:

  BOXI extract location

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html).
