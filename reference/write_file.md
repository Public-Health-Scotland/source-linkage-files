# Write a data to a file

Write data to a file, the function chosen to write the file is dependant
on the file path extension.

- `.rds` uses
  [`readr::write_rds()`](https://readr.tidyverse.org/reference/read_rds.html).

- `.parquet` uses
  [`arrow::write_parquet()`](https://arrow.apache.org/docs/r/reference/write_parquet.html).

## Usage

``` r
write_file(data, path, group_id = 3356, ...)
```

## Arguments

- data:

  The data to be written

- path:

  The file path to be write

- group_id:

  The group id for setting permissions. The default is 3356 for
  sourcedev. To set this to hscdiip, use 3206.

- ...:

  Additional arguments passed to the relevant function.

## Value

the data (invisibly) as a
[tibble](https://tibble.tidyverse.org/reference/tibble-package.html).
