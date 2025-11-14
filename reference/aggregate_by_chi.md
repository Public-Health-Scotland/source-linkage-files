# Aggregate by CHI

Aggregate episode file by CHI to convert into individual file.

## Usage

``` r
aggregate_by_chi(episode_file, year, exclude_sc_var = FALSE)
```

## Arguments

- episode_file:

  Tibble containing episodic data.

- year:

  financial year, string, eg "1920"

- exclude_sc_var:

  Boolean, whether exclude social care variables
