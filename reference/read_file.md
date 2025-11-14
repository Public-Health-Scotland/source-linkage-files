# Read a file

Read a file, the function chosen to read the file is dependant on the
file path.

- `.rds` uses
  [`readr::read_rds()`](https://readr.tidyverse.org/reference/read_rds.html).

- `.csv` and `.gz` use
  [`readr::read_csv()`](https://readr.tidyverse.org/reference/read_delim.html).
  Note that this assumes any file ending with `.gz` is a zipped CSV
  which isn't necessarily true!

- `.parquet` uses
  [`arrow::read_parquet()`](https://arrow.apache.org/docs/r/reference/read_parquet.html).

## Usage

``` r
read_file(path, col_select = NULL, as_data_frame = TRUE, ...)
```

## Arguments

- path:

  The file path to be read

- col_select:

  A character vector of column names to keep, as in the "select"
  argument to
  [`data.table::fread()`](https://rdatatable.gitlab.io/data.table/reference/fread.html),
  or a [tidy selection
  specification](https://tidyselect.r-lib.org/reference/eval_select.html)
  of columns, as used in
  [`dplyr::select()`](https://dplyr.tidyverse.org/reference/select.html).

- as_data_frame:

  Should the function return a `tibble` (default) or an Arrow
  [Table](https://arrow.apache.org/docs/r/reference/Table-class.html)?

- ...:

  Addition arguments passed to the relevant function.

## Value

the data a
[tibble](https://tibble.tidyverse.org/reference/tibble-package.html)
