#' Portuguese aliases
#'
#' Every endpoint function has an alias named after the API endpoint it
#' wraps, for analysts who would rather keep their whole pipeline in
#' Portuguese. The aliases are ordinary functions with the same
#' arguments, the same defaults and the same return value as their
#' English counterparts — only the name differs.
#'
#' | Portuguese | English |
#' | --- | --- |
#' | `alepe_parlamentares()` | [alepe_representatives()] |
#' | `alepe_servidores()` | [alepe_staff()] |
#' | `alepe_cargos()` | [alepe_positions()] |
#' | `alepe_lotacoes()` | [alepe_departments()] |
#' | `alepe_remuneracao()` | [alepe_remuneration()] |
#' | `alepe_contratos()` | [alepe_contracts()] |
#' | `alepe_licitacoes()` | [alepe_procurements()] |
#' | `alepe_projetos()` | [alepe_bills()] |
#' | `alepe_indicacoes()` | [alepe_indications()] |
#' | `alepe_requerimentos()` | [alepe_requests()] |
#' | `alepe_limpar_cache()` | [alepe_cache_clear()] |
#'
#' Names are written without accents, since accented characters in R
#' identifiers are awkward to type and travel badly between locales.
#'
#' Argument *values* follow the same both-ways rule: `status` accepts
#' the English vocabulary and the original API terms alike, so
#' `alepe_servidores(status = "efetivo")` and
#' `alepe_staff(status = "permanent")` are the same query.
#'
#' @inheritParams alepe_staff
#' @inheritParams alepe_bills
#' @returns The same tibble the corresponding English function returns.
#' @examplesIf interactive()
#' alepe_parlamentares()
#' alepe_servidores(status = "efetivo")
#' alepe_projetos(ano = 2024)
#' @name alepe_aliases
NULL

#' @rdname alepe_aliases
#' @export
alepe_parlamentares <- function(refresh = FALSE) {
  alepe_representatives(refresh = refresh)
}

#' @rdname alepe_aliases
#' @export
alepe_servidores <- function(status = NULL, refresh = FALSE) {
  alepe_staff(status = status, refresh = refresh)
}

#' @rdname alepe_aliases
#' @export
alepe_cargos <- function(status = NULL, refresh = FALSE) {
  alepe_positions(status = status, refresh = refresh)
}

#' @rdname alepe_aliases
#' @export
alepe_lotacoes <- function(refresh = FALSE) {
  alepe_departments(refresh = refresh)
}

#' @rdname alepe_aliases
#' @export
alepe_remuneracao <- function(refresh = FALSE) {
  alepe_remuneration(refresh = refresh)
}

#' @rdname alepe_aliases
#' @export
alepe_contratos <- function(refresh = FALSE) {
  alepe_contracts(refresh = refresh)
}

#' @rdname alepe_aliases
#' @export
alepe_licitacoes <- function(refresh = FALSE) {
  alepe_procurements(refresh = refresh)
}

#' The propositions aliases also accept Portuguese argument names
#' (`numero`, `ano`, `legislatura`), which is why they are spelled out
#' rather than passing `...` straight through.
#' @param numero Portuguese spelling of `number`.
#' @param ano Portuguese spelling of `year`.
#' @param legislatura Portuguese spelling of `legislature`.
#' @rdname alepe_aliases
#' @export
alepe_projetos <- function(numero = NULL, ano = NULL, legislatura = NULL,
                           refresh = FALSE) {
  alepe_bills(
    number = numero, year = ano, legislature = legislatura,
    refresh = refresh
  )
}

#' @rdname alepe_aliases
#' @export
alepe_indicacoes <- function(numero = NULL, ano = NULL, legislatura = NULL,
                             refresh = FALSE) {
  alepe_indications(
    number = numero, year = ano, legislature = legislatura,
    refresh = refresh
  )
}

#' @rdname alepe_aliases
#' @export
alepe_requerimentos <- function(numero = NULL, ano = NULL,
                                legislatura = NULL, refresh = FALSE) {
  alepe_requests(
    number = numero, year = ano, legislature = legislatura,
    refresh = refresh
  )
}

#' @rdname alepe_aliases
#' @export
alepe_limpar_cache <- function() {
  alepe_cache_clear()
}
