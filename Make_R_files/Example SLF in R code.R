### Notes  ----
# Whilst this format does allow MUCH faster reading and processing
# the files are still very large, this means that, unless you read
# a very small subset this will have to be done on the RStudio server
# http://nssrstudio.csa.scot.nhs.uk/
# The RStudio server is a shared resource so please make sure to
# remove objects you don't need with rm(<object name>) and try to filter
# and cut down the objects as much as possible.



### Set up ----
# Install the fst package from CRAN
# Only needed the first time
install.packages("fst") # At present you will need V0.9.0 or greater

# Load the fst package
library(fst)


### Reading ----
# Read a SLF
slf_dir = "/conf/hscdiip/01-Source-linkage-files"
ep_1718 <- read_fst(file.path(slf_dir, "source-episode-file-201718.fst"))


# fst allows selective reading of rows and columns
# the less you read in the faster it will be

# Read certain columns only
slf_dir = "/conf/hscdiip/01-Source-linkage-files"
ep_1718 <- read_fst(file.path(slf_dir, "source-episode-file-201718.fst"),
                    columns = c("anon_chi", "dob", "demographic_cohort"))

# Drop (don't read) certain columns
slf_dir = "/conf/hscdiip/01-Source-linkage-files"
ep_1718 <- read_fst(file.path(slf_dir, "source-episode-file-201718.fst"),
                    columns = c("anon_chi", "dob", "demographic_cohort"))

# Read a subset of rows
# possibly useful for testing code on a small dataset
# however bear in mind that the data is sorted by Anon_CHI
# so blanks will be at the top of the episode file
slf_dir = "/conf/hscdiip/01-Source-linkage-files"
ep_1718 <- read_fst(file.path(slf_dir, "source-episode-file-201718.fst"),
                    from = 100000, to = 200000)

# In all of the examples above the resulting object 'ep_1718' will be a tibble
# Remember to remove the object as soon asyou have finshed to free up the memory for others
rm(ep_1718)

### Writing ----

# If you need to save data to file and you want to use the fst format
# remember to use full compression and delete when no longer needed
write_fst(ep_1718, "path", compress = 100)
