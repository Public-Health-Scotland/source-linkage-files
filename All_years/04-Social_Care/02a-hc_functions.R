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
    stop(
      glue::glue(
        "Demographics file doesn't exists or the name: ",
        "'{path_file(demog_file_path)}' is incorrect"
      )
    )
  }

  clean_file <- read_rds(demog_file_path) %>%
    tidylog::mutate(
      across(c(where(is_integer_like), -chi), as.integer),
      across(where(is.character), zap_empty)
    ) %>%
    haven::zap_formats() %>%
    haven::zap_widths()

  return(clean_file)
}


is_integer_like <- function(x) {
  values <- unique(x)

  if (is.character(values)) {
    values <- trimws(values)

    is_empty <- values == ""

    # \\D is any non-digit
    contains_only_digits <- !grepl("\\D", values)

    if (all(contains_only_digits | is_empty)) {
      values <- as.numeric(values)
      contains_only_integers <- na.exclude(values) %% 1 == 0

      return(all(contains_only_integers))
    } else {
      return(FALSE)
    }

  } else if (is.numeric(values)) {
    return(all(na.exclude(values) %% 1 == 0))
  } else {
    return(FALSE)
  }

}
