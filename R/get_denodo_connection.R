#' Open a connection to the Denodo database
#'
#' @description Opens a connection to the Denodo database given a Data Source
#' Name (DSN). It will attempt to retrieve the username automatically, prompting
#' for input if in an interactive session and no username is found. It uses the
#' keyring package to find an existing keyring , which should contain a
#' `denodo_password` with the user's database password.
#'
#' @param dsn The Data Source Name (DSN) passed on to [odbc::dbConnect()].
#' The DSN must be configured on the system first (e.g., `DVPREPROD` or `DVPROD`).
#' @param username The username to use for authentication. If not supplied,
#' the function tries to detect it from system environment variables or
#' system info.
#'
#' @return a connection to the Denodo database.
#' @export
get_denodo_connection <- function(dsn = "DVPREPROD", username) {
  if (missing(username)) {
    # Collect username if possible
    username <- dplyr::case_when(
      Sys.info()["USER"] != "unknown" ~ Sys.info()["USER"],
      Sys.getenv("USER") != "" ~ Sys.getenv("USER"),
      system2("whoami", stdout = TRUE) != "" ~ system2("whoami", stdout = TRUE),
      .default = NA
    )
  }

  # If the username is missing try to get input from the user
  if (is.na(username)) {
    if (rlang::is_interactive()) {
      username <- rstudioapi::showPrompt(
        title = "Denodo Username",
        message = "Please enter your Denodo username:",
        default = ""
      )
    } else {
      cli::cli_abort(
        c("x" = "No username found. Please provide the {.arg username} argument or
               add {.code USER = 'your_id'} to your {.file .Renviron} file.")
      )
    }
  }

  # Keyring Configuration
  keyring_name <- "denodo_keyring"
  service_name <- "denodo_password"

  keyring_exists <- keyring_name %in% keyring::keyring_list()[["keyring"]]

  if (keyring_exists) {
    key_exists <- service_name %in% keyring::key_list(keyring = keyring_name)[["service"]]
  } else {
    key_exists <- FALSE
  }

  # Does the 'DENODO_KEYRING_PASS' environment variable exist
  env_var_pass_exists <- Sys.getenv("DENODO_KEYRING_PASS") != ""

  # Validation and Setup Trigger
  if (!all(keyring_exists, key_exists, env_var_pass_exists)) {
    if (rlang::is_interactive()) {
      setup_denodo_keyring(
        keyring = keyring_name,
        key = service_name,
        keyring_exists = keyring_exists,
        key_exists = key_exists,
        env_var_pass_exists = env_var_pass_exists
      )
    } else {
      cli::cli_abort("Denodo Keyring is not configured. Please run {.fn setup_denodo_keyring} interactively.")
    }
  }

  # Create the connection
  keyring_pass <- if (env_var_pass_exists) {
    Sys.getenv("DENODO_KEYRING_PASS")
  } else {
    rstudioapi::askForPassword("Enter the password for your Denodo Keyring:")
  }

  keyring::keyring_unlock(keyring = keyring_name, password = keyring_pass)

  db_connection <- odbc::dbConnect(
    odbc::odbc(),
    dsn = dsn,
    uid = username,
    pwd = keyring::key_get(
      keyring = keyring_name,
      service = service_name
      )
  )

  # Relock for security
  keyring::keyring_lock(keyring = keyring_name)

  return(db_connection)
}


