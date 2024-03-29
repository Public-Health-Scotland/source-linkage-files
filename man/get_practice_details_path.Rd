% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_practice_details_path.R
\name{get_practice_details_path}
\alias{get_practice_details_path}
\title{Practice Details File Path}
\usage{
get_practice_details_path(update = latest_update(), ...)
}
\arguments{
\item{update}{the update month (defaults to use \code{\link[=latest_update]{latest_update()}})}

\item{...}{additional arguments passed to \code{\link[=get_file_path]{get_file_path()}}}
}
\value{
The path to the Practice Details file as an \code{\link[fs:path]{fs::path()}}
}
\description{
Get the path to the Practice Details file
}
\seealso{
\code{\link[=get_file_path]{get_file_path()}} for the generic function.

Other file path functions: 
\code{\link{get_dd_path}()},
\code{\link{get_demographic_cohorts_path}()},
\code{\link{get_file_path}()},
\code{\link{get_homelessness_completeness_path}()},
\code{\link{get_ltcs_path}()},
\code{\link{get_nsu_path}()},
\code{\link{get_readcode_lookup_path}()},
\code{\link{get_service_use_cohorts_path}()},
\code{\link{get_sg_homelessness_pub_path}()}
}
\concept{file path functions}
