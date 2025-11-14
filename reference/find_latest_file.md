# Find the latest version of a file

This will return the latest created file matching the criteria. It uses
[`fs::dir_info()`](https://fs.r-lib.org/reference/dir_ls.html) to find
the files then picks the one with the latest `birthtime`.

## Usage

``` r
find_latest_file(directory, regexp, selection_method = "modification_date")
```

## Arguments

- directory:

  The directory in which to search.

- regexp:

  a [regular
  expression](https://www.regular-expressions.info/quickstart.html)
  passed to
  [`fs::dir_info()`](https://fs.r-lib.org/reference/dir_ls.html) to
  search for the file.

- selection_method:

  Valid arguments are "modification_date" (the default) or "file_name".

## Value

the [`fs::path()`](https://fs.r-lib.org/reference/path.html) to the file

## Examples

``` r
if (FALSE) { # \dontrun{
find_latest_file(
  directory = get_lookups_dir(),
  regexp = "Scottish_Postcode_Directory_.+?\\.rds"
)
} # }
```
