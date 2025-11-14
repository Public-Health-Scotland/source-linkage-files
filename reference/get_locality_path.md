# Locality File Path

Get the path to the centrally held HSCP Localities file.

## Usage

``` r
get_locality_path(file_name = NULL, ext = "rds")
```

## Arguments

- file_name:

  The file name (with extension if not supplied to `ext`)

- ext:

  The extension (type of the file) - optional

## Value

An [`fs::path()`](https://fs.r-lib.org/reference/path.html) to the
Scottish Postcode Directory

## See also

Other lookup file paths:
[`get_gpprac_ref_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_gpprac_ref_path.md),
[`get_lookups_dir()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_lookups_dir.md),
[`get_pop_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_pop_path.md),
[`get_simd_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_simd_path.md),
[`get_spd_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_spd_path.md),
[`get_uk_postcode_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_uk_postcode_path.md)
