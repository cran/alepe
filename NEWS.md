# alepe 0.1.1

* `alepe_staff()` gains `status = "lent"` (API term `"efetivo-cedido"`):
  the Assembly's own permanent staff lent to other bodies. The API
  publishes them with `vinculo` `"Efetivo"`, so this server-side filter
  is the only way to single them out. `alepe_positions()` does not accept
  it, because `/cargos` ignores the value and returns every status.
* An invalid `status` in `alepe_staff()` / `alepe_positions()` (and
  their aliases) is now an error, as documented. It used to be evaluated
  inside the fetch layer's error handler and surfaced as a warning that
  the API could not be reached, followed by an empty tibble.
* Author metadata: the maintainer's name is spelled André Leite; Marcos
  Wasiliew's e-mail address is updated; ORCIDs added for Marcos Wasiliew
  and Júlia Nascimento Barreto.

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
