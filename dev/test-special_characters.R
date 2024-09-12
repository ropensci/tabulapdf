devtools::load_all()
libname <- "/home/pacha/R/x86_64-pc-linux-gnu-library/4.4"
pkgname <- "tabulapdf"
rJava::.jpackage(pkgname, jars = "*", lib.loc = libname)
rJava::J("java.lang.System")$setProperty("java.awt.headless", "true")

file <- "inst/examples/xbar.pdf"
pages <- NULL
area <- NULL
password <- NULL
encoding <- NULL
copy <- FALSE

pdfDocument <- load_doc(file, password = password, copy = copy)
on.exit(pdfDocument$close())

stripper <- new(J("org.apache.pdfbox.text.PDFTextStripper"))

if (is.null(stripper)) {
  stop("Failed to initialize PDFTextStripper.")
}

stripper$setSortByPosition(TRUE)
stripper$setAddMoreFormatting(TRUE)

out <- stripper$getText(pdfDocument)
