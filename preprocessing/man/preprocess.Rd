% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/preprocess.R
\name{preprocess}
\alias{preprocess}
\title{Run the pre-processing pipeline}
\usage{
preprocess(out_path = Sys.getenv("PREPROCESS_OUT_PATH"))
}
\arguments{
\item{out_path}{The directory where the pre-processed data will be written to.
Defaults  to the \code{PREPROCESS_OUT_PATH} environment variable.}
}
\value{
Whether the pre-processing was run: \code{TRUE} or \code{FALSE}, invisibly.
}
\description{
The pre-processing pipeline generates the following files:
}
\details{
\itemize{
\item \code{out_path}/omopcat_concepts.parquet
\item \code{out_path}/omopcat_monthly_counts.parquet
\item \code{out_path}/omopcat_summary_stats.parquet
}

If all these files already exist, the pipeline will not be run.
}
