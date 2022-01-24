#' Function for reading in all care home episodes
#'
#' @param update Latest update or previous update
#'
#' @return The care home episodes file
#' @export
get_all_ch_episodes_path <- function(update = latest_update()) {

  file_name = "all_ch_episodes"

  all_ch_episodes_path <- fs::path(
    get_slf_dir(),
    "Social_care",
    paste0(file_name, update)
  )

  all_ch_episodes_path <- fs::path_ext_set(
    all_ch_episodes_path,
    "zsav"
  )

  return(all_ch_episodes_path )
}
