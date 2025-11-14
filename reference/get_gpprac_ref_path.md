# GP Practice Reference File Path (gpprac)

Get the path for the centrally held reference file `gpprac`

## Usage

``` r
get_gpprac_ref_path(ext = "csv")
```

## Arguments

- ext:

  The extension (type of the file) - optional

## Value

An [`fs::path()`](https://fs.r-lib.org/reference/path.html) to the file

## See also

Other lookup file paths:
[`get_locality_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_locality_path.md),
[`get_lookups_dir()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_lookups_dir.md),
[`get_pop_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_pop_path.md),
[`get_simd_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_simd_path.md),
[`get_spd_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_spd_path.md),
[`get_uk_postcode_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_uk_postcode_path.md)
