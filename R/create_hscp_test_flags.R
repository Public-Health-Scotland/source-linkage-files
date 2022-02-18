#' Create HSCP test flags
#'
#' @param data the data containing a HSCP variable
#' @param hscp_var HSCP variable e.g. HSCP2019 HSCP2018
#'
#' @return a dataframe with flag (1 or 0) for each HSCP
#' @export
#' @importFrom dplyr mutate if_else
#' @family create test flags functions
create_hscp_test_flags <- function(data, hscp_var) {
  data <- data %>%
    mutate(
      Aberdeen_City = if_else({{ hscp_var }} == "S37000001", 1, 0),
      Aberdeenshire = if_else({{ hscp_var }} == "S37000002", 1, 0),
      Angus = if_else({{ hscp_var }} == "S37000003", 1, 0),
      Argyll_and_Bute = if_else({{ hscp_var }} == "S37000004", 1, 0),
      Clackmannanshire_and_Stirling = if_else({{ hscp_var }} == "S37000005", 1, 0),
      Dumfries_and_Galloway = if_else({{ hscp_var }} == "S37000006", 1, 0),
      Dundee_City = if_else({{ hscp_var }} == "S37000007", 1, 0),
      East_Ayrshire = if_else({{ hscp_var }} == "S37000008", 1, 0),
      East_Dunbartonshire = if_else({{ hscp_var }} == "S37000009", 1, 0),
      East_Lothian = if_else({{ hscp_var }} == "S37000010", 1, 0),
      East_Renfrewshire = if_else({{ hscp_var }} == "S37000011", 1, 0),
      Edinburgh = if_else({{ hscp_var }} == "S37000012", 1, 0),
      Falkirk = if_else({{ hscp_var }} == "S37000013", 1, 0),
      Highland = if_else({{ hscp_var }} == "S37000016", 1, 0),
      Inverclyde = if_else({{ hscp_var }} == "S37000017", 1, 0),
      Midlothian = if_else({{ hscp_var }} == "S37000018", 1, 0),
      Moray = if_else({{ hscp_var }} == "S37000019", 1, 0),
      North_Ayrshire = if_else({{ hscp_var }} == "S37000020", 1, 0),
      Orkney_Islands = if_else({{ hscp_var }} == "S37000022", 1, 0),
      Renfrewshire = if_else({{ hscp_var }} == "S37000024", 1, 0),
      Scottish_Borders = if_else({{ hscp_var }} == "S37000025", 1, 0),
      Shetland_Islands = if_else({{ hscp_var }} == "S37000026", 1, 0),
      South_Ayrshire = if_else({{ hscp_var }} == "S37000027", 1, 0),
      South_Lanarkshire = if_else({{ hscp_var }} == "S37000028", 1, 0),
      West_Dunbartonshire = if_else({{ hscp_var }} == "S37000029", 1, 0),
      West_Lothian = if_else({{ hscp_var }} == "S37000030", 1, 0),
      Western_Isles = if_else({{ hscp_var }} == "S37000031", 1, 0),
      Fife = if_else({{ hscp_var }} == "S37000032", 1, 0),
      Perth_and_Kinross = if_else({{ hscp_var }} == "S37000033", 1, 0),
      Glasgow_City = if_else({{ hscp_var }} %in% c("S37000015", "S37000034"), 1, 0),
      North_Lanarkshire = if_else({{ hscp_var }} %in% c("S37000021", "S37000035"), 1, 0)
    )
}
