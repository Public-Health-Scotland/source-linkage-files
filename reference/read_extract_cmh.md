# Read CMH extract

Read CMH extract

## Usage

``` r
read_extract_cmh(
  year,
  file_path = get_boxi_extract_path(year = year, type = "cmh")
)
```

## Arguments

- year:

  Financial year for the BOXI extract.

- file_path:

  BOXI extract location

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html).
