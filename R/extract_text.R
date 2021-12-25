#' @title extract_text
#' @description Extract text from a file
#' @param file A character string specifying the path or URL to a PDF file, or raw vector with pdf data.
#' @param pages An optional integer vector specifying pages to extract from.
#' @param area An optional list, of length equal to the number of pages specified, where each entry contains a four-element numeric vector of coordinates (top,left,bottom,right) containing the table for the corresponding page. As a convenience, a list of length 1 can be used to extract the same area from all (specified) pages.
#' @param password Optionally, a character string containing a user password to access a secured PDF.
#' @param encoding Optionally, a character string specifying an encoding for the text, to be passed to the assignment method of \code{\link[base]{Encoding}}.
#' @param copy Specifies whether the original local file(s) should be copied to
#' \code{tempdir()} before processing. \code{FALSE} by default. The argument is
#' ignored if \code{file} is URL.
#' @details This function converts the contents of a PDF file into a single unstructured character string.
#' @return If \code{pages = NULL} (the default), a length 1 character vector, otherwise a vector of length \code{length(pages)}.
#' @author Thomas J. Leeper <thosjleeper@gmail.com>
#' @examples
#' \dontrun{
#' # simple demo file
#' f <- system.file("examples", "text.pdf", package = "tabulizer")
#' 
#' # extract all text
#' extract_text(f)
#' 
#' # extract all text from page 1 only
#' extract_text(f, pages = 1)
#' 
#' # extract text from selected area only
#' extract_text(f, area = list(c(209.4, 140.5, 304.2, 500.8)))
#' 
#' }
#' @seealso \code{\link{extract_tables}}, \code{\link{extract_areas}}, \code{\link{split_pdf}}
#' @importFrom rJava J new
#' @export
extract_text <- function(file,
                         pages = NULL,
                         area = NULL,
                         password = NULL,
                         encoding = NULL,
                         copy = FALSE) {
    pdfDocument <- load_doc(file, password = password, copy = copy)
    on.exit(pdfDocument$close())
    
    if (!is.null(pages)) {
      tryCatch(pages <- as.integer(pages),
               error = function(e) {
                 stop("'pages' should be an integer or coercible to integer.")})
    }
    
    if (!is.null(area)) {
      stripper <- new(J("org.apache.pdfbox.text.PDFTextStripperByArea"))
    } else {
      stripper <- new(J("org.apache.pdfbox.text.PDFTextStripper"))
    }
    
    if (!is.null(area)) {
      npages <- pdfDocument$getNumberOfPages()
      area <- make_area(area = area, pages = pages, npages = npages, target = "java")
      if (!is.null(pages)) {
        pageIndex <- pages - 1L
      } else {
        pageIndex <- seq_len(npages) - 1L
      }
      out <- unlist(Map(function(x, y) {
        PDPage <- pdfDocument$getPage(x)
        region <- "text"
        stripper$removeRegion(region)
        stripper$addRegion(region, y)
        stripper$extractRegions(PDPage)
        stripper$getTextForRegion(region)
      }, pageIndex, area))
    } else if (!is.null(pages) && is.null(area)) {
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
