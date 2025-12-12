# Add Potentially Preventable Admission (PPA) Marker

This function takes a data frame input and determines, based on a
combination of diagnostic codes and operation codes, whether an
admission was preventable or not.

## Usage

``` r
add_ppa_flag(data)
```

## Arguments

- data:

  A data frame

## Value

A data frame to use as a lookup of PPAs

## See also

Other episode_file:
[`add_activity_after_death_flag()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_activity_after_death_flag.md),
[`add_homelessness_flag()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_homelessness_flag.md),
[`add_nsu_cohort()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_nsu_cohort.md),
[`correct_cij_vars()`](https://public-health-scotland.github.io/source-linkage-files/reference/correct_cij_vars.md),
[`create_cohort_lookups()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_cohort_lookups.md),
[`create_cost_inc_dna()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_cost_inc_dna.md),
[`fill_missing_cij_markers()`](https://public-health-scotland.github.io/source-linkage-files/reference/fill_missing_cij_markers.md),
[`link_delayed_discharge_eps()`](https://public-health-scotland.github.io/source-linkage-files/reference/link_delayed_discharge_eps.md)
