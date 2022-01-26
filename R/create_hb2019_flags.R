#' Create HB 2019 flag
#'
#' @param data the data containing health board 2019
#'
#' @return a dataframe with flag (1 or 0) for each HB
#' @importFrom dplyr mutate if_else
create_hb2019_flags <- function(data) {
  data <- data %>%
    dplyr::mutate(
      NHS_Ayrshire_and_Arran = if_else(.data$HB2019 == "S08000015", 1, 0),
      NHS_Borders = if_else(.data$HB2019 == "S08000016", 1, 0),
      NHS_Dumfries_and_Galloway = if_else(.data$HB2019 == "S08000017", 1, 0),
      NHS_Forth_Valley = if_else(.data$HB2019 == "S08000019", 1, 0),
      NHS_Grampian = if_else(.data$HB2019 == "S08000020", 1, 0),
      NHS_Highland = if_else(.data$HB2019 == "S08000022", 1, 0),
      NHS_Lothian = if_else(.data$HB2019 == "S08000024", 1, 0),
      NHS_Orkney = if_else(.data$HB2019 == "S08000025", 1, 0),
      NHS_Shetland = if_else(.data$HB2019 == "S08000026", 1, 0),
      NHS_Western_Isles = if_else(.data$HB2019 == "S08000028", 1, 0),
      NHS_Fife = if_else(.data$HB2019 == "S08000029", 1, 0),
      NHS_Tayside = if_else(.data$HB2019 == "S08000030", 1, 0),
      NHS_Greater_Glasgow_and_Clyde = if_else(.data$HB2019 == "S08000031", 1, 0),
      NHS_Lanarkshire = if_else(.data$HB2019 == "S08000032", 1, 0)
    )
}
