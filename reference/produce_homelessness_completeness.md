# Produce the Homelessness Completeness lookup

Produce the Homelessness Completeness lookup

## Usage

``` r
produce_homelessness_completeness(homelessness_data, update, sg_pub_path)
```

## Arguments

- homelessness_data:

  The Homelessness data to produce

- update:

  The update to use (default is
  [`latest_update()`](https://public-health-scotland.github.io/source-linkage-files/reference/latest_update.md)).

- sg_pub_path:

  The path to the SG pub figures (default is
  [`get_sg_homelessness_pub_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_sg_homelessness_pub_path.md)).

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)
as a lookup with `year`, `sending_local_authority_name` and the
proportion completeness `pct_complete_all`.
