% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/add_activity_after_death_flag.R
\name{add_activity_after_death_flag}
\alias{add_activity_after_death_flag}
\title{Match on BOXI NRS death dates to process activity after death flag}
\usage{
add_activity_after_death_flag(
  data,
  year,
  deaths_data = read_file(get_combined_slf_deaths_lookup_path()) \%>\%
    slfhelper::get_chi()
)
}
\arguments{
\item{data}{episode files}

\item{year}{financial year, e.g. '1920'}

\item{deaths_data}{The death data for the year}
}
\value{
data flagged if activity after death
}
\description{
Match on CHI number where available in the episode file, and add date of death from the BOXI NRS lookup.
Create new activity after death flag
}
