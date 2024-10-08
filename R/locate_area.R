#' @rdname extract_areas
#' @title extract_areas
#' @description Interactively identify areas and extract
#' @param file A character string specifying the path to a PDF file. This can also be a URL, in which case the file will be downloaded to the R temporary directory using \code{download.file}.
#' @param pages An optional integer vector specifying pages to extract from. To extract multiple tables from a given page, repeat the page number (e.g., \code{c(1,2,2,3)}).
#' @param thumbnails A directory containing prefetched thumbnails created with the function \code{\link{make_thumbnails}}. This will greatly increase loading speed.
#' @param resolution An integer specifying the resolution of the PNG images conversions. A low resolution is used by default to speed image loading.
#' @param guess See \code{\link{extract_tables}} (note the different default value).
#' @param widget A one-element character vector specifying the type of \dQuote{widget} to use for locating the areas. The default (\dQuote{shiny}) is a shiny widget. The alternatives are a widget based on the native R graphics device (\dQuote{native}, where available), or a very reduced functionality model (\dQuote{reduced}).
#' @param copy Specifies whether the original local file(s) should be copied to
#' \code{tempdir()} before processing. \code{FALSE} by default. The argument is
#' ignored if \code{file} is URL.
#' @param \dots Other arguments passed to \code{\link{extract_tables}}.
#' @details \code{extract_areas} is an interactive mode for \code{\link{extract_tables}} allowing the user to specify areas of each PDF page in a file that they would like extracted. When used, each page is rendered to a PNG file and displayed in an R graphics window sequentially, pausing on each page to call \code{\link[graphics]{locator}} so the user can click and highlight an area to extract.
#'
#' The exact behaviour is a somewhat platform-dependent, and depends on the value of \code{widget} (and further, whether you are working in RStudio or the R console). In RStudio (where \code{widget = "shiny"}), a Shiny gadget is provided which allows the user to click and drag to select areas on each page of a file, clicking \dQuote{Done} on each page to advance through them. It is not possible to return to previous pages. In the R console, a Shiny app will be launched in a web browser.
#'
#' For other values of \code{widget}, functionality is provided through the graphics device. If graphics events are supported, then it is possibly to interactively highlight a page region, make changes to that region, and navigate through the pages of the document while retaining the area highlighted on each page. If graphics events are not supported, then some of this functionality is not available (see below).
#'
#' In \emph{full functionality mode} (\code{widget = "native"}), areas are input in a native graphics device. For each page, the first mouse click on a page initializes a highlighting rectangle; the second click confirms it. If unsatisfied with the selection, the process can be repeated. The window also responds to keystrokes. \kbd{PgDn}, \kbd{Right}, and \kbd{Down} advance to the next page image, while \kbd{PgUp}, \kbd{Left}, and \kbd{Up} return to the previous page image. \kbd{Home} returns to the first page image and \kbd{End} advances to the final page image. \kbd{Q} quits the interactive mode and proceeds with extraction. When navigating between pages, any selected areas will be displayed and can be edited. \kbd{Delete} removes a highlighted area from a page (and then displays it again). (This mode may not work correctly from within RStudio.)
#'
#' In \emph{reduced functionality mode} (where \code{widget = "reduced"} or on platforms where graphics events are unavailable), the interface requires users to indicate the upper-left and lower-right (or upper-right and lower-left) corners of an area on each page, this area will be briefly confirmed with a highlighted rectangle and the next page will be displayed. Dynamic page navigation and area editing are not possible.
#'
#' In any of these modes, after the areas are selected, \code{extract_areas} passes these user-defined areas to \code{\link{extract_tables}}. \code{locate_areas} implements the interactive component only, without actually extracting; this might be useful for interactive work that needs some modification before executing \code{extract_tables} computationally.
#' @return For \code{extract_areas}, see \code{\link{extract_tables}}. For \code{locate_areas}, a list of four-element numeric vectors (top,left,bottom,right), one per page of the file.
#' @author Thomas J. Leeper <thosjleeper@gmail.com>
#' @examples
#' if (interactive()) {
#'   # simple demo file
#'   f <- system.file("examples", "mtcars.pdf", package = "tabulapdf")
#'
#'   # locate areas only, using Shiny app
#'   locate_areas(f)
#'
#'   # locate areas only, using native graphics device
#'   locate_areas(f, widget = "shiny")
#'
#'   # locate areas and extract
#'   extract_areas(f)
#' }
#' @seealso \code{\link{extract_tables}}, \code{\link{make_thumbnails}}, , \code{\link{get_page_dims}}
#' @importFrom tools file_path_sans_ext
#' @importFrom rJava J new
#' @importFrom png readPNG
#' @importFrom grDevices dev.capabilities dev.off
#' @importFrom graphics par rasterImage locator plot
#' @export
locate_areas <- function(file,
                         pages = NULL,
                         thumbnails = NULL,
                         resolution = 60L,
                         widget = c("shiny", "native", "reduced"),
                         copy = FALSE) {
  if (!interactive()) {
    stop("locate_areas() is only available in an interactive session")
  } else {
    requireNamespace("graphics")
    requireNamespace("grDevices")
  }

  file <- localize_file(file, copy = copy)
  # on.exit(unlink(file), add = TRUE)
  dims <- get_page_dims(file, pages = pages)

  if (!is.null(thumbnails)) {
    filelist <- list.files(path.expand(thumbnails), pattern = "\\.png$", ignore.case = TRUE, full.names = TRUE)
    file.copy(filelist, tempdir(), overwrite = T)
    paths <- file.path(tempdir(), basename(filelist))
    cat("fetching files")
  } else {
    paths <- make_thumbnails(file,
      outdir = tempdir(),
      pages = pages,
      format = "png",
      resolution = resolution
    )
  }
  on.exit(unlink(paths), add = TRUE)

  areas <- rep(list(NULL), length(paths))
  i <- 1
  warnThisTime <- TRUE
  while (TRUE) {
    if (!is.na(paths[i])) {
      a <- try_area(
        file = paths[i],
        dims = dims[[i]],
        area = areas[[i]],
        warn = warnThisTime,
        widget = match.arg(widget)
      )
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
extract_areas <- function(file,
                          pages = NULL,
                          guess = FALSE,
                          copy = FALSE,
                          ...) {
  areas <- locate_areas(file = file, pages = pages, copy = copy)
  extract_tables(
    file = file,
    pages = pages,
    thumbnails = NULL,
    area = areas,
    guess = guess,
    ...
  )
}

try_area <- function(file, dims, area = NULL, warn = FALSE, widget = c("shiny", "native", "reduced")) {
  widget <- match.arg(widget)
  if (widget == "shiny") {
    try_area_shiny(file = file, dims = dims, area = area)
  } else {
    if (widget == "reduced" || !length(grDevices::dev.capabilities()[["events"]])) {
      try_area_reduced(file = file, dims = dims, area = area, warn = warn)
    } else {
      try_area_full(file = file, dims = dims, area = area)
    }
  }
}
