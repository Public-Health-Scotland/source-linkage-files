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


convert_sc_sl_to_lca <- function(sending_location){

  lca <- dplyr::case_when({{sending_location}} == "100" ~ "01",
          {{sending_location}} == "110" ~ "02",
          {{sending_location}} == "120" ~ "03",
          {{sending_location}} == "130" ~ "04",
          {{sending_location}} == "150" ~ "06",
          {{sending_location}} == "170" ~ "08",
          {{sending_location}} == "180" ~ "09",
          {{sending_location}} == "190" ~ "10",
          {{sending_location}} == "200" ~ "11",
          {{sending_location}} == "210" ~ "12",
          {{sending_location}} == "220" ~ "13",
          {{sending_location}} == "230" ~ "14",
          {{sending_location}} == "235" ~ "32",
          {{sending_location}} == "240" ~ "15",
          {{sending_location}} == "250" ~ "16",
          {{sending_location}} == "260" ~ "17",
          {{sending_location}} == "270" ~ "18",
          {{sending_location}} == "280" ~ "19",
          {{sending_location}} == "290" ~ "20",
          {{sending_location}} == "300" ~ "21",
          {{sending_location}} == "310" ~ "22",
          {{sending_location}} == "330" ~ "24",
          {{sending_location}} == "340" ~ "25",
          {{sending_location}} == "350" ~ "26",
          {{sending_location}} == "355" ~ "05",
          {{sending_location}} == "360" ~ "27",
          {{sending_location}} == "370" ~ "28",
          {{sending_location}} == "380" ~ "29",
          {{sending_location}} == "390" ~ "30",
          {{sending_location}} == "395" ~ "07",
          {{sending_location}} == "400" ~ "31")
  return(lca)
}


