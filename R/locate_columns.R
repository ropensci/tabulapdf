
#' Locate separators between columns
#'
#' This function allows the user to manually locate the separators between columns of a table in a pdf. The output can be used as the \code{columns} argument in \code{extract_tables()}
#' 
#' Manually selecting the separators can ensure that values stay in their respective columns. This is useful when some rows of a table have no or only little white space between columns. The code is an adaptation of the \code{locate_area()} function and its helpers.
#' @param file A character string specifying the path or URL to a PDF file.
#' @param pages An optional integer vector specifying pages to extract from.
#' @param resolution An integer specifying the resolution of the PNG images conversions. A low resolution is used by default to speed image loading.
#' @param copy Specifies whether the original local file(s) should be copied to tempdir() before processing. FALSE by default. The argument is ignored if file is URL.
#' @return a list.
#' @author Thore Engel <thore.engel@posteo.de>  
#' @export
#'
#' @examples
#' \donttest{
#' f <- system.file("examples", "data.pdf", package = "tabulizer")
#' separators<-locate_columns(f, pages= 1 )
#' extract_tables(f,pages = 1, columns = separators[1])
#' }
#' 
locate_columns <- function(file,
                         pages = NULL,
                         resolution = 60L,
                         copy = FALSE) {
    if (!interactive()) {
        stop("locate_columns() is only available in an interactive session")
    } else {
        requireNamespace("graphics")
        requireNamespace("grDevices")
    }
    
    file <- localize_file(file, copy = copy)
    # on.exit(unlink(file), add = TRUE)
    dims <- get_page_dims(file, pages = pages)
    paths <- make_thumbnails(file,
                             outdir = tempdir(),
                             pages = pages,
                             format = "png",
                             resolution = resolution)
    on.exit(unlink(paths), add = TRUE)
    
    separators <- rep(list(NULL), length(paths))
    i <- 1
    warnThisTime <- TRUE
    while (TRUE) {
        if (!is.na(paths[i])) {
            a <- try_columns_reduced(file = paths[i], 
                          dims = dims[[i]],warn = warnThisTime)
            if(warnThisTime) warnThisTime <- F
            if (!is.null(a[["separators"]])) {
                separators[[i]] <- a[["separators"]]
            }
            if (tolower(a[["key"]]) %in% c("del", "delete", "ctrl-h")) {
                separators[i] <- list(NULL)
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
    return(separators)
}


#' Helper function to locate_columns()
#'
#' @param file A character string specifying the path or URL to a PDF file.
#' @param dims An integer specifying the resolution of the PNG images conversions. A low resolution is used by default to speed image loading.
#' @param warn Display warning?

try_columns_reduced <- function(file, dims, warn = FALSE) {
    if (warn) {
        message("Click at the locations of separators between columns.")
    }
    if (grDevices::dev.capabilities()[["rasterImage"]] == "no") {
        stop("Graphics device does not support rasterImage() plotting")
    }
    thispng <- readPNG(file, native = TRUE)
    drawPage <- function() {
        graphics::plot(c(0, dims[1]), c(0, dims[2]), type = "n", xlab = "", ylab = "", asp = 1)
        graphics::rasterImage(thispng, 0, 0, dims[1], dims[2])
    }
    
    pre_par <- graphics::par(mar=c(0,0,0,0), xaxs = "i", yaxs = "i", bty = "n")
    on.exit(graphics::par(pre_par), add = TRUE)
    drawPage()
    on.exit(grDevices::dev.off(), add = TRUE)
    
    tmp <- locator()
    graphics::abline(v=tmp$x)
    Sys.sleep(4)
    separators= as.numeric(tmp$x)
    return(list(key = "right", separators = separators))
}
