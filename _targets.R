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
  tarchetypes::tar_map(
    list(year = c("1819", "1920")),
    tar_target(acute, process_extract_acute(read_extract_acute(year), year, write_to_disk = write_to_disk)),
    tar_target(ae, process_extract_ae(read_extract_ae(year), year, write_to_disk = write_to_disk)),
    tar_target(mental_health, process_extract_mental_health(read_extract_mental_health(year), year, write_to_disk = write_to_disk)),
    tar_target(maternity, process_extract_maternity(read_extract_maternity(year), year, write_to_disk = write_to_disk)),
    tar_target(nrs_deaths, process_extract_nrs_deaths(read_extract_nrs_deaths(year), year, write_to_disk = write_to_disk)),
    tar_target(outpatients, process_extract_outpatients(read_extract_outpatients(year), year, write_to_disk = write_to_disk)),
    tar_target(pis, process_extract_prescribing(read_extract_prescribing(year), year, write_to_disk = write_to_disk)),
    tar_target(ltc, process_lookup_ltc(read_lookup_ltc(), year, write_to_disk = write_to_disk)) # ,
    # tar_target(ooh, process_extract_ooh(read_extract_ooh(year), year, write_to_disk = write_to_disk))
  )
)
