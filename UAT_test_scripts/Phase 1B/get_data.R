# get_local_filepath now points to unprocessed test boxi extract
# get_local_data now uses get_denodo_connection to access preprod social care data
# TODO: Add switchers for both of these

devtools::load_all()
library(createslf)

################################################################################.
# Function to show all values for `family` argument in `get_types()`
################################################################################.

get_families <- function(){
  family_list <- c(
    "all", # All Extracts (46)
    "boxi", # BOXI Extracts (13)
    "archive", # Archived Extracts (3)
    "it", # IT Extracts (3)
    "team", # Extracts from Teams (3)
    "lookup", # Lookups (14)
    "sc", # Social Care Extracts (7)
    "opendata" # PHS Open Data (4)
  )
  return(family_list)
}

################################################################################.
# Function to show the `type` code for each dataset
# Option to filter for a specific "family" or whether extracts are year specific or file ingests
################################################################################.

get_types <- function(family = "all", year_specific = NULL, file_ingest = NULL) {

  # Check family is valid
  if (!is.character(family) || length(family) != 1 || !family %in% get_families()){
    message(paste("`family` argument invalid. Use `get_families()`."))
    return(NA_character_)
  }

  # Check year_specific format is correct
  if (!(isTRUE(year_specific) || isFALSE(year_specific) || is.null(year_specific))) {
    message("`year_specific` argument invalid. Must be TRUE, FALSE or NULL.")
    return(NA_character_)
  }

  # Check file_ingest format is correct
  if (!(isTRUE(file_ingest) || isFALSE(file_ingest) || is.null(file_ingest))) {
    message("`file_ingest` argument invalid. Must be TRUE, FALSE or NULL.")
    return(NA_character_)
  }

  # BOXI Extracts (13)
  boxi_extracts <-c(
    "ae", # A&E
    "ae_cup", # A&E CUP
    "acute", # Acute
    "acute_cup", # Acute CUP
    "gp_ooh-c", # GP Out of Hours Consultations
    "gp_ooh-d", # GP Out of Hours Diagnoses
    "gp_ooh-o", # GP Out of Hours Outcomes
    "gp_ooh_cup", # GP Out of Hours CUP
    "homelessness", # Homelessness
    "maternity", # Maternity
    "mh", # Mental Health
    "outpatients", # Outpatients
    "nrs_deaths" # NRS Deaths
  )

  # Archived Extracts (3)
  archived_extracts <- c(
    "cmh", # Community Mental Health
    "dn", # District Nursing
    "hhg" # High Health Gains
  )

  # IT Extracts (3)
  it_extracts <- c(
    "chi_deaths", # CHI Deaths
    "ltc", # Long Term Conditions
    "pis" # Prescribing
  )

  # Extracts from Teams (3)
  team_extracts <- c(
    "dd", # Delayed Discharges
    "nsu", # Non Service Users
    "sparra" # SPARRA
  )

  # Lookups (14)
  lookups <- c(
    "ch_name", # Care Home Name Lookup
    "datazone", # Datazone Population Lookup
    "dn_contacts", # District Nursing Contacts
    "dn_cost", # District Nursing Cost Lookup
    "gpprac_ref", # GP Practise Reference Lookup
    "hc_cost", # Home Care Costs Lookup
    "homelessness_completeness", # Homelessness Completeness
    "hscp", # HSCP Population Lookup
    "locality", # HSCP Locality Lookup
    "ooh_cost", # GP Out of Hours Costs Lookup
    "readcode", # Read Code Lookup
    "simd", # SIMD Lookup
    "spd", # Scottish Postcode Directory Lookup
    "uk_postcode" # UK Postcode Lookup
  )

  # Social Care Extracts (7)
  sc_extracts <- c(
    "at", # Alarms Telecare
    "ch", # Care Homes
    "client_fy", # Client Information (year)
    "client_qtr", # Client Information (quarter)
    "hc", # Home Care
    "sc_demog", # Demographics
    "sds" # SDS
  )

  # PHS Open Data (4)
  open_data_extracts <- c(
    "ch_cost", # Care Home Costs Lookup
    "gpprac_cluster", # GP Practise Contact Lookup
    "geography_labels", # GP Practise OpenData Lookup
    "la_code" # Local Authority Code Lookup
  )

  # Year specific extracts
  year_specific_extracts <- unique(c(
    boxi_extracts,
    archived_extracts,
    "pis",
    "nsu",
    "sparra",
    "client_fy",
    "client_qtr"
  ))

  # Extracts submitted to NSS as files
  file_ingest_extracts <- unique(c(
    archived_extracts,
    lookups,
    "dd",
    "nsu"
  ))

  # All extracts
  all_extracts <- unique(c(
    boxi_extracts,
    archived_extracts,
    it_extracts,
    team_extracts,
    lookups,
    sc_extracts,
    open_data_extracts
  ))

  # Get list of types for each family member
  type_list <- switch(
      family,
      "all" = all_extracts,
      "boxi" = boxi_extracts,
      "archive" = archived_extracts,
      "it" = it_extracts,
      "team" = team_extracts,
      "lookup" = lookups,
      "sc" = sc_extracts,
      "opendata" = open_data_extracts
  )

  # Filter for year specific extracts
  if (isTRUE(year_specific)) {
    type_list <- intersect(type_list, year_specific_extracts)
  } else if (isFALSE(year_specific)) {
    type_list <- setdiff(type_list, year_specific_extracts)
  }

  # Filter for file ingest extracts
  if (isTRUE(file_ingest)) {
    type_list <- intersect(type_list, file_ingest_extracts)
  } else if (isFALSE(file_ingest)) {
    type_list <- setdiff(type_list, file_ingest_extracts)
  }

  # Return NA if there are no types in the selection
  if(length(type_list) == 0){
    message("No types found.")
    return(NA_character_)
  }

  return(sort(type_list))
}

