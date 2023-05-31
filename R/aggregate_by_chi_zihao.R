library(data.table)

aggregate_by_chi_zihao <- function(episode_file) {
  cli::cli_alert_info("Aggregate by CHI function started at {Sys.time()}")

  data.table::setDT(episode_file) # Convert to data.table

  # Sort the data within each chunk
  data.table::setkeyv(episode_file, c("chi", "record_keydate1", "keytime1", "record_keydate2", "keytime2"))

  data.table::setnames(
    episode_file,
    c(
      "ch_chi_cis", "cij_marker", "ooh_case_id"
      # ,"hh_in_fy"
    ),
    c(
      "ch_cis_episodes", "cij_total", "ooh_cases"
      # ,"HL1_in_FY"
    )
  )

  # Initialize an empty data.table for the aggregated results
  aggregated_data <- data.table::data.table()

  # Process the data in chunks
  chunk_size <- min(nrow(episode_file), 1e7) # Adjust the chunk size as per your system's memory capacity
  n_chunks <- nrow(episode_file) %/% chunk_size


  # colums specification
  cols2 <- names(episode_file)[grepl("postcode$|DoB$|gpprac$",
    names(episode_file),
    ignore.case = TRUE
  )]
  cols3 <- c(
    "ch_cis_episodes",
    "cij_total",
    "CIJ_el",
    "CIJ_non_el",
    "CIJ_mat",
    # "cij_delay",
    "ooh_cases",
    "preventable_admissions"
  )
  cols4 <- names(episode_file)[grepl(
    paste(
      "episodes$",
      "beddays$",
      "cost$",
      "attendances$",
      "attend$",
      # "contacts$",
      "hours$",
      "alarms$",
      "telecare$",
      "paid_items$",
      "advice$",
      "homeV$",
      "time$",
      "assessment$",
      "other$",
      # "DN$",
      "NHS24$",
      "PCC$",
      "_dnas$",
      "^SDS_option",
      sep = "|"
    ),
    names(episode_file),
    ignore.case = TRUE
  )]
  cols4 <- cols4[!(cols4 %in% c("ch_cis_episodes"))]
  # cols5 <- names(episode_file)[grepl("^sc|HL1_in_FY|NSU", names(episode_file), ignore.case = TRUE)]
  # cols5 <- cols5[!(cols5 %in% c("sc_send_lca", "sc_latest_submission"))]
  cols6 <- c(
    condition_cols(),
    # "death_date",
    # "deceased",
    "year",
    names(episode_file)[grepl("_Cohort$|end_fy$|start_fy$",
      names(episode_file),
      ignore.case = TRUE
    )]
  )

  for (i in 1:n_chunks) {
    start <- (i - 1) * chunk_size + 1
    end <- i * chunk_size
    # Subset the data to the current chunk
    chunk <- episode_file[start:end]

    # compute
    chunk_cols1 <- chunk[,
      .(gender = mean(gender)),
      by = chi
    ]
    chunk_cols2 <- chunk[,
      .SD[.N],
      # .SDcols = patterns("postcode$|DoB$|gpprac$"),
      .SDcols = cols2,
      by = chi
    ]
    chunk_cols3 <- chunk[,
      lapply(.SD, function(x) data.table::uniqueN(x, na.rm = TRUE)),
      .SDcols = cols3,
      by = chi
    ]
    chunk_cols4 <- chunk[,
      lapply(.SD, function(x) sum(x, na.rm = TRUE)),
      .SDcols = cols4,
      by = chi
    ]
    # chunk_cols5 <- chunk[,
    #                      lapply(.SD, function(x) max(x, na.rm = TRUE)),
    #                      .SDcols = cols5,
    #                      by = chi]
    chunk_cols6 <- chunk[,
      # .SD[1]
      lapply(.SD, function(x) x[!is.na(x)][1]),
      .SDcols = cols6,
      by = chi
    ]
    chunk_agg <- cbind(
      chunk_cols1,
      chunk_cols2[, chi := NULL],
      chunk_cols3[, chi := NULL],
      chunk_cols4[, chi := NULL],
      # chunk_cols5[, chi := NULL],
      chunk_cols6[, chi := NULL]
    )

    # Append the aggregated chunk to the overall result
    aggregated_data <- data.table::rbindlist(list(aggregated_data, chunk_agg))
  }
  aggregated_data <- dplyr::as_tibble(aggregated_data)
  return(aggregated_data)
}
