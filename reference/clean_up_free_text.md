# Clean up a free text string

Take a messy string and clean it up by converting it to title case,
removing any superfluous whitespace and optionally removing any
punctuation. The use case is to make text style uniform to aid with
matching.

## Usage

``` r
clean_up_free_text(
  string,
  case_to = c("upper", "lower", "sentence", "title", "none"),
  remove_punct = TRUE
)
```

## Arguments

- string:

  string variable

- case_to:

  the case to convert the string to

- remove_punct:

  Should any punctuation be removed? (default `TRUE`)

## Value

The cleaned string

## Examples

``` r
clean_up_free_text("hiwSDS SD. h")
#> [1] "Hiwsds Sd H"
```
