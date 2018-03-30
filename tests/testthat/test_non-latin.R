context("Non-latin character tests")

test_that("Read Spanish language PDF", {
    f1 <- "https://github.com/tabulapdf/tabula-java/raw/98957221950af4b90620b51a29e0bbe502eea9ad/src/test/resources/technology/tabula/argentina_diputados_voting_record.pdf"
    expect_true(is.matrix(extract_tables(f1, pages = 1, area = list(c(269.875, 12.75, 790.5, 561)))[[1]]))
    t1a <- extract_tables(f1, pages = 1, area = list(c(269.875, 12.75, 790.5, 561)), method = "data.frame", encoding = "latin1")
    #expect_true(names(t1a[[1]])[2] == "Frente.CÃ.vico.por.Santiago", label = "latin1 encoding worked")
    t1b <- extract_tables(f1, pages = 1, area = list(c(269.875, 12.75, 790.5, 561)), method = "data.frame", encoding = "UTF-8")
    #expect_true(names(t1b[[1]])[2] == "Frente.Cívico.por.Santiago", label = "UTF-8 encoding worked")
    
})

test_that("Read French language PDF w/correct encoding", {
    f2 <- "http://publications-sfds.math.cnrs.fr/index.php/J-SFdS/article/download/514/486"
    t2a <- extract_text(f2, page = 1, encoding = "latin1")[[1]]
    t2b <- extract_text(f2, page = 1, encoding = "UTF-8")[[1]]
    #expect_true(nchar(strsplit(t2a, "\n")[[1]][1]) == 50, label = "latin1 encoding worked")
    #expect_true(nchar(strsplit(t2b, "\n")[[1]][1]) == 47, label = "UTF-8 encoding worked")
})
