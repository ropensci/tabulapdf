localize_file <- function(path, copy = FALSE, quiet = TRUE) {
    if (grepl("^http.*://", path)) {
        tmp <- tempfile(fileext = ".pdf")
        utils::download.file(path, tmp, quiet = quiet, mode = "wb")
        path <- tmp
    } else {
        if (isTRUE(copy)) {
            filename <- paste0(tools::file_path_sans_ext(basename(path)),
                               ".pdf")
            tmp <- normalizePath(file.path(tempdir(), filename))
            file_to <- path.expand(path)
            if (file_to != tmp) {
              file.copy(from = file_to, to = tmp, overwrite = TRUE)
            }
            path <- tmp
        } else {
            path <- path.expand(path)
        }
    }
    path
}

load_doc <- function(file, password = NULL, copy = TRUE) {
    localfile <- localize_file(path = file, copy = copy)
    pdfDocument <- new(J("org.apache.pdfbox.pdmodel.PDDocument"))
    fileInputStream <- new(J("java.io.FileInputStream"), name <- localfile)
    if (is.null(password)) {
        doc <- pdfDocument$load(input = fileInputStream)
    } else {
        doc <- pdfDocument$load(input = fileInputStream, password = password)
    }
    pdfDocument$close()
    doc
}

make_pages <- function(pages, oe) {
    x <- new(J("java.util.ArrayList"))
    lapply(pages, function(thispage) {
        x$add(new(J("java.lang.Integer"), thispage))
    })
    return(x)
}

convert_coordinates <- function(coordinates,
                                dims = NULL,
                                from = c("graphics", "page", "tabula", "java"),
                                to = c("graphics", "page", "tabula", "java")) {
  from <- match.arg(from)
  to <- match.arg(to)
  
  if (length(coordinates) != 4) {
    stop("Coordinates must have length 4")
  }
  if (to == "page" && is.null(dims)) {
    stop("Page dimensions are required for converting to 'page'")
  }
  if ("graphics" %in% c(to, from)) {
    stop("'graphics' has not been implemented yet")
  }
  
  # graphics: startx, starty, endx, endy
  # page: top, left, bottom, right
  # tabula: y(top), x(left), width, heigth
  # java: x(left), y(top), width, height 
  if (from == "page" && to == "java") {
    coordinates <- c(coordinates[c(2,1)],
                     coordinates[4] - coordinates[2],
                     coordinates[3] - coordinates[1])
  }
  else if (from == "page" && to == "tabula") {
    coordinates <- c(coordinates[c(1,2)],
                     coordinates[4] - coordinates[2],
                     coordinates[3] - coordinates[1])
  }
  else if (from == "page" && to == "graphics") {
    # TODO
  }
  else if (from == "java" && to == "page") {
    coordinates <- c(coordinates[c(2,1)],
                     dims[2] - coordinates[2] - coordinates[4],
                     dims[1] - coordinates[1] - coordinates[3])
  }
  else if (from == "tabula" && to == "page") {
    coordinates <- c(coordinates[c(1,2)],
                     dims[2] - coordinates[1] - coordinates[4],
                     dims[1] - coordinates[2] - coordinates[3])
  }
  else if ((from == "tabula" && to == "java") ||
           (from == "java" && to == "tabula")) {
    coordinates[c(1,2)] <- coordinates[c(2,1)]
  }
  else if (from == "tabula" && to == "graphics") {
    # TODO
  }
  else if (from == "java" && to == "graphics") {
    # TODO
  }
  coordinates
}

make_area <- function(area = NULL,
                      pages = NULL,
                      npages = NULL,
                      target = c("tabula", "java")) {
    target = match.arg(target)
  
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
                if (target == "tabula") {
                  x <- convert_coordinates(x, from = "page", to = "tabula")
                  new(J("technology.tabula.Rectangle"), .jfloat(x[1]),
                      .jfloat(x[2]), .jfloat(x[3]), .jfloat(x[4]))
                }
                else if (target == "java") {
                  x <- convert_coordinates(x, from = "page", to = "java")
                  new(J("java.awt.geom.Rectangle2D$Float"), .jfloat(x[1]),
                      .jfloat(x[2]), .jfloat(x[3]), .jfloat(x[4]))
                }
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
