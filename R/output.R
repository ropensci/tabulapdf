write_csvs <- function(tables, file, outdir, ...) {
    file <- basename(file)
    writer <- new(J("technology.tabula.writers.CSVWriter"))
    tablesIterator <- tables$iterator()
    p <- 1L
    while (.jcall(tablesIterator, "Z", "hasNext")) {
        filename <- paste0(tools::file_path_sans_ext(file), "-", p, ".csv")
        outfile <- normalizePath(file.path(outdir, filename), mustWork = FALSE)
        bufferedWriter <- new(
            J("java.io.BufferedWriter"),
            new(J("java.io.FileWriter"), outfile)
        )
        tab <- .jcall(tablesIterator, "Ljava/lang/Object;", "next")
        writer$write(bufferedWriter, tab)
        rm(tab)
        bufferedWriter$close()
        p <- p + 1L
    }
    outdir
}

write_tsvs <- function(tables, file, outdir, ...) {
    file <- basename(file)
    writer <- new(J("technology.tabula.writers.TSVWriter"))
    tablesIterator <- tables$iterator()
    p <- 1L
    while (.jcall(tablesIterator, "Z", "hasNext")) {
        filename <- paste0(tools::file_path_sans_ext(file), "-", p, ".tsv")
        outfile <- normalizePath(file.path(outdir, filename), mustWork = FALSE)
        bufferedWriter <- new(
            J("java.io.BufferedWriter"),
            new(J("java.io.FileWriter"), outfile)
        )
        tab <- .jcall(tablesIterator, "Ljava/lang/Object;", "next")
        writer$write(bufferedWriter, tab)
        rm(tab)
        bufferedWriter$close()
        p <- p + 1L
    }
    outdir
}

write_jsons <- function(tables, file, outdir, ...) {
    file <- basename(file)
    writer <- new(J("technology.tabula.writers.JSONWriter"))
    tablesIterator <- tables$iterator()
    p <- 1L
    while (.jcall(tablesIterator, "Z", "hasNext")) {
        filename <- paste0(tools::file_path_sans_ext(file), "-", p, ".json")
        outfile <- normalizePath(file.path(outdir, filename), mustWork = FALSE)
        bufferedWriter <- new(
            J("java.io.BufferedWriter"),
            new(J("java.io.FileWriter"), outfile)
        )
        tab <- .jcall(tablesIterator, "Ljava/lang/Object;", "next")
        writer$write(bufferedWriter, tab)
        rm(tab)
        bufferedWriter$close()
        p <- p + 1L
    }
    outdir
}

list_matrices <- function(tables, encoding = NULL, ...) {
    out <- list()
    n <- 1L
    tablesIterator <- tables$iterator()
    while (.jcall(tablesIterator, "Z", "hasNext")) {
        nxt <- .jcall(tablesIterator, "Ljava/lang/Object;", "next")
        if (.jcall(nxt, "I", "size") == 0L) {
            break
        }
        tab <- .jcall(nxt, "Ljava/lang/Object;", "get", 0L)
        out[[n]] <- matrix(NA_character_,
            nrow = tab$getRowCount(),
            ncol = tab$getColCount()
        )
        for (i in seq_len(nrow(out[[n]]))) {
            for (j in seq_len(ncol(out[[n]]))) {
                out[[n]][i, j] <- tab$getCell(i - 1L, j - 1L)$getText()
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
