#' @title make_thumbnails
#' @description Convert Pages to Image Thumbnails
#' @param file A character string specifying the path or URL to a PDF file.
#' @param pages An optional integer vector specifying pages to extract from.
#' @param format A character string specifying an image file format.
#' @param resolution An integer specifying the image resolution in DPI.
#' @details This function save each (specified) page of a document as an image with 720 dpi resolution. Images are saved in the same directory as the original file, with file names specified by the original file name, a page number, and the corresponding file format extension.
#' @note This may generate Java \dQuote{INFO} messages in the console, which can be safely ignored.
#' @return A character vector of file paths.
#' @references \href{http://tabula.technology/}{Tabula}
#' @author Thomas J. Leeper <thosjleeper@gmail.com>
#' @examples
#' \dontrun{
#' # simple demo file
#' f <- system.file("examples", "data.pdf", package = "tabulizer")
#' 
#' make_thumbnails(f)
#' }
#' @importFrom tools file_path_sans_ext
#' @importFrom rJava J new
#' @seealso \code{\link{extract_tables}}, \code{\link{extract_text}}, \code{\link{make_thumbnails}}
#' @export
make_thumbnails <- function(file, pages = NULL, format = c("png", "jpeg", "bmp", "gif"), resolution = 72L) {
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
    
    format <- match.arg(format)
    
    out <- lapply(pages, function(x) {
        PDFImageWriter <- new(J("org.apache.pdfbox.util.PDFImageWriter"))
        PDFImageWriter$writeImage(doc, format, "", x, x, file_path_sans_ext(file), 1L, as.integer(resolution))
    })
    out <- unlist(out)
    ifelse(out, paste0(file_path_sans_ext(file), pages, ".", format), NA_character_)
}
