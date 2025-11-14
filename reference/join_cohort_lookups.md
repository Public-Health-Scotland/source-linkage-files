# Join cohort lookups

Join cohort lookups

## Usage

``` r
join_cohort_lookups(
  data,
  year,
  update = latest_update(),
  demographic_cohort = read_file(get_demographic_cohorts_path(year, update), col_select =
    c("anon_chi", "demographic_cohort")),
  service_use_cohort = read_file(get_service_use_cohorts_path(year, update), col_select =
    c("anon_chi", "service_use_cohort"))
)
```

## Arguments

- data:

  The in-progress episode file data.

- year:

  The year to process, in FY format.

- update:

  The update to use

- demographic_cohort, service_use_cohort:

  The cohort data

## Value

The data including the Demographic and Service Use lookups.
