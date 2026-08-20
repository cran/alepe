#' List current state representatives
#'
#' Retrieves the members of the current legislature of the Legislative
#' Assembly of Pernambuco, with name and party.
#'
#' @param refresh If `TRUE`, bypass the local cache.
#' @returns A tibble with one row per representative:
#'   `nome_parlamentar` and `partido`. On network failure a warning is
#'   issued and a zero-row tibble with the same columns is returned.
#' @examplesIf interactive()
#' alepe_representatives()
#' @export
alepe_representatives <- function(refresh = FALSE) {
  schema <- c(nome_parlamentar = "chr", partido = "chr")
  records <- alepe_fetch_json("parlamentares", refresh = refresh)
  out <- records_to_tibble(records, schema)
  report_rows(out, "representatives")
}

#' List ALEPE staff
#'
#' Retrieves the Assembly's staff roster, optionally filtered by
#' employment status.
#'
#' @param status Employment status filter. One of `"permanent"`,
#'   `"commissioned"`, or `"seconded"` (the original API terms
#'   `"efetivo"`, `"comissionado"`, and `"a-disposicao"` are also
#'   accepted), or `NULL` (default) for all.
#' @inheritParams alepe_representatives
#' @returns A tibble with one row per staff member: `nome`,
#'   `codigo_lotacao`, `nome_lotacao`, `cargo_efetivo`, `cargo_nivel`,
#'   `vinculo`, and `data_admissao` (`Date`). Zero rows (with a
#'   warning) on network failure.
#' @examplesIf interactive()
#' alepe_staff(status = "permanent")
#' @export
alepe_staff <- function(status = NULL, refresh = FALSE) {
  schema <- c(
    nome = "chr", codigo_lotacao = "chr", nome_lotacao = "chr",
    cargo_efetivo = "chr", cargo_nivel = "chr", vinculo = "chr",
    data_admissao = "date"
  )
  records <- alepe_fetch_json(
    "servidores",
    vinculo = map_status(status),
    refresh = refresh
  )
  out <- records_to_tibble(records, schema)
  report_rows(out, "staff members")
}

#' Count staff by position
#'
#' Retrieves the number of staff members per position/level, optionally
#' filtered by employment status.
#'
#' @inheritParams alepe_staff
#' @returns A tibble with `total` and `cargo_nivel`. Zero rows (with a
#'   warning) on network failure.
#' @examplesIf interactive()
#' alepe_positions(status = "commissioned")
#' @export
alepe_positions <- function(status = NULL, refresh = FALSE) {
  schema <- c(total = "int", cargo_nivel = "chr")
  records <- alepe_fetch_json(
    "cargos",
    vinculo = map_status(status),
    refresh = refresh
  )
  out <- records_to_tibble(records, schema)
  report_rows(out, "positions")
}

#' Count staff by department
#'
#' Retrieves the number of active staff members grouped by department
#' (`lotacao`) and employment status. The reference period is fixed by
#' the API and excludes retired staff.
#'
#' @inheritParams alepe_representatives
#' @returns A tibble with `total`, `nome_lotacao`, and `vinculo`. Zero
#'   rows (with a warning) on network failure.
#' @examplesIf interactive()
#' alepe_departments()
#' @export
alepe_departments <- function(refresh = FALSE) {
  schema <- c(total = "int", nome_lotacao = "chr", vinculo = "chr")
  records <- alepe_fetch_json("lotacoes", refresh = refresh)
  out <- records_to_tibble(records, schema)
  report_rows(out, "departments")
}

#' List remuneration by position
#'
#' Retrieves position remuneration values published by the Assembly for
#' the current reference month.
#'
#' @inheritParams alepe_representatives
#' @returns A tibble with `cargo`, `remuneracao` (numeric, BRL),
#'   `tipo_cargo`, `mes_competencia`, and `ano_competencia`. Zero rows
#'   (with a warning) on network failure.
#' @examplesIf interactive()
#' alepe_remuneration()
#' @export
alepe_remuneration <- function(refresh = FALSE) {
  schema <- c(
    cargo = "chr", remuneracao = "brl", tipo_cargo = "chr",
    mes_competencia = "int", ano_competencia = "int"
  )
  records <- alepe_fetch_json("remuneracao", refresh = refresh)
  out <- records_to_tibble(records, schema)
  report_rows(out, "remuneration entries")
}
