# Add HRI variables to an SLF Individual File

Add HRI variables to an SLF Individual File

## Usage

``` r
add_hri_variables(
  data,
  chi_variable = "anon_chi",
  slf_pc_lookup = read_file(get_slf_postcode_path(), col_select = "postcode")
)
```

## Arguments

- data:

  An SLF individual file.

- chi_variable:

  string, claiming chi or anon_chi.

- slf_pc_lookup:

  The Source postcode lookup, defaults to
  [`get_slf_postcode_path()`](https://public-health-scotland.github.io/source-linkage-files/reference/get_slf_postcode_path.md)
  read using
  [`read_file()`](https://public-health-scotland.github.io/source-linkage-files/reference/read_file.md).

## Value

The individual file with HRI variables matched on

## Details

Filters the dataset to only include Scottish residents, then creates a
lookup where HRIs are calculated at Scotland, Health Board, and LCA
level. Then joins on this lookup by chi/anon_chi.

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
[`flag_non_scottish_residents()`](https://public-health-scotland.github.io/source-linkage-files/reference/flag_non_scottish_residents.md),
[`recode_gender()`](https://public-health-scotland.github.io/source-linkage-files/reference/recode_gender.md),
[`remove_blank_chi()`](https://public-health-scotland.github.io/source-linkage-files/reference/remove_blank_chi.md)
