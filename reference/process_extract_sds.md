# Process the (year specific) SDS extract

This will read and process the (year specific) SDS extract, it will
return the final data and (optionally) write it to disk.

## Usage

``` r
process_extract_sds(data, year, write_to_disk = TRUE)
```

## Arguments

- data:

  The full processed data which will be selected from to create the year
  specific data.

- year:

  The year to process, in FY format.

- write_to_disk:

  (optional) Should the data be written to disk default is `TRUE` i.e.
  write the data to disk.

## Value

the final data as a
[tibble](https://tibble.tidyverse.org/reference/tibble-package.html).

## See also

Other process extracts:
[`create_homelessness_lookup()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_homelessness_lookup.md),
[`process_extract_acute()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_extract_acute.md),
[`process_extract_ae()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_extract_ae.md),
[`process_extract_alarms_telecare()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_extract_alarms_telecare.md),
[`process_extract_care_home()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_extract_care_home.md),
[`process_extract_cmh()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_extract_cmh.md),
[`process_extract_delayed_discharges()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_extract_delayed_discharges.md),
[`process_extract_district_nursing()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_extract_district_nursing.md),
[`process_extract_gp_ooh()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_extract_gp_ooh.md),
[`process_extract_home_care()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_extract_home_care.md),
[`process_extract_homelessness()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_extract_homelessness.md),
[`process_extract_maternity()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_extract_maternity.md),
[`process_extract_mental_health()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_extract_mental_health.md),
[`process_extract_nrs_deaths()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_extract_nrs_deaths.md),
[`process_extract_ooh_consultations()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_extract_ooh_consultations.md),
[`process_extract_ooh_diagnosis()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_extract_ooh_diagnosis.md),
[`process_extract_ooh_outcomes()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_extract_ooh_outcomes.md),
[`process_extract_outpatients()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_extract_outpatients.md),
[`process_extract_prescribing()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_extract_prescribing.md),
[`process_it_chi_deaths()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_it_chi_deaths.md),
[`process_lookup_gpprac()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_lookup_gpprac.md),
[`process_lookup_postcode()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_lookup_postcode.md),
[`process_lookup_sc_client()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_lookup_sc_client.md),
[`process_lookup_sc_demographics()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_lookup_sc_demographics.md),
[`process_refined_death()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_refined_death.md),
[`process_sc_all_alarms_telecare()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_sc_all_alarms_telecare.md),
[`process_sc_all_care_home()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_sc_all_care_home.md),
[`process_sc_all_home_care()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_sc_all_home_care.md),
[`process_sc_all_sds()`](https://public-health-scotland.github.io/source-linkage-files/reference/process_sc_all_sds.md),
[`read_extract_gp_ooh()`](https://public-health-scotland.github.io/source-linkage-files/reference/read_extract_gp_ooh.md),
[`read_it_chi_deaths()`](https://public-health-scotland.github.io/source-linkage-files/reference/read_it_chi_deaths.md),
[`read_lookup_sc_client()`](https://public-health-scotland.github.io/source-linkage-files/reference/read_lookup_sc_client.md)
