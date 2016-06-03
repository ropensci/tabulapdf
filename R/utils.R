localize_file <- function(path, copy = FALSE, quiet = TRUE) {
    if (grepl("^http.*://", path)) {
        if (copy) {
            tmp <- tempfile(fileext = ".pdf")
            download.file(path, tmp, quiet = quiet, mode = "wb")
            path <- tmp
        } else {
            path <- new(J("java.net.URL"), path)
        }
    } else {
        if (copy) {
            tmp <- file.path(tempdir(), paste0(basename(file_path_sans_ext(path.expand(path))), ".pdf"))
            file.copy(from = path.expand(path), to = tmp)
            path <- tmp
        } else {
            path <- path.expand(path)
        }
    }
    path
}

load_doc <- function(file, password = NULL) {
    file <- localize_file(path = file, copy = TRUE)
    pdfDocument <- new(J("org.apache.pdfbox.pdmodel.PDDocument"))
    doc <- pdfDocument$load(file)
    pdfDocument$close()
    if (!is.null(password)) {
        pm <- new(J("org.apache.pdfbox.pdmodel.encryption.StandardDecryptionMaterial"), password)
        doc$openProtection(pm)
    } else if (doc$getDocument()$isEncrypted()) {
        warning("PDF appears to be password protected and no password was supplied.")
    }
    doc
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
            if (!is.null(x)) {
                new(J("technology.tabula.Rectangle"), .jfloat(x[1]), .jfloat(x[2]), .jfloat(x[4]-x[2]), .jfloat(x[3]-x[1]))
            } else {
                NULL
            }
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
