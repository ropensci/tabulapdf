#' @rdname get_page_dims
#' @title Page length and dimensions
#' @description Get Page Length and Dimensions
#' @param file A character string specifying the path or URL to a PDF file.
#' @param pages An optional integer vector specifying pages to extract from.
#' @param doc Optionally,, in lieu of \code{file}, an rJava reference to a PDDocument Java object.
#' @param password Optionally, a character string containing a user password to access a secured PDF.
#' @param copy Specifies whether the original local file(s) should be copied to
#' \code{tempdir()} before processing. \code{FALSE} by default. The argument is
#' ignored if \code{file} is URL.
#' @details \code{get_n_pages} returns the page length of a PDF document. \code{get_page_dims} extracts the dimensions of specified pages in a PDF document. This can be useful for figuring out how to specify the \code{area} argument in \code{\link{extract_tables}}
#' @return For \code{get_n_pages}, an integer. For \code{get_page_dims}, a list of two-element numeric vectors specifying the width and height of each page, respectively.
#' @references \href{https://tabula.technology/}{Tabula}
#' @author Thomas J. Leeper <thosjleeper@gmail.com>
#' @examples
#' # simple demo file
#' f <- system.file("examples", "mtcars.pdf", package = "tabulapdf")
#'
#' get_n_pages(file = f)
#' get_page_dims(f)
#' @importFrom tools file_path_sans_ext
#' @importFrom rJava J new
#' @seealso \code{\link{extract_tables}}, \code{\link{extract_text}}, \code{\link{make_thumbnails}}
#' @export
get_page_dims <- function(file, doc, pages = NULL, password = NULL, copy = FALSE) {
  if (!missing(file)) {
    doc <- load_doc(file, password = password, copy = copy)
    on.exit(doc$close())
  }

  if (!is.null(pages)) {
    pages <- as.integer(pages)
  } else {
    pages <- 1L:(get_n_pages(doc = doc))
  }

  allpages <- doc$getDocumentCatalog()$getPages()
  lapply(pages, function(x) {
    thispage <- allpages$get(x - 1L)
    c(thispage$getMediaBox()$getWidth(), thispage$getMediaBox()$getHeight())
  })
}

#' @rdname get_page_dims
#' @export
get_n_pages <- function(file, doc, password = NULL, copy = FALSE) {
  if (!missing(file)) {
    doc <- load_doc(file, password = password, copy = copy)
    on.exit(doc$close())
  }
  doc$getNumberOfPages()
}
