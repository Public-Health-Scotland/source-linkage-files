% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/convert_eng_gpprac_to_dummy.R
\name{convert_eng_gpprac_to_dummy}
\alias{convert_eng_gpprac_to_dummy}
\title{Convert GP Practice Codes to a Dummy Code}
\usage{
convert_eng_gpprac_to_dummy(gpprac, dummy_code = 9995L)
}
\arguments{
\item{gpprac}{A character vector containing the GP practice codes}

\item{dummy_code}{The dummy code to use. Default is 9995}
}
\value{
An integer vector with only Scottish GP codes
}
\description{
Convert English GP practice codes to a dummy code
}
