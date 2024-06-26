% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_sandpit_extract_path.R
\name{get_sandpit_extract_path}
\alias{get_sandpit_extract_path}
\title{Sandpit Extract File Path}
\usage{
get_sandpit_extract_path(
  type = c("at", "ch", "hc", "sds", "client", "demographics"),
  year = NULL,
  update = latest_update(),
  ...
)
}
\arguments{
\item{type}{sandpit extract type at, ch, hc, sds, client, or demographics}

\item{year}{financial year in string class}

\item{update}{The update month to use,
defaults to \code{\link[=latest_update]{latest_update()}}}

\item{...}{additional arguments passed to \code{\link[=get_file_path]{get_file_path()}}}
}
\value{
The path to the sandpit extracts as an \code{\link[fs:path]{fs::path()}}
}
\description{
Get the file path for sandpit extracts
}
\seealso{
\code{\link[=get_file_path]{get_file_path()}} for the generic function.
}
\concept{social care sandpit extract paths}
