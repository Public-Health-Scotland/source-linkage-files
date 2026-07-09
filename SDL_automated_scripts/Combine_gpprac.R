# Combine GP practice reference files
#
# Original Author - Zihao Li
# Original Date - June 2026
# Written/run on - R Posit
# Version of R - 4.5.1


# Stage 1 - Setup environment ------------------
# load package
devtools::load_all()

# Define the source directory and financial year pattern
gpprac_ref_path = get_gpprac_ref_path()
print(stringr::str_glue("Use {gpprac_ref_path}"))

## Stage 2 - Read and clean columns before binding ---------------
gpprac_ref_file <- read_file(path = gpprac_ref_path) %>%
  dplyr::select(
    "gpprac" = "praccode",
    "pc7" = "postcode"
  ) %>%
  # Ensure all postcodes are strictly pc7 format
  dplyr::mutate(
    pc7 = phsmethods::format_postcode(.data$pc7, format = "pc7")
  )

## Stage 3 - Bind files together and save to disk -----------
gpprac_ref_file %>%
  write_file(get_sdl_gpprac_lookup_path(check_mode = "write"))
