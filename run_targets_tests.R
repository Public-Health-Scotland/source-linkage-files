library(targets)
tar_make_future(
  names = (targets::starts_with("tests_"))
)

tar_make(
  names = (targets::contains("1718"))
)
set.seed()

sort(tar_outdated(reporter = "forecast"))
tar_make_future()
tar_visnetwork(
  targets_only = TRUE,
  level_separation = 750,
  degree_from = 3,
  degree_to = 3,
  label = c("time", "size")
)
tar_meta()

tar_prune()
tar_delete()
tar_invalidate()


reader <- arrow::ParquetFileReader$create(slf_path)
reader$GetSchema()

years <- c("2223")
purrr::walk(
  years,
  function(year) {
    code <- readr::read_lines("run_targets_1718.R")

    new_code <- stringr::str_replace(code, stringr::fixed("1718"), year)

    path <- stringr::str_glue("run_targets_{year}.R")

    readr::write_lines(new_code, path)
  }
)
