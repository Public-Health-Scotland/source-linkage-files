skip_on_ci()

test_that("SC care home episodes file path works", {
  expect_s3_class(get_sc_ch_episodes_path(), "fs_path")
  expect_s3_class(
    get_sc_ch_episodes_path(update = previous_update()),
    "fs_path"
  )
})

test_that("SC home care episodes file path works", {
  expect_s3_class(get_sc_hc_episodes_path(), "fs_path")
  expect_s3_class(
    get_sc_hc_episodes_path(update = previous_update()),
    "fs_path"
  )
})

test_that("SC alarms telecare episodes file path works", {
  expect_s3_class(get_sc_at_episodes_path(), "fs_path")
  expect_s3_class(
    get_sc_at_episodes_path(update = previous_update()),
    "fs_path"
  )
})

test_that("SC SDS episodes file path works", {
  expect_s3_class(get_sc_sds_episodes_path(), "fs_path")
  expect_s3_class(
    get_sc_sds_episodes_path(update = previous_update()),
    "fs_path"
  )
})
