# Fix and fill care home name and postcodes

Fix and fill care home name and postcodes

## Usage

``` r
fill_ch_names(
  ch_data,
  ch_name_lookup_path = get_slf_ch_name_lookup_path(),
  spd_path = get_spd_path(),
  uk_pc_path = get_uk_postcode_path()
)
```

## Arguments

- ch_data:

  partially cleaned up care home data as a
  [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)

- ch_name_lookup_path:

  Path to the 'official' Care Home name Excel Workbook, this defaults to
  [`get_slf_ch_name_lookup_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_slf_ch_name_lookup_path.md)

- spd_path:

  Path to the Scottish Postcode Directory (rds) version, this defaults
  to
  [`get_spd_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_spd_path.md)

- uk_pc_path:

  Path to the UK postcode list. This is defaults to
  [`get_uk_postcode_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_uk_postcode_path.md)

## Value

the same data with improved accuracy and completeness of the Care Home
names and postcodes, as a
[tibble](https://tibble.tidyverse.org/reference/tibble-package.html).
