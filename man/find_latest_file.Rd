% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/find_latest_file.R
\name{find_latest_file}
\alias{find_latest_file}
\title{Find the latest version of a file}
\usage{
find_latest_file(directory, regexp, selection_method = "modification_date")
}
\arguments{
\item{directory}{The directory in which to search.}

\item{regexp}{a
\href{https://www.regular-expressions.info/quickstart.html}{regular expression}
passed to \code{\link[fs:dir_ls]{fs::dir_info()}} to search for the file.}

\item{selection_method}{Valid arguments are "modification_date"
(the default) or "file_name".}
}
\value{
the \code{\link[fs:path]{fs::path()}} to the file
}
\description{
This will return the latest created file matching
the criteria. It uses \code{\link[fs:dir_ls]{fs::dir_info()}} to
find the files then picks the one with the latest
\code{birthtime}.
}
\examples{
\dontrun{
find_latest_file(
  directory = get_lookups_dir(),
  regexp = "Scottish_Postcode_Directory_.+?\\\\.rds"
)
}
}
