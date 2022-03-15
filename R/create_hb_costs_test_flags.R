#' Create Health Board Cost test flags
#'
#' @param data the data containing a health board variable e.g. HB2019
#' @param cost_var cost to be entered into the health board cost e.g cost_total_net
#'
#' @return a dataframe with flag (1 or 0) for each Health Board
#' @export
#' @importFrom dplyr mutate if_else
#' @family create test flags functions
create_hb_costs_test_flags <- function(data, cost_var) {
  data <- data %>%
    mutate(
      NHS_Ayrshire_and_Arran_cost = if_else(NHS_Ayrshire_and_Arran == 1, {{ cost_var }}, 0),
      NHS_Borders_cost = if_else(NHS_Borders == 1, {{ cost_var }}, 0),
      NHS_Dumfries_and_Galloway_cost = if_else(NHS_Dumfries_and_Galloway == 1, {{ cost_var }}, 0),
      NHS_Forth_Valley_cost = if_else(NHS_Forth_Valley == 1, {{ cost_var }}, 0),
      NHS_Grampian_cost = if_else(NHS_Grampian == 1, {{ cost_var }}, 0),
      NHS_Highland_cost = if_else(NHS_Highland == 1, {{ cost_var }}, 0),
      NHS_Lothian_cost = if_else(NHS_Lothian == 1, {{ cost_var }}, 0),
      NHS_Orkney_cost = if_else(NHS_Orkney == 1, {{ cost_var }}, 0),
      NHS_Shetland_cost = if_else(NHS_Shetland == 1, {{ cost_var }}, 0),
      NHS_Western_Isles_cost = if_else(NHS_Western_Isles == 1, {{ cost_var }}, 0),
      NHS_Fife_cost = if_else(NHS_Fife == 1, {{ cost_var }}, 0),
      NHS_Tayside_cost = if_else(NHS_Tayside == 1, {{ cost_var }}, 0),
      NHS_Greater_Glasgow_and_Clyde_cost = if_else(NHS_Greater_Glasgow_and_Clyde == 1, {{ cost_var }}, 0),
      NHS_Lanarkshire_cost = if_else(NHS_Lanarkshire == 1, {{ cost_var }}, 0)
    )
}
