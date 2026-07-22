##########################
# Convert ch_name_lookup files
#
# Original Author - Zihao
# Original Date - July 2026
# Written/run on - R Posit
# Version of R - 4.5.1
##########################


## Stage 1 - Setup environment
#-------------------------------------------------------------------------------
# load package
devtools::load_all()

# Stage 2 - read files ---------------
ch_name_lookup <- openxlsx::read.xlsx(get_slf_ch_name_lookup_path(),
  detectDates = TRUE
) %>%
  dplyr::select(
    case_number = "CaseNumber",
    case_service = "CareService",
    main_client_group = "MainClientGroup",
    sector = "Sector",
    service_name = "ServiceName",
    accomodation_street_address1 = "AccomStreetAddress1",
    accomodation_street_address1a = "AccomStreetAddress1a",
    accomodation_street_address1b = "AccomStreetAddress1b",
    accomodation_street_address4 = "AccomStreetAddress4",
    accomodation_postcode_city = "AccomPostCodeCity",
    accomodation_postcode_number = "AccomPostCodeNo",
    service_status = "ServiceStatusAt300625",
    date_service_cancelled = "DateCanx",
    date_of_registration = "DateReg",
    council_area_name = "Council_Area_Name",
    data_zone = "Datazone"
  )

## Stage 3 - save to disk -----------
ch_name_lookup %>%
  write_file(get_sdl_ch_name_lookup_path(check_mode = "write"))

## END OF SCRIPT ##
