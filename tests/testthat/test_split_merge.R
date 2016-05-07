context("Test Split/Merge")

pdffile <- system.file("examples", "data.pdf", package = "tabulizer")
s <- split_pdf(pdffile)
tmp <- tempfile()
m <- merge_pdfs(s, outfile = tmp)

test_that("Split PDF", {
    expect_true(is.character(s))
    expect_true(length(s) == 3)
    expect_true(get_n_pages(file = s[1]) == 1)
    expect_true(all(file.exists(s)))
})

test_that("Merge PDFs", {
    expect_true(file.exists(tmp))
    expect_true(get_n_pages(file = tmp) == 3)
})
