################################################################################.
# Function to convert column data type
################################################################################.

convert_types <- function(df, mapping) {
  for (i in seq_len(nrow(mapping))) {
    # Get the column name from the lookup
    column <- mapping$old_colname[i]
    # Skip if the column does not exist
    if (!column %in% names(df)) {next}
    # Set the target data type
    target_type <- mapping$data_type[i]
    # Skip conversion if no type supplied
    if (is.na(target_type) || target_type == "") {next}
    # Convert data type
    df[[column]] <- switch(
      target_type,
      integer = as.integer(df[[column]]),
      double = as.double(df[[column]]),
      character = as.character(df[[column]]),
      factor = as.factor(df[[column]]),
      date = as.Date(df[[column]], format = "%Y/%m/%d %H:%M:%S"),
      datetime = readr::parse_datetime(df[[column]], format = "%Y/%m/%d %H:%M:%S"),
      time = readr::parse_time(df[[column]], format = "%H:%M"),
      df[[column]]
    )
  }
  df
}

################################################################################.
# Function to read Local Data
################################################################################.

read_raw_local <- function(test_dataset, year, local_mapping){

  # Column Map
  local_test_map <- local_mapping %>%
    # Filter the local mapping for the dataset required
    filter(type == test_dataset) %>%
    # Replace spaces and special characters with . (R does this to column names automatically)
    mutate(old_colname = make.names(old_colname))

  # Data
  # Read local data
  local_data <- get_data(test_dataset, "local", year, sdl_submission = T)
  # Select columns specified in PHS code (raw name)
  local_data <- local_data %>% select(all_of(local_test_map$old_colname))
  # TODO: May need to rename IT columns with make.names
  # Convert columns to type specified in PHS code
  local_data <- local_data %>% convert_types(local_test_map)
  # Rename columns from raw to SLF
  colnames(local_data) <- local_test_map$new_colname
  # Convert to tibble
  local_data <- as_tibble(local_data)

  # Pad CHI
  chi_cols <- c("anon_chi")
  local_data <- local_data %>% mutate(across(any_of(chi_cols), phsmethods::chi_pad))
  # Replace empty strings with NA
  local_data <- local_data %>% mutate(across(where(is.character), ~ na_if(.x, "")))
  # Pad specified columns e.g. "1" --> "01"
  pad_cols <- c("lca", "ae_alcohol", "ae_arrivalmode", "ae_attendcat", "ae_bodyloc")
  local_data <- local_data %>% mutate(across(any_of(pad_cols), ~ str_pad(.x, width = 2, side = "left", pad = "0")))

  return(local_data)
}

################################################################################.
# Function to read SDL Data
################################################################################.

read_raw_sdl <- function(test_dataset, year, sdl_mapping, sdl_filters){

  # Column Map
  sdl_test_map <- sdl_mapping %>%
    # Filter the local mapping for the dataset required
    filter(type == test_dataset)

  # Filter Conditions (required for selecting a single year)
  filter_conditions <- sdl_filters %>%
    filter(dataset == test_dataset) %>%
    pull(filter)
  c_year <- convert_fyyear_to_year(year)
  f_year <- check_year_format(year)

  # Data
  # Make connection to Denodo
  denodo_connect <- get_denodo_connection()
  # Query
  sdl_data <- dplyr::tbl(
    denodo_connect,
    # Get data from the test dataset SDL table
    dbplyr::in_schema("sdl", get_sdl_raw_names(test_dataset))) %>%
    # Filter data using the filter conditions specified in PHS code
    {
      if (length(filter_conditions) > 0 &&
          !is.na(filter_conditions) &&
          nzchar(filter_conditions)) {
        dplyr::filter(., !!rlang::parse_expr(filter_conditions))
      } else {
        .
      }
    } %>%
    # Select columns specified in PHS code (raw name)
    dplyr::select(all_of(sdl_test_map$old_colname)) %>%
    # Collect
    dplyr::collect()

  # Denodo disconnect
  DBI::dbDisconnect(denodo_connect)
  # Rename columns from raw to SLF
  colnames(sdl_data) <- sdl_test_map$new_colname
  # Convert to tibble
  sdl_data <- as_tibble(sdl_data)

  return(sdl_data)
}

