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

#' Interactively set up the keyring for denodo connection
#'
#' @description This is meant to be used with [get_denodo_connection()].
#' It will go through the steps to set up a keyring which can be used to
#' supply passwords to [odbc::dbConnect()] in a secure and seamless way.
#'
#' @param keyring Name of the keyring
#' @param key Name of the key
#' @param keyring_exists Does the keyring already exist
#' @param key_exists Does the key already exist
#' @param env_var_pass_exists Does the password for the keyring already exist
#' in the environment.
#'
#' @return NULL (invisibly)
#' @export
setup_denodo_keyring <- function(keyring = "denodo_keyring",
                                 key = "denodo_password",
                                 keyring_exists = FALSE,
                                 key_exists = FALSE,
                                 env_var_pass_exists = FALSE) {

  # setup keyring_backend to avoid error
  options(keyring_backend = "file")

  # Handle .Renviron entry. Set the keyring vault password.
  if (!env_var_pass_exists) {
    keyring_password <- rstudioapi::askForPassword("Enter a password for the Keyring vault (NOT LDAP)")

    renviron_line <- stringr::str_glue('DENODO_KEYRING_PASS = "{keyring_password}"')
    readr::write_lines(renviron_line, ".Renviron", append = TRUE)

    cli::cli_alert_success("Added password to .Renviron. Please restart your R session.")
    return(invisible(NULL))
  }

  # Create Keyring
  if (!keyring_exists) {
    keyring::keyring_create(keyring = keyring, password = Sys.getenv("DENODO_KEYRING_PASS"))
  }

  # Set the denodo Password
  keyring::keyring_unlock(keyring = keyring, password = Sys.getenv("DENODO_KEYRING_PASS"))
  if (!key_exists) {
    keyring::key_set(keyring = keyring, service = key, prompt = "Enter your Denodo password")
  }

  keyring::keyring_lock(keyring = keyring)
  cli::cli_alert_success("Denodo Keyring is ready!")
}
