#' List administrative contracts
#'
#' Retrieves the Assembly's administrative contracts, including
#' modality, contractor name and tax id (CPF/CNPJ), object, value,
#' originating procurement process, and validity period.
#'
#' @inheritParams alepe_representatives
#' @returns A tibble with one row per contract: `modalidade`,
#'   `numero_contrato`, `ano`, `contratada`, `cpf_cnpj`, `objeto`,
#'   `valor` (numeric, BRL), `numero_licitacao`, `ano_licitacao`,
#'   `vigencia_inicio`, and `vigencia_fim` (`Date`). Identifier fields
#'   are kept as published by the API. Zero rows (with a warning) on
#'   network failure.
#' @examplesIf interactive()
#' alepe_contracts()
#' @export
alepe_contracts <- function(refresh = FALSE) {
  schema <- c(
    modalidade = "chr", numero_contrato = "chr", ano = "int",
    contratada = "chr", cpf_cnpj = "chr", objeto = "chr",
    valor = "brl", numero_licitacao = "int", ano_licitacao = "int",
    vigencia_inicio = "date", vigencia_fim = "date"
  )
  records <- alepe_fetch_json("contratos", refresh = refresh)
  out <- records_to_tibble(records, schema)
  report_rows(out, "contracts")
}

#' List procurement processes
#'
#' Retrieves the Assembly's procurement (bidding) processes, including
#' process number and year, modality, object, estimated and awarded
#' values, winner, and status.
#'
#' @inheritParams alepe_representatives
#' @returns A tibble with one row per procurement process:
#'   `numero_processo`, `ano`, `numero_modalidade`, `modalidade`,
#'   `objeto`, `valor_estimado` (numeric, BRL), `status`, `vencedor`,
#'   and `valor_adjudicado` (numeric, BRL). Value and winner fields are
#'   `NA` when the process has not been decided. Zero rows (with a
#'   warning) on network failure.
#' @examplesIf interactive()
#' alepe_procurements()
#' @export
alepe_procurements <- function(refresh = FALSE) {
  schema <- c(
    numero_processo = "int", ano = "int", numero_modalidade = "int",
    modalidade = "chr", objeto = "chr", valor_estimado = "brl",
    status = "chr", vencedor = "chr", valor_adjudicado = "brl"
  )
  records <- alepe_fetch_json("licitacoes", refresh = refresh)
  out <- records_to_tibble(records, schema)
  report_rows(out, "procurement processes")
}