################################################################################.
# Function to get the local filepath to each dataset as submitted to NSS
################################################################################.

get_submission_filepath <- function(type) {

  # Check type is valid
  if (!type %in% get_types()){
    message("`type` not valid. To check valid types use `get_types()`.")
    return(NA_character_)
  }

  # Check the type is a file ingest
  if (type %in% get_types(file_ingest = FALSE)){
    message("The type supplied is not a file ingest. To check file ingest types use `get_types(file_ingest = TRUE)`.")
    return(NA_character_)
  }

  # Get the submission folder
  extract_folder <- dplyr::case_when(
    # Archived Extracts (3)
    type == "cmh" ~ "cmh",
    type == "dn" ~ "dn",
    type == "hhg" ~ "hhg",

    # Extracts from Teams (2/3)
    type == "dd" ~ "dd",
    type == "nsu" ~ "nsu",

    # Lookups (14)
    type == "ch_name" ~ "ch_name_lookup",
    type == "datazone" ~ "datazone_population",
    type == "dn_contacts" ~ "dn_contacts",
    type == "dn_cost" ~ "dn_cost_lookup",
    type == "gpprac_ref" ~ "gpprac_ref",
    type == "hc_cost" ~ "hc_cost_lookup",
    type == "homelessness_completeness" ~ "homelessness_completeness",
    type == "hscp" ~ "hscp_population",
    type == "locality" ~ "hscp_localities",
    type == "ooh_cost" ~ "ooh_cost_lookup",
    type == "readcode" ~ "read_code_lookup",
    type == "simd" ~ "simd",
    type == "spd" ~ "spd",
    type == "uk_postcode" ~ "uk_postcode",

    # Default
    TRUE ~ NA_character_
  )

  # Add the general path to the submission folders
  submission_folder <- paste0("/conf/hscdiip/SDL_submission/", extract_folder, "/")

  # Check that the submission folder exists
  if (!dir.exists(submission_folder)){
    message("Submission folder not available.")
    return(NA_character_)
  }

  # List all files in the submission folder
  all_files <- list.files(
    path = submission_folder,
    pattern = "^SDL"
  )

  # Check that there are files in the submission folder
  if (length(all_files) == 0){
    message("No files found in submission folder.")
    return(NA_character_)

  # Get the latest submission
  } else {
    # Extract numbers
    nums <-  as.numeric(
      sapply(stringr::str_extract_all(all_files, "\\d+"), paste0, collapse = "")
    )

    # Select file with the highest number (most recent)
    filename <- all_files[which.max(nums)]

    # Full filepath
    submission_filepath <- paste0(submission_folder, filename)

    return(submission_filepath)
  }
}

################################################################################.
# Function get test boxi extract path
################################################################################.

