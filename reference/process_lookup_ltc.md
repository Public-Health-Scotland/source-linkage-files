# Process LTC IT extract

Process LTC IT extract

## Usage

``` r
process_lookup_ltc(data, year, write_to_disk = TRUE)
```

## Arguments

- data:

  The extract to process

- year:

  The year to process, in FY format.

- write_to_disk:

  (optional) Should the data be written to disk default is `TRUE` i.e.
  write the data to disk.

## Value

the final data as a
[tibble](https://tibble.tidyverse.org/reference/tibble-package.html).
