% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create_individual_file.R
\name{add_standard_cols}
\alias{add_standard_cols}
\title{Add standard columns}
\usage{
add_standard_cols(
  episode_file,
  prefix,
  condition,
  episode = FALSE,
  cost = FALSE
)
}
\arguments{
\item{episode_file}{Tibble containing episodic data.}

\item{prefix}{Prefix to add to related columns, e.g. "Acute"}

\item{condition}{Condition to create new columns based on}

\item{episode}{Whether to create prefix_episodes col, e.g. "Acute_episodes"}

\item{cost}{Whether to create prefix_cost col, e.g. "Acute_cost"}
}
\description{
Add standard columns (DoB, postcode, gpprac, episodes, cost)
to episode file.
}
\seealso{
Other individual_file: 
\code{\link{add_acute_columns}()},
\code{\link{add_ae_columns}()},
\code{\link{add_all_columns}()},
\code{\link{add_at_columns}()},
\code{\link{add_ch_columns}()},
\code{\link{add_cij_columns}()},
\code{\link{add_cmh_columns}()},
\code{\link{add_dd_columns}()},
\code{\link{add_dn_columns}()},
\code{\link{add_gls_columns}()},
\code{\link{add_hc_columns}()},
\code{\link{add_hl1_columns}()},
\code{\link{add_ipdc_cols}()},
\code{\link{add_keep_population_flag}()},
\code{\link{add_mat_columns}()},
\code{\link{add_mh_columns}()},
\code{\link{add_nrs_columns}()},
\code{\link{add_nsu_columns}()},
\code{\link{add_ooh_columns}()},
\code{\link{add_op_columns}()},
\code{\link{add_pis_columns}()},
\code{\link{add_sds_columns}()},
\code{\link{clean_up_ch}()},
\code{\link{condition_cols}()},
\code{\link{create_individual_file}()},
\code{\link{recode_gender}()},
\code{\link{remove_blank_chi}()}
}
\concept{individual_file}
