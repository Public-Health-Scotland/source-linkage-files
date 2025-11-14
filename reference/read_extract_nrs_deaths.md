# Read NRS Deaths extract

Read NRS Deaths extract

## Usage

``` r
read_extract_nrs_deaths(
  year,
  file_path = get_boxi_extract_path(year = year, type = "deaths")
)
```

## Arguments

- year:

  Financial year for the BOXI extract.

- file_path:

  BOXI extract location

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html).