get_test_boxi_data <- function(type, year){
  source_dir <- "/conf/sourcedev/Source_Linkage_File_Updates/Extracts Temp/"
  year <- convert_fyyear_to_year(year)

  filename <- dplyr::recode_values(
    type,
    "ae"            ~ "A&E-episode-level-extract-",
    "ae_cup"        ~ "A&E-UCD-CUP-extract-",
    "acute_cup"     ~ "Acute-CUP-extract-",
    "acute"         ~ "Acute-episode-level-extract-",
    "gp_ooh-c"      ~ "GP-OoH-consultations-extract-",
    "gp_ooh_cup"    ~ "GP-OoH-CUP-extract-",
    "gp_ooh-d"      ~ "GP-OoH-diagnosis-extract-",
    "gp_ooh-o"      ~ "GP-OoH-outcomes-extract-",
    "homelessness"  ~ "Homelessness-extract-",
    "maternity"     ~ "Maternity-episode-level-extract-",
    "mh"            ~ "Mental-Health-episode-level-extract-",
    "nrs_deaths"    ~ "NRS-death-registrations-extract-",
    "outpatients"   ~ "Outpatients-episode-level-extract-",
    default = NA_character_
  )
  paste0(source_dir, filename, year, ".csv")
}

################################################################################.
# Function to get the local filepath to each dataset
# If sdl_submission is TRUE, returns path to file submitted to NSS
# NOTE: Social Care extracts return a table name and Open Data returns a res_id
################################################################################.

get_local_filepath <- function(type, year = "", sdl_submission = FALSE) {

  # Check type is valid
  if (!type %in% get_types()){
    message("`type` not valid. To check valid types use `get_types()`.")
    return(NA_character_)
  }

  # Check year format is correct
  if (!(year == "" ||
        (is.character(year) &&
         length(year) == 1 &&
         grepl("^\\d{4}$", year) &&
         as.integer(substr(year,3,4)) ==
         as.integer(substr(year,1,2)) + 1))) {
    message("`year` argument invalid. Must be in the correct format e.g. `1718`.")
    return(NA_character_)
  }

  # Check sdl_submission is valid
  if (!(isTRUE(sdl_submission) || isFALSE(sdl_submission))) {
    message("`sdl_submission` argument invalid. Must be TRUE or FALSE.")
    return(NA_character_)
  }

  # Check if type is year specific and year is not provided
  if (type %in% get_types(year_specific = TRUE) && year == ""){
    message("This is a year specific extract. `year` must be provided.")
    return(NA_character_)
  }

  # Check if type is not year specific but year is provided
  if (type %in% get_types(year_specific = FALSE) && year != ""){
    message("This is not a year specific extract. Returning all years.")
  }

  # Check if type is not a file ingest but sdl_submission is TRUE
  if (type %in% get_types(file_ingest = FALSE) && isTRUE(sdl_submission)){
    message("This is not a file ingest. Returning non-submission file path.")
  }

  # Return the submission file path if sdl_submission is TRUE and type is a file ingest (get_submission_filepath returns NA if type is not a file ingest)
  if (type %in% get_types(file_ingest = TRUE) && isTRUE(sdl_submission)){
    local_filepath <- get_submission_filepath(type)
      return(local_filepath)
  }

  # Return the local file path
  if (type %in% c(
    # BOXI Extracts (13)
    "ae",
    "ae_cup",
    "acute",
    "acute_cup",
    "gp_ooh-c",
    "gp_ooh-d",
    "gp_ooh-o",
    "gp_ooh_cup",
    "homelessness",
    "maternity",
    "mh",
    "nrs_deaths",
    "outpatients"
  )) {
    local_filepath <- suppressMessages(get_test_boxi_data(type = type, year = year))

  } else {
    local_filepath <- switch(
      type,
      # Archived Extracts
      "cmh" =  suppressMessages(get_boxi_extract_path(type = type, year = year)),
      "dn" =  suppressMessages(get_boxi_extract_path(type = type, year = year)),
      "hhg" = suppressMessages(get_hhg_path(year = year)),
      # IT Extracts
      "chi_deaths" = suppressMessages(get_it_deaths_path()),
      "ltc" = suppressMessages(get_it_ltc_path()),
      "pis" = suppressMessages(get_it_prescribing_path(year = year)),
      # Extracts from Teams
      "dd" = suppressMessages(get_dd_path()),
      "nsu" = suppressMessages(get_nsu_path(year = year)),
      "sparra" = suppressMessages(get_sparra_path(year = year)),
      # Lookups
      "ch_name" = suppressMessages(get_slf_ch_name_lookup_path()),
      "datazone" = suppressMessages(get_pop_path(type = "datazone")),
      "dn_contacts" = "/conf/hscdiip/SLF_Extracts/Costs/DN-Contacts-Numbers-for-Costs.csv",
      "dn_cost" = suppressMessages(get_dn_raw_costs_path()),
      "gpprac_ref" = suppressMessages(get_gpprac_ref_path()),
      "hc_cost" = suppressMessages(get_hc_raw_costs_path()),
      "homelessness_completeness" = suppressMessages(get_sg_homelessness_pub_path()),
      "hscp" = suppressMessages(get_pop_path(type = "hscp")),
      "locality" = suppressMessages(get_locality_path()),
      "ooh_cost" = suppressMessages(get_gp_ooh_raw_costs_path()),
      "readcode" = suppressMessages(get_readcode_lookup_path()),
      "simd" = suppressMessages(get_simd_path()),
      "spd" = suppressMessages(get_spd_path()),
      "uk_postcode" = suppressMessages(get_uk_postcode_path()),
      # Social Care Extracts
      "at" = "equipment_snapshot",
      "ch" = "carehome_snapshot",
      "client_fy" = "client_fy_snapshot",
      "client_qtr" = "client_qtr_snapshot",
      "hc" = "homecare_snapshot",
      "sc_demog" = "demographic_snapshot",
      "sds" = "sds_snapshot",
      # Open Data
      "ch_cost" = "4ee7dc84-ca65-455c-9e76-b614091f389f",
      "gpprac_cluster" = "gp-practice-contact-details-and-list-sizes",
      "geography_labels" = "944765d7-d0d9-46a0-b377-abb3de51d08e",
      "la_code" = "967937c4-8d67-4f39-974f-fd58c4acfda5",
      # Default
      NA_character_
    )
  }

  if (type %in% get_types("sc")){
    message("This is a Social Care extract. Returning Denodo table name.")
  }

  if (type %in% get_types("opendata")){
    message("This is a PHS Open Data extract. Returning dataset ID.")
  }

  return(local_filepath)
}

