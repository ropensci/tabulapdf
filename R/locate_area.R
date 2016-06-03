#' @rdname extract_areas
#' @title extract_areas
#' @description Interactively identify areas and extract
#' @param file A character string specifying the path to a PDF file. This can also be a URL, in which case the file will be downloaded to the R temporary directory using \code{download.file}.
#' @param pages An optional integer vector specifying pages to extract from. To extract multiple tables from a given page, repeat the page number (e.g., \code{c(1,2,2,3)}).
#' @param resolution An integer specifying the resolution of the PNG images conversions. A low resolution is used by default to speed image loading.
#' @param guess See \code{\link{extract_tables}} (note the different default value).
#' @param \dots Other arguments passed to \code{\link{extract_tables}}.
#' @details \code{extract_areas} is an interactive mode for \code{\link{extract_tables}} allowing the user to specify areas of each PDF page in a file that they would like extracted. When used, each page is rendered to a PNG file and displayed in an R graphics window sequentially, pausing on each page to call \code{\link[graphics]{locator}} so the user can click and highlight an area to extract.
#'
#' The exact behaviour is a somewhat platform-dependent. If graphics events are supported, then it is possibly to interactively highlight a page region, make changes to that region, and navigate through the pages of the document while retaining the area highlighted on each page. If graphics events are not supported (e.g., in RStudio), then some of this functionality is not available (see below).
#'
#' In \emph{full functionality mode}, the first mouse click initializes a highlighting rectangle; the second click confirms it. If unsatisfied with the selection, the process can be repeated. The window also responds to keystrokes. \kbd{PgDn}, \kbd{Right}, and \kbd{Down} advance to the next page image, while \kbd{PgUp}, \kbd{Left}, and \kbd{Up} return to the previous page image. \kbd{Home} returns to the first page image and \kbd{End} advances to the final page image. \kbd{Q} quits the interactive mode and proceeds with extraction. When navigating between pages, any selected areas will be displayed and can be edited. \kbd{Delete} removes a highlighted area from a page (and then displays it again).
#'
#' In \emph{reduced functionality mode}, the interface requires users to indicate the upper-left and lower-right (or upper-right and lower-left) corners of an area on each page, this area will be briefly confirmed with a highlighted rectangle and the next page will be displayed. Dynamic page navigation and area editing are not possible.
#'
#' In either mode, after the areas are selected, \code{extract_areas} passes these user-defined areas to \code{\link{extract_tables}}. \code{locate_areas} implements the interactive component only, without actually extracting; this might be useful for interactive work that needs some modification before executing \code{extract_tables} computationally.
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
locate_areas <- function(file, pages = NULL, resolution = 60L) {
    if (!interactive()) {
        stop("locate_areas() is only available in an interactive session")
    } else {
        requireNamespace("graphics")
        requireNamespace("grDevices")
    }
    
    file <- localize_file(file, copy = TRUE)
    on.exit(unlink(file), add = TRUE)
    dims <- get_page_dims(file, pages = pages)
    paths <- make_thumbnails(file, outdir = tempdir(), pages = pages, format = "png", resolution = resolution)
    on.exit(unlink(paths), add = TRUE)
    
    areas <- rep(list(NULL), length(paths))
    i <- 1
    warnThisTime <- TRUE
    while (TRUE) {
        if (!is.na(paths[i])) {
            a <- try_area(file = paths[i], dims = dims[[i]], area = areas[[i]], warn = warnThisTime)
            warnThisTime <- FALSE
            if (!is.null(a[["area"]])) {
                areas[[i]] <- a[["area"]]
            }
            if (tolower(a[["key"]]) %in% c("del", "delete", "ctrl-h")) {
                areas[i] <- list(NULL)
                next
            } else if (tolower(a[["key"]]) %in% c("home")) {
                i <- 1
                next
            } else if (tolower(a[["key"]]) %in% c("end")) {
                i <- length(paths)
                next
            } else if (tolower(a[["key"]]) %in% c("pgup", "page_up", "up", "left")) {
                i <- if (i == 1) 1 else i - 1
                next
            } else if (tolower(a[["key"]]) %in% c("q")) {
                break
            }
        }
        i <- i + 1
        if (i > length(paths)) {
            break
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

try_area <- function(file, dims, area = NULL, warn = FALSE) {
    deviceUnits <- "nfc"
    if (Sys.info()["sysname"] == "Darwin") {
        grDevices::X11(type = "xlib")
    }
    if (grDevices::dev.capabilities()[["rasterImage"]] != "yes") {
        stop("Graphics device does not support rasterImage() plotting")
    }
    thispng <- readPNG(file, native = TRUE)
    drawPage <- function() {
        graphics::plot(c(0, dims[1]), c(0, dims[2]), type = "n", xlab = "", ylab = "", asp = 1)
        graphics::rasterImage(thispng, 0, 0, dims[1], dims[2])
    }
    drawRectangle <- function() {
        if (!is.null(endx)) {
            graphics::rect(startx, starty, endx, endy, col = grDevices::rgb(1,0,0,.2) )
        }
    }
        
    pre_par <- graphics::par(mar=c(0,0,0,0), xaxs = "i", yaxs = "i", bty = "n")
    on.exit(graphics::par(pre_par), add = TRUE)
    drawPage()
    on.exit(grDevices::dev.off(), add = TRUE)
    
    if (!length(grDevices::dev.capabilities()[["events"]])) {
        if (warn) {
            message("Graphics device does not support event handling...\n",
                    "Entering reduced functionality mode.\n",
                    "Click upper-left and then lower-right corners of area.")
        }
        tmp <- locator(2)
        graphics::rect(tmp$x[1], tmp$y[1], tmp$x[2], tmp$y[2], col = grDevices::rgb(1,0,0,.5))
        Sys.sleep(2)
        
        # convert to: top,left,bottom,right
        area <- c(dims[2] - max(tmp$y), min(tmp$x), dims[2] - min(tmp$y), max(tmp$x))
        return(list(key = "right", area = area))
    }
    
    clicked <- FALSE
    lastkey <- NA_character_
    if (!length(area)) {
        startx <- NULL
        starty <- NULL
        endx <- NULL
        endy <- NULL
    } else {
        showArea <- function() {
            # convert from: top,left,bottom,right
            startx <<- area[2]
            starty <<- dims[2] - area[1]
            endx <<- area[4]
            endy <<- dims[2] - area[3]
            drawRectangle()
        }
        showArea()
    }
    
    devset <- function() {
        if (grDevices::dev.cur() != eventEnv$which) grDevices::dev.set(eventEnv$which)
    }
    
    mousedown <- function(buttons, x, y) {
        devset()
        if (clicked) {
            endx <<- graphics::grconvertX(x, deviceUnits, "user")
            endy <<- graphics::grconvertY(y, deviceUnits, "user")
            clicked <<- FALSE
            eventEnv$onMouseMove <- NULL
        } else {
            startx <<- graphics::grconvertX(x, deviceUnits, "user")
            starty <<- graphics::grconvertY(y, deviceUnits, "user")
            clicked <<- TRUE
            eventEnv$onMouseMove <- dragmousemove
        }
        NULL
    }

    dragmousemove <- function(buttons, x, y) {
        devset()
        if (clicked) {
            endx <<- graphics::grconvertX(x, deviceUnits, "user")
            endy <<- graphics::grconvertY(y, deviceUnits, "user")
            drawPage()
            drawRectangle()
        }
        NULL
    }

    keydown <- function(key) {
        devset()
        eventEnv$onMouseMove <- NULL
        lastkey <<- key
        TRUE
    }

    p <- "Click and drag to select a table area. Press <Right> for next page or <Q> to quit."
    grDevices::setGraphicsEventHandlers(prompt = p,
                                        onMouseDown = mousedown,
                                        onKeybd = keydown)
    eventEnv <- grDevices::getGraphicsEventEnv()
    grDevices::getGraphicsEvent()
    
    backToPageSize <- function() {
        # convert to: top,left,bottom,right
        if (!is.null(startx)) {
            c(top = dims[2] - max(c(starty, endy)),
              left = min(c(startx,endx)),
              bottom = dims[2] - (min(c(starty,endy))),
              right = max(c(startx,endx)) )
        } else {
            NULL
        }
    }
    return(list(key = lastkey, area = backToPageSize()))
}
