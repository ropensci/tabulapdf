#' @title extract_tables
#' @description Extract tables from a file
#' @param file A character string specifying the path or URL to a PDF file.
#' @param pages An optional integer vector specifying pages to extract from.
#' @param area An optional list, of length equal to the number of pages specified, where each entry contains a four-element numeric vector of coordinates (top,left,bottom,right) containing the table for the corresponding page. As a convenience, a list of length 1 can be used to extract the same area from all (specified) pages. Only specify \code{area} xor \code{columns}.
#' @param columns An optional list, of length equal to the number of pages specified, where each entry contains a numeric vector of horizontal (x) coordinates separating columns of data for the corresponding page. As a convenience, a list of length 1 can be used to specify the same columns for all (specified) pages. Only specify \code{area} xor \code{columns}.
#' @param guess A logical indicating whether to guess the locations of tables on each page. If \code{FALSE}, \code{area} or \code{columns} must be specified; if \code{TRUE}, columns is ignored.
#' @param method A string identifying the prefered method of table extraction.
#' \itemize{
#'   \item \code{method = "decide"} (default) automatically decide (for each page) whether spreadsheet-like formatting is present and "lattice" is appropriate
#'   \item \code{method = "lattice"} use Tabula's spreadsheet extraction algorithm
#'   \item \code{method = "stream"} use Tabula's basic extraction algorithm
#' }
#' @param output A function to coerce the Java response object (a Java ArrayList of Tabula Tables) to some output format. The default method, \dQuote{matrices}, returns a list of character matrices. See Details for other options.
#' @param outdir Output directory for files if \code{output} is set to
#' \code{"csv"}, \code{"tsv"} or \code{"json"}, ignored otherwise. If equals
#' \code{NULL} (default), uses R sessions temporary directory \code{tempdir()}.
#' @param password Optionally, a character string containing a user password to access a secured PDF.
#' @param encoding Optionally, a character string specifying an encoding for the text, to be passed to the assignment method of \code{\link[base]{Encoding}}.
#' @param copy Specifies whether the original local file(s) should be copied to
#' \code{tempdir()} before processing. \code{FALSE} by default. The argument is
#' ignored if \code{file} is URL.
#' @param \dots These are additional arguments passed to the internal functions dispatched by \code{method}.
#' @details This function mimics the behavior of the Tabula command line utility. It returns a list of R character matrices containing tables extracted from a file by default. This response behavior can be changed by using the following options.
#' \itemize{
#'   \item \code{output = "character"} returns a list of single-element character vectors, where each vector is a tab-delimited, line-separate string of concatenated table cells.
#'   \item \code{output = "data.frame"} attempts to coerce the structure returned by \code{method = "character"} into a list of data.frames and returns character strings where this fails.
#'   \item \code{output = "csv"} writes the tables to comma-separated (CSV) files using Tabula's CSVWriter method in the same directory as the original PDF. \code{method = "tsv"} does the same but with tab-separated (TSV) files using Tabula's TSVWriter and \code{method = "json"} does the same using Tabula's JSONWriter method. Any of these three methods return the path to the directory containing the extract table files.
#'   \item \code{output = "asis"} returns the Java object reference, which can be useful for debugging or for writing a custom parser.
#' }
#' \code{\link{extract_areas}} implements this functionality in an interactive mode allowing the user to specify extraction areas for each page.
#' @return By default, a list of character matrices. This can be changed by specifying an alternative value of \code{method} (see Details).
#' @references \href{http://tabula.technology/}{Tabula}
#' @author Thomas J. Leeper <thosjleeper@gmail.com>, Tom Paskhalis <tpaskhalis@gmail.com>
#' @examples
#' \dontrun{
#' # simple demo file
#' f <- system.file("examples", "data.pdf", package = "tabulizer")
#'
#' # extract all tables
#' extract_tables(f)
#'
#' # extract tables from only second page
#' extract_tables(f, pages = 2)
#'
#' # extract areas from a page
#' ## full table
#' extract_tables(f, pages = 2, area = list(c(126, 149, 212, 462)))
#' ## part of the table
#' extract_tables(f, pages = 2, area = list(c(126, 284, 174, 417)))
#'
#' # return data.frames
#' extract_tables(f, pages = 2, output = "data.frame")
#' }
#' @seealso \code{\link{extract_areas}}, \code{\link{get_page_dims}}, \code{\link{make_thumbnails}}, \code{\link{split_pdf}}
#' @import tabulizerjars
#' @importFrom utils read.delim download.file
#' @importFrom tools file_path_sans_ext
#' @importFrom rJava J new .jfloat .jcall
#' @export
extract_tables <- function(file,
                           pages = NULL,
                           area = NULL,
                           columns = NULL,
                           guess = TRUE,
                           method = c("decide", "lattice", "stream"),
                           output = c("matrix", "data.frame", "character",
                                      "asis", "csv", "tsv", "json"),
                           outdir = NULL,
                           password = NULL,
                           encoding = NULL,
                           copy = FALSE,
                           ...) {
    method <- match.arg(method)
    output <- match.arg(output)

    if (is.null(outdir)) {
      outdir <- normalizePath(tempdir())
    } else {
      outdir <- normalizePath(outdir)
    }

    pdfDocument <- load_doc(file, password = password, copy = copy)
    on.exit(pdfDocument$close())
    oe <- new(J("technology.tabula.ObjectExtractor"), pdfDocument)

    # parse arguments
    if (is.null(pages)) {
        pageIterator <- oe$extract()
    } else {
        pages <- as.integer(pages)
        pageIterator <- oe$extract(make_pages(pages))
    }
    npages <- pdfDocument$getNumberOfPages()
    area <- make_area(area = area, pages = pages, npages = npages, target = "tabula")
    columns <- make_columns(columns = columns, pages = pages, npages = npages)

    # setup extractors
    basicExtractor <- new(J("technology.tabula.extractors.BasicExtractionAlgorithm"))
    spreadsheetExtractor <- new(J("technology.tabula.extractors.SpreadsheetExtractionAlgorithm"))
    if (method == "lattice") {
      use <- method
    }
    else if (method == "stream") {
      use <- method
    }

    tables <- new(J("java.util.ArrayList"))
    p <- 1L # page number
    while (.jcall(pageIterator, "Z", "hasNext")) {
        page <- .jcall(pageIterator, "Ljava/lang/Object;", "next")

        if (!is.null(area[[p]])) {
            page <- page$getArea(area[[p]])
        }

        # decide whether to use spreadsheet or basic extractor
        if (method == "decide") {
            tabular <- spreadsheetExtractor$isTabular(page)
            if (identical(FALSE, tabular)) {
              use <- "stream"
            } else {
              use <- "lattice"
            }
        }
        if (isTRUE(guess) && use == "lattice") {
            tables$add(spreadsheetExtractor$extract(page))
        } else {
            if (isTRUE(guess)) {
                # detect table locations
                detector <- new(J("technology.tabula.detectors.NurminenDetectionAlgorithm"))
                guesses <- detector$detect(page)
                guessesIterator <- guesses$iterator()
                while (.jcall(guessesIterator, "Z", "hasNext")) {
                    guessRect <- .jcall(guessesIterator, "Ljava/lang/Object;", "next")
                    thisGuess <- page$getArea(guessRect)
                    tables$add(basicExtractor$extract(thisGuess))
                    rm(thisGuess)
                }
            } else {
                if (is.null(columns[[p]])) {
                    tables$add(basicExtractor$extract(page))
                } else {
                    tables$add(basicExtractor$extract(page, columns[[p]]))
                }
            }
        }

        rm(page)
        p <- p + 1L # iterate page number
    }
    rm(p)

    # return output
    switch(tolower(output),
           "csv" = write_csvs(tables, file = file, outdir = outdir, ...),
           "tsv" = write_tsvs(tables, file = file, outdir = outdir, ...),
           "json" = write_jsons(tables, file = file, outdir = outdir, ...),
           "character" = list_characters(tables, encoding = encoding, ...),
           "matrix" = list_matrices(tables, encoding = encoding, ...),
           "data.frame" = list_data_frames(tables, encoding = encoding, ...),
           "asis" = tables,
           tables)
}
