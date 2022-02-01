#' Create Health Board test flags
#'
#' @param data the data containing a health board variable e.g. HB2019
#' @param hb_var Health board variable e.g. HB2019 HB2018 hbpraccode
#'
#' @return a dataframe with flag (1 or 0) for each Health Board
#' @export
#' @importFrom dplyr if_else
#' @family create test flags functions
create_hb_test_flags <- function(data, hb_var) {
  data <- data %>%
    dplyr::mutate(
      NHS_Ayrshire_and_Arran = if_else({{ hb_var }} == "S08000015", 1, 0),
      NHS_Borders = if_else({{ hb_var }} == "S08000016", 1, 0),
      NHS_Dumfries_and_Galloway = if_else({{ hb_var }} == "S08000017", 1, 0),
      NHS_Forth_Valley = if_else({{ hb_var }} == "S08000019", 1, 0),
      NHS_Grampian = if_else({{ hb_var }} == "S08000020", 1, 0),
      NHS_Highland = if_else({{ hb_var }} == "S08000022", 1, 0),
      NHS_Lothian = if_else({{ hb_var }} == "S08000024", 1, 0),
      NHS_Orkney = if_else({{ hb_var }} == "S08000025", 1, 0),
      NHS_Shetland = if_else({{ hb_var }} == "S08000026", 1, 0),
      NHS_Western_Isles = if_else({{ hb_var }} == "S08000028", 1, 0),
      NHS_Fife = if_else({{ hb_var }} == "S08000029", 1, 0),
      NHS_Tayside = if_else({{ hb_var }} == "S08000030", 1, 0),
      NHS_Greater_Glasgow_and_Clyde = if_else({{ hb_var }} %in% c("S08000031", "S08000021"), 1, 0),
      NHS_Lanarkshire = if_else({{ hb_var }} %in% c("S08000032", "S08000023"), 1, 0)
    )
}
