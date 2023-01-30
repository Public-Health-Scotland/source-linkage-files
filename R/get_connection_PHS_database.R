#' Open a connection to a PHS database
#'
#' @description Opens a connection to PHS database to allow data to be collected
#'
#' @param dsn The Data Source Name passed on to `odbc::dbconnect`
#' the dsn must be setup first. e.g. SMRA or DVPROD
#' @param username The username to use for authentication,
#' if not supplied it first will check the environment variable
#' and finally ask the user for input.
#'
#' @return a connection to the specified dsn
#' @export
#'
phs_db_connection <- function(dsn, username = Sys.getenv("USER")) {
  # Collect username from the environment
  username <- Sys.getenv("USER")

  # Check the username is not empty and take input if not
  if (is.na(username) | username == "") {
    if (interactive()) {
      username <- rstudioapi::showPrompt(
        title = "Username",
        message = "Username",
        default = ""
      )
    } else {
      cli::cli_abort("no username supplied")
    }
  }

  # TODO improve error messages and provide instructions for setting up keyring
  # Add the following code to R profile.
  # Sys.setenv("CREATESLF_KEYRING_PASS" = "createslf"),
  # keyring_create("createslf", password = Sys.getenv("CREATESLF_KEYRING_PASS")),
  # key_set(keyring = "createslf", service = "db_password")

  if (!("createslf" %in% keyring::keyring_list()[["keyring"]])) {
    cli::cli_abort("The keyring for createslf does not exist. Please set this up by updating your R profile")
  }

  if (!("db_password" %in% keyring::key_list(keyring = "createslf")[["service"]])) {
    cli::cli_abort("The keyring password has not been supplied. Please set this up in your R profile")
  }

  if (Sys.getenv("CREATESLF_KEYRING_PASS") == "") {
    cli::cli_abort("createslf keyring pw needs to be set in the environment variable
                   {.env CREATESLF_KEYRING_PASS}")
  }

  keyring::keyring_unlock(keyring = "createslf", password = Sys.getenv("CREATESLF_KEYRING_PASS"))

  if (keyring::keyring_is_locked(keyring = "createslf")) {
    cli::cli_abort("Keyring is locked. To unlock createslf keyring, please use {.fun keyring_unlock}")
  }


  # Create the connection
  password_text <- glue::glue("{dsn} password for user: {username}")
  db_connection <- odbc::dbConnect(
    odbc::odbc(),
    dsn = dsn,
    uid = username,
    pwd = keyring::key_get(keyring = "createslf", service = "db_password")
  )

  keyring::keyring_lock(keyring = "createslf")

  return(db_connection)
}
