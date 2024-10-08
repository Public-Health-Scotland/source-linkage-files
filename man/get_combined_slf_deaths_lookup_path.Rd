% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_slf_lookup_paths.R
\name{get_combined_slf_deaths_lookup_path}
\alias{get_combined_slf_deaths_lookup_path}
\title{SLF death dates File Path}
\usage{
get_combined_slf_deaths_lookup_path(update = latest_update(), ...)
}
\arguments{
\item{update}{the update month (defaults to use \code{\link[=latest_update]{latest_update()}})}

\item{...}{additional arguments passed to \code{\link[=get_file_path]{get_file_path()}}}
}
\description{
Get the full path to the BOXI NRS Deaths lookup file for all financial years
Note this name is very similar to the existing slf_deaths_lookup_path
which returns the path for the refined_death with deceased flag for each financial year.
This function will return the combined financial years lookup
i.e. all years put together.
}
\seealso{
\code{\link[=get_file_path]{get_file_path()}} for the generic function.

Other slf lookup file path: 
\code{\link{get_slf_ch_name_lookup_path}()},
\code{\link{get_slf_chi_deaths_path}()},
\code{\link{get_slf_deaths_lookup_path}()},
\code{\link{get_slf_gpprac_path}()},
\code{\link{get_slf_postcode_path}()}
}
\concept{slf lookup file path}