################################################################################.
# Function to compare local and raw data
################################################################################.

compare_data <- function(test_dataset, year, local_mapping, sdl_mapping, sdl_filters){

  # Read local data + note time
  local_data <- read_raw_local(test_dataset, year, local_mapping)
  local_time <- Sys.time() + 3600
  local_download_time <- file.info(get_local_filepath(test_dataset, year, sdl_submission = T)) %>% pull(mtime) + 3600

  # Read SDL data + note time
  sdl_data <- read_raw_sdl(test_dataset, year, sdl_mapping, sdl_filters)
  sdl_time <- Sys.time() + 3600

  # Order rows and columns as similarly as possible
  common_cols <- intersect(colnames(local_data), colnames(sdl_data))
  local_specific_cols <- setdiff(colnames(local_data), colnames(sdl_data))
  sdl_specific_cols <- setdiff(colnames(sdl_data), colnames(local_data))

  sdl_data <- sdl_data %>%
    select(all_of(common_cols), all_of(sdl_specific_cols)) %>%
    arrange(across(all_of(common_cols)))

  local_data <- local_data %>%
    select(all_of(common_cols), all_of(local_specific_cols)) %>%
    arrange(across(all_of(common_cols)))

  # Filter the column name mapping
  colname_mapping <- full_join(local_mapping, sdl_mapping, by = c("type", "new_colname")) %>%
    select(type, colname = new_colname, sdl_original_colname = old_colname.y, local_original_colname = old_colname.x,
           final_interface_spec = data_type.y)

  # Add type
  summary_df <- colname_mapping %>%
    filter(type == test_dataset)

  # Compare each column in a loop
  details_df <- data.frame()
  for(column in summary_df$colname){

    # Table comparing counts for each value in the column (local and SDL)
    if ((column %in% colnames(local_data)) && (column %in% colnames(sdl_data))) {
      match_values <- full_join(
        data.frame(table(local_data[[column]], useNA = "ifany")),
        data.frame(table(sdl_data[[column]], useNA = "ifany")),
        by = "Var1")
    } else {
      match_values <- NULL
    }

    # If the column is a factor, convert to character to work with the code below
    # This also means we don't flag factor-character mismatches
    if (column %in% colnames(local_data) && is.factor(local_data[[column]])) {
      local_data[[column]] <- as.character(local_data[[column]])
    }

    # Comparisons
    details_df <- bind_rows(
      details_df,
      data.frame(

        colname = column,
        in_local = ifelse(column %in% colnames(local_data), T, F),
        in_sdl = ifelse(column %in% colnames(sdl_data), T, F),

        min_local = ifelse(column %in% colnames(local_data), as.character(min(local_data[[column]], na.rm = TRUE)), NA),
        min_sdl = ifelse(column %in% colnames(sdl_data), as.character(min(sdl_data[[column]], na.rm = TRUE)), NA),

        max_local = ifelse(column %in% colnames(local_data), as.character(max(local_data[[column]], na.rm = TRUE)), NA),
        max_sdl = ifelse(column %in% colnames(sdl_data), as.character(max(sdl_data[[column]], na.rm = TRUE)), NA),

        median_local = ifelse(column %in% colnames(local_data), as.character(median(local_data[[column]], na.rm = TRUE)), NA),
        median_sdl = ifelse(column %in% colnames(sdl_data), as.character(median(sdl_data[[column]], na.rm = TRUE)), NA),

        mean_local = ifelse(column %in% colnames(local_data), mean(as.numeric(local_data[[column]]), na.rm = TRUE), NA),
        mean_sdl = ifelse(column %in% colnames(sdl_data), mean(as.numeric(sdl_data[[column]]), na.rm = TRUE), NA),

        sum_local = ifelse(column %in% colnames(local_data), sum(as.numeric(local_data[[column]]), na.rm = TRUE), NA),
        sum_sdl = ifelse(column %in% colnames(sdl_data), sum(as.numeric(sdl_data[[column]]), na.rm = TRUE), NA),

        local_type = ifelse(column %in% colnames(local_data), class(local_data[[column]]), NA),
        sdl_type = ifelse(column %in% colnames(sdl_data), class(sdl_data[[column]]), NA),

        total_vals_local = ifelse(column %in% colnames(local_data), length(local_data[[column]]), NA),
        total_vals_sdl = ifelse(column %in% colnames(sdl_data), length(sdl_data[[column]]), NA),

        local_na_count = ifelse(column %in% colnames(local_data), sum(is.na(local_data[[column]])), NA),
        sdl_na_count = ifelse(column %in% colnames(sdl_data), sum(is.na(sdl_data[[column]])), NA),

        unique_vals_local = ifelse(column %in% colnames(local_data), length(unique(local_data[[column]])), NA),
        unique_vals_sdl = ifelse(column %in% colnames(sdl_data), length(unique(sdl_data[[column]])), NA),
        unique_vals_mismatch = ifelse(is.null(match_values), NA, length(setdiff(local_data[[column]], sdl_data[[column]]))),
        unique_vals_with_different_counts = ifelse(is.null(match_values), NA, nrow(match_values %>% filter(Freq.x != Freq.y | is.na(Freq.x) | is.na(Freq.y))))

        #total_count_difference = ifelse(is.null(match_values), NA, sum((match_values %>% filter(Freq.x != Freq.y | is.na(Freq.x) | is.na(Freq.y)) %>% mutate(n = abs(Freq.x - Freq.y)))$n, na.rm = TRUE)),
        #n_row_mismatch_ordered = ifelse(is.null(match_values), NA, sum(local_data[[column]] != sdl_data[[column]], na.rm = TRUE))

      ))
  }

  # Helper function to return TRUE if values are the same or both NA
  equal_or_both_na <- function(x, y) {
    (x == y) | (is.na(x) & is.na(y))
  }

  # Join with the mapping dataframes
  summary_df <- summary_df %>%
    full_join(details_df, by = "colname") %>%
    mutate(
      in_both = equal_or_both_na(in_local, in_sdl),
      min_match = equal_or_both_na(min_local, min_sdl),
      max_match = equal_or_both_na(max_local, max_sdl),
      mean_match = equal_or_both_na(mean_local, mean_sdl),
      median_match = equal_or_both_na(median_local, median_sdl),
      sum_match = equal_or_both_na(sum_local, sum_sdl),
      type_match = equal_or_both_na(local_type, sdl_type),
      change_total_vals = total_vals_sdl - total_vals_local,
      perc_change_total_vals = ifelse(total_vals_sdl == 0 & total_vals_local == 0, 0, round((total_vals_sdl - total_vals_local) / total_vals_local * 100, 2)),
      change_na = sdl_na_count - local_na_count,
      perc_change_na = ifelse(sdl_na_count == 0 & local_na_count == 0, 0, round((sdl_na_count - local_na_count) / local_na_count * 100, 2)),
      change_unique_vals = unique_vals_sdl - unique_vals_local,
      perc_change_unique_vals = ifelse(unique_vals_sdl == 0 & unique_vals_local == 0, 0, round((unique_vals_sdl - unique_vals_local) / unique_vals_local * 100, 2)),
      RESULT = if_else(
        rowSums(cbind(in_both, min_match, max_match, mean_match, median_match, sum_match, type_match), na.rm = TRUE) == 7 &
          rowSums(cbind(change_total_vals, change_na, change_unique_vals, perc_change_total_vals, perc_change_na, perc_change_unique_vals, unique_vals_mismatch, unique_vals_with_different_counts), na.rm = TRUE) == 0,
        "PASS",
        "FAIL"
      ),
      sdl_time = sdl_time,
      local_time = local_time,
      download_time = local_download_time
    ) %>%
    select(-min_local, -min_sdl, -max_local, -max_sdl, -mean_local, -mean_sdl, -median_local, -median_sdl, -sum_local, -sum_sdl)

  return(summary_df)
}

