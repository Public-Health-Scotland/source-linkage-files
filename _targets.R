# _targets.R file
library(targets)
library(tarchetypes)

tar_option_set(
  imports = "createslf",
  packages = "createslf"
)

future::plan(future::multisession)

list(
  tar_target(write_to_disk, FALSE),
  tar_target(sc_demog_data, phs_db_connection(dsn = "DVPROD")),
  tar_target(sc_demog_lookup, process_lookup_sc_demographics(read_lookup_sc_demographics(sc_demog_data), write_to_disk = write_to_disk)),
  tar_target(spd_data, get_spd_path()),
  tar_target(source_pc_lookup, process_lookup_postcode(spd_data, write_to_disk = write_to_disk)),
  tar_target(gpprac_data, phsopendata::get_dataset("gp-practice-contact-details-and-list-sizes", max_resources = 20L)),
  tar_target(source_gp_lookup, process_lookup_gpprac(gpprac_data, write_to_disk = write_to_disk)),
  tar_target(chi_deaths_data, get_it_deaths_path()),
  tar_target(source_chi_deaths_lookup, process_lookup_chi_deaths(read_lookup_chi_deaths(chi_deaths_data), write_to_disk = write_to_disk)),
   tarchetypes::tar_map(
    list(year = c("1920")),
     tar_target(acute_data, get_boxi_extract_path(year, type = "Acute"))#,
    # tar_target(acute_source_extract, process_extract_acute(read_extract_acute(year, acute_data), year, write_to_disk = write_to_disk)),
    # tar_target(ae_data, get_boxi_extract_path(year, type = "AE")),
    # tar_target(ae_source_extract, process_extract_ae(read_extract_ae(year, ae_data), year, write_to_disk = write_to_disk)),
    # tar_target(maternity_data, get_boxi_extract_path(year, type = "Maternity")),
    # tar_target(maternity_source_extract, process_extract_maternity(read_extract_maternity(year, maternity_data), year, write_to_disk = write_to_disk)),
    # tar_target(mental_health_data, get_boxi_extract_path(year, type = "MH")),
    # tar_target(mental_health_source_extract, process_extract_mental_health(read_extract_mental_health(year, mental_health_data), year, write_to_disk = write_to_disk)),
    # tar_target(nrs_deaths_data, get_boxi_extract_path(year, type = "Deaths")),
    # tar_target(nrs_deaths_source_extract, process_extract_nrs_deaths(read_extract_nrs_deaths(year, nrs_deaths_data), year, write_to_disk = write_to_disk)),
    # tar_target(outpatients_data, get_boxi_extract_path(year, type = "Outpatient")),
    # tar_target(outpatients_source_extract, process_extract_outpatients(read_extract_outpatients(year, outpatients_data), year, write_to_disk = write_to_disk)),
    # tar_target(pis_data, get_it_prescribing_path(year)),
    # tar_target(pis_source_extract, process_extract_prescribing(read_extract_prescribing(year, pis_data), year, write_to_disk = write_to_disk)),
    # tar_target(ltc_data, get_it_ltc_path()),
    # tar_target(ltc_source_extract, process_lookup_ltc(read_lookup_ltc(ltc_data), year, write_to_disk = write_to_disk)),
    # tar_target(diagnosis_data, get_boxi_extract_path(year = year, type = "GP_OoH-d")),
    # tar_target(outcomes_data, get_boxi_extract_path(year = year, type = "GP_OoH-o")),
    # tar_target(consultations_data, get_boxi_extract_path(year = year, type = "GP_OoH-c")),
    # tar_target(ooh_source_extract, process_extract_gp_ooh(year, read_extract_gp_ooh(year,
    #                                                                                 diagnosis_data,
    #                                                                                 outcomes_data,
    #                                                                                 consultations_data),
    #                                                       write_to_disk = write_to_disk))
  )
)


# Read year dependent extracts
# tar_target(cmh_data, get_boxi_extract_path(year, type = "CMH")),
# tar_target(dd_data, get_dd_path(ext = "zsav"))
# tar_target(dn_data, get_boxi_extract_path(year, type = "DN"))
# tar_target(homelessness_data, get_boxi_extract_path(year, type = "Homelessness"))


# # Lookups

