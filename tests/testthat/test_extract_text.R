context("Minimum functionality of extract_text")

sf <- system.file("examples", "text.pdf", package = "tabulapdf")

test_that("Text can be extracted from the whole document", {
  txt <- extract_text(sf, encoding = "UTF-8")
  txt <- gsub("[\r\n]", " ", txt)
  txt <- gsub("\\s+$", "", txt)
  expect_identical(txt, "42 is the number from which the meaning of life, the universe, and everything can be derived. 42 is the number from which the meaning of life, the universe, and everything can be derived.")
})

test_that("'page' argument in extract_text works", {
  txt <- extract_text(sf, pages = 1, encoding = "UTF-8")
  txt <- gsub("[\r\n]", " ", txt)
  txt <- gsub("\\s+$", "", txt)
  expect_identical(txt, "42 is the number from which the meaning of life, the universe, and everything can be derived.")
})

test_that("'area' argument in extract_text works", {
  txt <- extract_text(sf, area = list(c(10, 15, 100, 550)), encoding = "UTF-8")
  txt <- gsub("[\r\n]", " ", txt)
  txt <- gsub("\\s+$", "", txt)
  expect_identical(txt[1], "42 is the number from which the meaning of life, the universe, and everything can be derived.")
})

test_that("'area' and 'page' arguments in extract_text work together", {
  txt <- extract_text(sf, pages = 1, area = list(c(10, 15, 100, 550)), encoding = "UTF-8")
  txt <- gsub("[\r\n]", " ", txt)
  txt <- gsub("\\s+$", "", txt)
  expect_identical(txt, "42 is the number from which the meaning of life, the universe, and everything can be derived.")
})

test_that("Multiple pages with different areas can be extracted", {
  txt <- extract_text(sf,
    pages = c(1, 2),
    area = list(
      c(10, 15, 100, 550),
      c(10, 15, 100, 500)
    ), encoding = "UTF-8"
  )
  txt <- gsub("[\r\n]", " ", txt)
  txt <- gsub("\\s+$", "", txt)

  expect_identical(
    txt,
    c(
      "42 is the number from which the meaning of life, the universe, and everything can be derived.",
      "42 is the number from which the meaning of life, the universe, and everything can be deriv"
    )
  )
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
