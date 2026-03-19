devtools::load_all(".")
source("tools/audit_tidyverse_deprecations.R")

res <- audit_tidyverse_deprecations(
  root = "R",
  output_csv = "tools/tidyverse_deprecation_audit.csv"
)
