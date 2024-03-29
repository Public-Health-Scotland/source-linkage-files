% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/check_variables_exist.R
\name{check_variables_exist}
\alias{check_variables_exist}
\title{Check variables exist in data}
\usage{
check_variables_exist(data, variables)
}
\arguments{
\item{data}{a dataframe to check}

\item{variables}{a character vector of variable names which should be in
the data}
}
\value{
TRUE (invisibly) if all variables are present otherwise it will
throw an informative error message
}
\description{
Check variables exist in data
}
