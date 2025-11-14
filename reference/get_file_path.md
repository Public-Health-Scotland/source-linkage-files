# Get and check and full file path

This generic function takes a directory and file name then checks to
make sure they exist. The parameter `check_mode` will also test to make
sure the file is readable (default) or writeable
(`check_mode = "write"`). By default it will return an error if the file
doesn't exist but with `create = TRUE` it will create an empty file with
appropriate permissions.

## Usage

``` r
get_file_path(
  directory,
  file_name = NULL,
  ext = NULL,
  check_mode = "read",
  create = NULL,
  file_name_regexp = NULL,
  selection_method = "modification_date"
)
```

## Arguments

- directory:

  The file directory

- file_name:

  The file name (with extension if not supplied to `ext`)

- ext:

  The extension (type of the file) - optional

- check_mode:

  The mode passed to
  [`fs::file_access()`](https://fs.r-lib.org/reference/file_access.html),
  defaults to "read" to check that you have read access to the file

- create:

  Optionally create the file if it doesn't exists, the default is to
  only create a file if we set `check_mode = "write"`

- file_name_regexp:

  A regular expression to search for the file name if this is used
  `file_name` should not be, it will return the most recently created
  file using
  [`find_latest_file()`](https://public-health-scotland.github.io/source-linkage-files/reference/find_latest_file.md)

- selection_method:

  Passed only to
  [`find_latest_file()`](https://public-health-scotland.github.io/source-linkage-files/reference/find_latest_file.md),
  will select the file based on latest modification date (default) or
  file name

## Value

The full file path, an error will be thrown if the path doesn't exist or
it's not readable

## See also

Other file path functions:
[`get_dd_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_dd_path.md),
[`get_demographic_cohorts_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_demographic_cohorts_path.md),
[`get_homelessness_completeness_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_homelessness_completeness_path.md),
[`get_ltcs_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_ltcs_path.md),
[`get_nsu_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_nsu_path.md),
[`get_practice_details_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_practice_details_path.md),
[`get_readcode_lookup_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_readcode_lookup_path.md),
[`get_service_use_cohorts_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_service_use_cohorts_path.md),
[`get_sg_homelessness_pub_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_sg_homelessness_pub_path.md)
