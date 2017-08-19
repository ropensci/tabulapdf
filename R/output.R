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
        ## list holder for >=1 tables
        outTab <- list()
        ## Whilst on a page, loop over the number of tables in that page
        for (nTabs in seq_len(nxt$size())) {
            ## Get the next table
            tab <- nxt$get(nTabs - 1L)
            ## Create empty matrix for table
            outTab[[nTabs]] <- matrix(NA_character_, 
                                      nrow = tab$getRows()$size(), 
                                      ncol = tab$getCols()$size())
            ## Loop over elements in the table and store in the matrix
            for (i in seq_len(nrow(outTab[[nTabs]]))) {
                for (j in seq_len(ncol(outTab[[nTabs]]))) {
                    outTab[[nTabs]][i, j] <- tab$getCell(i-1L, j-1L)$getText()
                }
            }
            if (!is.null(encoding)) {
                Encoding(outTab[[nTabs]]) <- encoding
            }
            rm(tab)
        }
        ## Put outTab into out, depending on size (i.e return a matrix if only a
        ## single table on the page, otherwise a list of matrices).
        if (nxt$size() == 1L) {
            out[[n]] <- outTab[[1]]
        } else {
            out[[n]] <- outTab
        }
        rm(outTab)
        n <- n + 1L
    }
    out
}

list_characters <- function(tables, sep = "\t", encoding = NULL, ...) {
    m <- list_matrices(tables, encoding = encoding, ...)
    lapply(m, function(x) {
        if (inherits(x, "matrix")) {
            paste0(apply(x, 1, paste, collapse = sep), collapse = "\n")
        } else {
            lapply(x, function(y) paste0(apply(y, 1, paste, collapse = sep),
                                         collapse = "\n"))
        }
    })
}

list_data_frames <- function(tables, sep = "\t", stringsAsFactors = FALSE, encoding = NULL, ...) {
    char <- list_characters(tables = tables, sep = sep, encoding = encoding)
    lapply(char, function(x) {
        if (inherits(x, "character")) {
            o <- try(read.delim(text = x, stringsAsFactors = stringsAsFactors,
                                ...),
                     silent = TRUE)
            if (inherits(o, "try-error")) {
                return(x)
            } else {
                return(o)
            }
        } else {
            lapply(x, function(y) {
                o <- try(read.delim(text = y, stringsAsFactors =
                                                  stringsAsFactors, ...),
                         silent = TRUE)
                if (inherits(o, "try-error")) {
                    return(y)
                } else {
                    return(o)
                }
            })
        }
        })
}
