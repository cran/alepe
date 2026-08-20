# alepe 0.1.0

* Initial release.
* Tidy wrappers for all documented v1 endpoints of the ALEPE open data
  API: representatives, staff, positions, departments, remuneration,
  contracts, procurements, and legislative propositions (bills,
  indications, requests).
* Local response cache, exponential-backoff retries, graceful failures
  compliant with the CRAN policy on internet resources.

* Every endpoint function has a Portuguese alias named after the API
  endpoint it wraps (`alepe_servidores()`, `alepe_contratos()`,
  `alepe_projetos()`, ...); see `?alepe_aliases`.
