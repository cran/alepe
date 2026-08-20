test_that("clean_names normalizes accents, case and separators", {
  expect_equal(
    clean_names(c("NOME_LOTAÇÃO", "CARGO NÍVEL", "CPF/CNPJ ")),
    c("nome_lotacao", "cargo_nivel", "cpf_cnpj")
  )
})

test_that("clean_names splits camelCase API field names", {
  expect_equal(
    clean_names(c(
      "nomeParlamentar", "cpfCnpj", "vigenciaInicio",
      "mesCompetencia", "dataPublicacao"
    )),
    c(
      "nome_parlamentar", "cpf_cnpj", "vigencia_inicio",
      "mes_competencia", "data_publicacao"
    )
  )
})

test_that("parse_br_number handles both API number encodings", {
  expect_equal(
    parse_br_number(c(
      "1.234,56", # Brazilian money string
      "119267.04", # plain float string
      "2026.00", # float-formatted integer
      "R$ 10,50", # currency prefix
      "12.345.678", # pure 3-digit groups: grouping dots
      "256", # plain integer
      "" # empty -> NA
    )),
    c(1234.56, 119267.04, 2026, 10.5, 12345678, 256, NA_real_)
  )
})

test_that("map_status accepts English and Portuguese vocabularies", {
  expect_null(map_status(NULL))
  expect_equal(map_status("permanent"), "efetivo")
  expect_equal(map_status("efetivo"), "efetivo")
  expect_equal(map_status("seconded"), "a-disposicao")
  expect_error(map_status("nope"), class = "rlang_error")
})

test_that("records_to_tibble builds typed tibbles and handles NULL", {
  schema <- c(nome = "chr", total = "int", valor = "brl", inicio = "date")

  empty <- records_to_tibble(NULL, schema)
  expect_s3_class(empty, "tbl_df")
  expect_equal(nrow(empty), 0L)
  expect_type(empty$total, "integer")
  expect_s3_class(empty$inicio, "Date")

  recs <- list(
    list(
      NOME = "ANA", TOTAL = "12",
      VALOR = "1.234,56", INICIO = "01/02/2024"
    ),
    list(NOME = "BIA", TOTAL = "3", VALOR = "10,00", INICIO = "2024-03-05")
  )
  out <- records_to_tibble(recs, schema)
  expect_equal(out$total, c(12L, 3L))
  expect_equal(out$valor, c(1234.56, 10))
  expect_equal(out$inicio, as.Date(c("2024-02-01", "2024-03-05")))
})

test_that("missing fields become NA, extra fields are ignored", {
  schema <- c(nome = "chr", email = "chr")
  recs <- list(list(NOME = "ANA", PARTIDO = "XYZ"))
  out <- records_to_tibble(recs, schema)
  expect_equal(out$nome, "ANA")
  expect_true(is.na(out$email))
  expect_named(out, c("nome", "email"))
})

test_that("Portuguese aliases forward to their English counterparts", {
  records <- jsonlite::read_json(testthat::test_path("fixtures", "servidores.json"))
  local_mocked_bindings(alepe_fetch_json = function(...) records)

  expect_identical(alepe_servidores(), alepe_staff())
  expect_identical(
    alepe_servidores(status = "efetivo"),
    alepe_staff(status = "permanent")
  )
})

test_that("proposition aliases translate Portuguese argument names", {
  csv <- readr::read_csv(
    testthat::test_path("fixtures", "projetos.csv"),
    locale = readr::locale(encoding = "UTF-8"),
    show_col_types = FALSE, progress = FALSE
  )
  local_mocked_bindings(alepe_fetch_csv = function(...) csv)

  expect_identical(alepe_projetos(ano = 2024), alepe_bills(year = 2024))
  expect_error(alepe_projetos(numero = 10), class = "alepe_error_input")
})

test_that("every English endpoint has a Portuguese alias", {
  exported <- getNamespaceExports("alepe")
  aliases <- c(
    "alepe_parlamentares", "alepe_servidores", "alepe_cargos",
    "alepe_lotacoes", "alepe_remuneracao", "alepe_contratos",
    "alepe_licitacoes", "alepe_projetos", "alepe_indicacoes",
    "alepe_requerimentos", "alepe_limpar_cache"
  )
  expect_true(all(aliases %in% exported))
})
