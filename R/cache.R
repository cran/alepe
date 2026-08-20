#' Cache directory used by alepe
#'
#' Responses from the ALEPE API are cached on disk to avoid repeated
#' downloads. The location follows [tools::R_user_dir()], as required by
#' CRAN policy. Cached entries expire after
#' `getOption("alepe.cache_max_age", 6 * 3600)` seconds.
#'
#' @returns The cache directory path, invisibly for `alepe_cache_clear()`.
#' @examples
#' alepe_cache_dir()
#' @export
alepe_cache_dir <- function() {
  getOption("alepe.cache_dir", tools::R_user_dir("alepe", "cache"))
}

#' @rdname alepe_cache_dir
#' @export
alepe_cache_clear <- function() {
  dir <- alepe_cache_dir()
  if (dir.exists(dir)) {
    unlink(dir, recursive = TRUE)
    alepe_inform(c("v" = "Cleared alepe cache at {.path {dir}}."))
  } else {
    alepe_inform(c("i" = "No alepe cache found at {.path {dir}}."))
  }
  invisible(dir)
}
