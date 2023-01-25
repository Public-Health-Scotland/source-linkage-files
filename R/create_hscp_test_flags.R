#' Create HSCP test flags
#'
#' @description Create flags for Health & Social Care Partnerships
#'
#' @param data the data containing a HSCP variable
#' @param hscp_var HSCP variable e.g. HSCP2019 HSCP2018
#'
#' @return a dataframe with flag (1 or 0) for each HSCP
#' @export
#' @family flag functions
create_hscp_test_flags <- function(data, hscp_var) {
  data <- data %>%
    dplyr::mutate(
      Aberdeen_City = dplyr::if_else(
        {{ hscp_var }} == "S37000001",
        1L,
        0L
      ),
      Aberdeenshire = dplyr::if_else(
        {{ hscp_var }} == "S37000002",
        1L,
        0L
      ),
      Angus = dplyr::if_else(
        {{ hscp_var }} == "S37000003",
        1L,
        0L
      ),
      Argyll_and_Bute = dplyr::if_else(
        {{ hscp_var }} == "S37000004",
        1L,
        0L
      ),
      Clackmannanshire_and_Stirling = dplyr::if_else(
        {{ hscp_var }} == "S37000005",
        1L,
        0L
      ),
      Dumfries_and_Galloway = dplyr::if_else(
        {{ hscp_var }} == "S37000006",
        1L,
        0L
      ),
      Dundee_City = dplyr::if_else(
        {{ hscp_var }} == "S37000007",
        1L,
        0L
      ),
      East_Ayrshire = dplyr::if_else(
        {{ hscp_var }} == "S37000008",
        1L,
        0L
      ),
      East_Dunbartonshire = dplyr::if_else(
        {{ hscp_var }} == "S37000009",
        1L,
        0L
      ),
      East_Lothian = dplyr::if_else(
        {{ hscp_var }} == "S37000010",
        1L,
        0L
      ),
      East_Renfrewshire = dplyr::if_else(
        {{ hscp_var }} == "S37000011",
        1L,
        0L
      ),
      Edinburgh = dplyr::if_else(
        {{ hscp_var }} == "S37000012",
        1L,
        0L
      ),
      Falkirk = dplyr::if_else(
        {{ hscp_var }} == "S37000013",
        1L,
        0L
      ),
      Highland = dplyr::if_else(
        {{ hscp_var }} == "S37000016",
        1L,
        0L
      ),
      Inverclyde = dplyr::if_else(
        {{ hscp_var }} == "S37000017",
        1L,
        0L
      ),
      Midlothian = dplyr::if_else(
        {{ hscp_var }} == "S37000018",
        1L,
        0L
      ),
      Moray = dplyr::if_else(
        {{ hscp_var }} == "S37000019",
        1L,
        0L
      ),
      North_Ayrshire = dplyr::if_else(
        {{ hscp_var }} == "S37000020",
        1L,
        0L
      ),
      Orkney_Islands = dplyr::if_else(
        {{ hscp_var }} == "S37000022",
        1L,
        0L
      ),
      Renfrewshire = dplyr::if_else(
        {{ hscp_var }} == "S37000024",
        1L,
        0L
      ),
      Scottish_Borders = dplyr::if_else(
        {{ hscp_var }} == "S37000025",
        1L,
        0L
      ),
      Shetland_Islands = dplyr::if_else(
        {{ hscp_var }} == "S37000026",
        1L,
        0L
      ),
      South_Ayrshire = dplyr::if_else(
        {{ hscp_var }} == "S37000027",
        1L,
        0L
      ),
      South_Lanarkshire = dplyr::if_else(
        {{ hscp_var }} == "S37000028",
        1L,
        0L
      ),
      West_Dunbartonshire = dplyr::if_else(
        {{ hscp_var }} == "S37000029",
        1L,
        0L
      ),
      West_Lothian = dplyr::if_else(
        {{ hscp_var }} == "S37000030",
        1L,
        0L
      ),
      Western_Isles = dplyr::if_else(
        {{ hscp_var }} == "S37000031",
        1L,
        0L
      ),
      Fife = dplyr::if_else(
        {{ hscp_var }} == "S37000032",
        1L,
        0L
      ),
      Perth_and_Kinross = dplyr::if_else(
        {{ hscp_var }} == "S37000033",
        1L,
        0L
      ),
      Glasgow_City = dplyr::if_else(
        {{ hscp_var }} %in% c("S37000015", "S37000034"),
        1L,
        0L
      ),
      North_Lanarkshire = dplyr::if_else(
        {{ hscp_var }} %in% c("S37000021", "S37000035"),
        1L,
        0L
      )
    )
}
