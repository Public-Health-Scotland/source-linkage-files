################################################################################ .
# Script to print the results of the tidyverse deprecation audit for GitHub Issue
################################################################################

# Read in audit
audit <- read_csv("tools/tidyverse_deprecation_audit.csv")

# Filter for each type of script (these will be edited on different branches)
read_scripts <- audit %>% filter(str_starts(file, "R/read_"))
process_scripts <- audit %>% filter(str_starts(file, "R/process_") & !str_starts(file, "R/process_tests"))
test_scripts <- audit %>% filter(str_starts(file, "R/process_tests"))
ep_ind <- audit %>% filter(file %in% c("R/create_episode_file.R", "R/create_individual_file.R"))
other_scripts <- audit %>% anti_join(bind_rows(read_scripts, process_scripts, test_scripts, ep_ind))

# Function to pring the audit results (file name + number and type of deprecation messages)
print_audit <- function(df, type) {
  message(paste("**Depreciation detected in", length(unique(df$file)), type, "scripts**\n\n"))
  for (script in unique(df$file)) {
    tbl <- data.frame(table((df %>% filter(file == script))$suggestion))
    message(paste0("**File Name:** ", str_extract(script, "(?<=/)[^.]+")))
    message(paste0("**Deprecation message(s):**"))
    message(paste0("- ", tbl$Var1, " (x", tbl$Freq, ")\n"))
  }
}

# Use function to print audit for each type of script
print_audit(read_scripts, "'read'")
print_audit(process_scripts, "'process'")
print_audit(test_scripts, "'test'")
print_audit(ep_ind, "episode/individual")
print_audit(other_scripts, "other")
