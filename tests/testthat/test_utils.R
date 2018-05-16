context("Test Utilities")

pdffile <- system.file("examples", "data.pdf", package = "tabulizer")

test_that("File localization does not overwrite existing temporary file", {
  tmp <- tempfile(fileext = ".pdf")
  file.copy(from = pdffile, to = tmp)
  localfile <- tabulizer:::localize_file(tmp, copy = TRUE)
  expect_identical(tmp, localfile)
})
    
test_that("Page length", {
    np <- get_n_pages(file = pdffile)
    expect_true(np == 3)
})

test_that("Page dimensions", {
    d1 <- get_page_dims(pdffile)
    expect_true(is.list(d1))
    expect_true(length(d1) == 3)
    expect_true(all.equal(d1[[1]], c(612, 792)))
    d2 <- get_page_dims(pdffile, pages = 1)
    expect_true(length(d2) == 1)
})

test_that("Make thumbnails", {
    tmp <- tempfile(fileext = ".pdf")
    file.copy(from = pdffile, to = tmp)
    m1 <- make_thumbnails(tmp)
    expect_true(length(m1) == 3)
    unlink(m1)
    m2 <- make_thumbnails(tmp, pages = 1)
    expect_true(length(m2) == 1)
    unlink(m2)
})

test_that("Extract Metadata", {
    expect_true(is.list(extract_metadata(pdffile)))
})

test_that("Extract text", {
    expect_true(is.character(extract_text(pdffile)))
    expect_true(length(extract_text(pdffile)) == 1)
    expect_true(length(extract_text(pdffile, pages = 2)) == 1)
    expect_true(length(extract_text(pdffile, pages = c(1,3))) == 2)
})

test_that("Repeat areas", {
    a1 <- tabulizer:::make_area(list(c(0, 0, 10, 10)), pages = 1)
    a2 <- tabulizer:::make_area(list(c(0, 0, 10, 10)), pages = 1:2)
    a3 <- tabulizer:::make_area(list(c(0, 0, 10, 10)), npages = 2)
    expect_true(length(a1) == 1)
    expect_true(length(a2) == 2)
    expect_true(length(a3) == 2)
})

test_that("make_area errors", {
    expect_error(tabulizer:::make_area(1L))
    expect_error(tabulizer:::make_area(list(c(0,0,10,10), c(0,0,10,10)), pages = 1))
    expect_error(tabulizer:::make_area(list(c(0,0,10,10), c(0,0,10,10)), npages = 3))
})

test_that("Repeat columns", {
    c1 <- tabulizer:::make_columns(list(c(0, 0, 10, 10)), pages = 1)
    c2 <- tabulizer:::make_columns(list(c(0, 0, 10, 10)), pages = 1:2)
    c3 <- tabulizer:::make_columns(list(c(0, 0, 10, 10)), npages = 2)
    expect_true(length(c1) == 1)
    expect_true(length(c2) == 2)
    expect_true(length(c3) == 2)
})

test_that("make_columns errors", {
    expect_error(tabulizer:::make_columns(1L))
    expect_error(tabulizer:::make_columns(list(c(0,1,2,3), c(0,1,2,3)), pages = 1))
    expect_error(tabulizer:::make_columns(list(c(0,1,2,3), c(0,1,2,3)), npages = 3))
})
