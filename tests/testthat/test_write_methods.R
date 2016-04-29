context("Table writing methods")

pdffile <- system.file("examples", "data.pdf", package = "tabulizer")
tabs <- extract_tables(pdffile, method = "I")
    
test_that("Java reference return", {
    expect_true(inherits(tabs, "jobjRef"))
})

test_that("Make list of matrices", {
    t1 <- tabulizer:::list_matrices(tabs)
    expect_true(is.list(t1))
    expect_true(is.matrix(t1[[1]]))
    expect_true(ncol(t1[[1]]) == 10)
    expect_true(nrow(t1[[1]]) == 32)
})

test_that("Make list of character vectors", {
    t2 <- tabulizer:::list_characters(tabs)
    expect_true(is.list(t2))
    expect_true(is.character(t2[[1]]))
})

test_that("Make list of data.frames", {
    t3 <- tabulizer:::list_data_frames(tabs)
    expect_true(is.list(t3))
    expect_true(is.data.frame(t3[[1]]))
})

test_that("Write CSV Files", {
    tmp4 <- tempfile()
    t4 <- tabulizer:::write_csvs(tabs, file = tmp4)
    expect_true(is.character(t4))
    expect_true(length(dir(t4, pattern = "csv$")) == 4)
})

test_that("Write TSV Files", {
    tmp5 <- tempfile()
    t5 <- tabulizer:::write_tsvs(tabs, file = tmp5)
    expect_true(is.character(t5))
    expect_true(length(dir(t5, pattern = "tsv$")) == 4)
})

test_that("Write JSON Files", {
    tmp6 <- tempfile()
    t6 <- tabulizer:::write_jsons(tabs, file = tmp6)
    expect_true(is.character(t6))
    expect_true(length(dir(t6, pattern = "json$")) == 4)
})
