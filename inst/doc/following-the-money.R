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

# Charts below are guarded with `have_rows()`: when the API is
# unreachable while this vignette is being rendered, the endpoints
# return zero-row tibbles by design, and an empty chart would be worse
# than an honest note.
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

