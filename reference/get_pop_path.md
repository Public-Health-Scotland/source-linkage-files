# Populations File Path for different types

Get the path to the populations estimates

## Usage

``` r
get_pop_path(
  file_name = NULL,
  ext = "rds",
  type = c("datazone", "hscp", "ca", "hb", "intzone")
)
```

## Arguments

- file_name:

  The file name (with extension if not supplied to `ext`)

- ext:

  The extension (type of the file) - optional

- type:

  population type datazone, or hscp, or ca, or hb, or interzone

## Value

An [`fs::path()`](https://fs.r-lib.org/reference/path.html) to the
populations estimates file

## See also

Other lookup file paths:
[`get_gpprac_ref_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_gpprac_ref_path.md),
[`get_locality_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_locality_path.md),
[`get_lookups_dir()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_lookups_dir.md),
[`get_simd_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_simd_path.md),
[`get_spd_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_spd_path.md),
[`get_uk_postcode_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_uk_postcode_path.md)
