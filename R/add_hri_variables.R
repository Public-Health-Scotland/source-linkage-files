#' Flag non-Scottish residents
#'
#' @details The variable keep flag can be in the range c(0:4) where
#' \itemize{
#' \item{keep_flag = 0 when resident is Scottish}
#' \item{keep_flag = 1 when resident is not Scottish}
#' \item{keep_flag = 2 when the postcode is missing or a dummy, and the gpprac is missing}
#' \item{keep_flag = 3 when the gpprac is not English and the postcode is missing}
#' \item{keep_flag = 4 when the gpprac is not English and the postcode is a dummy}
#' }
#' The intention is to only keep the records where keep_flag = 0
#'
#' @inheritParams add_hri_variables
#'
#' @return A data frame with the variable 'keep_flag'
flag_non_scottish_residents <- function(
    data,
    slf_pc_lookup) {
  check_variables_exist(data, c("postcode", "gpprac"))

  # Make a lookup of postcode areas, which consist of the first characters
  # of the postcode
  pc_areas <- slf_pc_lookup %>%
    dplyr::mutate(
      pc_area = stringr::str_match(.data$postcode, "^[A-Z]{1,3}"),
      scot_flag = TRUE
    ) %>%
    dplyr::distinct(.data$pc_area, .data$scot_flag)

  # Create a flag, 'keep_flag', to determine whether individuals are Scottish
  # residents or not
  return_data <- data %>%
    dplyr::mutate(pc_area = stringr::str_match(.data$postcode, "^[A-Z]{1,3}")) %>%
    dplyr::left_join(pc_areas, by = "pc_area") %>%
    dplyr::mutate(
      dummy_postcode = .data$postcode %in% c("BF010AA", "NF1 1AB", "NK010AA") |
        stringr::str_sub(.data$postcode, 1, 4) %in% c("ZZ01", "ZZ61"),
      eng_prac = .data$gpprac %in% c(99942, 99957, 99961, 99976, 99981, 99995, 99999),
      scottish_resident = dplyr::case_when(
        .data$scot_flag ~ 0L,
        (is_missing(.data$postcode) | .data$dummy_postcode) & is.na(.data$gpprac) ~ 2L,
        !.data$eng_prac & is_missing(.data$postcode) ~ 3L,
        !.data$eng_prac & .data$dummy_postcode ~ 4L,
        .default = 1L
      )
    ) %>%
    dplyr::select(-"dummy_postcode", -"eng_prac")

  cli::cli_alert_info("Add HRI variables function finished at {Sys.time()}")

  return(return_data)
}

#' Add HRI variables to an SLF Individual File
#'
#' @details Filters the dataset to only include Scottish residents, then
#' creates a lookup where HRIs are calculated at Scotland, Health Board, and
#' LCA level. Then joins on this lookup by chi/anon_chi.
#'
#' @param data An SLF individual file.
#' @param slf_pc_lookup The Source postcode lookup, defaults
#' to [get_slf_postcode_path()] read using [read_file()].
#' @param chi_variable string, claiming chi or anon_chi.
#'
#' @return The individual file with HRI variables matched on
#' @export
add_hri_variables <- function(
    data,
    chi_variable = "chi",
    slf_pc_lookup = read_file(
      get_slf_postcode_path(),
      col_select = "postcode"
    )) {
  hri_lookup <- data %>%
    dplyr::select(
      "year",
      chi_variable,
      "postcode",
      "gpprac",
      "lca",
      "hbrescode",
      "health_net_cost",
      "acute_episodes",
      "mat_episodes",
      "mh_episodes",
      "gls_episodes",
      "op_newcons_attendances",
      "op_newcons_dnas",
      "ae_attendances",
      "pis_paid_items",
      "ooh_cases"
    ) %>%
    flag_non_scottish_residents(slf_pc_lookup = slf_pc_lookup) %>%
    dplyr::filter(.data$scottish_resident == 0L) %>%
    # Scotland cost and proportion
    dplyr::mutate(
      scotland_cost = sum(.data$health_net_cost),
      scotland_pct = (.data$health_net_cost / .data$scotland_cost) * 100
    ) %>%
    dplyr::arrange(dplyr::desc(.data$health_net_cost)) %>%
    dplyr::mutate(hri_scotp = cumsum(.data$scotland_pct)) %>%
    # Health Board
    dplyr::group_by(.data$hbrescode) %>%
    dplyr::mutate(
      hb_cost = sum(.data$health_net_cost),
      hb_pct = (.data$health_net_cost / .data$hb_cost) * 100
    ) %>%
    dplyr::arrange(dplyr::desc(.data$health_net_cost), .by_group = TRUE) %>%
    dplyr::mutate(hri_hbp = cumsum(.data$hb_pct)) %>%
    dplyr::ungroup() %>%
    # LCA
    dplyr::group_by(.data$lca) %>%
    dplyr::mutate(
      lca_cost = sum(.data$health_net_cost),
      lca_pct = (.data$health_net_cost / .data$lca_cost) * 100
    ) %>%
    dplyr::arrange(dplyr::desc(.data$health_net_cost), .by_group = TRUE) %>%
    dplyr::mutate(hri_lcap = cumsum(.data$lca_pct)) %>%
    dplyr::ungroup() %>%
    # Add HRI flags
    dplyr::mutate(
      hri_scot = .data$hri_scotp <= 50.0,
      hri_hb = .data$hri_hbp <= 50.0,
      hri_lca = .data$hri_lcap <= 50.0,
      # Deal with potential missing variables
      hri_hb = dplyr::if_else(is_missing(.data$hbrescode), FALSE, .data$hri_hb),
      hri_hbp = dplyr::if_else(is_missing(.data$hbrescode), NA, .data$hri_hbp),
      hri_lca = dplyr::if_else(is_missing(.data$lca), FALSE, .data$hri_lca),
      hri_lcap = dplyr::if_else(is_missing(.data$lca), NA, .data$hri_lcap)
    ) %>%
    # Select only required variables for the lookup
    dplyr::select(
      chi_variable,
      "hri_scot",
      "hri_scotp",
      "hri_hb",
      "hri_hbp",
      "hri_lca",
      "hri_lcap"
    )

  return_data <- dplyr::left_join(data, hri_lookup, by = chi_variable)

  return(return_data)
}
