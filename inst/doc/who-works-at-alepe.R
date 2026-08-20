## ----include = FALSE----------------------------------------------------------
NOT_CRAN <- identical(Sys.getenv("NOT_CRAN"), "true")
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = NOT_CRAN,
  purl = NOT_CRAN,
  fig.width = 7,
  fig.height = 4.5
)

# See following-the-money.Rmd: charts are skipped, with a note, when the
# API is unreachable at build time.
have_rows <- function(x) {
  NOT_CRAN && is.data.frame(x) && nrow(x) > 0L
}
offline_note <- function(what) {
  knitr::asis_output(paste0(
    "> The ALEPE API did not return ", what, " while this page was ",
    "being built, so the chart is omitted. Run the code above ",
    "yourself for current data.\n"
  ))
}

