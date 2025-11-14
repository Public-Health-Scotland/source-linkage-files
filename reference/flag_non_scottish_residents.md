# Flag non-Scottish residents

Flag non-Scottish residents

## Usage

``` r
flag_non_scottish_residents(data, slf_pc_lookup)
```

## Arguments

- data:

  An SLF individual file.

- slf_pc_lookup:

  The Source postcode lookup, defaults to
  [`get_slf_postcode_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_slf_postcode_path.md)
  read using
  [`read_file()`](https://public-health-scotland.github.io/source-linkage-files/reference/read_file.md).

## Value

A data frame with the variable 'keep_flag'

## Details

The variable keep flag can be in the range c(0:4) where

- keep_flag = 0 when resident is Scottish

- keep_flag = 1 when resident is not Scottish

- keep_flag = 2 when the postcode is missing or a dummy, and the gpprac
  is missing

- keep_flag = 3 when the gpprac is not English and the postcode is
  missing

- keep_flag = 4 when the gpprac is not English and the postcode is a
  dummy

The intention is to only keep the records where keep_flag = 0

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
[`add_ipdc_cols()`](https://public-health-scotland.github.io/source-linkage-files/reference/add_ipdc_cols.md),
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
[`recode_gender()`](https://public-health-scotland.github.io/source-linkage-files/reference/recode_gender.md),
[`remove_blank_chi()`](https://public-health-scotland.github.io/source-linkage-files/reference/remove_blank_chi.md)
