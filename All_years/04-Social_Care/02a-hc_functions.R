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

get_demog_file_path <- function(social_care_dir, latest_update) {
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

  return(demog_file_path)
}


is_number_like <- function(x) {
  values <- unique(x)

  if (!is.character(values)) {
    return(FALSE)
  }

  return(all(!grepl("\\D", values)))
}

is_integer_like <- function(x) {
  values <- unique(x)

  if (!is.numeric(values)) {
    return(FALSE)
  }

  return(all(na.exclude(values) %% 1 == 0))
}
