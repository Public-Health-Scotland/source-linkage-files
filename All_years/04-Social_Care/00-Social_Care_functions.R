# Shared Social Care dir path
social_care_dir <- fs::path("/conf/hscdiip/SLF_Extracts/Social_care")


#' Latest update
#'
#' @description Get the date of the latest update, e.g 'Jun_2022'
#'
#' @return Latest update as MMM_YYYY
#' @export
#'
#' @family initialisation
latest_update <- function() {
  "Sep_2022"
}

#' Open a connection to a PHS database
#'
#' @param dsn The Data Source Name passed on to `odbc::dbconnect`
#' the dsn must be setup first. e.g. SMRA or DVPROD
#' @param username The username to use for authentication,
#' if not supplied it first will check the environment variable
#' and finally ask the user for input.
#'
#' @return a connection to the specified dsn
#' @export
phs_db_connection <- function(dsn, username = Sys.getenv("USER")) {
  # Collect username from the environment
  username <- Sys.getenv("USER")

  # Check the username is not empty and take input if not
  if (is.na(username) | username == "") {
    username <- rstudioapi::showPrompt(
      title = "Username",
      message = "Username",
      default = ""
    )
  }

  # Create the connection
  password_text <- glue::glue("{dsn} password for user: {username}")
  db_connection <- odbc::dbConnect(
    odbc::odbc(),
    dsn = dsn,
    uid = username,
    pwd = rstudioapi::askForPassword(password_text)
  )

  return(db_connection)
}


# TODO- check R conversion for SC demog lookup. This may differ
#' Social Care Demographic Lookup File Path
#'
#' @description Get the file path for the Social Care Demographic lookup file
#'
#' @param social_care_dir The path to the social care directory.
#' @param latest_update The update month to use,
#' defaults to [latest_update()]
#
#'
#' @return The path to the social care demographic file
#' as an [fs::path()]
#' @export
read_demog_file <- function(social_care_dir, latest_update) {
  demog_file_path <- fs::path(
    social_care_dir,
    glue::glue("sc_demographics_lookup_{latest_update}.rds")
  )

  if (!fs::file_exists(demog_file_path)) {
    demog_file_path <- fs::path_ext_set(demog_file_path, "zsav")
  } else if (!fs::file_exists(fs::path_ext_set(demog_file_path, "zsav"))) {
    cli::cli_abort(c(
        "The demographics file doesn't exist in {.val rds} or {.val zsav} format
         or the name: {.val {fs::path_ext_remove(fs::path_file(demog_file_path))}}
         is incorrect"
      )
    )
  }

  data <- switch(fs::path_ext(demog_file_path),
    "rds" = readr::read_rds(demog_file_path),
    "zsav" = haven::read_sav(demog_file_path)
  )

  clean_data <- data %>%
    tidylog::mutate(
      across(c(where(is_integer_like), -chi), as.integer),
      across(where(is.character), zap_empty)
    ) %>%
    haven::zap_formats() %>%
    haven::zap_widths()

  return(clean_data)
}


#' Check if an object looks like an integer
#'
#' @description Take a vector and check to see if
#' it looks like it contains only integers.
#'
#' @param x a vector of values to check
#'
#' @return TRUE or FALSE indicating if all values
#' look like integers - if the vector is not of type
#' character or numeric it will always return FALSE
#' @export
#'
#' @examples
#' library(dplyr)
#' data <-
#'   tibble(
#'     x = c(1, 2, 3),
#'     y = c("4", "5", "6"),
#'     z = c("a", "b", "c")
#'   )
#' data %>%
#'   mutate(across(where(is_integer_like), as.integer))
is_integer_like <- function(x) {
  values <- unique(x)

  if (is.character(values)) {
    values <- suppressWarnings(as.numeric(values))

    if (all(is.na(values))) {
      return(FALSE)
    }

    return(rlang::is_integerish(values))
  } else if (is.numeric(values)) {
    return(rlang::is_integerish(values))
  } else {
    return(FALSE)
  }
}


