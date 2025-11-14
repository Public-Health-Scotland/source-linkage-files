# Convert HSCP Codes to Names

Convert Health & Social Care Partnership Codes to the Health & Social
Care Partnership Name.

## Usage

``` r
convert_hscp_to_hscpnames(hscp)
```

## Arguments

- hscp:

  vector of HSCP codes

## Value

a vector of HSCP names

## See also

Other code functions:
[`convert_ca_to_lca()`](https://public-health-scotland.github.io/source-linkage-files/reference/convert_ca_to_lca.md),
[`convert_hb_to_hbnames()`](https://public-health-scotland.github.io/source-linkage-files/reference/convert_hb_to_hbnames.md),
[`convert_sc_sending_location_to_lca()`](https://public-health-scotland.github.io/source-linkage-files/reference/convert_sc_sending_location_to_lca.md)

## Examples

``` r
hscp <- c("S37000001", "S37000002")
convert_hscp_to_hscpnames(hscp)
#> [1] "Aberdeen City" "Aberdeenshire"
```
