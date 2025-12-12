# Match on BOXI NRS death dates to process activity after death flag

Match on CHI number where available in the episode file, and add date of
death from the BOXI NRS lookup. Create new activity after death flag

## Usage

``` r
add_activity_after_death_flag(
  data,
  year,
  deaths_data = read_file(get_combined_slf_deaths_lookup_path())
)
```

## Arguments

- data:

  episode files

- year:

  financial year, e.g. '1920'

- deaths_data:

  The death data for the year

## Value

data flagged if activity after death

## See also

Other episode_file:
[`add_homelessness_flag()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_homelessness_flag.md),
[`add_nsu_cohort()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_nsu_cohort.md),
[`add_ppa_flag()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_ppa_flag.md),
[`correct_cij_vars()`](https://public-health-scotland.github.io/source-linkage-files/reference/correct_cij_vars.md),
[`create_cohort_lookups()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_cohort_lookups.md),
[`create_cost_inc_dna()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_cost_inc_dna.md),
[`fill_missing_cij_markers()`](https://public-health-scotland.github.io/source-linkage-files/reference/fill_missing_cij_markers.md),
[`link_delayed_discharge_eps()`](https://public-health-scotland.github.io/source-linkage-files/reference/link_delayed_discharge_eps.md)