################################################################################.
# Helper function to detect a file type and read the file
################################################################################.

auto_file_read <- function(filepath, n_rows = NULL){

  # Check filepath argument is valid
  if (!is.character(filepath) ||
      length(filepath) != 1 ||
      is.na(filepath) ||
      filepath == "") {
    message("`filepath` must be a non-empty character string of length 1.")
    return(NULL)
  }

  # Check n_rows argument is valid
  if (!is.null(n_rows) &&
      (!is.numeric(n_rows) ||
       length(n_rows) != 1 ||
       n_rows < 1 ||
       n_rows %% 1 != 0)) {
    message("`n_rows` must be a positive integer or NULL.")
    return(NULL)
  }

  # Check filepath exists
  if (!file.exists(filepath)) {
    message("File does not exist.")
    return(NULL)
  }

  # .csv / .csv.gz
  if (grepl("\\.csv(\\.gz)?$", filepath, ignore.case = TRUE)) {
    if (is.null(n_rows)) {
      data <- read.csv(filepath)
    } else {
      data <- read.csv(filepath, nrows = n_rows)
    }

    # .rds / .rds.gz
  } else if (grepl("\\.rds(\\.gz)?$", filepath, ignore.case = TRUE)) {
    data <- readr::read_rds(filepath)
    if (!is.null(n_rows)) {
      data <- utils::head(data, n_rows)
    }

    # .parquet
  } else if (tolower(tools::file_ext(filepath)) == "parquet") {
    if (is.null(n_rows)) {
      data <- arrow::read_parquet(filepath)
    } else {
      data <- arrow::open_dataset(filepath) |>
        dplyr::slice_head(n = n_rows) |>
        dplyr::collect()
    }

    # .xlsx
  } else if (tolower(tools::file_ext(filepath)) == "xlsx") {
    if (is.null(n_rows)) {
      data <- openxlsx::read.xlsx(filepath)
    } else {
      data <- openxlsx::read.xlsx(
        filepath,
        rows = seq_len(n_rows + 1) # Assume row 1 is a header
      )
    }

    # Invalid extension
  } else {
    message("Invalid file extension.")
    return(NULL)
  }

  return(data)
}

################################################################################.
# Function to read in data from local file path
# NOTE: Social Care extracts return data from Denodo (social_care_2) and Open Data returns data from phsopendata
################################################################################.

get_local_data <- function(type, year = "", sdl_submission = FALSE, n_rows = NULL){

  # Check the file path exists
  filepath <- get_local_filepath(type = type, year = year, sdl_submission = sdl_submission)
  if (is.na(filepath)){
    return(NULL)
  }

  # Check n_rows is valid
  if (!(is.null(n_rows) ||
        (is.numeric(n_rows) &&
         length(n_rows) == 1 &&
         !is.na(n_rows) &&
         n_rows > 0 &&
         n_rows %% 1 == 0))) {
    message("`n_rows` must be a positive integer or NULL.")
    return(NULL)
  }

  # Social Care data read from social_care_2
  if (type %in% get_types("sc")) {
    # Denodo connection
    sc_dvprod_connection <- get_denodo_connection()
    # Filter rows
    if (!is.null(n_rows)) {
      data <- tibble::as_tibble(DBI::dbGetQuery(
        sc_dvprod_connection,
        glue::glue("SELECT * FROM social_care_2.{filepath} LIMIT {n_rows}")))
    # All data
    } else {
      data <- tibble::as_tibble(DBI::dbGetQuery(
        sc_dvprod_connection,
        glue::glue("SELECT * FROM social_care_2.{filepath}")))
    }
    message(paste0("Data read from: social_care_2, ", filepath))
    DBI::dbDisconnect(sc_dvprod_connection)

  # Open Data
  } else if (type %in% get_types("opendata")){
    # Read data using get_dataset()
    if (type == "gpprac_cluster"){
      data <- phsopendata::get_dataset(filepath)
    # Read data using get_resource()
    } else {
      # Columns to select
      col_select <- switch(
        type,
        "ch_cost" = c("Date", "KeyStatistic", "CA", "Value"),
        "geography_labels" = c("HSCP", "HSCPName", "HB", "HBName"),
        "la_code" = c("CA", "CAName", "HBName"),
        NULL)
      # Read data
      data <- phsopendata::get_resource(
        res_id = filepath,
        col_select = col_select)
    }
    if (!is.null(n_rows)) {
      data <- utils::head(data, n_rows)
    }
    message(paste0("Data read from: PHS OpenData (", filepath, ")"))

  # Files
  } else if (type == "homelessness_completeness" && isFALSE(sdl_submission)){
    data <- openxlsx::read.xlsx(
      filepath,
      sheet = "Table 1",
      rows = 8L:39L,
      cols = 1L:37L,
      colNames = F
    )
  } else {
    data <- auto_file_read(filepath, n_rows)
    message(paste0("Data read from: ", filepath))
  }

  return(data)
}

################################################################################.
# Function to get preprod connection to denodo (copied from development branch)
################################################################################.

