# Add homelessness date flags episode

Add flags to episodes indicating if they have had at least one active
homelessness application in 6 months before, 6 months after, or during
an episode.

## Usage

``` r
add_homelessness_date_flags(
  data,
  year,
  lookup = create_homelessness_lookup(year)
)
```

## Arguments

- data:

  The data to add the flag to - the episode or individual file.

- year:

  The year to process, in FY format.

- lookup:

  The homelessness lookup created by
  [`create_homelessness_lookup()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_homelessness_lookup.md)

## Value

the final data as a
[tibble](https://tibble.tidyverse.org/reference/tibble-package.html).
