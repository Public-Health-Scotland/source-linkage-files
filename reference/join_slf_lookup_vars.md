# Join slf lookup variables

Join lookup variables from slf postcode lookup and slf gpprac lookup.

## Usage

``` r
join_slf_lookup_vars(
  individual_file,
  slf_postcode_lookup = read_file(get_slf_postcode_path()),
  slf_gpprac_lookup = read_file(get_slf_gpprac_path(), col_select = c("gpprac",
    "cluster", "hbpraccode")),
  hbrescode_var = "hb2018"
)
```

## Arguments

- individual_file:

  the processed individual file.

- slf_postcode_lookup:

  SLF processed postcode lookup

- slf_gpprac_lookup:

  SLF processed gpprac lookup

- hbrescode_var:

  hbrescode variable
