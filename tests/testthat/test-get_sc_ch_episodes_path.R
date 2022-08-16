skip_on_ci()

test_that("SC care home episodes file path works", {
  expect_s3_class(get_sc_ch_episodes_path(), "fs_path")
  expect_s3_class(get_sc_ch_episodes_path(update = previous_update(), ext = "zsav"), "fs_path")
})
