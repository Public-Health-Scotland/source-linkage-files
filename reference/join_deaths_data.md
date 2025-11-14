# Join Deaths data

Join Deaths data

## Usage

``` r
join_deaths_data(
  data,
  year,
  slf_deaths_lookup = read_file(get_slf_deaths_lookup_path(year))
)
```

## Arguments

- data:

  Episode file data

- year:

  financial year, e.g. '1920'

- slf_deaths_lookup:

  The SLF deaths lookup.

## Value

The data including the deaths lookup matched on to the episode file.
