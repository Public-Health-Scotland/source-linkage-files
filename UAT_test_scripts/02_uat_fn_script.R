# Read in Test data
sdl_data <- as_tibble(dbGetQuery(
  denodo_connect,
  glue::glue("select * from sdl.{sdl_name} LIMIT 100")
))

# Read boxi data
boxi_data <- get(fn_name)(year = "1920")

# Read denodo variables for renaming SLF variables
denodo_vars <- readxl::read_excel(get_slf_variable_lookup(),
  sheet = dataset_name
)


#-------------------------------------------------------------------------------

## Create Output --------
dataset_output <- create_uat_output(
  dataset_name = dataset_name,
  boxi_data = boxi_data,
  sdl_data = sdl_data,
  denodo_vars = denodo_vars
)

## Write to Excel workbook
dataset_output %>%
  write_uat_tests(
    sheet_name = dataset_name,
    analyst = analyst
  )

# End of Script #
