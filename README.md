# alepe <img src="man/figures/logo.svg" align="right" height="138" alt="" />

<!-- badges: start -->
[![R-CMD-check](https://github.com/StrategicProjects/alepe/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/StrategicProjects/alepe/actions/workflows/R-CMD-check.yaml)
[![CRAN status](https://www.r-pkg.org/badges/version/alepe)](https://CRAN.R-project.org/package=alepe)
<!-- badges: end -->

Tidy access to the open data API of the Legislative Assembly of the
State of Pernambuco, Brazil ([ALEPE](https://dadosabertos.alepe.pe.gov.br)):
representatives, staff, positions, departments, remuneration, contracts,
procurement, and legislative propositions — as tibbles with clean names
and parsed types.

- Built on [httr2](https://httr2.r-lib.org): local **caching**,
  automatic **retries with exponential backoff**, descriptive user agent.
- **Graceful failures**: network problems warn and return typed
  zero-row tibbles — your pipeline keeps running.
- Friendly progress messages via [cli](https://cli.r-lib.org),
  silenceable with `options(alepe.quiet = TRUE)`.

## Installation

```r
# CRAN (once accepted)
install.packages("alepe")

# Development version
pak::pak("StrategicProjects/alepe")
```

## Quick start

```r
library(alepe)
library(dplyr)

# Current representatives
alepe_representatives()

# Permanent staff, largest departments
alepe_staff(status = "permanent") |>
  count(nome_lotacao, sort = TRUE)

# Contracts active today
alepe_contracts() |>
  filter(vigencia_inicio <= Sys.Date(), vigencia_fim >= Sys.Date())

# Bills of a given year
alepe_bills(year = 2024)
```

Filter values use an English vocabulary (`"permanent"`,
`"commissioned"`, `"seconded"`), but the original API terms
(`"efetivo"`, `"comissionado"`, `"a-disposicao"`) are accepted as well.
Column names keep the official Portuguese field names, normalized to
snake_case, so results stay traceable to the source.

## How it works

Every exported function is a thin wrapper over the same core: a cached,
retrying request whose response is typed into a tibble by a documented
schema. When the API cannot be reached, the call warns and returns a
zero-row tibble with those same columns instead of raising an error.

<img src="man/figures/request-flow.svg" alt="A call to alepe_contracts() goes through alepe_req(), which adds the user agent, a 60 second timeout, a six-hour cache and retries, then alepe_perform() talks to the ALEPE API. A 2xx response is parsed by alepe_fetch_json() and typed by records_to_tibble() into a tibble with data; a timeout or an error surviving the retries produces a classed warning and a zero-row tibble with the same columns." width="100%" />

## Architecture

<img src="man/figures/architecture.svg" alt="Three layers. The endpoint layer holds R/people.R, R/money.R, R/propositions.R and R/cache.R, which export one function per endpoint. They share a core layer: R/req.R for requests, caching, retries and graceful failure, and R/utils.R for naming, typing and Brazilian number and date formats. Below sit the ALEPE open data API and the on-disk response cache." width="100%" />

## Em português

Cada função tem um alias com o nome do próprio endpoint da API, para
quem prefere manter o pipeline inteiro em português. Mesmos argumentos,
mesmos padrões, mesmo resultado:

```r
alepe_parlamentares()
alepe_servidores(status = "efetivo")
alepe_contratos()
alepe_projetos(ano = 2024)
```

`alepe_cargos()`, `alepe_lotacoes()`, `alepe_remuneracao()`,
`alepe_licitacoes()`, `alepe_indicacoes()`, `alepe_requerimentos()` and
`alepe_limpar_cache()` complete the set — see `?alepe_aliases`.

## Related packages

`alepe` belongs to a family of R clients for Brazilian public data that
share the same httr2/cli design and the same graceful-failure contract.
All of them are on CRAN:

| Package | Covers |
| --- | --- |
| [tceper](https://CRAN.R-project.org/package=tceper) | Pernambuco Court of Accounts |
| [BigDataPE](https://CRAN.R-project.org/package=BigDataPE) | Pernambuco state data platform |
| [transferegovr](https://CRAN.R-project.org/package=transferegovr) | Federal transfers ('TransfereGov') |
| [tesouror](https://CRAN.R-project.org/package=tesouror) | National Treasury |
| [obrasgovr](https://CRAN.R-project.org/package=obrasgovr) | Federal public works ('ObrasGov') |
| [comexr](https://CRAN.R-project.org/package=comexr) | Foreign trade statistics ('ComexStat') |
| [datasusr](https://CRAN.R-project.org/package=datasusr) | Public health data ('DATASUS') |
| [ibger](https://CRAN.R-project.org/package=ibger) | 'IBGE' aggregate data |
| [pixr](https://CRAN.R-project.org/package=pixr) | Central Bank 'PIX' open data |

Developed at CASTLab/UFPE and published under
[StrategicProjects](https://github.com/StrategicProjects).

## Code of Conduct

Please note that this project is released with a [Contributor Code of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing you agree to abide by its terms.
