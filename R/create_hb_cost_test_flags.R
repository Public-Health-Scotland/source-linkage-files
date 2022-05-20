#' Create Health Board cost test flags
#'
#' @param data the data containing a health board variable e.g. HB2019
#' @param hb_var Health board variable e.g. HB2019 HB2018 hbpraccode
#' @param cost_var Cost variable e.g. cost_total_net
#'
#' @return a dataframe with flag (1 or 0) for each Health Board
#' @export
#' @family create test flags functions
create_hb_cost_test_flags <- function(data, hb_var, cost_var) {
  data <- data %>%
    dplyr::mutate(
      NHS_Ayrshire_and_Arran_cost = dplyr::if_else({{ hb_var }} == "S08000015", {{ cost_var }}, 0),
      NHS_Borders_cost = dplyr::if_else({{ hb_var }} == "S08000016", {{ cost_var }}, 0),
      NHS_Dumfries_and_Galloway_cost = dplyr::if_else({{ hb_var }} == "S08000017", {{ cost_var }}, 0),
      NHS_Forth_Valley_cost = dplyr::if_else({{ hb_var }} == "S08000019", {{ cost_var }}, 0),
      NHS_Grampian_cost = dplyr::if_else({{ hb_var }} == "S08000020", {{ cost_var }}, 0),
      NHS_Highland_cost = dplyr::if_else({{ hb_var }} == "S08000022", {{ cost_var }}, 0),
      NHS_Lothian_cost = dplyr::if_else({{ hb_var }} == "S08000024", {{ cost_var }}, 0),
      NHS_Orkney_cost = dplyr::if_else({{ hb_var }} == "S08000025", {{ cost_var }}, 0),
      NHS_Shetland_cost = dplyr::if_else({{ hb_var }} == "S08000026", {{ cost_var }}, 0),
      NHS_Western_Isles_cost = dplyr::if_else({{ hb_var }} == "S08000028", {{ cost_var }}, 0),
      NHS_Fife_cost = dplyr::if_else({{ hb_var }} == "S08000029", {{ cost_var }}, 0),
      NHS_Tayside_cost = dplyr::if_else({{ hb_var }} == "S08000030", {{ cost_var }}, 0),
      NHS_Greater_Glasgow_and_Clyde_cost = dplyr::if_else({{ hb_var }} %in% c("S08000031", "S08000021"), {{ cost_var }}, 0),
      NHS_Lanarkshire_cost = dplyr::if_else({{ hb_var }} %in% c("S08000032", "S08000023"), {{ cost_var }}, 0)
    )
}
