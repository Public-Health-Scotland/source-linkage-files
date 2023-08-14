#' Create Health Board test flags
#'
#' @description Create test flags for NHS Health Boards
#'
#' @param data the data containing a health board variable e.g. HB2019
#' @param hb_var Health board variable e.g. HB2019 HB2018 hbpraccode
#'
#' @return a dataframe with flag (1 or 0) for each Health Board
#'
#' @family flag functions
create_hb_test_flags <- function(data, hb_var) {
  data <- data %>%
    dplyr::mutate(
      NHS_Ayrshire_and_Arran = {{ hb_var }} == "S08000015",
      NHS_Borders = {{ hb_var }} == "S08000016",
      NHS_Dumfries_and_Galloway = {{ hb_var }} == "S08000017",
      NHS_Forth_Valley = {{ hb_var }} == "S08000019",
      NHS_Grampian = {{ hb_var }} == "S08000020",
      NHS_Highland = {{ hb_var }} == "S08000022",
      NHS_Lothian = {{ hb_var }} == "S08000024",
      NHS_Orkney = {{ hb_var }} == "S08000025",
      NHS_Shetland = {{ hb_var }} == "S08000026",
      NHS_Western_Isles = {{ hb_var }} == "S08000028",
      NHS_Fife = {{ hb_var }} == "S08000029",
      NHS_Tayside = {{ hb_var }} == "S08000030",
      NHS_Greater_Glasgow_and_Clyde = {{ hb_var }} %in% c("S08000031", "S08000021"),
      NHS_Lanarkshire = {{ hb_var }} %in% c("S08000032", "S08000023")
    )
}
