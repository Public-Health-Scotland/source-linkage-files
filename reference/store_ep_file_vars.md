# Store the unneeded episode file variables

Store the unneeded episode file variables

## Usage

``` r
store_ep_file_vars(data, year, vars_to_keep)
```

## Arguments

- data:

  The in-progress episode file data.

- year:

  The year to process, in FY format.

- vars_to_keep:

  a character vector of the variables to keep, all others will be
  stored.

## Value

`data` with only the `vars_to_keep` kept
