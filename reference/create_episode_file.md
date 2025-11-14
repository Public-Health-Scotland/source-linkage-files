# Produce the Source Episode file

Produce the Source Episode file

## Usage

``` r
create_episode_file(
  processed_data_list,
  year,
  dd_data = read_file(get_source_extract_path(year, "dd")),
  homelessness_lookup = create_homelessness_lookup(year),
  nsu_cohort = read_file(get_nsu_path(year)),
  ltc_data = read_file(get_ltcs_path(year)),
  slf_pc_lookup = read_file(get_slf_postcode_path()),
  slf_gpprac_lookup = read_file(get_slf_gpprac_path(), col_select = c("gpprac",
    "cluster", "hbpraccode")),
  slf_deaths_lookup = read_file(get_slf_deaths_lookup_path(year)),
  sc_client = read_file(get_sc_client_lookup_path(year)),
  write_to_disk = TRUE,
  write_temp_to_disk = FALSE
)
```

## Arguments

- processed_data_list:

  containing data from processed extracts.

- year:

  The year to process, in FY format.

- dd_data:

  The processed DD extract

- homelessness_lookup:

  the lookup file for homelessness

- nsu_cohort:

  The NSU data for the year

- ltc_data:

  The LTC data for the year

- slf_pc_lookup:

  The SLF Postcode lookup

- slf_gpprac_lookup:

  The SLF GP Practice lookup

- slf_deaths_lookup:

  The SLF deaths lookup.

- sc_client:

  social care lookup file

- write_to_disk:

  (optional) Should the data be written to disk default is `TRUE` i.e.
  write the data to disk.

- write_temp_to_disk:

  write intermediate data for investigation or debug

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)
containing the episode file
