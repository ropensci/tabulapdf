localize_file <- function(path) {
    if (grepl("^http.*://", path)) {
        tmp <- tempfile(fileext = basename(path))
        download.file(path, destfile = tmp, method = "libcurl", quiet = TRUE, mode = "wb")
        return(tmp)
    }
    path
}

make_pages <- function(pages, oe) {
    x <- new(J("java.util.ArrayList"))
    sapply(pages, function(z) {
        x$add(new(J("java.lang.Integer"), z))
    })
    return(x)
}

make_area <- function(area = NULL, pages = NULL, npages = NULL) {
    if (!is.null(area)) {
        if (!is.list(area)) {
            stop("'area' must be a list of length 1 or length equal to number of pages")
        }
        if (!is.null(pages)) {
            if ((length(area) == 1L) && (length(pages) != 1L)) {
                area <- rep(area[1], length(pages))
            } else if (length(area) != length(pages)) {
                stop("'area' must be a list of length 1 or length equal to number of pages")
            }
        } else {
            if ((length(area) == 1L) && (npages != 1L)) {
                area <- rep(area[1], npages)
            } else if (length(area) != npages) {
                stop("'area' must be a list of length 1 or length equal to number of pages")
            }
        }
        area <- lapply(area, function(x) {
            new(J("technology.tabula.Rectangle"), .jfloat(x[1]), .jfloat(x[2]), .jfloat(x[4]-x[2]), .jfloat(x[3]-x[1]))
        })
    }
    area
}

make_columns <- function(columns = NULL, pages = NULL, npages = NULL) {
    if (!is.null(columns)) {
        if (!is.list(columns)) {
            stop("'columns' must be a list of length 1 or length equal to number of pages")
        }
        if (!is.null(pages)) {
            if ((length(columns) == 1L) && (length(pages) != 1L)) {
                columns <- rep(columns, length(pages))
            } else if (length(columns) != length(pages)) {
                stop("'columns' must be a list of length 1 or length equal to number of pages")
            }
        } else {
            if ((length(columns) == 1L) && (npages != 1L)) {
                columns <- rep(columns[1], npages)
            } else if (length(columns) != npages) {
                stop("'columns' must be a list of length 1 or length equal to number of pages")
            }
        }
        columns <- lapply(columns, function(x) {
            z <- new(J("java.util.ArrayList"))
            for (i in seq_along(x)) {
                z$add(new(J("java.lang.Float"), rJava::.jfloat(x[i])))
            }
            z
        })
    }
    columns
}
