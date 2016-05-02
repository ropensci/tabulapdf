context("Test Utilities")

pdffile <- system.file("examples", "data.pdf", package = "tabulizer")
    
test_that("Page dimensions", {
    d <- get_page_dims(pdffile)
    expect_true(is.list(d))
    expect_true(length(d) == 3)
    expect_true(all.equal(d[[1]], c(612, 792)))
})

test_that("Page dimensions", {
    tmp <- tempfile(fileext = ".pdf")
    file.copy(pdffile, tmp)
    m <- make_thumbnails(tmp)
    expect_true(length(m) == 3)
    unlink(m)
})

