# Convert NHS Health Board Codes to Names

Convert NHS Health Board Codes to the NHS Health Board Names

## Usage

``` r
convert_hb_to_hbnames(hb)
```

## Arguments

- hb:

  vector of NHS Health Board codes

## Value

a vector of NHS Health Board names

## See also

Other code functions:
[`convert_ca_to_lca()`](https://public-health-scotland.github.io/source-linkage-files/reference/convert_ca_to_lca.md),
[`convert_hscp_to_hscpnames()`](https://public-health-scotland.github.io/source-linkage-files/reference/convert_hscp_to_hscpnames.md),
[`convert_sc_sending_location_to_lca()`](https://public-health-scotland.github.io/source-linkage-files/reference/convert_sc_sending_location_to_lca.md)

## Examples

``` r
hb <- c("S08000015", "S08000016")
convert_hb_to_hbnames(hb)
#> [1] "Ayrshire and Arran" "Borders"           
```
