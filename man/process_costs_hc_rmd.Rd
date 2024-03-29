% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/process_costs_rmd.R
\name{process_costs_hc_rmd}
\alias{process_costs_hc_rmd}
\title{Process Home Care cost lookup Rmd file}
\usage{
process_costs_hc_rmd(file_path = get_hc_costs_path())
}
\arguments{
\item{file_path}{Path to the cost lookup.}
}
\value{
a \link[tibble:tibble-package]{tibble} containing the final cost data.
}
\description{
This will read and process the
Home Care cost lookup, it will return the final data
and write it to disk.
}
