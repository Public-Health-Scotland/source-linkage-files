library(targets)

year <- "2021"

# use targets for the process until testing episode files
tar_make_future(
  # it does not recognise `contains(year)`
  names = (targets::contains("2021"))
)

