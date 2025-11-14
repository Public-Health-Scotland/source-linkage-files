# Convert Council Areas into Local Council Authority Codes

Convert Council Area code into the Local Council Authority code

## Usage

``` r
convert_ca_to_lca(ca_var)
```

## Arguments

- ca_var:

  vector of council area codes or names

## Value

a vector of local council authority codes

## See also

convert_sc_sending_location_to_lca

Other code functions:
[`convert_hb_to_hbnames()`](https://public-health-scotland.github.io/source-linkage-files/reference/convert_hb_to_hbnames.md),
[`convert_hscp_to_hscpnames()`](https://public-health-scotland.github.io/source-linkage-files/reference/convert_hscp_to_hscpnames.md),
[`convert_sc_sending_location_to_lca()`](https://public-health-scotland.github.io/source-linkage-files/reference/convert_sc_sending_location_to_lca.md)

## Examples

``` r
ca <- c("S12000033", "S12000034")
convert_ca_to_lca(ca)
#> [1] "01" "02"
```
