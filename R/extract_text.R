#' @title extract_text
#' @description Extract text from a file
#' @param file A character string specifying the path or URL to a PDF file.
#' @param pages An optional integer vector specifying pages to extract from.
#' @param password Optionally, a character string containing a user password to access a secured PDF.
#' @param encoding Optionally, a character string specifying an encoding for the text, to be passed to the assignment method of \code{\link[base]{Encoding}}.
#' @details This function converts the contents of a PDF file into a single unstructured character string.
#' @return If \code{pages = NULL} (the default), a length 1 character vector, otherwise a vector of length \code{length(pages)}.
#' @author Thomas J. Leeper <thosjleeper@gmail.com>
#' @examples
#' \dontrun{
#' # simple demo file
#' f <- system.file("examples", "data.pdf", package = "tabulizer")
#' 
#' # extract all text from page 1 only
#' extract_text(f, from = 1, to = 1)
#' 
#' # extract all text
#' extract_text(f)
#' }
#' @seealso \code{\link{extract_tables}}, \code{\link{extract_areas}}, \code{\link{split_pdf}}
#' @importFrom rJava J new
#' @export
extract_text <- function(file, pages = NULL, password = NULL, encoding = NULL) {
    pdfDocument <- load_doc(file, password = password)
    on.exit(pdfDocument$close())
    
    stripper <- new(J("org.apache.pdfbox.util.PDFTextStripper"))
    
    if (!is.null(pages)) {
        pages <- as.integer(pages)
        out <- unlist(lapply(pages, function(x) {
            stripper$setStartPage(x)
            stripper$setEndPage(x)
            stripper$getText(pdfDocument)
        }))
    } else {
        out <- stripper$getText(pdfDocument)
    }
    if (!is.null(encoding)) {
        Encoding(out) <- encoding
    }
    out
}
