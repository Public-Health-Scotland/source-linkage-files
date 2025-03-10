library(targets)
library(createslf)

# use tar_make() to run targets for all years
# This will run everything needed for creating the episode file.
tar_make_future()

createslf::combine_tests()
