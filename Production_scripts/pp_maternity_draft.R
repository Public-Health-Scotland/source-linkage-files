#####################################################
# Draft pre processing code for Maternity
# Author: Jennifer Thom
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input - Maternity.csv from BOXI
# Description - Preprocessing of Maternity raw BOXI file.
#              Tidy up file in line with SLF format
#              prior to processing.
#####################################################

year <- "1920"

# Load extract file
maternity_file <- read_csv(
  file = get_boxi_extract_path(year, "Maternity"), n_max = 20000),
  col_type = cols(
    `Costs Financial Year` = col_integer(),
    `Date of Admission Full Date` = col_date(format = "%Y/%m/%d %T"),
    `Date of Discharge Full Date` = col_date(format = "%Y/%m/%d %T"),
    `Pat UPI [C]` = col_character(),
    `Pat Date Of Birth [C]` = col_date(format = "%Y/%m/%d %T"),
    `Practice Location Code` = col_integer(),
    `Pat Date Of Birth [C]` = col_date(format = "%Y/%m/%d %T"),
    `Practice Location Code` = col_character(),
    `Practice NHS Board Code - current` = col_character(),
    `Geo Postcode [C]` = col_character(),
    `NHS Board of Residence Code - current` = col_character(),
    `HSCP of Residence Code - current` = col_character(),
    `Geo Council Area Code` = col_character(),
    `Treatment Location Code` = col_character(),
    `Treatment NHS Board Code - current` = col_character(),
    `Occupied Bed Days` = col_integer(),
    `Specialty Classification 1/4/97 Code` = col_double(),
    `Significant Facility Code` = col_character(),
    `Consultant/HCP Code` = col_character(),
    `Management of Patient Code` = col_character(),
    `Admission Reason Code` = col_integer(),
    `Admitted/Transfer from Code (new)` = col_integer(),
    `Admitted/transfer from - Location Code` = col_integer(),
    `Discharge Type Code` = col_integer(),
    `Discharge/Transfer to Code (new)` = col_integer(),
    `Discharged to - Location Code` = col_integer(),
    `Condition On Discharge Code` = col_integer(),
    `Continuous Inpatient Journey Marker` = col_integer(),
    `CIJ Planned Admission Code` = col_integer(),
    `CIJ Inpatient Day Case Identifier Code` = col_character(),
    `CIJ Type of Admission Code` = col_integer(),
    `CIJ Admission Specialty Code` = col_character(),
    `CIJ Discharge Specialty Code` = col_character(),
    `CIJ Start Date` = col_character(),
    `CIJ End Date` = col_character(),
    `Total Net Costs` = col_integer(),
    `Diagnosis 1 Discharge Code` = col_character(),
    `Diagnosis 2 Discharge Code` = col_character(),
    `Diagnosis 3 Discharge Code` = col_character(),
    `Diagnosis 4 Discharge Code` = col_character(),
    `Diagnosis 5 Discharge Code` = col_character(),
    `Diagnosis 6 Discharge Code` = col_character(),
    `Operation 1A Code` = col_character(),
    `Operation 2A Code` = col_character(),
    `Operation 2A Code` = col_character(),
    `Operation 4A Code` = col_character(),
    `Date of Main Operation Full Date` = col_date(format = "%Y/%m/%d %T"),
    `Age at Midpoint of Financial Year` = col_integer(),
    `NHS Hospital Flag` = col_character(),
    `Community Hospital Flag` = col_character(),
    `Alcohol Related AdmissioN` = col_character(),
    `Substance Misuse Related Admission` = col_character(),
    `Falls Related Admission` = col_character(),
    `Self Harm Related Admission` = col_character(),
    `Maternity Unique Record Identifier [C]` = col_integer()
  )
)
names(maternity_file) <- str_replace_all(names(maternity_file), " ", "_")
