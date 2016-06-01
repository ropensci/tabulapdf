#' @title make_thumbnails
#' @description Convert Pages to Image Thumbnails
#' @param file A character string specifying the path or URL to a PDF file.
#' @param outdir An optional character string specifying a directory into which to split the resulting files. If \code{NULL}, the directory of the original PDF is used, unless \code{file} is a URL in which case a temporary directory is used.
#' @param pages An optional integer vector specifying pages to extract from.
#' @param format A character string specifying an image file format.
#' @param resolution An integer specifying the image resolution in DPI.
#' @param password Optionally, a character string containing a user password to access a secured PDF.
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
make_thumbnails <- 
function(file, outdir = NULL, pages = NULL, format = c("png", "jpeg", "bmp", "gif"), resolution = 72L, password = NULL) {
    file <- localize_file(file)
    pdfDocument <- load_doc(file, password = password)
    on.exit(pdfDocument$close())
    
    if (!is.null(pages)) {
        pages <- as.integer(pages)
    } else {
        pages <- 1L:(get_n_pages(doc = pdfDocument))
    }
    
    format <- match.arg(format)
    
    fileseq <- formatC(pages, width = max(nchar(pages)), flag = 0)
    if (is.null(outdir)) {
        outfile <- paste0(file_path_sans_ext(file), fileseq, ".pdf")
    } else {
        outfile <- file.path(outdir, paste0(basename(file_path_sans_ext(file)), fileseq, ".pdf"))
    }
    
    for (i in seq_along(pages)) {
        PDFImageWriter <- new(J("org.apache.pdfbox.util.PDFImageWriter"))
        PDFImageWriter$writeImage(pdfDocument, format, "", pages[i], pages[i], 
                                  outfile[i], 1L, as.integer(resolution))
    }
    ifelse(file.exists(outfile), outfile, NA_character_)
}
