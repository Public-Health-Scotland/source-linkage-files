% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/process_tests_sc_demographics.R
\name{produce_sc_demog_lookup_tests}
\alias{produce_sc_demog_lookup_tests}
\title{Social Care Demographic Lookup Tests}
\usage{
produce_sc_demog_lookup_tests(data)
}
\arguments{
\item{data}{new or old data for testing summary flags
(data is from \code{\link[=get_sc_demog_lookup_path]{get_sc_demog_lookup_path()}})}
}
\value{
a dataframe with a count of each flag.
}
\description{
Produce the tests for Social Care Demographic Lookup
}
\seealso{
Other social care test functions: 
\code{\link{produce_sc_all_episodes_tests}()},
\code{\link{produce_source_at_tests}()},
\code{\link{produce_source_sds_tests}()},
\code{\link{produce_tests_sc_client_lookup}()}
}
\concept{social care test functions}
