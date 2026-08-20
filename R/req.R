#' @keywords internal
alepe_base_url <- "https://dadosabertos.alepe.pe.gov.br/api/v1"

#' Build a request to the ALEPE open data API
#'
#' Central request constructor used by every endpoint function. Adds a
#' descriptive user agent, exponential backoff retries for transient
#' failures, a 60 s timeout, and a local response cache.
#'
#' @param endpoint API path appended to the base URL, e.g. `"parlamentares"`.
#' @param ... Named query parameters. `NULL` values are dropped.
#' @param refresh If `TRUE`, bypass the local cache for this call.
#' @returns An `httr2_request` object.
#' @noRd
alepe_req <- function(endpoint, ..., refresh = FALSE) {
  req <- httr2::request(alepe_base_url) |>
    httr2::req_url_path_append(endpoint, "") |>
    httr2::req_url_query(...) |>
    httr2::req_user_agent(
      "alepe R package (https://github.com/StrategicProjects/alepe)"
    ) |>
    # 60 s, not 30: /licitacoes routinely takes ~28 s to answer, close
    # enough to a 30 s limit that the endpoint failed intermittently.
    httr2::req_timeout(getOption("alepe.timeout", 60)) |>
    httr2::req_retry(
      max_tries = getOption("alepe.max_tries", 3),
      backoff = function(i) 2^i,
      is_transient = function(resp) {
        httr2::resp_status(resp) %in% c(429L, 500L, 502L, 503L, 504L)
      }
    )

  if (!isTRUE(refresh)) {
    req <- httr2::req_cache(
      req,
      path = alepe_cache_dir(),
      max_age = getOption("alepe.cache_max_age", 6 * 3600)
    )
  }

  req
}

#' Perform a request and fail gracefully
#'
#' Wraps [httr2::req_perform()]. On connection errors, timeouts, or
#' non-2xx responses that survive the retry policy, emits an informative
#' warning (per CRAN policy on internet resources) and returns `NULL`
#' instead of erroring.
#'
#' @param req An `httr2_request`.
#' @param error_call Environment for error reporting.
#' @returns An `httr2_response`, or `NULL` on failure.
#' @noRd
alepe_perform <- function(req, error_call = rlang::caller_env()) {
  alepe_inform(c("i" = "Requesting {.url {req$url}}"))

  resp <- tryCatch(
    httr2::req_perform(req),
    httr2_error = function(cnd) cnd,
    error = function(cnd) cnd
  )

  if (rlang::is_condition(resp)) {
    cli::cli_warn(
      c(
        "!" = "The ALEPE open data API could not be reached.",
        "i" = "Returning {.code NULL}. Original error: {conditionMessage(resp)}",
        "i" = "The service may be temporarily down; try again later."
      ),
      class = "alepe_error_http",
      call = error_call
    )
    return(NULL)
  }

  if (httr2::resp_status(resp) >= 400L) {
    cli::cli_warn(
      c(
        "!" = "ALEPE API returned HTTP {httr2::resp_status(resp)}
               ({httr2::resp_status_desc(resp)}).",
        "i" = "Returning {.code NULL}."
      ),
      class = "alepe_error_http",
      call = error_call
    )
    return(NULL)
  }

  resp
}

#' Fetch and parse a JSON endpoint
#'
#' @param endpoint API path.
#' @param ... Query parameters.
#' @param refresh Bypass cache.
#' @returns A list parsed from JSON, or `NULL` on failure.
#' @noRd
alepe_fetch_json <- function(endpoint, ..., refresh = FALSE,
                             error_call = rlang::caller_env()) {
  resp <- alepe_perform(
    alepe_req(endpoint, ..., refresh = refresh),
    error_call = error_call
  )
  if (is.null(resp)) {
    return(NULL)
  }

  tryCatch(
    httr2::resp_body_json(resp),
    error = function(cnd) {
      cli::cli_warn(
        c(
          "!" = "Could not parse the ALEPE API response as JSON.",
          "i" = "Returning {.code NULL}. Original error:
                 {conditionMessage(cnd)}"
        ),
        class = "alepe_error_parse",
        call = error_call
      )
      NULL
    }
  )
}

#' Fetch and parse a CSV endpoint
#'
#' Used for the propositions endpoints, whose structured formats are XML
#' and CSV. CSV keeps the dependency footprint smaller than XML.
#'
#' @inheritParams alepe_fetch_json
#' @returns A tibble, or `NULL` on failure.
#' @noRd
alepe_fetch_csv <- function(endpoint, ..., refresh = FALSE,
                            error_call = rlang::caller_env()) {
  resp <- alepe_perform(
    alepe_req(endpoint, ..., formato = "csv", refresh = refresh),
    error_call = error_call
  )
  if (is.null(resp)) {
    return(NULL)
  }

  tryCatch(
    readr::read_csv(
      httr2::resp_body_raw(resp),
      locale = readr::locale(encoding = "UTF-8"),
      show_col_types = FALSE,
      progress = FALSE
    ),
    error = function(cnd) {
      cli::cli_warn(
        c(
          "!" = "Could not parse the ALEPE API response as CSV.",
          "i" = "Returning {.code NULL}. Original error:
                 {conditionMessage(cnd)}"
        ),
        class = "alepe_error_parse",
        call = error_call
      )
      NULL
    }
  )
}