get_denodo_connection <- function(username = NULL, BYOC_MODE = FALSE) {
  if (!BYOC_MODE) {
    dsn <- "DVPREPROD"
  } else {
    dsn <- Sys.getenv("denodo_dsn")
  }

  if (BYOC_MODE) {
    cli::cli_alert_info("Running in BYOC mode")

    cloud_user <- Sys.getenv("denodo_username")
    cloud_pass <- Sys.getenv("denodo_password")

    db_connection <- odbc::dbConnect(
      odbc::odbc(),
      dsn = dsn,
      uid = cloud_user,
      pwd = cloud_pass
    )

    cli::cli_alert_success("Connected to Denodo in BYOC_MODE")
    return(db_connection)
  }

  keyring_name <- "denodo_keyring"
  service_pass <- "denodo_password"
  service_user <- "denodo_user"

  # Check if keyring and environment variable exist
  keyring_list <- keyring::keyring_list()
  keyring_exists <- keyring_name %in% keyring_list[["keyring"]]
  env_var_pass <- Sys.getenv("DENODO_KEYRING_PASS")
  env_var_exists <- env_var_pass != ""

  # If not setup, trigger setup (Interactive only)
  if (!keyring_exists || !env_var_exists) {
    if (rlang::is_interactive()) {
      cli::cli_alert_info("Denodo credentials not configured. Starting setup...")
      setup_denodo_keyring(keyring = keyring_name)
      return(invisible(NULL))
    } else {
      cli::cli_abort("Denodo Keyring is not configured. Run this first.")
    }
  }

  # Unlock the keyring vault to retrieve username and password
  tryCatch(
    {
      keyring::keyring_unlock(keyring = keyring_name, password = env_var_pass)
    },
    error = function(e) {
      cli::cli_abort("Failed to unlock keyring. Check if DENODO_KEYRING_PASS is correct.")
    }
  )

  # Retrieve Username (From: 1. Function argument, 2. Keyring, 3. System)
  if (is.null(username)) {
    stored_keys <- keyring::key_list(keyring = keyring_name)[["service"]]
    if (service_user %in% stored_keys) {
      username <- keyring::key_get(service_user, keyring = keyring_name)
    } else {
      # Fallback to system user if not in keyring
      username <- Sys.info()["user"]
    }
  }

  # Retrieve Password
  db_pwd <- keyring::key_get(service_pass, keyring = keyring_name)

  # Create Connection
  cli::cli_alert_info("Connecting to {dsn} as {username}...")

  db_connection <- odbc::dbConnect(
    odbc::odbc(),
    dsn = dsn,
    uid = username,
    pwd = db_pwd
  )

  # Re-lock the keyring vault for security
  keyring::keyring_lock(keyring = keyring_name)

  cli::cli_alert_success("Connected to denodo successfully!")
  return(db_connection)
}

################################################################################.
# Function to set up keyring for denodo (copied from development branch)
################################################################################.

setup_denodo_keyring <- function(keyring = "denodo_keyring") {
  options(keyring_backend = "file")
  service_pass <- "denodo_password"
  service_user <- "denodo_user"

  # Setup the keyring vault password (Saved to .Renviron)
  if (Sys.getenv("DENODO_KEYRING_PASS") == "") {
    cli::cli_rule("Create Keyring Vault Password")
    keyring_password <- rstudioapi::askForPassword(
      "Create a new keyring vault password (Store this in a safe place!):"
    )

    if (!file.exists(".Renviron")) file.create(".Renviron")

    renviron_line <- sprintf('\nDENODO_KEYRING_PASS="%s"\n', keyring_password)
    cat(renviron_line, file = ".Renviron", append = TRUE)

    cli::cli_alert_warning("Vault key added to .Renviron.")
    cli::cli_alert_danger("Restart R session and run setup_denodo_keyring() again to finish setup.")
    return(invisible(NULL))
  }

  # Setup Denodo Credentials
  cli::cli_rule("Setup Denodo Credentials")
  master_pass <- Sys.getenv("DENODO_KEYRING_PASS")

  # Create keyring if it doesn't exist
  if (!(keyring %in% keyring::keyring_list()[["keyring"]])) {
    keyring::keyring_create(keyring = keyring, password = master_pass)
  }

  keyring::keyring_unlock(keyring = keyring, password = master_pass)

  # Store the Denodo Username and Password
  # We're currently connecting to the Denodo TEST environment. Users will use the shared Test Account
  # credentials to set up the keyring. Do NOT use your personal LDAP username/password at this stage.
  # This section will be refactored for LDAP integration once moved to Production.

  uid_input <- rstudioapi::showPrompt("Username", "Enter your Denodo Username:")

  keyring::key_set_with_value(keyring = keyring, service = service_user, password = uid_input)

  keyring::key_set(
    keyring = keyring,
    service = service_pass,
    prompt = "Enter your Denodo Password:"
  )

  keyring::keyring_lock(keyring = keyring)
  cli::cli_alert_success("Setup Complete! You can now use get_denodo_connection().")
}

################################################################################.
# Function to return the table names for each dataset in Denodo
################################################################################.

