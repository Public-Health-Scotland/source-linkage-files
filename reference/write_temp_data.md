# Write a temp data to disk in parquet format for debugging purpose

Write a temp data in parquet format to disk for debugging purpose.

## Usage

``` r
write_temp_data(data, year, file_name, write_temp_to_disk)
```

## Arguments

- data:

  The data to be written

- year:

  year variable

- file_name:

  The file name to be written

- write_temp_to_disk:

  Boolean type, write temp data to disk or not

## Value

the data for next step as a
[tibble](https://tibble.tidyverse.org/reference/tibble-package.html).
