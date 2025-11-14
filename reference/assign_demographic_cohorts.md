# Assign Mental Health cohort

A record is considered to be in the MH cohort if the recid is 04B. Also,
if the recid is one of 01B, GLS, 50B, 02B or AE2 **and** any of the
diagnosis codes start with F2, F3, F067, F070, F072, F078, or F079.

A record is considered to be in the frailty cohort if:

- The recid is 01B, 50B, 02B, 04B or AE2 **and**

  1.  One of the diagnosis codes starts with W0 or W1

  2.  One of the diagnosis codes starts with F00, F01, F02, F03, F05,
      I61, I63, I64, G20 or G21

  3.  One of the diagnosis codes starts with R268 or G22X

  4.  The specialty is AB

  5.  The significant facility is 1E or 1D

  6.  The recid is GLS

A record is considered to be in the Maternity cohort if the recid is 02B

A record is considered to be in the High Complex Conditions cohort if
the patient has any of the listed LTCs, or the specialty is G5

A record is considered to be in the Medium Complex Conditions cohort if
the patient has any of the listed LTCs

A record is considered to be in the Low Complex Conditions cohort if the
patient has any of the listed LTCs.

Not using this cohort until we have more datasets and Scotland complete
DN etc. so will always return FALSE.

A person is considered to be in this cohort if their age is over 18 and
the recid is 01B, or their prescribing cost is £500 or over

A person is considered to be in this cohort if their age is under 18 and
the recid is 01B, or their prescribing cost is £500 or over

A record is considered to be in the EoL cohort if it is an NRS death
record and the cause of death is not external. The exception to this is
if the cause of death is external and is classified as a fall

Please see technical documentation for full description of the Substance
Misuse cohort

## Usage

``` r
assign_d_cohort_mh(recid, diag1, diag2, diag3, diag4, diag5, diag6)

assign_d_cohort_frailty(
  recid,
  diag1,
  diag2,
  diag3,
  diag4,
  diag5,
  diag6,
  spec,
  sigfac
)

assign_d_cohort_maternity(recid)

assign_d_cohort_high_cc(dementia, hefailure, refailure, liver, cancer, spec)

assign_d_cohort_medium_cc(cvd, copd, chd, parkinsons, ms)

assign_d_cohort_low_cc(epilepsy, asthma, arth, diabetes, atrialfib)

assign_d_cohort_comm_living()

assign_d_cohort_adult_major(recid, age, cost_total_net)

assign_d_cohort_child_major(recid, age, cost_total_net)

assign_d_cohort_eol(
  recid,
  deathdiag1,
  deathdiag2,
  deathdiag3,
  deathdiag4,
  deathdiag5,
  deathdiag6,
  deathdiag7,
  deathdiag8,
  deathdiag9,
  deathdiag10,
  deathdiag11
)

assign_d_cohort_substance(data)
```

## Arguments

- recid:

  A vector of recids

- diag1, diag2, diag3, diag4, diag5, diag6:

  Character vectors of ICD-10 diagnosis codes.

- spec:

  A vector of specialties

- sigfac:

  A vector of significant facilities

- dementia:

  A vector of dementia LTC flags

- hefailure:

  A vector of heart failure LTC flags

- refailure:

  A vector of renal failure LTC flags

- liver:

  A vector of liver disease LTC flags

- cancer:

  A vector of cancer LTC flags

- cvd:

  A vector of CVD LTC flags

- copd:

  A vector of COPD LTC flags

- chd:

  A vector of CHD LTC flags

- parkinsons:

  A vector of Parkinson's LTC flags

- ms:

  A vector of MS LTC flags

- epilepsy:

  A vector of epilepsy LTC flags

- asthma:

  A vector of asthma LTC flags

- arth:

  A vector of arthritis LTC flags

- diabetes:

  A vector of diabetes LTC flags

- atrialfib:

  A vector of atrial fibrillation LTC flags

- age:

  A vector of ages

- cost_total_net:

  A vector of total net costs

- deathdiag1, deathdiag2, deathdiag3, deathdiag4, deathdiag5,
  deathdiag6, deathdiag7, deathdiag8, deathdiag9, deathdiag10,
  deathdiag11:

  Character vectors of ICD-10 death diagnosis codes.

- data:

  A data frame containing at least
  ``` recid`` and the six diagnosis codes ( ```diag`:`diag6\`)

## Value

A boolean vector indicating whether a record is in the particular
demographic cohort.

A data frame with an additional boolean variable, `substance`,
indicating a record is in the substance misuse cohort.

## See also

Other Demographic and Service Use Cohort functions:
[`add_operation_flag()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_operation_flag.md),
[`assign_cohort_names()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_cohort_names.md),
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
[`assign_s_cohort_residential_care()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_s_cohort_residential_care.md),
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

Other Demographic and Service Use Cohort functions:
[`add_operation_flag()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_operation_flag.md),
[`assign_cohort_names()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_cohort_names.md),
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
[`assign_s_cohort_residential_care()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_s_cohort_residential_care.md),
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

Other Demographic and Service Use Cohort functions:
[`add_operation_flag()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_operation_flag.md),
[`assign_cohort_names()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_cohort_names.md),
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
[`assign_s_cohort_residential_care()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_s_cohort_residential_care.md),
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

Other Demographic and Service Use Cohort functions:
[`add_operation_flag()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_operation_flag.md),
[`assign_cohort_names()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_cohort_names.md),
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
[`assign_s_cohort_residential_care()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_s_cohort_residential_care.md),
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

Other Demographic and Service Use Cohort functions:
[`add_operation_flag()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_operation_flag.md),
[`assign_cohort_names()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_cohort_names.md),
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
[`assign_s_cohort_residential_care()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_s_cohort_residential_care.md),
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

Other Demographic and Service Use Cohort functions:
[`add_operation_flag()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_operation_flag.md),
[`assign_cohort_names()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_cohort_names.md),
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
[`assign_s_cohort_residential_care()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_s_cohort_residential_care.md),
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

Other Demographic and Service Use Cohort functions:
[`add_operation_flag()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_operation_flag.md),
[`assign_cohort_names()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_cohort_names.md),
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
[`assign_s_cohort_residential_care()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_s_cohort_residential_care.md),
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

Other Demographic and Service Use Cohort functions:
[`add_operation_flag()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_operation_flag.md),
[`assign_cohort_names()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_cohort_names.md),
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
[`assign_s_cohort_residential_care()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_s_cohort_residential_care.md),
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

Other Demographic and Service Use Cohort functions:
[`add_operation_flag()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_operation_flag.md),
[`assign_cohort_names()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_cohort_names.md),
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
[`assign_s_cohort_residential_care()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_s_cohort_residential_care.md),
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

Other Demographic and Service Use Cohort functions:
[`add_operation_flag()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_operation_flag.md),
[`assign_cohort_names()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_cohort_names.md),
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
[`assign_s_cohort_residential_care()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_s_cohort_residential_care.md),
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

Other Demographic and Service Use Cohort functions:
[`add_operation_flag()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_operation_flag.md),
[`assign_cohort_names()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_cohort_names.md),
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
[`assign_s_cohort_residential_care()`](https://public-health-scotland.github.io/source-linkage-files/reference/assign_s_cohort_residential_care.md),
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
