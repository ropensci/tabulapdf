# devtools::install()

library(tabulapdf)

out <- extract_tables("inst/examples/data.pdf", pages = 1, output = "tibble")

class(out)

class(out[[1]])

library(tibble)

out
