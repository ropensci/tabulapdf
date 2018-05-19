#' @title make_thumbnails
#' @description Convert Pages to Image Thumbnails
#' @param file A character string specifying the path or URL to a PDF file.
#' @param outdir An optional character string specifying a directory into which
#' to split the resulting files. If \code{NULL}, the \code{outdir} is
#' \code{tempdir()}. If \code{file} is a URL, both file and thumbnails are
#' stored in the R session's temporary directory.
#' @param pages An optional integer vector specifying pages to extract from.
#' @param format A character string specifying an image file format.
#' @param resolution A numeric value specifying the image resolution in DPI.
#' @param password Optionally, a character string containing a user password
#' to access a secured PDF.
#' @param copy Specifies whether the original local file(s) should be copied to
#' \code{tempdir()} before processing. \code{FALSE} by default. The argument is
#' ignored if \code{file} is URL.
#' @details This function save each (specified) page of a document as an image
#' with 720 dpi resolution. Images are saved in the same directory as the
#' original file, with file names specified by the original file name,
#' a page number, and the corresponding file format extension.
#' @note This may generate Java \dQuote{INFO} messages in the console,
#' which can be safely ignored.
#' @return A character vector of file paths.
#' @references \href{http://tabula.technology/}{Tabula}
#' @author Thomas J. Leeper <thosjleeper@gmail.com>
#' @examples
#' \donttest{
#' # simple demo file
#' f <- system.file("examples", "data.pdf", package = "tabulizer")
#' 
#' make_thumbnails(f)
#' }
#' @importFrom tools file_path_sans_ext
#' @importFrom rJava J new .jfloat
#' @seealso \code{\link{extract_tables}}, \code{\link{extract_text}},
#' \code{\link{make_thumbnails}}
#' @export
make_thumbnails <- function(file,
                            outdir = NULL,
                            pages = NULL,
                            format = c("png", "jpeg", "bmp", "gif"),
                            resolution = 72,
                            password = NULL,
                            copy = FALSE) {
    file <- localize_file(file, copy = copy)
    pdfDocument <- load_doc(file, password = password, copy = copy)
    on.exit(pdfDocument$close())
    
    if (!is.null(pages)) {
        pages <- as.integer(pages)
    } else {
        pages <- 1L:(get_n_pages(doc = pdfDocument))
    }
    
    format <- match.arg(format)
    fileseq <- formatC(pages, width = max(nchar(pages)), flag = 0)
    if (is.null(outdir)) {
        outdir <- tempdir()
    }
    filename <- paste0(file_path_sans_ext(basename(file)), fileseq, ".", format)
    outfile <- file.path(outdir, filename)

    for (i in seq_along(pages)) {
        pageIndex <- pages[i] - 1L
        PDFRenderer <- new(J("org.apache.pdfbox.rendering.PDFRenderer"),
                           document = pdfDocument)
        BufferedImage <- PDFRenderer$renderImageWithDPI(pageIndex,
                                                        scale = .jfloat(resolution))
        JavaFile <- new(J("java.io.File"), pathname = outfile[i])
        J("javax.imageio.ImageIO")$write(BufferedImage,
                                         format,
                                         JavaFile)
    }
    ifelse(file.exists(outfile), outfile, NA_character_)
}
