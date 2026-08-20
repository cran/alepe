#' Query legislative propositions
#'
#' Retrieves legislative propositions from the Assembly: bills
#' (`alepe_bills()`), indications (`alepe_indications()`), and requests
#' (`alepe_requests()`). Two query modes are supported by the API:
#'
#' * **Detail**: pass `number` and `year` to fetch the full record of a
#'   single proposition.
#' * **Listing**: pass `year` and/or `legislature` to fetch summaries of
#'   multiple propositions. When no filter is given, the API defaults to
#'   the current year.
#'
#' These endpoints serve structured data as XML embedded in CSV; the
#' package parses the XML fields into regular columns, with names
#' normalized to snake_case and HTML markup stripped from free-text
#' fields.
#'
#' @param number Proposition number, for the detail mode. Requires
#'   `year`.
#' @param year Filter by year (listing mode) or select the proposition
#'   (detail mode).
#' @param legislature Filter by legislature number (listing mode).
#' @param refresh If `TRUE`, bypass the local cache.
#' @returns A tibble. In listing mode, one row per proposition with
#'   `docid`, `numero`, `ano`, `legislatura`, `tipo`, `subtipo`,
#'   `ementa`, `data_publicacao` (`Date`), and `autores` (author names,
#'   `;`-separated). In detail mode, a single row with `numero`, `ano`,
#'   `legislatura`, `tipo`, `autores`, `ementa`, `materia`,
#'   `justificativa`, `regime_tramitacao`, `impacto_orcamentario`,
#'   `resultado_final`, `data_publicacao` (`Date`), `numero_dpl`, and
#'   `lotacao_atual`. On network failure, a zero-column tibble (with a
#'   warning).
#' @examplesIf interactive()
#' # All bills of the current year
#' alepe_bills()
#'
#' # One specific bill
#' alepe_bills(number = 100, year = 2024)
#' @export
alepe_bills <- function(number = NULL, year = NULL, legislature = NULL,
                        refresh = FALSE) {
  alepe_proposition(
    "projetos", "bills",
    number = number, year = year, legislature = legislature,
    refresh = refresh
  )
}

#' @rdname alepe_bills
#' @export
alepe_indications <- function(number = NULL, year = NULL,
                              legislature = NULL, refresh = FALSE) {
  alepe_proposition(
    "indicacoes", "indications",
    number = number, year = year, legislature = legislature,
    refresh = refresh
  )
}

#' @rdname alepe_bills
#' @export
alepe_requests <- function(number = NULL, year = NULL, legislature = NULL,
                           refresh = FALSE) {
  alepe_proposition(
    "requerimentos", "requests",
    number = number, year = year, legislature = legislature,
    refresh = refresh
  )
}

#' @noRd
alepe_proposition <- function(type, what, number, year, legislature,
                              refresh = FALSE,
                              error_call = rlang::caller_env()) {
  if (!is.null(number) && is.null(year)) {
    cli::cli_abort(
      c(
        "!" = "{.arg number} requires {.arg year}.",
        "i" = "The detail mode of the propositions API selects a single
               proposition by number {.emph and} year."
      ),
      class = "alepe_error_input",
      call = error_call
    )
  }

  out <- alepe_fetch_csv(
    file.path("proposicoes", type),
    numero = number,
    ano = year,
    legislatura = legislature,
    refresh = refresh,
    error_call = error_call
  )

  if (is.null(out)) {
    return(tibble::tibble())
  }

  out <- if (is.null(number)) {
    parse_proposition_listing(out)
  } else {
    parse_proposition_detail(out)
  }
  report_rows(out, what)
}

# The propositions endpoints serve CSV whose single column carries XML:
# one <projeto|indicacao|requerimento .../> fragment per row in listing
# mode, or one full XML document in detail mode. Parsed here with
# regular expressions -- the fragments are machine-generated and flat,
# and this keeps xml2 out of the dependencies (see D4).

#' @noRd
parse_proposition_listing <- function(df) {
  schema <- c(
    docid = "int", numero = "int", ano = "int", legislatura = "chr",
    tipo = "chr", subtipo = "chr", ementa = "chr",
    data_publicacao = "date", autores = "chr"
  )
  cells <- df[[1L]]
  cells <- cells[!is.na(cells) & grepl('docid="', cells, fixed = TRUE)]
  if (length(cells) == 0L) {
    return(empty_tibble(schema))
  }

  records <- lapply(cells, function(cell) {
    rec <- xml_root_attrs(cell)
    rec$autores <- collapse_authors(cell)
    rec
  })
  out <- records_to_tibble(records, schema)
  out$legislatura <- trimws(out$legislatura)
  out$ementa <- strip_html(out$ementa)
  out
}

#' @noRd
parse_proposition_detail <- function(df) {
  schema <- c(
    numero = "int", ano = "int", legislatura = "chr", tipo = "chr",
    autores = "chr", ementa = "chr", materia = "chr",
    justificativa = "chr", regime_tramitacao = "chr",
    impacto_orcamentario = "chr", resultado_final = "chr",
    data_publicacao = "date", numero_dpl = "int", lotacao_atual = "chr"
  )
  doc <- paste(df[[1L]], collapse = "\n")
  doc <- sub("<\\?xml[^>]*\\?>", "", doc)

  rec <- xml_root_attrs(doc)
  rec$autores <- collapse_authors(doc)
  for (tag in c(
    "ementa", "materia", "justificativa", "regimeTramitacao",
    "impactoOrcamentario", "resultadoFinal", "dataPublicacao",
    "numeroDpl", "lotacaoAtual"
  )) {
    rec[[tag]] <- xml_element_text(doc, tag)
  }

  out <- records_to_tibble(list(rec), schema)
  out$legislatura <- trimws(out$legislatura)
  for (nm in c("ementa", "materia", "justificativa")) {
    out[[nm]] <- strip_html(out[[nm]])
  }
  out
}

#' Named attributes of the first (root) tag of an XML string
#' @noRd
xml_root_attrs <- function(x) {
  head <- substr(x, 1L, regexpr(">", x, fixed = TRUE) - 1L)
  pieces <- regmatches(
    head,
    gregexpr('[[:alnum:]]+="[^"]*"', head)
  )[[1L]]
  keys <- sub("=.*$", "", pieces)
  vals <- sub('"$', "", sub('^[^"]*"', "", pieces))
  rlang::set_names(as.list(xml_unescape(vals)), keys)
}

#' Text content of a leaf element, or NULL if absent
#' @noRd
xml_element_text <- function(doc, tag) {
  pattern <- paste0("<", tag, "(\\s[^>]*)?>([\\s\\S]*?)</", tag, ">")
  m <- regmatches(doc, regexpr(pattern, doc, perl = TRUE))
  if (length(m) == 0L) {
    return(NULL)
  }
  inner <- sub(paste0("^<", tag, "[^>]*>"), "", m)
  inner <- sub(paste0("</", tag, ">$"), "", inner)
  xml_unescape(inner)
}

#' @noRd
collapse_authors <- function(x) {
  pieces <- regmatches(
    x,
    gregexpr('<autor\\s[^>]*nome="[^"]*"', x)
  )[[1L]]
  if (length(pieces) == 0L) {
    return(NA_character_)
  }
  nomes <- sub('"$', "", sub('^.*nome="', "", pieces))
  paste(xml_unescape(nomes), collapse = "; ")
}
