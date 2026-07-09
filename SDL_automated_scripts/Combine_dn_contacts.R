# Combine District Nursing Contacts
#
# Original Author - Zihao Li
# Original Date - June 2026
# Written/run on - R Posit
# Version of R - 4.5.1


# Stage 1 - Setup environment ------------------
# load package
devtools::load_all()

# Stage 2 - read files ---------------
dn_raw_contacts <- readr::read_csv(
  fs::path(get_slf_dir(), "Costs", "DN-Contacts-Numbers-for-Costs.csv"),
  name_repair = janitor::make_clean_names
) %>%
  # create year variable as fy
  dplyr::mutate(year = convert_year_to_fyyear(contact_financial_year)) %>%
  # rename TreatmentNHSBoardCode
  dplyr::rename(hb2019 = treatment_nhs_board_code_9,
                number_of_contacts = number_of_contacts)


## Stage 3 - save to disk -----------
dn_raw_contacts %>%
  write_file(get_sdl_dn_contacts_path(check_mode = "write"))
