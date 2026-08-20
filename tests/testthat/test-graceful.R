# Graceful-failure contract: network problems warn (classed) and endpoint
# functions return zero-row tibbles with the documented schema.

test_that("connection failure warns and returns typed empty tibble", {
  local_mocked_bindings(
    alepe_fetch_json = function(...) {
      cli::cli_warn("boom", class = "alepe_error_http")
      NULL
    }
  )

  expect_warning(
    out <- alepe_staff(),
    class = "alepe_error_http"
  )
  expect_s3_class(out, "tbl_df")
  expect_equal(nrow(out), 0L)
  expect_named(
    out,
    c(
      "nome", "codigo_lotacao", "nome_lotacao", "cargo_efetivo",
      "cargo_nivel", "vinculo", "data_admissao"
    )
  )
})

test_that("HTTP >= 400 after retries yields NULL with classed warning", {
  resp <- httr2::response(status_code = 503L)
  local_mocked_bindings(
    alepe_perform = function(req, ...) {
      cli::cli_warn("HTTP 503", class = "alepe_error_http")
      NULL
    }
  )
  expect_warning(
    expect_null(alepe_fetch_json("servidores")),
    class = "alepe_error_http"
  )
})

test_that("propositions validate number/year pairing before any request", {
  expect_error(
    alepe_bills(number = 100),
    class = "alepe_error_input"
  )
})
