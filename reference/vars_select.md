# Select columns according to a pattern

Select columns according to a pattern

## Usage

``` r
vars_end_with(data, vars, ignore_case = FALSE)

vars_start_with(data, vars, ignore_case = FALSE)

vars_contain(data, vars, ignore_case = FALSE)
```

## Arguments

- data:

  The data from which to select columns/variables.

- vars:

  The variables / pattern to find, as a character vector

- ignore_case:

  Should case be ignored (Default: FALSE)

## Functions

- `vars_end_with()`: Choose variables ending in a given pattern.

- `vars_start_with()`: Choose variables starting with a given pattern.

- `vars_contain()`: Choose variables which contain a given pattern.
