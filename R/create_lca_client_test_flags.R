#' Create LCA test flags
#'
#' @description Create flags for Local Authorities
#'
#' @param data the data containing an LCA variable
#' @param lca_var LCA variable e.g. CA2019, CA2011
#'
#' @return a dataframe with flag (1 or 0) for each LCA
#'
#' @family flag functions
create_lca_client_test_flags <- function(data, lca_var) {
  data %>%
    dplyr::mutate(
      Aberdeen_City_clients = {{ lca_var }} %in% c("S12000033", "01"),
      Aberdeenshire_clients = {{ lca_var }} %in% c("S12000034", "02"),
      Angus_clients = {{ lca_var }} %in% c("S12000041", "03"),
      Argyll_and_Bute_clients = {{ lca_var }} %in% c("S12000035", "04"),
      City_of_Edinburgh_clients = {{ lca_var }} %in% c("S12000036", "14"),
      Clackmannanshire_clients = {{ lca_var }} %in% c("S12000005", "06"),
      Dumfries_and_Galloway_clients = {{ lca_var }} %in% c("S12000006", "08"),
      Dundee_City_clients = {{ lca_var }} %in% c("S12000042", "09"),
      East_Ayrshire_clients = {{ lca_var }} %in% c("S12000008", "10"),
      East_Dunbartonshire_clients = {{ lca_var }} %in% c("S12000045", "11"),
      East_Lothian_clients = {{ lca_var }} %in% c("S12000010", "12"),
      East_Renfrewshire_clients = {{ lca_var }} %in% c("S12000011", "13"),
      Falkirk_clients = {{ lca_var }} %in% c("S12000014", "15"),
      Fife_clients = {{ lca_var }} %in% c("S12000047", "S12000015", "16"),
      Glasgow_City_clients = {{ lca_var }} %in% c("S12000046", "S12000049", "17"),
      Highland_clients = {{ lca_var }} %in% c("S12000017", "18"),
      Inverclyde_clients = {{ lca_var }} %in% c("S12000018", "19"),
      Midlothian_clients = {{ lca_var }} %in% c("S12000019", "20"),
      Moray_clients = {{ lca_var }} %in% c("S12000020", "21"),
      Na_h_Eileanan_Siar_clients = {{ lca_var }} %in% c("S12000013", "32"),
      North_Ayrshire_clients = {{ lca_var }} %in% c("S12000021", "22"),
      North_Lanarkshire_clients = {{ lca_var }} %in% c("S12000044", "S12000050", "23"),
      Orkney_Islands_clients = {{ lca_var }} %in% c("S12000023", "24"),
      Perth_and_Kinross_clients = {{ lca_var }} %in% c("S12000024", "S12000048", "25"),
      Renfrewshire_clients = {{ lca_var }} %in% c("S12000038", "26"),
      Scottish_Borders_clients = {{ lca_var }} %in% c("S12000026", "05"),
      Shetland_Islands_clients = {{ lca_var }} %in% c("S12000027", "27"),
      South_Ayrshire_clients = {{ lca_var }} %in% c("S12000028", "28"),
      South_Lanarkshire_clients = {{ lca_var }} %in% c("S12000029", "29"),
      Stirling_clients = {{ lca_var }} %in% c("S12000030", "30"),
      West_Dunbartonshire_clients = {{ lca_var }} %in% c("S12000039", "07"),
      West_Lothian_clients = {{ lca_var }} %in% c("S12000040", "31")
    )
}
