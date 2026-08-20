#' @keywords internal
#' @section Package options:
#'
#' * `alepe.quiet`: suppress informational messages. Defaults to `TRUE`
#'   in non-interactive sessions.
#' * `alepe.cache_dir`: cache location. Defaults to
#'   `tools::R_user_dir("alepe", "cache")`.
#' * `alepe.cache_max_age`: cache expiry in seconds. Defaults to 6 hours.
#' * `alepe.max_tries`: maximum request attempts. Defaults to 3, with
#'   exponential backoff between attempts.
#' * `alepe.timeout`: request timeout in seconds. Defaults to 60; the
#'   slowest endpoint (`/licitacoes`) regularly needs close to 30 s.
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL
