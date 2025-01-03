context("Non-latin character tests")

test_that("Read Spanish language PDF", {
  # file from "https://github.com/tabulapdf/tabula-java/raw/98957221950af4b90620b51a29e0bbe502eea9ad/src/test/resources/technology/tabula/argentina_diputados_voting_record.pdf"
  f1 <- system.file("examples", "argentina.pdf", package = "tabulapdf")
  t1 <- extract_tables(f1, pages = 1, area = list(c(269.875, 12.75, 790.5, 561)), guess = FALSE)
  t1a <- extract_tables(f1, pages = 1, area = list(c(269.875, 12.75, 790.5, 561)), guess = FALSE, output = "tibble", encoding = "latin1")
  t1b <- extract_tables(f1, pages = 1, area = list(c(269.875, 12.75, 790.5, 561)), guess = FALSE, output = "tibble", encoding = "UTF-8")
  expect_true(is.data.frame(t1[[1]]))
  expect_true(is.data.frame(t1a[[1]]))
  expect_true(is.data.frame(t1b[[1]]))
})

test_that("Read French language PDF w/correct encoding", {
  # file from https://cdn-contenu.quebec.ca/cdn-contenu/adm/min/finances/publications-adm/Comptes-publics/FR/CPFR_Devancement_Preparation.pdf
  f2 <- system.file("examples", "quebec.pdf", package = "tabulapdf")
  t2a <- extract_text(f2, page = 1, encoding = "latin1")
  t2b <- extract_text(f2, page = 1, encoding = "UTF-8")
  expect_false(t2a == t2b)
})
