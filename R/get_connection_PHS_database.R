#' Open a connection to a PHS database
#'
#' @description Opens a connection to PHS database given a Data Source Name
#' (DSN) it will try to get the username, asking for input if in an interactive
#' session. It will also use [keyring][keyring::keyring-package] to find
#' an existing keyring called 'createslf' which should contain a `db_password`
#' key with the users database password.
#'
#' @param dsn The Data Source Name (DSN) passed on to [odbc::dbConnect()]
#' the DSN must be set up first. e.g. `SMRA` or `DVPROD`
#' @param username The username to use for authentication,
#' if not supplied it will try to find it automatically and if possible ask the
#' user for input.
#'
#' @return a connection to the specified Data Source.
#' @export
phs_db_connection <- function(dsn, username) {
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
        title = "Username",
        message = "Username",
        default = ""
      )
    } else {
      cli::cli_abort(
        c(
          "x" = "No username found, you can use the {.arg username} argument.",
          "i" = "Alternatively, add {.code USER = \"<your username>\"} to your
          {.file .Renviron} file."
        )
      )
    }
  }

  # Check the status of keyring
  # Does the 'createslf' keyring exist
  keyring_exists <- "createslf" %in% keyring::keyring_list()[["keyring"]]

  # Does the 'db_password' key exist in the 'createslf' keyring
  if (keyring_exists) {
    key_exists <- "db_password" %in% keyring::key_list(keyring = "createslf")[["service"]]
  } else {
    key_exists <- FALSE
  }

  # Does the 'CREATESLF_KEYRING_PASS' environment variable exist
  env_var_pass_exists <- Sys.getenv("CREATESLF_KEYRING_PASS") != ""

  if (!all(keyring_exists, key_exists, env_var_pass_exists)) {
    if (rlang::is_interactive()) {
      setup_keyring(
        keyring = "createslf",
        key = "db_password",
        keyring_exists = keyring_exists,
        key_exists = key_exists,
        env_var_pass_exists = env_var_pass_exists
      )
    } else {
      if (any(keyring_exists, key_exists, env_var_pass_exists)) {
        cli::cli_abort(
          c(
            "x" = "Your keyring needs to be set up, run:",
            "{.code setup_keyring(keyring = \"createslf\", key = \"db_password\",
  keyring_exists = {keyring_exists}, key_exists = {key_exists},
  env_var_pass_exists = {env_var_pass_exists})}"
          )
        )
      } else {
        cli::cli_abort(
          c(
            "x" = "Your keyring needs to be set up, run:",
            "{.code setup_keyring(keyring = \"createslf\",
            key = \"db_password\")}"
          )
        )
      }
    }
  }

  if (env_var_pass_exists) {
    keyring::keyring_unlock(
      keyring = "createslf",
      password = Sys.getenv("CREATESLF_KEYRING_PASS")
    )
  } else {
    keyring::keyring_unlock(
      keyring = "createslf",
      password = rstudioapi::askForPassword(
        prompt = "Enter the password for the keyring you just created."
      )
    )
  }


  # Create the connection
  db_connection <- odbc::dbConnect(
    odbc::odbc(),
    dsn = dsn,
    uid = username,
    pwd = keyring::key_get(
      keyring = "createslf",
      service = "db_password"
    )
  )

  keyring::keyring_lock(keyring = "createslf")

  return(db_connection)
}

#' Interactively set up the keyring
#'
#' @description
#' This is meant to be used with [phs_db_connection()], it can only be used
#' interactively i.e. not in targets or in a workbench job.
#'
#' With the default options it will go through the steps to set up a keyring
#' which can be used to supply passwords to [odbc::dbConnect()] (or others) in a
#' secure and seamless way.
#'
#'  1. Create an .Renviron file in the project and add a password (for the
#'  keyring) to it.
#'  2. Create a keyring with the password - Since we have saved the password as
#'  an environment variable it can be picked unlocked and used automatically.
#'  3. Add the database password to the keyring.
#'
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
setup_keyring <- function(
    keyring = "createslf",
    key = "db_password",
    keyring_exists = FALSE,
    key_exists = FALSE,
    env_var_pass_exists = FALSE) {

  # setup keyring_backend to avoid error
  # Error in default_backend()$keyring_list() : attempt to apply non-function
  options(keyring_backend = "file")

  # First we need the password as an environment variable
  if (!env_var_pass_exists) {
    if (Sys.getenv("CREATESLF_KEYRING_PASS") != "") {
      cli::cli_alert_warning(
        "{.env CREATESLF_KEYRING_PASS} already exists in the environment, you
        will need to clean this up manually if it's not correct."
      )
      keyring_password <- Sys.getenv("CREATESLF_KEYRING_PASS")
    } else if (
      any(stringr::str_detect(
        readr::read_lines(".Renviron"),
        "^CREATESLF_KEYRING_PASS\\s*?=\\s*?['\"].+?['\"]$"
      ))

    ) {
      cli::cli_abort(
        "Your {.file .Renviron} file looks ok, try restarting your session."
      )
    } else {
      keyring_password <- rstudioapi::askForPassword(
        prompt = stringr::str_glue(
          "Enter a password for the '{keyring}' keyring, this should
        not be your LDAP / database password."
        )
      )
      if (is.null(keyring_password)) {
        cli::cli_abort("No keyring password entered.")
      }
      if (!fs::file_exists(".Renviron")) {
        cli::cli_alert_success("Creating an {.file .Renviron} file.")
      }

      renviron_text <- stringr::str_glue(
        "CREATESLF_KEYRING_PASS = \"{keyring_password}\""
      )

      readr::write_lines(
        x = renviron_text,
        file = ".Renviron",
        append = TRUE
      )

      cli::cli_alert_success(
        "Added {.code {renviron_text}} to the {.file .Renviron} file."
      )

      cli::cli_alert_info("You will need to restart your R session.")
    }
  } else {
    keyring_password <- Sys.getenv("CREATESLF_KEYRING_PASS")
  }

  # If the keyring doesn't exist create it now.
  if (!keyring_exists) {
    if (keyring %in% keyring::keyring_list()[["keyring"]]) {
      cli::cli_alert_warning(
        "The {keyring} keyring already exists, you will be asked to
        overwrite it."
      )
    }
    keyring::keyring_create(
      keyring = keyring,
      password = keyring_password
    )

    cli::cli_alert_success(
      "Created the '{keyring}' keyring with {.fun keyring::keyring_create}."
    )
  }

  # If we just created the keyring it will already be unlocked
  keyring::keyring_unlock(
    keyring = keyring,
    password = keyring_password
  )

  # Now add the password to the keyring
  if (!key_exists) {
    keyring::key_set(
      keyring = keyring,
      service = key,
      prompt = "Enter you LDAP password for database connections."
    )

    cli::cli_alert_success(
      "Added the '{key}' key to the '{keyring}' keyring with
      {.fun keyring::keyring_set}."
    )
  }

  keyring::keyring_lock(keyring = keyring)

  cli::cli_alert_success(
    "The keyring should now be set up correctly."
  )

  return(invisible(NULL))
}
