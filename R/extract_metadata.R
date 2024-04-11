#' @title extract_metadata
#' @description Extract metadata from a file
#' @param file A character string specifying the path or URL to a PDF file.
#' @param password Optionally, a character string containing a user password to access a secured PDF.
#' @param copy Specifies whether the original local file(s) should be copied to
#' \code{tempdir()} before processing. \code{FALSE} by default. The argument is
#' ignored if \code{file} is URL.
#' @details This function extracts metadata from a PDF
#' @return A list.
#' @author Thomas J. Leeper <thosjleeper@gmail.com>
#' @examples
#' \dontrun{
#' # simple demo file
#' f <- system.file("examples", "data.pdf", package = "tabulapdf")
#'
#' extract_metadata(f)
#' }
#' @seealso \code{\link{extract_tables}}, \code{\link{extract_areas}}, \code{\link{extract_text}}, \code{\link{split_pdf}}
#' @importFrom rJava J new
#' @export
extract_metadata <- function(file, password = NULL, copy = FALSE) {
    pdfDocument <- load_doc(file, password = password, copy = copy)
    on.exit(pdfDocument$close())

    info <- pdfDocument$getDocumentInformation()
    list(
        pages = pdfDocument$getNumberOfPages(),
        title = info$getTitle(),
        author = info$getAuthor(),
        subject = info$getSubject(),
        keywords = info$getKeywords(),
        creator = info$getCreator(),
        producer = info$getProducer(),
        created = info$getCreationDate()$getTime()$toString(),
        modified = info$getModificationDate()$getTime()$toString(),
        trapped = info$getTrapped()
    )
}