################################################################################.
# Function to save as excel sheet
################################################################################.

save_as_sheet <- function(summary_df, workbook_file){

  # If the workbook already exists, load it
  wb <- if (file.exists(workbook_file)) {
    loadWorkbook(workbook_file)
    # If not create a new workbook
  } else {
    createWorkbook()
  }

  # Set the sheet name as the dataset type
  sheet_name <- unique(summary_df$type)

  # If a sheet for that dataset type already exists, remove it
  if (sheet_name %in% names(wb)) {
    removeWorksheet(wb, sheet_name)
  }

  # Add a new worksheet containing the summary data
  addWorksheet(
    wb,
    sheetName = sheet_name,
    tabColour = if (all(summary_df$RESULT == "PASS", na.rm = TRUE))
      "palegreen"
    else
      "#FFC7CE")
  writeData(wb, sheet_name, summary_df)

  # Freeze/anchor the header row
  freezePane(wb, sheet = sheet_name, firstActiveRow = 2)

  # Make the header row bold
  addStyle(
    wb,
    sheet = sheet_name,
    style = createStyle(textDecoration = "bold"),
    rows = 1,
    cols = seq_along(summary_df),
    gridExpand = TRUE
  )

  # Red style for mismatching cells
  mismatch_style <- createStyle(
    fgFill = "#FFC7CE",
    fontColour = "firebrick",
    textDecoration = "bold"
  )

  # Green style for pass
  pass_style <- createStyle(
    fgFill = "palegreen",
    fontColour = "darkgreen",
    textDecoration = "bold"
  )

  # Helper function to highlight cells
  highlight_cells <- function(column_names, rows, style) {
    rows <- which(rows) + 1  # +1 because row 1 contains column headings
    if (length(rows) > 0) {
      addStyle(
        wb,
        sheet = sheet_name,
        style = style,
        rows = rows,
        cols = match(column_names, names(summary_df)),
        gridExpand = TRUE,
        stack = TRUE
      )
    }
  }

  highlight_cells("in_both", summary_df$in_both != TRUE, mismatch_style)
  highlight_cells("min_match", summary_df$min_match != TRUE, mismatch_style)
  highlight_cells("max_match", summary_df$max_match != TRUE, mismatch_style)
  highlight_cells("mean_match", summary_df$mean_match != TRUE, mismatch_style)
  highlight_cells("median_match", summary_df$median_match != TRUE, mismatch_style)
  highlight_cells("sum_match", summary_df$sum_match != TRUE, mismatch_style)
  highlight_cells("type_match", summary_df$type_match != TRUE, mismatch_style)

  highlight_cells("change_total_vals", summary_df$change_total_vals != 0, mismatch_style)
  highlight_cells("change_na", summary_df$change_na != 0, mismatch_style)
  highlight_cells("change_unique_vals", summary_df$change_unique_vals != 0, mismatch_style)
  highlight_cells("perc_change_total_vals", summary_df$perc_change_total_vals != 0, mismatch_style)
  highlight_cells("perc_change_na", summary_df$perc_change_na != 0, mismatch_style)
  highlight_cells("perc_change_unique_vals", summary_df$perc_change_unique_vals != 0, mismatch_style)
  highlight_cells("unique_vals_mismatch", summary_df$unique_vals_mismatch != 0, mismatch_style)
  highlight_cells("unique_vals_with_different_counts", summary_df$unique_vals_with_different_counts != 0, mismatch_style)

  # Highlight result column
  highlight_cells("RESULT", summary_df$RESULT == "FAIL", mismatch_style)
  highlight_cells("RESULT", summary_df$RESULT == "PASS", pass_style)

  # Save
  saveWorkbook(wb, workbook_file, overwrite = TRUE)
}
