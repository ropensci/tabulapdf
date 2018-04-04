context("Minimum functionality of extract_text")

sf <- system.file("examples", "text.pdf", package = "tabulizer")

test_that("Text can be extracted from the whole document", {
  txt <- extract_text(sf)
  cite <- paste(format(citation()), collapse = "")
  striptxt <- gsub("[[:space:]+]", "", txt)
  stripcite <- gsub("[[:space:]+]", "", cite)
  expect_true(nchar(striptxt)/2 == nchar(stripcite))
})

test_that("'page' argument in extract_text works", {
  txt <- extract_text(sf, pages = 1)
  cite <- paste(format(citation()), collapse = "")
  striptxt <- gsub("[[:space:]+]", "", txt)
  stripcite <- gsub("[[:space:]+]", "", cite)
  expect_true(nchar(striptxt) == nchar(striptxt))
})

test_that("'area' argument in extract_text works", {
  txt <- extract_text(sf, area = list(c(209.4, 140.5, 304.2, 500.8)))
  txt <- paste(txt, collapse = "")
  bibtex <- paste(as.character(toBibtex(citation())), collapse = "")
  striptxt <- gsub("[[:space:]+]", "", txt)
  stripbib <- gsub("[[:space:]+]", "", bibtex)
  expect_true(nchar(striptxt) == 2*nchar(stripbib))
})

test_that("'area' and 'page' arguments in extract_text work", {
  txt <- extract_text(sf, pages = 1, area = list(c(209.4, 140.5, 304.2, 500.8)))
  bibtex <- paste(as.character(toBibtex(citation())), collapse = "")
  striptxt <- gsub("[[:space:]+]", "", txt)
  stripbib <- gsub("[[:space:]+]", "", bibtex)
  expect_true(nchar(striptxt) == nchar(stripbib))
})
