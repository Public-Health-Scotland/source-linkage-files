################################################################################
# Name of file - uat_descriptive_stats.R
#
# Original Authors - Oluwatobi Oni
# Original Date - January 2026
# Written/run on - R Posit
# Version of R - 4.4.2
#
# Description: Functions used to support the BYOC UAT tests.
#
################################################################################

library(openxlsx)
library(dplyr)

devtools::load_all()

# 1. Define the lists to loop through
years <- c("1415", "1516", "1617", "1718", "1819", "1920", "2021", "2122", "2223", "2324", "2425", "2526")
types <- c("acute", "ae", "at", "ch", "cmh", "dd", "deaths", "dn", "gp_ooh", "hc", "homelessness", "maternity", "mh", "outpatients", "pis", "sds")
# removed "client" from types as "anon-client_for_source_" is not present in sourcedev.

# 2. Create an empty list to hold the results
results_list <- list()

# 3. Start the loop
for (t in types) {
  for (y in years) {
    # Check if data type is available for the financial year
    is_valid <- check_year_valid(year = y, type = t)

    if (is_valid == FALSE) {
      message("Skipping: ", t, " for fy ", y, " (No data available)")
      next
    }

    message("Currently processing: ", t, " for fy ", y)

    # Get the file path and read the data
    file_path <- get_source_extract_path(y, type = t)
    data <- read_file(file_path)

    # Descriptive Statistics Calculations
    rows <- nrow(data)
    cols <- ncol(data)
    nas <- sum(is.na(data))
    prop <- nas / (rows * cols)

    # Store the results
    results_list[[paste(t, y)]] <- data.frame(
      Dataset = t,
      FY = y,
      Number_of_Rows = rows,
      Number_of_Columns = cols,
      Proportion_of_NA = prop
    )

    # Remove the big data object and clean memory before the next loop to save memory
    rm(data)
    gc()
  }
}

# 4. Combine all the small results into one big table
final_table <- do.call(rbind, results_list)

# 5. Save to Excel
write.xlsx(final_table, "/conf/sourcedev/Source_Linkage_File_Updates/uat_testing/4_dataset_testing/UAT_support.xlsx", sheetName = "UAT support")

message("Descriptive statistics complete. File saved to: /conf/sourcedev/Source_Linkage_File_Updates/uat_testing/4_dataset_testing/UAT_support.xlsx")

