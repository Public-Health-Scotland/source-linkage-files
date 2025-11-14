# Link Delayed Discharge to WIP episode file

Link Delayed Discharge to WIP episode file

## Usage

``` r
link_delayed_discharge_eps(
  episode_file,
  year,
  dd_data = read_file(get_source_extract_path(year, "dd")) %>% slfhelper::get_chi()
)
```

## Arguments

- episode_file:

  The episode file

- year:

  The year being processed

- dd_data:

  The processed DD extract

## Value

A data frame with the delayed discharge cohort added and linked using
the `cij_marker`

## See also

Other episode_file:
[`add_activity_after_death_flag()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_activity_after_death_flag.md),
[`add_homelessness_flag()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_homelessness_flag.md),
[`add_nsu_cohort()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_nsu_cohort.md),
[`add_ppa_flag()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_ppa_flag.md),
[`apply_cost_uplift()`](https://public-health-scotland.github.io/source-linkage-files/reference/apply_cost_uplift.md),
[`correct_cij_vars()`](https://public-health-scotland.github.io/source-linkage-files/reference/correct_cij_vars.md),
[`create_cohort_lookups()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_cohort_lookups.md),
[`create_cost_inc_dna()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_cost_inc_dna.md),
[`fill_missing_cij_markers()`](https://public-health-scotland.github.io/source-linkage-files/reference/fill_missing_cij_markers.md),
[`lookup_uplift()`](https://public-health-scotland.github.io/source-linkage-files/reference/lookup_uplift.md)
