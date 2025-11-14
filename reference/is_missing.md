# Check for NA or blank values in a character vector

Checks within a vector if there are any missing (NA) or blank characters

## Usage

``` r
is_missing(x)
```

## Arguments

- x:

  a character vector

## Value

a logical vector indicating if each value is missing

## Examples

``` r
x <- c("string", " ", NA)
is_missing(x)
#> [1] FALSE FALSE  TRUE
```
