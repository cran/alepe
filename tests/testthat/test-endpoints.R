# Endpoint parsing tests against fixtures holding verbatim samples of
# real API payloads (captured 2026-08-12; see DECISIONS.md).
#
# To refresh a fixture, fetch the endpoint and keep the first few
# records, e.g.:
#
#   curl -A "alepe R package" \
#     "https://dadosabertos.alepe.pe.gov.br/api/v1/servidores/" |
#     jq '.[0:4]' > tests/testthat/fixtures/servidores.json

fixture_json <- function(name) {
  # jsonlite is a hard dependency of httr2, so it is always available.
  jsonlite::read_json(testthat::test_path("fixtures", name))
}

fixture_csv <- function(name) {
  readr::read_csv(
    testthat::test_path("fixtures", name),
    locale = readr::locale(encoding = "UTF-8"),
    show_col_types = FALSE,
    progress = FALSE
  )
}

test_that("representatives fixture parses into documented schema", {
  records <- fixture_json("parlamentares.json")
  local_mocked_bindings(alepe_fetch_json = function(...) records)

  out <- alepe_representatives()
  expect_s3_class(out, "tbl_df")
  expect_named(out, c("nome_parlamentar", "partido"))
  expect_equal(out$nome_parlamentar[[1]], "Abimael Santos")
})

test_that("staff fixture parses into documented schema", {
  records <- fixture_json("servidores.json")
  local_mocked_bindings(alepe_fetch_json = function(...) records)

  out <- alepe_staff()
  expect_s3_class(out, "tbl_df")
  expect_gt(nrow(out), 0L)
  expect_named(
    out,
    c(
      "nome", "codigo_lotacao", "nome_lotacao", "cargo_efetivo",
      "cargo_nivel", "vinculo", "data_admissao"
    )
  )
  expect_s3_class(out$data_admissao, "Date")
  expect_false(anyNA(out$data_admissao))
})

test_that("positions fixture parses totals as integers", {
  records <- fixture_json("cargos.json")
  local_mocked_bindings(alepe_fetch_json = function(...) records)

  out <- alepe_positions()
  expect_type(out$total, "integer")
  expect_true(all(out$total > 0L))
})

test_that("departments fixture parses into documented schema", {
  records <- fixture_json("lotacoes.json")
  local_mocked_bindings(alepe_fetch_json = function(...) records)

  out <- alepe_departments()
  expect_named(out, c("total", "nome_lotacao", "vinculo"))
  expect_type(out$total, "integer")
})

test_that("remuneration fixture parses dot-decimal money", {
  records <- fixture_json("remuneracao.json")
  local_mocked_bindings(alepe_fetch_json = function(...) records)

  out <- alepe_remuneration()
  expect_named(
    out,
    c(
      "cargo", "remuneracao", "tipo_cargo", "mes_competencia",
      "ano_competencia"
    )
  )
  expect_type(out$remuneracao, "double")
  # "11685.70" must parse as 11685.70, not 1168570
  expect_equal(out$remuneracao[[1]], 11685.70)
  expect_type(out$ano_competencia, "integer")
})

test_that("contracts fixture parses values, years, and nested dates", {
  records <- fixture_json("contratos.json")
  local_mocked_bindings(alepe_fetch_json = function(...) records)

  out <- alepe_contracts()
  expect_named(
    out,
    c(
      "modalidade", "numero_contrato", "ano", "contratada", "cpf_cnpj",
      "objeto", "valor", "numero_licitacao", "ano_licitacao",
      "vigencia_inicio", "vigencia_fim"
    )
  )
  # "119267.04" is a plain float string, not "119.267,04"
  expect_equal(out$valor[[1]], 119267.04)
  # "2026.00" must come out as the year 2026
  expect_equal(out$ano[[1]], 2026L)
  expect_s3_class(out$vigencia_inicio, "Date")
  expect_false(anyNA(out$vigencia_inicio))
  expect_true(all(out$vigencia_fim >= out$vigencia_inicio))
})

test_that("procurements fixture parses into documented schema", {
  records <- fixture_json("licitacoes.json")
  local_mocked_bindings(alepe_fetch_json = function(...) records)

  out <- alepe_procurements()
  expect_named(
    out,
    c(
      "numero_processo", "ano", "numero_modalidade", "modalidade",
      "objeto", "valor_estimado", "status", "vencedor",
      "valor_adjudicado"
    )
  )
  expect_type(out$numero_processo, "integer")
  expect_type(out$valor_estimado, "double")
})

test_that("proposition listing parses XML fragments into columns", {
  csv <- fixture_csv("projetos.csv")
  local_mocked_bindings(alepe_fetch_csv = function(...) csv)

  out <- alepe_bills(year = 2024)
  expect_named(
    out,
    c(
      "docid", "numero", "ano", "legislatura", "tipo", "subtipo",
      "ementa", "data_publicacao", "autores"
    )
  )
  expect_type(out$docid, "integer")
  expect_equal(out$ano[[1]], 2024L)
  expect_equal(out$legislatura[[1]], "VIG\u00c9SIMA")
  expect_s3_class(out$data_publicacao, "Date")
  expect_false(any(grepl("<", out$ementa, fixed = TRUE)))
})

test_that("proposition listing strips HTML from ementa", {
  csv <- fixture_csv("indicacoes.csv")
  local_mocked_bindings(alepe_fetch_csv = function(...) csv)

  out <- alepe_indications(year = 2024)
  expect_gt(nrow(out), 0L)
  # ementas arrive as double-encoded HTML ("&lt;p ...&gt;", "&amp;agrave;")
  expect_false(any(grepl("&lt;|&amp;|<p", out$ementa)))
  expect_false(is.na(out$autores[[1]]))
})

test_that("proposition detail parses one full record", {
  csv <- fixture_csv("projeto_detalhe.csv")
  local_mocked_bindings(alepe_fetch_csv = function(...) csv)

  out <- alepe_bills(number = 3, year = 2024)
  expect_equal(nrow(out), 1L)
  expect_named(
    out,
    c(
      "numero", "ano", "legislatura", "tipo", "autores", "ementa",
      "materia", "justificativa", "regime_tramitacao",
      "impacto_orcamentario", "resultado_final", "data_publicacao",
      "numero_dpl", "lotacao_atual"
    )
  )
  expect_equal(out$numero, 3L)
  expect_equal(out$autores, "Coronel Alberto Feitosa")
  expect_equal(out$regime_tramitacao, "Ordin\u00e1ria")
  expect_equal(out$data_publicacao, as.Date("2024-06-14"))
  expect_match(out$materia, "^Art\\. 1")
})

test_that("detail mode requires year alongside number", {
  expect_error(alepe_bills(number = 10), class = "alepe_error_input")
})
