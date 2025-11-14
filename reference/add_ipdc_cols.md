# Add columns based on IPDC

Add columns based on value in IPDC column, which can be further split by
Elective/Non-Elective CIJ.

## Usage

``` r
add_ipdc_cols(episode_file, prefix, condition, ipdc_d = TRUE, elective = TRUE)
```

## Arguments

- episode_file:

  Tibble containing episodic data.

- prefix:

  Prefix to add to related columns, e.g. "Acute"

- condition:

  Condition to create new columns based on

- ipdc_d:

  Whether to create columns based on IPDC = "D" (lgl)

- elective:

  Whether to create columns based on Elective/Non-Elective cij_pattype
  (lgl)

## See also

Other individual_file:
[`add_acute_columns()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_acute_columns.md),
[`add_ae_columns()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_ae_columns.md),
[`add_all_columns()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_all_columns.md),
[`add_at_columns()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_at_columns.md),
[`add_ch_columns()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_ch_columns.md),
[`add_cij_columns()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_cij_columns.md),
[`add_cmh_columns()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_cmh_columns.md),
[`add_dd_columns()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_dd_columns.md),
[`add_dn_columns()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_dn_columns.md),
[`add_gls_columns()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_gls_columns.md),
[`add_hc_columns()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_hc_columns.md),
[`add_hl1_columns()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_hl1_columns.md),
[`add_hri_variables()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_hri_variables.md),
[`add_keep_population_flag()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_keep_population_flag.md),
[`add_mat_columns()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_mat_columns.md),
[`add_mh_columns()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_mh_columns.md),
[`add_nrs_columns()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_nrs_columns.md),
[`add_nsu_columns()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_nsu_columns.md),
[`add_ooh_columns()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_ooh_columns.md),
[`add_op_columns()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_op_columns.md),
[`add_pis_columns()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_pis_columns.md),
[`add_sds_columns()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_sds_columns.md),
[`add_standard_cols()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_standard_cols.md),
[`aggregate_ch_episodes()`](https://public-health-scotland.github.io/source-linkage-files/reference/aggregate_ch_episodes.md),
[`clean_up_ch()`](https://public-health-scotland.github.io/source-linkage-files/reference/clean_up_ch.md),
[`condition_cols()`](https://public-health-scotland.github.io/source-linkage-files/reference/condition_cols.md),
[`create_individual_file()`](https://public-health-scotland.github.io/source-linkage-files/reference/create_individual_file.md),
[`flag_non_scottish_residents()`](https://public-health-scotland.github.io/source-linkage-files/reference/flag_non_scottish_residents.md),
[`recode_gender()`](https://public-health-scotland.github.io/source-linkage-files/reference/recode_gender.md),
[`remove_blank_chi()`](https://public-health-scotland.github.io/source-linkage-files/reference/remove_blank_chi.md)
