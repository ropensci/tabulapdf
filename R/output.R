write_csvs <- function(tables, file, ...) {
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

list_matrices <- function(tables, ...) {
    out <- list()
    n <- 1L
    tablesIterator <- tables$iterator()
    while (tablesIterator$hasNext()) {
        tab <- J(tablesIterator, "next")$get(0L)
        out[[n]] <- matrix(NA_character_, 
                           nrow = tab$getRows()$size(), 
                           ncol = tab$getCols()$size())
        for (i in 1:nrow(out[[n]])) {
            for (j in 1:ncol(out[[n]])) {
                out[[n]][i, j] <- tab$getCell(i-1L, j-1L)$getText()
            }
        }
        rm(tab)
        n <- n + 1L
    }
    out
}

list_characters <- function(tables, sep = "\t", ...) {
    m <- list_matrices(tables, ...)
    lapply(m, function(x) {
        paste0(apply(x, 1, paste, collapse = sep), collapse = "\n")
    })
}

list_data_frames <- function(tables, sep = "\t", ...) {
    char <- list_characters(tables = tables, sep = sep)
    lapply(char, function(x) {
        o <- try(read.delim(text = x, ...))
        if (inherits(o, "try-error")) {
            return(x)
        } else {
            return(o)
        }
    })
}
