## ----include = FALSE----------------------------------------------------------
# Network chunks only run outside CRAN, with connectivity.
NOT_CRAN <- identical(Sys.getenv("NOT_CRAN"), "true")
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = NOT_CRAN,
  purl = NOT_CRAN
)

