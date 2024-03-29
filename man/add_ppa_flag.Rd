% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/add_ppa_flag.R
\name{add_ppa_flag}
\alias{add_ppa_flag}
\title{Add Potentially Preventable Admission (PPA) Marker}
\usage{
add_ppa_flag(data)
}
\arguments{
\item{data}{A data frame}
}
\value{
A data frame to use as a lookup of PPAs
}
\description{
This function takes a data frame input and determines, based on
a combination of diagnostic codes and operation codes, whether an admission
was preventable or not.
}
\seealso{
Other episode_file: 
\code{\link{add_nsu_cohort}()},
\code{\link{apply_cost_uplift}()},
\code{\link{link_delayed_discharge_eps}()},
\code{\link{lookup_uplift}()}
}
\concept{episode_file}
