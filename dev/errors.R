# devtools::install()

library(tabulapdf)

out <- extract_tables("inst/examples/data.pdf", pages = 1, output = "data.frame")

out
