#' Create HSCP test flags
#'
#' @description Create flags for Health & Social Care Partnerships
#'
#' @param data the data containing a HSCP variable
#' @param hscp_var HSCP variable e.g. HSCP2019 HSCP2018
#'
#' @return a dataframe with flag (TRUE or FALSE) for each HSCP
#'
#' @family flag functions
create_hscp_test_flags <- function(data, hscp_var) {
  data <- data %>%
    dplyr::mutate(
      Aberdeen_City = {{ hscp_var }} == "S37000001",
      Aberdeenshire = {{ hscp_var }} == "S37000002",
      Angus = {{ hscp_var }} == "S37000003",
      Argyll_and_Bute = {{ hscp_var }} == "S37000004",
      Clackmannanshire_and_Stirling = {{ hscp_var }} == "S37000005",
      Dumfries_and_Galloway = {{ hscp_var }} == "S37000006",
      Dundee_City = {{ hscp_var }} == "S37000007",
      East_Ayrshire = {{ hscp_var }} == "S37000008",
      East_Dunbartonshire = {{ hscp_var }} == "S37000009",
      East_Lothian = {{ hscp_var }} == "S37000010",
      East_Renfrewshire = {{ hscp_var }} == "S37000011",
      Edinburgh = {{ hscp_var }} == "S37000012",
      Falkirk = {{ hscp_var }} == "S37000013",
      Highland = {{ hscp_var }} == "S37000016",
      Inverclyde = {{ hscp_var }} == "S37000017",
      Midlothian = {{ hscp_var }} == "S37000018",
      Moray = {{ hscp_var }} == "S37000019",
      North_Ayrshire = {{ hscp_var }} == "S37000020",
      Orkney_Islands = {{ hscp_var }} == "S37000022",
      Renfrewshire = {{ hscp_var }} == "S37000024",
      Scottish_Borders = {{ hscp_var }} == "S37000025",
      Shetland_Islands = {{ hscp_var }} == "S37000026",
      South_Ayrshire = {{ hscp_var }} == "S37000027",
      South_Lanarkshire = {{ hscp_var }} == "S37000028",
      West_Dunbartonshire = {{ hscp_var }} == "S37000029",
      West_Lothian = {{ hscp_var }} == "S37000030",
      Western_Isles = {{ hscp_var }} == "S37000031",
      Fife = {{ hscp_var }} == "S37000032",
      Perth_and_Kinross = {{ hscp_var }} == "S37000033",
      Glasgow_City = {{ hscp_var }} %in% c("S37000015", "S37000034"),
      North_Lanarkshire = {{ hscp_var }} %in% c("S37000021", "S37000035"),
    )
}
