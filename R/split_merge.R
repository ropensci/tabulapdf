#' @rdname split_merge
#' @title Split and merge PDFs
#' @description Split PDF into separate pages or merge multiple PDFs into one.
#' @param file For \code{merge_pdfs}, a character vector specifying the path to one or more local PDF files. For \code{split_pdf}, a character string specifying the path or URL to a PDF file.
#' @param outfile A character string specifying the path to the PDF file to create from the merged documents.
#' @details \code{\link{split_pdf}} splits the file listed in \code{file} into separate one-page doucments. \code{\link{merge_pdfs}} creates a single PDF document from multiple separate PDF files.
#' @return For \code{split_pdfs}, a character vector specifying the output file names, which are patterned after the value of \code{file}. For \code{merge_pdfs}, the value of \code{outfile}.
#' @author Thomas J. Leeper <thosjleeper@gmail.com>
#' @examples
#' \dontrun{
#' # simple demo file
#' f <- system.file("examples", "data.pdf", package = "tabulizer")
#' get_n_pages(file = f)
#' 
#' # split PDF by page
#' sf <- split_pdf(f)
#' 
#' # merge pdf
#' merge_pdfs(sf, "merged.pdf")
#' get_n_pages(file = "merged.pdf")
#' }
#' @seealso \code{\link{extract_areas}}, \code{\link{get_page_dims}}, \code{\link{make_thumbnails}}
#' @import tabulizerjars
#' @importFrom rJava J new
#' @importFrom tools file_path_sans_ext
#' @export
split_pdf <- function(file) {

    pdfDocument <- load_doc(file)
    on.exit(pdfDocument$close())
    splitter <- new(J("org.apache.pdfbox.util.Splitter"))
    splitArray <- splitter$split(pdfDocument)
    iterator <- splitArray$iterator()
    p <- 1L
    outfile <- paste0(file_path_sans_ext(file), 1:splitArray$size(), ".pdf")
    while (iterator$hasNext()) {
        doc <- J(iterator, "next")
        doc$save(outfile[p])
        doc$close()
        p <- p + 1L
        rm(doc)
    }
    outfile
}

#' @rdname split_merge
#' @export
merge_pdfs <- function(file, outfile) {
    merger <- new(J("org.apache.pdfbox.util.PDFMergerUtility"))
    merger$setDestinationFileName(outfile)
    lapply(file, merger$addSource)
    merger$mergeDocuments()
    outfile
}
