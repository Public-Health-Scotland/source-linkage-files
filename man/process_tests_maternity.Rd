% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/process_tests_maternity.R
\name{process_tests_maternity}
\alias{process_tests_maternity}
\title{Process Maternity tests}
\usage{
process_tests_maternity(data, year)
}
\arguments{
\item{data}{a \link[tibble:tibble-package]{tibble} of the processed data extract.}

\item{year}{the financial year of the extract in the format '1718'.}
}
\value{
a \link[tibble:tibble-package]{tibble} containing a test comparison.
}
\description{
This script takes the processed homelessness extract and produces
a test comparison with the previous data. This is written to disk as an xlsx.
}
