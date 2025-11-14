# Join sc client variables onto episode file

Match on sc client variables.

## Usage

``` r
join_sc_client(
  data,
  year,
  sc_client = read_file(get_sc_client_lookup_path(year)),
  file_type = c("episode", "individual")
)
```

## Arguments

- data:

  the processed individual file

- year:

  financial year.

- sc_client:

  SC client lookup

- file_type:

  episode or individual file
