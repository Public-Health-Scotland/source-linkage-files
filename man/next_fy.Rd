% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_fy_dates.R
\name{next_fy}
\alias{next_fy}
\title{Return the next financial year}
\usage{
next_fy(year, format = c("fyyear", "alternate"))
}
\arguments{
\item{year}{a character vector of years}

\item{format}{the format of the year vector, default is financial year}
}
\value{
A character of the date in the requested format
}
\description{
Return the next financial year
}
\examples{
next_fy("1718")

}
\seealso{
Other date functions: 
\code{\link{calculate_stay}()},
\code{\link{compute_mid_year_age}()},
\code{\link{convert_date_to_numeric}()},
\code{\link{convert_numeric_to_date}()},
\code{\link{end_fy}()},
\code{\link{end_fy_quarter}()},
\code{\link{end_next_fy_quarter}()},
\code{\link{fy_interval}()},
\code{\link{is_date_in_fyyear}()},
\code{\link{last_date_month}()},
\code{\link{midpoint_fy}()},
\code{\link{start_fy}()},
\code{\link{start_fy_quarter}()},
\code{\link{start_next_fy_quarter}()}
}
\concept{date functions}
