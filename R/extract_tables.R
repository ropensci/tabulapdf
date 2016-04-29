#' @title extract_tables
#' @description Extract tables from a file
#' @param file A character string specifying the path to a PDF file.
#' @param pages An optional integer vector specifying pages to extract from.
#' @param area An optional list, of length equal to the number of pages specified, where each entry contains a four-element numeric vector of coordinates (top,left,bottom,right) containing the table for the corresponding page. Specify \code{area} xor \code{columns}.
#' @param columns An optional list, of length equal to the number of pages specified, where each entry contains a numeric vector of horizontal (x) coordinates separating columns of data for the corresponding page. Specify \code{area} xor \code{columns}.
#' @param guess A logical indicating whether to guess the locations of tables on each page. If \code{FALSE}, \code{area} or \code{columns} must be specified.
#' @param \dots Ignored.
#' @details This function mimics the behavior of the tabula command line utility. It returns a list of R data.frames containing tables extracted from a file.
#' @return A list of character matrices.
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
#' }
#' @importFrom tools file_path_sans_ext
#' @importFrom rJava J new  .jpackage .jfloat
#' @export
extract_tables <- 
function(file = "../inst/examples/mtcars.pdf", 
         pages = NULL, 
         area = NULL, 
         columns = NULL,
         guess = TRUE,
         ...) {

    file <- localize_file(path = file)
    
    pdfDocument <- new(J("org.apache.pdfbox.pdmodel.PDDocument"))$load(file)
    oe <- new(J("technology.tabula.ObjectExtractor"), pdfDocument)
    
    if (is.null(pages)) {
        pageIterator <- oe$extract()
    } else {
        pages <- sort(unique(as.integer(pages)))
        x <- new(J("java.util.ArrayList"))
        sapply(pages, function(z) {
            x$add(new(J("java.lang.Integer"), z))
        })
        pageIterator <- oe$extract(x)
        rm(x)
    }
    
    area <- make_area(area = area, pages = pages)
    columns <- make_columns(columns = columns, pages = pages)
    
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
        spreadsheet <- spreadsheetExtractor$isTabular(page)
        if (isTRUE(spreadsheet)) {
            tables$add(spreadsheetExtractor$extract(page))
        } else {
            if (isTRUE(guess)) {
                # detect table locations
                detector <- new(J("technology.tabula.detectors.NurminenDetectionAlgorithm"))
                guesses <- detector$detect(page)
                guessesIterator <- guesses$iterator()
                while (guessesIterator$hasNext()) {
                    guessRect <- J(guessesIterator, "next")
                    guess <- page$getArea(guessRect)
                    tables$add(basicExtractor$extract(guess))
                    rm(guess)
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
    
    #write_tables(file = file, tables = tables)
    out <- list_tables(tables)
    out
}
