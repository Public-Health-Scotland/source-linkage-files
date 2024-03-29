% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/write_file.R
\name{write_file}
\alias{write_file}
\title{Write a data to a file}
\usage{
write_file(data, path, ...)
}
\arguments{
\item{data}{The data to be written}

\item{path}{The file path to be write}

\item{...}{Additional arguments passed to the relevant function.}
}
\value{
the data (invisibly) as a \link[tibble:tibble-package]{tibble}.
}
\description{
Write data to a file, the function chosen to write the file is
dependant on the file path extension.
\itemize{
\item \code{.rds} uses \code{\link[readr:read_rds]{readr::write_rds()}}.
\item \code{.parquet} uses \code{\link[arrow:write_parquet]{arrow::write_parquet()}}.
}
}
