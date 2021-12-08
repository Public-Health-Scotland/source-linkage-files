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

read_demog_file <- function(social_care_dir, latest_update) {
  demog_file_path <- fs::path(
    social_care_dir,
    glue::glue("sc_demographics_lookup_{latest_update}.rds")
  )

  if (!fs::file_exists(demog_file_path)) {
    demog_file_path <- fs::path_ext_set(demog_file_path, "zsav")
  } else {
    stop(
      glue::glue(
        "Demographics file doesn't in rds or zsav format or the name: ",
        "'{fs::path_ext_remove(fs::path_file(demog_file_path))}' is incorrect"
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
