# Create the SLF Deaths lookup

Use all-year refined death data to produce year-specific
slf_deaths_lookup with deceased flag added.

## Usage

``` r
process_slf_deaths_lookup(
  year,
  refined_death = read_file(get_combined_slf_deaths_lookup_path()),
  write_to_disk = TRUE
)
```

## Arguments

- year:

  The year to process, in FY format.

- refined_death:

  refined death date combining nrs and it_chi.

- write_to_disk:

  (optional) Should the data be written to disk default is `TRUE` i.e.
  write the data to disk.

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)
add deceased flag to deaths
