% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_extract_gp_ooh.R
\name{read_extract_gp_ooh}
\alias{read_extract_gp_ooh}
\title{Process the GP OoH extract}
\usage{
read_extract_gp_ooh(
  year,
  diagnosis_path = get_boxi_extract_path(year = year, type = "gp_ooh-d"),
  outcomes_path = get_boxi_extract_path(year = year, type = "gp_ooh-o"),
  consultations_path = get_boxi_extract_path(year = year, type = "gp_ooh-c")
)
}
\arguments{
\item{year}{The year to process, in FY format.}

\item{diagnosis_path}{Path to diagnosis BOXI extract location.}

\item{outcomes_path}{Path to outcomes BOXI extract location.}

\item{consultations_path}{Path to consultations BOXI extract location.}
}
\value{
the final data as a \link[tibble:tibble-package]{tibble}.
}
\description{
This will read and process the
GP OoH extract, it will return the final data
and (optionally) write it to disk.
}
\seealso{
Other process extracts: 
\code{\link{create_homelessness_lookup}()},
\code{\link{process_extract_acute}()},
\code{\link{process_extract_ae}()},
\code{\link{process_extract_alarms_telecare}()},
\code{\link{process_extract_care_home}()},
\code{\link{process_extract_cmh}()},
\code{\link{process_extract_delayed_discharges}()},
\code{\link{process_extract_district_nursing}()},
\code{\link{process_extract_gp_ooh}()},
\code{\link{process_extract_home_care}()},
\code{\link{process_extract_homelessness}()},
\code{\link{process_extract_maternity}()},
\code{\link{process_extract_mental_health}()},
\code{\link{process_extract_nrs_deaths}()},
\code{\link{process_extract_ooh_consultations}()},
\code{\link{process_extract_ooh_diagnosis}()},
\code{\link{process_extract_ooh_outcomes}()},
\code{\link{process_extract_outpatients}()},
\code{\link{process_extract_prescribing}()},
\code{\link{process_extract_sds}()},
\code{\link{process_it_chi_deaths}()},
\code{\link{process_lookup_gpprac}()},
\code{\link{process_lookup_postcode}()},
\code{\link{process_lookup_sc_client}()},
\code{\link{process_lookup_sc_demographics}()},
\code{\link{process_refined_death}()},
\code{\link{process_sc_all_alarms_telecare}()},
\code{\link{process_sc_all_care_home}()},
\code{\link{process_sc_all_home_care}()},
\code{\link{process_sc_all_sds}()},
\code{\link{read_it_chi_deaths}()},
\code{\link{read_lookup_sc_client}()}
}
\concept{process extracts}
