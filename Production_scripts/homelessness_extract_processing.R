library(createslf)
library(purrr)

map(convert_year_to_fyyear(2017:2021), process_homelessness_extract)

