context("Minimum functionality of extract_tables")

test_that("It basically works", {
    tab <- extract_tables(system.file("examples", "data.pdf", package = "tabulizer"))
    expect_true(is.list(tab))
})
