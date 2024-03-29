% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/produce_homelessness_completeness.R
\name{produce_homelessness_completeness}
\alias{produce_homelessness_completeness}
\title{Produce the Homelessness Completeness lookup}
\usage{
produce_homelessness_completeness(homelessness_data, update, sg_pub_path)
}
\arguments{
\item{homelessness_data}{The Homelessness data to produce}

\item{update}{The update to use (default is \code{\link[=latest_update]{latest_update()}}).}

\item{sg_pub_path}{The path to the SG pub figures (default is
\code{\link[=get_sg_homelessness_pub_path]{get_sg_homelessness_pub_path()}}).}
}
\value{
a \link[tibble:tibble-package]{tibble} as a lookup with \code{year},
\code{sending_local_authority_name} and the proportion completeness
\code{pct_complete_all}.
}
\description{
Produce the Homelessness Completeness lookup
}
