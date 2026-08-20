op <- options(
  alepe.quiet = TRUE,
  alepe.cache_dir = file.path(tempdir(), "alepe-test-cache"),
  alepe.max_tries = 1
)

withr::defer(options(op), teardown_env())