#' Convert Social Care Sending Location Codes into LCA Codes
#'
#' @description Convert Social Care Sending Location Codes into the Local Council Authority Codes
#'
#' @param sending_location vector of sending location codes
#'
#' @return a vector of local council authority codes
#' @export
#'
#' @examples
#' sending_location <- c("100", "120")
#' convert_sending_location_to_lca(sending_location)
convert_sc_sl_to_lca <- function(sending_location) {
  lca <- dplyr::case_when(
    {{ sending_location }} == "100" ~ "01", # Aberdeen City
    {{ sending_location }} == "110" ~ "02", # Aberdeenshire
    {{ sending_location }} == "120" ~ "03", # Angus
    {{ sending_location }} == "130" ~ "04", # Argyll and Bute
    {{ sending_location }} == "355" ~ "05", # Scottish Borders
    {{ sending_location }} == "150" ~ "06", # Clackmannanshire
    {{ sending_location }} == "395" ~ "07", # West Dumbartonshire
    {{ sending_location }} == "170" ~ "08", # Dumfries and Galloway
    {{ sending_location }} == "180" ~ "09", # Dundee City
    {{ sending_location }} == "190" ~ "10", # East Ayrshire
    {{ sending_location }} == "200" ~ "11", # East Dunbartonshire
    {{ sending_location }} == "210" ~ "12", # East Lothian
    {{ sending_location }} == "220" ~ "13", # East Renfrewshire
    {{ sending_location }} == "230" ~ "14", # City of Edinburgh
    {{ sending_location }} == "240" ~ "15", # Falkirk
    {{ sending_location }} == "250" ~ "16", # Fife
    {{ sending_location }} == "260" ~ "17", # Glasgow City
    {{ sending_location }} == "270" ~ "18", # Highland
    {{ sending_location }} == "280" ~ "19", # Inverclyde
    {{ sending_location }} == "290" ~ "20", # Midlothian
    {{ sending_location }} == "300" ~ "21", # Moray
    {{ sending_location }} == "310" ~ "22", # North Ayrshire
    {{ sending_location }} == "320" ~ "23", # North Lanarkshire
    {{ sending_location }} == "330" ~ "24", # Orkney Islands
    {{ sending_location }} == "340" ~ "25", # Perth and Kinross
    {{ sending_location }} == "350" ~ "26", # Renfrewshire
    {{ sending_location }} == "360" ~ "27", # Shetland Islands
    {{ sending_location }} == "370" ~ "28", # South Ayrshire
    {{ sending_location }} == "380" ~ "29", # South Lanarkshire
    {{ sending_location }} == "390" ~ "30", # Stirling
    {{ sending_location }} == "400" ~ "31", # West Lothian
    {{ sending_location }} == "235" ~ "32"  # Na_h_Eileanan_Siar
  )
  return(lca)
}

#' Return the start date of FY year
#'
#' @description Get the start date of the specified financial year
#'
#' @param year a vector of years
#' @param format the format of the year vector, default is financial year
#'
#' @return a vector of the start dates of the FY year
#' @export
#'
#' @examples
#' start_fy("1718")
#'
#' @family date functions
start_fy <- function(year, format = c("fyyear", "alternate")) {
  if (missing(format)) {
    format <- "fyyear"
  }

  format <- match.arg(format)

  if (format == "fyyear") {
    start_fy <- as.Date(paste0(convert_fyyear_to_year(year), "-04-01"))
  } else if (format == "alternate") {
    start_fy <- as.Date(paste0(year, "-04-01"))
  }

  return(start_fy)
}

#' Return the end date of FY years
#'
#' @description Get the end date of the specified financial year
#'
#' @inheritParams start_fy
#'
#' @return a vector of dates of the end date of the FY year
#' @export
#'
#' @examples
#' end_fy("1718")
#'
#' @family date functions
end_fy <- function(year, format = c("fyyear", "alternate")) {
  if (missing(format)) {
    format <- "fyyear"
  }

  format <- match.arg(format)

  if (format == "fyyear") {
    end_fy <- as.Date(paste0(as.numeric(convert_fyyear_to_year(year)) + 1, "-03-31"))
  } else if (format == "alternate") {
    end_fy <- as.Date(paste0(as.numeric(year) + 1, "-03-31"))
  }

  return(end_fy)
}
