#' Convert Social Care Sending Location Codes into LCA
#'
#' @param sending_location vector of council area codes or names
#'
#' @return a vector of local council codes
#' @export
#'
#' @examples
#' sending_location <- c("100", "120")
#' convert_sending_location_to_lca(sending_location)
convert_sending_location_to_lca <- function(sending_location) {
  lca <- dplyr::case_when(
    sending_location == "100" ~ "01",
    sending_location == "110" ~ "02",
    sending_location == "120" ~ "03",
    sending_location == "130" ~ "04",
    sending_location == "150" ~ "06",
    sending_location == "170" ~ "07",
    sending_location == "180" ~ "09",
    sending_location == "190" ~ "10",
    sending_location == "200" ~ "11",
    sending_location == "220" ~ "13",
    sending_location == "230" ~ "14",
    sending_location == "235" ~ "32",
    sending_location == "240" ~ "15",
    sending_location == "250" ~ "16",
    sending_location == "260" ~ "17",
    sending_location == "270" ~ "18",
    sending_location == "280" ~ "19",
    sending_location == "290" ~ "20",
    sending_location == "300" ~ "21",
    sending_location == "310" ~ "22",
    sending_location == "320" ~ "23",
    sending_location == "330" ~ "24",
    sending_location == "340" ~ "25",
    sending_location == "350" ~ "26",
    sending_location == "360" ~ "27",
    sending_location == "370" ~ "28",
    sending_location == "380" ~ "29",
    sending_location == "390" ~ "30",
    sending_location == "395" ~ "07",
    sending_location == "400" ~ "31"
  )
  return(lca)
}
