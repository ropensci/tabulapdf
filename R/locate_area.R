#' @rdname extract_areas
#' @title extract_areas
#' @description Interactively identify areas and extract
#' @param file A character string specifying the path to a PDF file.
#' @param pages An optional integer vector specifying pages to extract from. To extract multiple tables from a given page, repeat the page number (e.g., \code{c(1,2,2,3)}).
#' @param silent A logical indicating whether to silence the \code{\link[graphics]{locator}} function.
#' @param guess See \code{\link{extract_tables}} (note the different default value).
#' @param \dots Other arguments passed to \code{\link{extract_tables}}.
#' @details \code{extract_areas} is an interactive mode for \code{\link{extract_tables}} allowing the user to specify areas of each PDF page in a file that they would like extracted. In interactive mode, each page is rendered to a PNG file and displayed in an R graphics window sequentially, pausing on each page to call \code{\link[graphics]{locator}} so the user can specify two points (e.g., upper-left and lower-right) to define bounds of page area. \code{extract_areas} then passes these user-defined areas to \code{\link{extract_tables}}. \code{locate_areas} implements the interactive component only, without actually extracting; this might be useful for interactive work that needs some modification before executing \code{extract_tables} computationally.
#' @note Currently, attempting to resize the graphics window at any point during this process will cause problems.
#' @return For \code{extract_areas}, see \code{\link{extract_tables}}. For \code{locate_areas}, a list of four-element numeric vectors (top,left,bottom,right), one per page of the file.
#' @author Thomas J. Leeper <thosjleeper@gmail.com>
#' @examples
#' \dontrun{
#' # simple demo file
#' f <- system.file("examples", "data.pdf", package = "tabulizer")
#' 
#' # locate areas only
#' locate_areas(f)
#' 
#' # locate areas and extract
#' extract_areas(f)
#' }
#' @importFrom tools file_path_sans_ext
#' @importFrom rJava J new
#' @seealso \code{\link{extract_tables}}, \code{\link{make_thumbnails}}, , \code{\link{get_page_dims}}
#' @importFrom png readPNG
#' @importFrom graphics par rasterImage locator
#' @export
locate_areas <- function(file, pages = NULL, silent = TRUE) {
    capable <- dev.capabilities("locator")$locator
    if (!capable) {
        stop("'locator()' is not supported on this device")
    }
    dims <- get_page_dims(file, pages = pages)
    paths <- make_thumbnails(file, pages = pages, format = "png")
    on.exit(unlink(paths))
    pngs <- lapply(paths, function(x) {
        if (!is.na(x)) {
            readPNG(x)
        } else {
            NA
        }
    })
    
    pre_op <- options()
    on.exit(options(pre_op), add = TRUE)
    options(locatorBell = !silent)
    pre_par <- par(mar=c(0,0,0,0), xaxs = "i", yaxs = "i", bty = "n")
    on.exit(par(pre_par), add = TRUE)
    on.exit(dev.off(), add = TRUE)
    areas <- list()
    for (i in seq_along(pngs)) {
        if (!is.na(paths[i])) {
            areas[[i]] <- try_area(dims = dims[[i]], thispng = pngs[[i]])
        } else {
            areas[[i]] <- NA_real_
        }
    }
    return(areas)
}

#' @rdname extract_areas
#' @export
extract_areas <- function(file, pages = NULL, guess = FALSE, ...) {
    areas <- locate_areas(file = file, pages = pages)
    extract_tables(file = file, pages = pages, area = areas, guess = guess, ...)
}

try_area <- function(dims, thispng) {
    plot(c(0, dims[1]), c(0, dims[2]), type = "n", xlab = "", ylab = "", asp = 1)
    rasterImage(thispng, 0, 0, dims[1], dims[2])
    tmp <- locator(2)
    #rect(tmp$x[1], tmp$y[1], tmp$x[2], tmp$y[2], col = rgb(1,0,0,.5))
    #Sys.sleep(1.5)
    
    # convert to: top,left,bottom,right
    area <- c(dims[2] - max(tmp$y), min(tmp$x), dims[2] - min(tmp$y), max(tmp$x))
    return(area)
}
