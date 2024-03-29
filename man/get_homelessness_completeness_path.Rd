% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/produce_homelessness_completeness.R
\name{get_homelessness_completeness_path}
\alias{get_homelessness_completeness_path}
\title{Homelessness Completeness lookup path}
\usage{
get_homelessness_completeness_path(year, update = latest_update(), ...)
}
\arguments{
\item{year}{the financial year of the update.}

\item{update}{the update month (defaults to use \code{\link[=latest_update]{latest_update()}}).}

\item{...}{additional arguments passed to \code{\link[=get_file_path]{get_file_path()}}.}
}
\value{
The path to the Homelessness Completeness lookup as an \code{\link[fs:path]{fs::path()}}.
}
\description{
Get the path to the Homelessness Completeness lookup. This file
is specific to year and update.
}
\seealso{
\code{\link[=get_file_path]{get_file_path()}} for the generic function.

Other file path functions: 
\code{\link{get_dd_path}()},
\code{\link{get_demographic_cohorts_path}()},
\code{\link{get_file_path}()},
\code{\link{get_ltcs_path}()},
\code{\link{get_nsu_path}()},
\code{\link{get_practice_details_path}()},
\code{\link{get_readcode_lookup_path}()},
\code{\link{get_service_use_cohorts_path}()},
\code{\link{get_sg_homelessness_pub_path}()}
}
\concept{file path functions}
