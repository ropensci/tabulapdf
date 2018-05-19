context("Minimum functionality of extract_text")

sf <- system.file("examples", "text.pdf", package = "tabulizer")

test_that("Text can be extracted from the whole document", {
  txt <- extract_text(sf, encoding = "UTF-8")
  cite <- paste(format(citation(), style = "citation"), collapse = "")
  striptxt <- gsub("[[:space:]+]", "", txt)
  stripcite <- gsub("[[:space:]+]", "", cite)
  expect_identical(nchar(striptxt), 2L*nchar(stripcite))
})

test_that("'page' argument in extract_text works", {
  txt <- extract_text(sf, pages = 1, encoding = "UTF-8")
  cite <- paste(format(citation(), style = "citation"), collapse = "")
  striptxt <- gsub("[[:space:]+]", "", txt)
  stripcite <- gsub("[[:space:]+]", "", cite)
  expect_identical(nchar(striptxt), nchar(stripcite))
})

test_that("'area' argument in extract_text works", {
  txt <- extract_text(sf, area = list(c(209.4, 140.5, 304.2, 500.8)), encoding = "UTF-8")
  txt <- paste(txt, collapse = "")
  bibtex <- paste(as.character(toBibtex(citation())), collapse = "")
  striptxt <- gsub("[[:space:]+]", "", txt)
  stripbib <- gsub("[[:space:]+]", "", bibtex)
  expect_identical(nchar(striptxt), 2L*nchar(stripbib))
})

test_that("'area' and 'page' arguments in extract_text work together", {
  txt <- extract_text(sf, pages = 1, area = list(c(209.4, 140.5, 304.2, 500.8)), encoding = "UTF-8")
  bibtex <- paste(as.character(toBibtex(citation())), collapse = "")
  striptxt <- gsub("[[:space:]+]", "", txt)
  stripbib <- gsub("[[:space:]+]", "", bibtex)
  expect_identical(nchar(striptxt), nchar(stripbib))
})

test_that("Multiple pages with different areas can be extracted", {
  txt <- extract_text(sf, pages = c(1, 2),
                      area = list(c(124, 131, 341.6, 504.3),
                                  c(209.4, 140.5, 304.2, 500.8)), encoding = "UTF-8")
  txt <- paste(txt, collapse = "")
  cite <- paste(format(citation(), style = "citation"), collapse = "")
  bibtex <- paste(as.character(toBibtex(citation())), collapse = "")
  striptxt <- gsub("[[:space:]+]", "", txt)
  stripcite <- gsub("[[:space:]+]", "", cite)
  stripbib <- gsub("[[:space:]+]", "", bibtex)
  bothpages <- paste0(stripcite, stripbib)
  expect_identical(nchar(striptxt), nchar(bothpages))
})

test_that("Test 'copy' argument", {
  fls <- list.files(tempdir())
  filepath <- file.path(tempdir(), basename(sf))
  txt <- extract_text(sf, encoding = "UTF-8", copy = TRUE)
  fls2 <- list.files(tempdir())
  expect_identical(length(fls) + 1L, length(fls2))
  expect_true(file.exists(filepath))
  unlink(filepath)
})
