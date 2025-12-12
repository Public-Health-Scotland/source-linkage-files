# Add NSU cohort to working file

Add NSU cohort to working file

## Usage

``` r
add_nsu_cohort(data, year, nsu_cohort = read_file(get_nsu_path(year)))
```

## Arguments

- data:

  The input data frame

- year:

  The year being processed

- nsu_cohort:

  The NSU data for the year

## Value

A data frame containing the Non-Service Users as additional rows

## See also

[`get_nsu_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_nsu_path.md)

Other episode_file:
[`add_activity_after_death_flag()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_activity_after_death_flag.md),
[`add_homelessness_flag()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_homelessness_flag.md),
[`add_ppa_flag()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_ppa_flag.md),
[`correct_cij_vars()`](https://public-health-scotland.github.io/source-linkage-files/reference/correct_cij_vars.md),
[`create_cohort_lookups()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_cohort_lookups.md),
[`create_cost_inc_dna()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_cost_inc_dna.md),
[`fill_missing_cij_markers()`](https://public-health-scotland.github.io/source-linkage-files/reference/fill_missing_cij_markers.md),
[`link_delayed_discharge_eps()`](https://public-health-scotland.github.io/source-linkage-files/reference/link_delayed_discharge_eps.md)
