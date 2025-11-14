# Assign residential care cohort flag

Please note that this function is not currently in use If the record has
a care home cost greater than zero, assign `TRUE`

## Usage

``` r
assign_s_cohort_residential_care(care_home_cost)
```

## Arguments

- care_home_cost:

  A vector of care home costs

## Value

A boolean vector of residential care cohort flags

## See also

Other Demographic and Service Use Cohort functions:
[`add_operation_flag()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_operation_flag.md),
[`assign_cohort_names()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_cohort_names.md),
[`assign_d_cohort_mh()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_demographic_cohorts.md),
[`assign_death_flag()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_death_flag.md),
[`assign_elective_daycase_instances()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_elective_daycase_instances.md),
[`assign_elective_inpatient_flag()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_elective_inpatient_flag.md),
[`assign_elective_inpatient_instances()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_elective_inpatient_instances.md),
[`assign_elective_instances()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_elective_instances.md),
[`assign_emergency_instances()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_emergency_instances.md),
[`assign_s_cohort_ae2()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_s_cohort_ae2.md),
[`assign_s_cohort_community_care()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_s_cohort_community_care.md),
[`assign_s_cohort_elective_inpatient()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_s_cohort_elective_inpatient.md),
[`assign_s_cohort_geriatric()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_s_cohort_geriatric.md),
[`assign_s_cohort_limited_daycases()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_s_cohort_limited_daycases.md),
[`assign_s_cohort_maternity()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_s_cohort_maternity.md),
[`assign_s_cohort_multiple_emergency()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_s_cohort_multiple_emergency.md),
[`assign_s_cohort_outpatient()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_s_cohort_outpatient.md),
[`assign_s_cohort_prescribing()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_s_cohort_prescribing.md),
[`assign_s_cohort_psychiatry()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_s_cohort_psychiatry.md),
[`assign_s_cohort_routine_daycase()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_s_cohort_routine_daycase.md),
[`assign_s_cohort_single_emergency()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_s_cohort_single_emergency.md),
[`calculate_acute_elective_cost()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_acute_elective_cost.md),
[`calculate_acute_emergency_cost()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_acute_emergency_cost.md),
[`calculate_ae2_cost()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_ae2_cost.md),
[`calculate_care_home_cost()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_care_home_cost.md),
[`calculate_community_care_cost()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_community_care_cost.md),
[`calculate_community_health_cost()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_community_health_cost.md),
[`calculate_elective_inpatient_cost()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_elective_inpatient_cost.md),
[`calculate_geriatric_cost()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_geriatric_cost.md),
[`calculate_home_care_cost()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_home_care_cost.md),
[`calculate_hospital_elective_cost()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_hospital_elective_cost.md),
[`calculate_hospital_emergency_cost()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_hospital_emergency_cost.md),
[`calculate_limited_daycases_cost()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_limited_daycases_cost.md),
[`calculate_maternity_cost()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_maternity_cost.md),
[`calculate_multiple_emergency_cost()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_multiple_emergency_cost.md),
[`calculate_outpatient_costs()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_outpatient_costs.md),
[`calculate_prescribing_cost()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_prescribing_cost.md),
[`calculate_psychiatry_cost()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_psychiatry_cost.md),
[`calculate_residential_care_cost()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_residential_care_cost.md),
[`calculate_routine_daycase_cost()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_routine_daycase_cost.md),
[`calculate_single_emergency_cost()`](https://public-health-scotland.github.io/source-linkage-files/reference/calculate_single_emergency_cost.md),
[`create_demographic_cohorts()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_demographic_cohorts.md),
[`create_service_use_cohorts()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_service_use_cohorts.md),
[`recalculate_elective_inpatient_cost()`](https://public-health-scotland.github.io/source-linkage-files/reference/recalculate_elective_inpatient_cost.md)
