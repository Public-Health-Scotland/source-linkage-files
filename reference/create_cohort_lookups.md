# Create the cohort lookups

Create the cohort lookups

## Usage

``` r
create_cohort_lookups(data, year, update = latest_update())
```

## Arguments

- data:

  The in-progress episode file data.

- year:

  The year to process, in FY format.

- update:

  The update to use.

## Value

The data unchanged (the cohorts are written to disk)

## See also

Other episode_file:
[`add_activity_after_death_flag()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_activity_after_death_flag.md),
[`add_homelessness_flag()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_homelessness_flag.md),
[`add_nsu_cohort()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_nsu_cohort.md),
[`add_ppa_flag()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_ppa_flag.md),
[`apply_cost_uplift()`](https://public-health-scotland.github.io/source-linkage-files/reference/apply_cost_uplift.md),
[`correct_cij_vars()`](https://public-health-scotland.github.io/source-linkage-files/reference/correct_cij_vars.md),
[`create_cost_inc_dna()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_cost_inc_dna.md),
[`fill_missing_cij_markers()`](https://public-health-scotland.github.io/source-linkage-files/reference/fill_missing_cij_markers.md),
[`link_delayed_discharge_eps()`](https://public-health-scotland.github.io/source-linkage-files/reference/link_delayed_discharge_eps.md),
[`lookup_uplift()`](https://public-health-scotland.github.io/source-linkage-files/reference/lookup_uplift.md)
