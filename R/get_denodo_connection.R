#' Open a connection to the Denodo
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
get_denodo_connection <- function(dsn = "DVPREPROD", username = NULL) {
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
  tryCatch({
    keyring::keyring_unlock(keyring = keyring_name, password = env_var_pass)
  }, error = function(e) {
    cli::cli_abort("Failed to unlock keyring. Check if DENODO_KEYRING_PASS is correct.")
  })

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

#' Interactively set up the keyring for denodo connection
#'
#' @description Helper function meant to be used with [get_denodo_connection()].
#' It will go through the steps to set up a keyring which can be used to supply
#' username and passwords to [odbc::dbConnect()] in a secure and seamless way.
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

  # Store the Denodo Username
  uid_input <- rstudioapi::showPrompt("Username", "Enter your Denodo Username:")
  keyring::key_set_with_value(keyring = keyring, service = service_user, password = uid_input)

  # Store the Denodo Password
  keyring::key_set(
    keyring = keyring,
    service = service_pass,
    prompt = "Enter your Denodo Password:"
  )

  keyring::keyring_lock(keyring = keyring)
  cli::cli_alert_success("Setup Complete! You can now use get_denodo_connection().")
}
