write_csvs <- function(tables, file, ...) {
    file <- path.expand(file)
    writer <- new(J("technology.tabula.writers.CSVWriter"))
    tablesIterator <- tables$iterator()
    p <- 1L
    while (tablesIterator$hasNext()) {
        outfile <- paste0(file_path_sans_ext(file), "-", p, ".csv")
        bufferedWriter <- new(J("java.io.BufferedWriter"), new(J("java.io.FileWriter"), outfile))
        tab <- J(tablesIterator, "next")
        writer$write(bufferedWriter, tab)
        rm(tab)
        bufferedWriter$close()
        p <- p + 1L
    }
    normalizePath(dirname(file))
}

write_tsvs <- function(tables, file, ...) {
    file <- path.expand(file)
    writer <- new(J("technology.tabula.writers.TSVWriter"))
    tablesIterator <- tables$iterator()
    p <- 1L
    while (tablesIterator$hasNext()) {
        outfile <- paste0(file_path_sans_ext(file), "-", p, ".tsv")
        bufferedWriter <- new(J("java.io.BufferedWriter"), new(J("java.io.FileWriter"), outfile))
        tab <- J(tablesIterator, "next")
        writer$write(bufferedWriter, tab)
        rm(tab)
        bufferedWriter$close()
        p <- p + 1L
    }
    normalizePath(dirname(file))
}

write_jsons <- function(tables, file, ...) {
    file <- path.expand(file)
    writer <- new(J("technology.tabula.writers.JSONWriter"))
    tablesIterator <- tables$iterator()
    p <- 1L
    while (tablesIterator$hasNext()) {
        outfile <- paste0(file_path_sans_ext(file), "-", p, ".json")
        bufferedWriter <- new(J("java.io.BufferedWriter"), new(J("java.io.FileWriter"), outfile))
        tab <- J(tablesIterator, "next")
        writer$write(bufferedWriter, tab)
        rm(tab)
        bufferedWriter$close()
        p <- p + 1L
    }
    normalizePath(dirname(file))
}

list_matrices <- function(tables, encoding = NULL, ...) {
    out <- list()
    n <- 1L
    tablesIterator <- tables$iterator()
    while (tablesIterator$hasNext()) {
        nxt <- J(tablesIterator, "next")
        if (nxt$size() == 0L) {
            break
        }
        tab <- nxt$get(0L)
        out[[n]] <- matrix(NA_character_, 
                           nrow = tab$getRows()$size(), 
                           ncol = tab$getCols()$size())
        for (i in 1:nrow(out[[n]])) {
            for (j in 1:ncol(out[[n]])) {
                out[[n]][i, j] <- tab$getCell(i-1L, j-1L)$getText()
            }
        }
        if (!is.null(encoding)) {
            Encoding(out[[n]]) <- encoding
        }
        rm(tab)
        n <- n + 1L
    }
    out
}

list_characters <- function(tables, sep = "\t", encoding = NULL, ...) {
    m <- list_matrices(tables, encoding = encoding, ...)
    lapply(m, function(x) {
        paste0(apply(x, 1, paste, collapse = sep), collapse = "\n")
    })
}

list_data_frames <- function(tables, sep = "\t", stringsAsFactors = FALSE, encoding = NULL, ...) {
    char <- list_characters(tables = tables, sep = sep, encoding = encoding)
    lapply(char, function(x) {
        o <- try(read.delim(text = x, stringsAsFactors = stringsAsFactors, ...))
        if (inherits(o, "try-error")) {
            return(x)
        } else {
            return(o)
        }
    })
}
