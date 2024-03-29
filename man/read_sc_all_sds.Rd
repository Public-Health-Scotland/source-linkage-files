% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_sc_all_sds.R
\name{read_sc_all_sds}
\alias{read_sc_all_sds}
\title{Read Social Care SDS data}
\usage{
read_sc_all_sds(sc_dvprod_connection = phs_db_connection(dsn = "DVPROD"))
}
\arguments{
\item{sc_dvprod_connection}{Connection to the SC platform}
}
\value{
an extract of the data as a \link[tibble:tibble-package]{tibble}.
}
\description{
Read Social Care SDS data
}