get_sdl_raw_names <- function(type) {

  # Check type is valid
  if (!is.character(type) || any(!type %in% get_types())) {
    message("`type` not valid. To check valid types use `get_types()`.")
    return(NA_character_)
  }

  sdl_names <- c(

    # BOXI Extracts (13)
    ae = "sdl_ae2_episode_level_source",
    ae_cup = "sdl_ae_ucd_cup_source",
    acute = "sdl_acute_source",
    acute_cup = "sdl_acute_cup_source",
    `gp_ooh-c` = "sdl_gp_ooh_consultation_source",
    `gp_ooh-d` = "sdl_gp_ooh_diagnosis_source",
    `gp_ooh-o` = "sdl_gp_ooh_outcome_source",
    gp_ooh_cup = "sdl_gp_ooh_cup_source",
    homelessness = "sdl_homelessness_source",
    maternity = "sdl_maternity_episode_source",
    mh = "sdl_mental_health_episode_source",
    outpatients = "sdl_outpatients_source",
    nrs_deaths = "sdl_nrs_deaths_source",

    # Archived Extracts (3)
    cmh = "sdl_cmh_source",
    dn = "sdl_dn_source",
    hhg = "sdl_hhg_source",

    # IT Extracts (3)
    chi_deaths = "sdl_chi_deaths_source",
    ltc = "sdl_long_term_condition_source",
    pis = "sdl_pis_source",

    # Extracts from Teams (3)
    dd = "sdl_dd_source",
    nsu = "sdl_nsu_source",
    sparra = "sdl_sparra_source",

    # Lookups (14)
    ch_name = "sdl_ch_name_lookup_source",
    datazone = "sdl_datazone_population_source",
    dn_contacts = "sdl_dn_contacts_source",
    dn_cost = "sdl_dn_cost_lookup_source",
    gpprac_ref = "sdl_gpprac_ref_source",
    hc_cost = "sdl_hc_cost_lookup_source",
    homelessness_completeness = "sdl_homelessness_completeness_source",
    hscp = "sdl_hscp_population_source",
    locality = "sdl_hscp_localities_source",
    ooh_cost = "sdl_ooh_cost_lookup_source",
    readcode = "sdl_read_code_lookup_source",
    simd = "sdl_simd_source",
    spd = "sdl_spd_source",
    uk_postcode = "sdl_uk_postcode_list_source",

    # Social Care Extracts (7)
    at = "sdl_sc_alarmtelecare_source",
    ch = "sdl_sc_carehome_source",
    client_fy = "sdl_sc_client_fy_source",
    client_qtr = "sdl_sc_client_qtr_source",
    hc = "sdl_sc_homecare_source",
    sc_demog = "sdl_sc_demographic_source",
    sds = "sdl_sc_sds_source",

    # Open Data (4)
    ch_cost = "sdl_carehomecostopendata_source",
    gpprac_cluster = "sdl_gpprac_cluster_source",
    geography_labels = "sdl_geography_labels_source",
    la_code = "sdl_laopendatalookup_source"
  )

  return(unname(sdl_names[type]))
}

################################################################################.
# Function to return the year column to filter for year specific datasets in Denodo (UNFINISHED)
################################################################################.

get_sdl_year_cols <- function(type) {

  # Check type is valid
  if (!is.character(type) || any(!type %in% get_types())) {
    message("`type` not valid. To check valid types use `get_types()`.")
    return(NA_character_)
  }

  # Check type is year specific
  if (any(!type %in% get_types(year_specific = TRUE))) {
    message("`type` not year specific. To check year specific types use `get_types(year_specific = TRUE)`.")
    return(NA_character_)
  }

  year_cols <- c(

    # BOXI Extracts (13)
    ae = "arrival_financial_year",
    ae_cup = "acute_admission_financial_year",
    acute = "costs_financial_year",
    acute_cup = "ed_arrival_financial_year",
    `gp_ooh-c` = "sc_start_financial_year",
    `gp_ooh-d` = "sc_start_financial_year",
    `gp_ooh-o` = "sc_start_financial_year",
    gp_ooh_cup = "gp_ooh_sc_start_financial_year",
    homelessness = "financial_year_of_assessment",
    maternity = "costs_financial_year",
    mh = "costs_financial_year",
    outpatients = "clinic_date_fin_year",
    nrs_deaths = "date_of_death_financial_year",

    # Archived Extracts (3)
    cmh = "", #####
    dn = "", #####
    hhg = "", #####

    # IT Extracts (1/3)
    pis = "", #####

    # Extracts from Teams (2/3)
    nsu = "", #####
    sparra = "risk_financial_year",

    # Social Care Extracts (2/7)
    client_fy = "", #####
    client_qtr = "" #####
  )

  return(unname(year_cols[type]))
}

