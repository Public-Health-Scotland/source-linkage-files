# Convert Social Care Sending Location Codes into LCA Codes

Convert Social Care Sending Location Codes into the Local Council
Authority Codes.

## Usage

``` r
convert_sc_sending_location_to_lca(sending_location)
```

## Arguments

- sending_location:

  vector of sending location codes

## Value

a vector of local council authority codes

## See also

convert_ca_to_lca

Other code functions:
[`convert_ca_to_lca()`](https://public-health-scotland.github.io/source-linkage-files/reference/convert_ca_to_lca.md),
[`convert_hb_to_hbnames()`](https://public-health-scotland.github.io/source-linkage-files/reference/convert_hb_to_hbnames.md),
[`convert_hscp_to_hscpnames()`](https://public-health-scotland.github.io/source-linkage-files/reference/convert_hscp_to_hscpnames.md)

## Examples

``` r
sending_location <- c(100, 120)
convert_sc_sending_location_to_lca(sending_location)
#> [1] "01" "03"
```
