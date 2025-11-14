# Read Homelessness extract

Read Homelessness extract

## Usage

``` r
read_extract_homelessness(
  year,
  file_path = get_boxi_extract_path(year = year, type = "homelessness")
)
```

## Arguments

- year:

  Financial year for the BOXI extract.

- file_path:

  BOXI extract location

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html).
