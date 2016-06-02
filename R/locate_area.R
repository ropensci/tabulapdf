#' @rdname extract_areas
#' @title extract_areas
#' @description Interactively identify areas and extract
#' @param file A character string specifying the path to a PDF file. This can also be a URL, in which case the file will be downloaded to the R temporary directory using \code{download.file}.
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
#' @importFrom grDevices dev.capabilities dev.off
#' @importFrom graphics par rasterImage locator plot
#' @export
locate_areas <- function(file, pages = NULL, silent = TRUE) {
    if (!interactive()) {
        stop("locate_areas() is only available in an interactive session")
    } else {
        requireNamespace("graphics")
        requireNamespace("grDevices")
    }
    
    file <- localize_file(file, copy = TRUE)
    on.exit(unlink(file), add = TRUE)
    dims <- get_page_dims(file, pages = pages)
    paths <- make_thumbnails(file, outdir = tempdir(), pages = pages, format = "png")
    on.exit(unlink(paths), add = TRUE)
    
    areas <- list()
    for (i in seq_along(paths)) {
        if (!is.na(paths[i])) {
            areas[[i]] <- try_area(file = paths[[i]], dims = dims[[i]])
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

try_area <- function(file, dims) {
    deviceCoord <- "nfc"
    cairoDevice::Cairo(width = dims[1], height = dims[2], pointsize = 12, surface = "screen")
    if (dev.capabilities()[["rasterImage"]] != "yes") {
        stop("Graphics device does not support rasterImage plotting")
    }
    thispng <- readPNG(file, native = TRUE)
    drawPage <- function() {
        graphics::plot(c(0, dims[1]), c(0, dims[2]), type = "n", xlab = "", ylab = "", asp = 1)
        graphics::rasterImage(thispng, 0, 0, dims[1], dims[2])
    }
    
    pre_par <- par(mar=c(0,0,0,0), xaxs = "i", yaxs = "i", bty = "n")
    on.exit(par(pre_par), add = TRUE)
    drawPage()
    on.exit(dev.off(), add = TRUE)

    clicked <- FALSE
    startx <- 0
    starty <- 0
    endx <- 0
    endy <- 0
    
    devset <- function() {
        if (dev.cur() != eventEnv$which) dev.set(eventEnv$which)
    }
    
    mousedown <- function(buttons, x, y) {
        devset()
        if (clicked) {
            endx <<- graphics::grconvertX(x, deviceCoord, "user")
            endy <<- graphics::grconvertY(y, deviceCoord, "user")
            clicked <<- FALSE
            eventEnv$onMouseMove <- NULL
        } else {
            startx <<- graphics::grconvertX(x, deviceCoord, "user")
            starty <<- graphics::grconvertY(y, deviceCoord, "user")
            clicked <<- TRUE
            eventEnv$onMouseMove <- dragmousemove
        }
        NULL
    }

    dragmousemove <- function(buttons, x, y) {
        devset()
        if (clicked) {
            endx <<- graphics::grconvertX(x, "nfc", "user")
            endy <<- graphics::grconvertY(y, "nfc", "user")
            drawPage()
            graphics::rect(startx, starty, endx, endy, col = rgb(1,0,0,.2) )
        }
        NULL
    }

    keydown <- function(key) {
        devset()
        eventEnv$onMouseMove <- NULL
        TRUE
    }

    p <- "Click and drag to select a table area, press any key to confirm"
    grDevices::setGraphicsEventHandlers(
        prompt = p,
        onMouseDown = mousedown,
        onKeybd = keydown)
    eventEnv <- grDevices::getGraphicsEventEnv()
    grDevices::getGraphicsEvent()
    
    backToPageSize <- function() {
        width <- dims[1]
        height <- dims[2]
        x1 <- graphics::grconvertX(startx, "user", "nfc")
        y1 <- graphics::grconvertY(starty, "user", "nfc")
        x2 <- graphics::grconvertX(endx, "user", "nfc")
        y2 <- graphics::grconvertY(endy, "user", "nfc")
        
        # convert to: top,left,bottom,right
        c(top = height - (max(c(y1, y2)) * height),
          left = min(c(x1,x2)) * width,
          bottom = height - (min(c(y1,y2)) * height),
          right = max(c(x1,x2)) * width
          )
    }
    return(backToPageSize())
}
