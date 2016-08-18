#' @rdname split_merge
#' @title Split and merge PDFs
#' @description Split PDF into separate pages or merge multiple PDFs into one.
#' @param file For \code{merge_pdfs}, a character vector specifying the path to one or more \emph{local} PDF files. For \code{split_pdf}, a character string specifying the path or URL to a PDF file.
#' @param outdir For \code{split_pdf}, an optional character string specifying a directory into which to split the resulting files. If \code{NULL}, the directory of the original PDF is used, unless \code{file} is a URL in which case a temporary directory is used.
#' @param outfile For \code{merge_pdfs}, a character string specifying the path to the PDF file to create from the merged documents.
#' @param password Optionally, a character string containing a user password to access a secured PDF. Currently, encrypted PDFs cannot be merged with \code{merge_pdfs}.
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
split_pdf <- function(file, outdir = NULL, password = NULL) {
    file <- localize_file(file, copy = TRUE)
    pdfDocument <- load_doc(file, password = password)
    on.exit(pdfDocument$close())
    splitter <- new(J("org.apache.pdfbox.util.Splitter"))
    splitArray <- splitter$split(pdfDocument)
    iterator <- splitArray$iterator()
    p <- 1L
    
    fileseq <- formatC(1:splitArray$size(), width = nchar(splitArray$size()), flag = 0)
    if (is.null(outdir)) {
        outfile <- paste0(file_path_sans_ext(file), fileseq, ".pdf")
    } else {
        outfile <- file.path(outdir, paste0(basename(file_path_sans_ext(file)), fileseq, ".pdf"))
    }
    
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
    outfile <- path.expand(outfile)
    file <- unlist(lapply(file, localize_file, copy = TRUE))
    merger <- new(J("org.apache.pdfbox.util.PDFMergerUtility"))
    merger$setDestinationFileName(outfile)
    lapply(file, merger$addSource)
    merger$mergeDocuments()
    outfile
}
