#' @title extract_tables
#' @description Extract tables from a file
#' @param file A character string specifying the path to a PDF file.
#' @param pages An optional integer vector specifying pages to extract from.
#' @param area An optional list, of length equal to the number of pages specified, where each entry contains a four-element numeric vector of coordinates (top,left,bottom,right) containing the table for the corresponding page. As a convenience, a list of length 1 can be used to extract the same area from all (specified) pages. Only specify \code{area} xor \code{columns}.
#' @param columns An optional list, of length equal to the number of pages specified, where each entry contains a numeric vector of horizontal (x) coordinates separating columns of data for the corresponding page. As a convenience, a list of length 1 can be used to specify the same columns for all (specified) pages. Only specify \code{area} xor \code{columns}.
#' @param guess A logical indicating whether to guess the locations of tables on each page. If \code{FALSE}, \code{area} or \code{columns} must be specified; if \code{TRUE}, columns is ignored.
#' @param spreadsheet A logical indicating whether to use Tabula's spreadsheet extraction algorithm. If \code{NULL} (the default), an automated assessment is made about whether it is appropriate.
#' @param method A function to coerce the Java response object (a Java ArrayList of Tabula Tables) to some output format. The default method, \dQuote{matrices}, returns a list of character matrices. See Details for other options.
#' @param \dots These are additional arguments passed to the internal functions dispatched by \code{method}.
#' @details This function mimics the behavior of the Tabula command line utility. It returns a list of R character matrices containing tables extracted from a file by default. This response behavior can be changed by using the following options. \code{method = "character"} returns a list of single-element character vectors, where each vector is a tab-delimited, line-separate string of concatenated table cells. \code{method = "data.frame"} attempts to coerce the structure returned by \code{method = "character"} into a list of data.frames and returns character strings where this fails. \code{method = "csv"} writes the tables to comma-separated (CSV) files using Tabula's CSVWriter method in the same directory as the original PDF. \code{method = "tsv"} does the same but with tab-separated (TSV) files using Tabula's TSVWriter and \code{method = "json"} does the same using Tabula's JSONWriter method. The previous three methods all return the path to the directory containing the extract table files. \code{method = "asis"} returns the Java object reference, which can be useful for debugging or for writing a custom parser.
#' \code{\link{extract_areas}} implements this functionality in an interactive mode allowing the user to specify extraction areas for each page.
#' @return By default, a list of character matrices. This can be changed by specifying an alternative value of \code{method} (see Details).
#' @references \href{http://tabula.technology/}{Tabula}
#' @author Thomas J. Leeper <thosjleeper@gmail.com>
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
#' # return data.frames
#' extract_tables(f, pages = 2, method = "data.frame")
#' }
#' @seealso \code{\link{extract_areas}}, \code{\link{get_page_dims}}, \code{\link{make_thumbnails}}
#' @importFrom tools file_path_sans_ext
#' @importFrom rJava J new  .jpackage .jfloat
#' @export
extract_tables <- 
function(file = "../inst/examples/mtcars.pdf", 
         pages = NULL, 
         area = NULL, 
         columns = NULL,
         guess = TRUE,
         spreadsheet = NULL,
         method = "matrix",
         ...) {

    # copy remote files to temp directory
    file <- localize_file(path = file)
    
    # load PDF file into Tabula
    PDDocumentClass <- new(J("org.apache.pdfbox.pdmodel.PDDocument"))
    pdfDocument <- PDDocumentClass$load(file)
    PDDocumentClass$close()
    on.exit(pdfDocument$close())
    oe <- new(J("technology.tabula.ObjectExtractor"), pdfDocument)
    
    # parse arguments
    if (is.null(pages)) {
        pageIterator <- oe$extract()
    } else {
        pages <- as.integer(pages)
        pageIterator <- oe$extract(make_pages(pages))
    }
    npages <- pdfDocument$getDocumentCatalog()$getAllPages()$size()
    area <- make_area(area = area, pages = pages, npages = npages)
    columns <- make_columns(columns = columns, pages = pages, npages = npages)
    
    # setup extractors
    basicExtractor <- new(J("technology.tabula.extractors.BasicExtractionAlgorithm"))
    spreadsheetExtractor <- new(J("technology.tabula.extractors.SpreadsheetExtractionAlgorithm"))
    
    tables <- new(J("java.util.ArrayList"))
    p <- 1L # page number
    while (pageIterator$hasNext()) {
        page <- J(pageIterator, "next")
        if (!is.null(area[[p]])) {
            page <- page$getArea(area[[p]])
        }
        
        # decide whether to use spreadsheet or basic extractor
        if (is.null(spreadsheet)) {
            spreadsheet <- spreadsheetExtractor$isTabular(page)
        }
        if (isTRUE(guess) && isTRUE(spreadsheet)) {
            tables$add(spreadsheetExtractor$extract(page))
        } else {
            if (isTRUE(guess)) {
                # detect table locations
                detector <- new(J("technology.tabula.detectors.NurminenDetectionAlgorithm"))
                guesses <- detector$detect(page)
                guessesIterator <- guesses$iterator()
                while (guessesIterator$hasNext()) {
                    guessRect <- J(guessesIterator, "next")
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
    
    # return output based on `method`
    switch(tolower(method),
           "csv" = write_csvs(tables, file = file, ...),
           "tsv" = write_tsvs(tables, file = file, ...),
           "json" = write_jsons(tables, file = file, ...),
           "character" = list_characters(tables, ...),
           "matrix" = list_matrices(tables, ...),
           "data.frame" = list_data_frames(tables, ...),
           "asis" = tables,
           tables)
}