################################################################################.
# Function to check available SDL datasets
################################################################################.
check_sdl_data <- function(){
  # Connect to denodo
  denodo_connect <- get_denodo_connection()

  # Execute the command: "Show me everything in the 'sdl' database/schema"
  all_views <- DBI::dbGetQuery(denodo_connect, "LIST VIEWS ON sdl")

  # Disconnect from denodo
  DBI::dbDisconnect(denodo_connect)

  # Filter the results in R (instead of SQL) to find names starting with 'sdl_' and ending in '_source'
  my_datasets <- all_views[grepl("^sdl_.*_source$", all_views$name, ignore.case = TRUE),]

  # Print available datasets
  message(paste0("The following ", length(my_datasets), " datasets are available:"))
  print(my_datasets)

  # Check get_sdl_raw_names() is up to date
  sdl_raw_names <- get_sdl_raw_names(get_types()) [get_sdl_raw_names(get_types()) != "unavailable"]

  # Datasets in get_sdl_raw_names() but not in denodo
  error1 <- setdiff(sdl_raw_names, my_datasets)
  if (length(error1) > 0){
    message("The following datasets are incorrectly named in `get_sdl_raw_names()` or are not yet available:")
    print(error1)
  }

  # Datasets in denodo but not in get_sdl_raw_names()
  error2 <- setdiff(my_datasets, sdl_raw_names)
  if (length(error2) > 0){
    message("The following datasets are available and need to be updated in `get_sdl_raw_names()`:")
    print(error2)
  }
  return(invisible(my_datasets))
}

################################################################################.
# Function to read SDL data from denodo
################################################################################.

get_sdl_data <- function(type, year = "", n_rows = NULL){

  # Check type is valid
  if (!type %in% get_types()){
    message("`type` not valid. To check valid types use `get_types()`.")
    return(NULL)
  }

  # Check year format is correct
  if (!(year == "" ||
        (is.character(year) &&
         length(year) == 1 &&
         grepl("^\\d{4}$", year) &&
         as.integer(substr(year,3,4)) ==
         as.integer(substr(year,1,2)) + 1))) {
    message("`year` argument invalid. Must be in the correct format e.g. `1718`.")
    return(NULL)
  }

  # Check n_rows is valid
  if (!(is.null(n_rows) ||
        (is.numeric(n_rows) &&
         length(n_rows) == 1 &&
         !is.na(n_rows) &&
         n_rows > 0 &&
         n_rows %% 1 == 0))) {
    message("`n_rows` must be a positive integer or NULL.")
    return(NULL)
  }

  # Check if type is year specific and year is not provided
  if (type %in% get_types(year_specific = TRUE) && year == ""){
    message("This is a year specific extract. `year` must be provided.")
    return(NULL)
  }

  # Check if type is not year specific but year is provided
  if (type %in% get_types(year_specific = FALSE) && year != ""){
    message("This is not a year specific extract. Returning all years.")
  }

  # Get table name
  sdl_name <- get_sdl_raw_names(type)

  if (sdl_name == "unavailable"){
    message("Currently waiting for data. Check using `check_sdl_data()` and update `get_sdl_raw_names()` when data is available.")
    return(NULL)
  }

  # Get data
  denodo_connect <- get_denodo_connection()

  if (!is.null(n_rows)) {
    data <- tibble::as_tibble(DBI::dbGetQuery(
      denodo_connect,
      glue::glue("SELECT * FROM sdl.{sdl_name} LIMIT {n_rows}")))
  } else {
    data <- tibble::as_tibble(DBI::dbGetQuery(
      denodo_connect,
      glue::glue("SELECT * FROM sdl.{sdl_name}")))
  }

  DBI::dbDisconnect(denodo_connect)

  return(data)
}

################################################################################.
# Function to get data from SDL, local or submission. Enables number of rows to be specified.
################################################################################.

get_data <- function(type, read_from, year = "", sdl_submission = FALSE, n_rows = NULL){

  # Check read_from argument is valid
  if(!read_from %in% c("local", "sdl")){
    message("`read_from` argument invalid. Must be `local` or `sdl`.")
    return(NA)
  }

  # Read local file
  if (read_from == "local"){
    data <- get_local_data(type, year, sdl_submission, n_rows)
  }

  # Read SDL table
  if (read_from == "sdl"){
    data <- get_sdl_data(type, year, n_rows)
  }

  return(data)
}
