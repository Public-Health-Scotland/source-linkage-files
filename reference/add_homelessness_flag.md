# Add 'homelessness in FY' flag

Add a flag to the data indicating if the CHI had a homelessness episode
within the financial year.

## Usage

``` r
add_homelessness_flag(data, year, lookup = create_homelessness_lookup(year))
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
[tibble](https://tibble.tidyverse.org/reference/tibble-package.html)

## See also

Other episode_file:
[`add_activity_after_death_flag()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_activity_after_death_flag.md),
[`add_nsu_cohort()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_nsu_cohort.md),
[`add_ppa_flag()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_ppa_flag.md),
[`apply_cost_uplift()`](https://public-health-scotland.github.io/source-linkage-files/reference/apply_cost_uplift.md),
[`correct_cij_vars()`](https://public-health-scotland.github.io/source-linkage-files/reference/correct_cij_vars.md),
[`create_cohort_lookups()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_cohort_lookups.md),
[`create_cost_inc_dna()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_cost_inc_dna.md),
[`fill_missing_cij_markers()`](https://public-health-scotland.github.io/source-linkage-files/reference/fill_missing_cij_markers.md),
[`link_delayed_discharge_eps()`](https://public-health-scotland.github.io/source-linkage-files/reference/link_delayed_discharge_eps.md),
[`lookup_uplift()`](https://public-health-scotland.github.io/source-linkage-files/reference/lookup_uplift.md)
