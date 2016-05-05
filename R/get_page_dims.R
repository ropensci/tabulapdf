#' @title get_page_dims
#' @description Get Page Dimensions
#' @param file A character string specifying the path or URL to a PDF file.
#' @param pages An optional integer vector specifying pages to extract from.
#' @details This function extracts the dimensions of pages in a PDF document. This can be useful for figuring out how to specify the \code{area} argument in \code{\link{extract_tables}}
#' @return A list of two-element numeric vectors specifying the width and height of each page, respectively.
#' @references \href{http://tabula.technology/}{Tabula}
#' @author Thomas J. Leeper <thosjleeper@gmail.com>
#' @examples
#' \dontrun{
#' # simple demo file
#' f <- system.file("examples", "data.pdf", package = "tabulizer")
#' 
#' get_page_dims(f)
#' }
#' @importFrom tools file_path_sans_ext
#' @importFrom rJava J new
#' @seealso \code{\link{extract_tables}}, \code{\link{extract_text}}, \code{\link{make_thumbnails}}
#' @export
get_page_dims <- function(file, pages = NULL) {
    file <- localize_file(path = file)
    pdfDocument <- new(J("org.apache.pdfbox.pdmodel.PDDocument"))
    doc <- pdfDocument$load(file)
    pdfDocument$close()
    on.exit(doc$close())
    
    if (!is.null(pages)) {
        pages <- as.integer(pages)
    } else {
        pages <- 1L:(doc$getDocumentCatalog()$getAllPages()$size())
    }
    
    allpages <- doc$getDocumentCatalog()$getAllPages()
    lapply(pages, function(x) {
        thispage <- allpages$get(x-1L)
        c(thispage$getMediaBox()$getWidth(), thispage$getMediaBox()$getHeight())
    })
}
