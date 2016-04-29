localize_file <- function(path) {
    if (grepl("^http.*://", path)) {
        tmp <- tempfile(fileext = basename(path))
        download.file(path, destfile = tmp, method = "libcurl")
        return(tmp)
    }
    path
}

make_area <- function(area = NULL, pages = NULL) {
    if (!is.null(area)) {
        # handle area
        if (!is.null(pages)) {
            if ((length(area) == 1L) && (length(pages) != 1L)) {
                area <- rep(area, length(pages))
            } else if (length(area) != length(pages)) {
                stop("'area' must be a list of length 1 or length equal to number of pages")
            }
        }
        area <- lapply(area, function(x) {
            new(J("technology.tabula.Rectangle"), x)
        })
    }
    area
}

make_columns <- function(columns = NULL, pages = NULL) {
    if (!is.null(columns)) {
        # handle columns
        if (!is.null(pages)) {
            if ((length(columns) == 1L) && (length(pages) != 1L)) {
                columns <- rep(columns, length(pages))
            } else if (length(columns) != length(pages)) {
                stop("'columns' must be a list of length 1 or length equal to number of pages")
            }
        }
        columns <- lapply(columns, function(x) {
            rJava::.jfloat(x)
        })
    }
    columns
}
