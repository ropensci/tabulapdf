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
#' # simple demo file
#' f <- system.file("examples", "mtcars.pdf", package = "tabulapdf")
#'
#' extract_metadata(f)
#' @seealso \code{\link{extract_tables}}, \code{\link{extract_areas}}, \code{\link{extract_text}}, \code{\link{split_pdf}}
#' @importFrom rJava J new
#' @export
extract_metadata <- function(file, password = NULL, copy = FALSE) {
  pdfDocument <- load_doc(file, password = password, copy = copy)
  on.exit(pdfDocument$close())

  info <- pdfDocument$getDocumentInformation()

  info_creation_date <- info$getCreationDate()
  info_modification_date <- info$getModificationDate()

  if (!is.null(info_creation_date)) {
    info_creation_date <- info_creation_date$getTime()$toString()
  }

  if (!is.null(info_modification_date)) {
    info_modification_date <- info_modification_date$getTime()$toString()
  }

  list(
    pages = pdfDocument$getNumberOfPages(),
    title = info$getTitle(),
    author = info$getAuthor(),
    subject = info$getSubject(),
    keywords = info$getKeywords(),
    creator = info$getCreator(),
    producer = info$getProducer(),
    created = info_creation_date,
    modified = info_modification_date,
    trapped = info$getTrapped()
  )
}
