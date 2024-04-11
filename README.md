
# tabulapdf: Extract tables from PDF documents <img src="man/figures/logo.svg" align="right" height="139" alt="" />

[![CRAN](https://www.r-pkg.org/badges/version/tabulapdf)](https://cran.r-project.org/package=tabulapdf)
[![Downloads](https://cranlogs.r-pkg.org/badges/tabulapdf)](https://cran.r-project.org/package=tabulapdf)
[![Build
Status](https://travis-ci.org/ropensci/tabulapdf.png?branch=master)](https://travis-ci.org/ropensci/tabulapdf)
[![R-CMD-check](https://github.com/ropensci/tabulapdf/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ropensci/tabulapdf/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/ropensci/tabulapdf/branch/master/graph/badge.svg)](https://app.codecov.io/gh/ropensci/tabulapdf?branch=main)
[![](https://badges.ropensci.org/42_status.svg)](https://github.com/ropensci/onboarding/issues/42)

**tabulapdf** provides R bindings to the [Tabula java
library](https://github.com/tabulapdf/tabula-java/), which can be used
to computationaly extract tables from PDF documents.

Note: tabulapdf is released under the MIT license, as is Tabula itself.

## Installation

tabulapdf depends on [rJava](https://cran.r-project.org/package=rJava),
which implies a system requirement for Java. This can be frustrating,
especially on Windows. The preferred Windows workflow is to use
[Chocolatey](https://chocolatey.org/) to obtain, configure, and update
Java. You need do this before installing rJava or attempting to use
tabulapdf. More on [this](#installing-java-on-windows-with-chocolatey)
and [troubleshooting](#troubleshooting) below.

tabulapdf is not available on CRAN, but it can be installed from
rOpenSci’s R-Universe:

``` r
install.packages("tabulapdf", repos = c("https://ropensci.r-universe.dev", "https://cloud.r-project.org"))
```

To install the latest development version:

``` r
if (!require(remotes)) install.packages("remotes")

# on 64-bit Windows
remotes::install_github(c("ropensci/tabulapdf"), INSTALL_opts = "--no-multiarch")

# elsewhere
remotes::install_github(c("ropensci/tabulapdf"))
```

## Code Examples

The main function, `extract_tables()` provides an R clone of the Tabula
command line application:

``` r
library("tabulapdf")
f <- system.file("examples", "data.pdf", package = "tabulapdf")
out1 <- extract_tables(f)
str(out1)
## List of 4
##  $ : chr [1:32, 1:10] "mpg" "21.0" "21.0" "22.8" ...
##  $ : chr [1:7, 1:5] "Sepal.Length " "5.1 " "4.9 " "4.7 " ...
##  $ : chr [1:7, 1:6] "" "145 " "146 " "147 " ...
##  $ : chr [1:15, 1] "supp" "VC" "VC" "VC" ...
```

By default, it returns the most table-like R structure available: a
matrix. It can also write the tables to disk or attempt to coerce them
to data.frames using the `output` argument. It is also possible to
select tables from only specified pages using the `pages` argument.

``` r
out2 <- extract_tables(f, pages = 1, guess = FALSE, output = "data.frame")
str(out2)
## List of 1
##  $ :'data.frame':       33 obs. of  13 variables:
##   ..$ X   : chr [1:33] "Mazda RX4 " "Mazda RX4 Wag " "Datsun 710 " "Hornet 4 Drive " ...
##   ..$ mpg : num [1:33] 21 21 22.8 21.4 18.7 18.1 14.3 24.4 22.8 19.2 ...
##   ..$ cyl : num [1:33] 6 6 4 6 8 6 8 4 4 6 ...
##   ..$ X.1 : int [1:33] NA NA NA NA NA NA NA NA NA NA ...
##   ..$ disp: num [1:33] 160 160 108 258 360 ...
##   ..$ hp  : num [1:33] 110 110 93 110 175 105 245 62 95 123 ...
##   ..$ drat: num [1:33] 3.9 3.9 3.85 3.08 3.15 2.76 3.21 3.69 3.92 3.92 ...
##   ..$ wt  : num [1:33] 2.62 2.88 2.32 3.21 3.44 ...
##   ..$ qsec: num [1:33] 16.5 17 18.6 19.4 17 ...
##   ..$ vs  : num [1:33] 0 0 1 1 0 1 0 1 1 1 ...
##   ..$ am  : num [1:33] 1 1 1 0 0 0 0 0 0 0 ...
##   ..$ gear: num [1:33] 4 4 4 3 3 3 3 4 4 4 ...
##   ..$ carb: int [1:33] 4 4 1 1 2 1 4 2 2 4 ...
```

It is also possible to manually specify smaller areas within pages to
look for tables using the `area` and `columns` arguments to
`extract_tables()`. This facilitates extraction from smaller portions of
a page, such as when a table is embeded in a larger section of text or
graphics.

Another function, `extract_areas()` implements this through an
interactive style in which each page of the PDF is loaded as an R
graphic and the user can use their mouse to specify upper-left and
lower-right bounds of an area. Those areas are then extracted
auto-magically (and the return value is the same as for
`extract_tables()`). Here’s a shot of it in action:

![extract\_areas()](https://i.imgur.com/USTyQl7.gif)

`locate_areas()` handles the area identification process without
performing the extraction, which may be useful as a debugger.

`extract_text()` simply returns text, possibly separately for each
(specified) page:

``` r
out3 <- extract_text(f, page = 3)
cat(out3, sep = "\n")
## len supp dose
## 4.2 VC 0.5
## 11.5 VC 0.5
## 7.3 VC 0.5
## 5.8 VC 0.5
## 6.4 VC 0.5
## 10.0 VC 0.5
## 11.2 VC 0.5
## 11.2 VC 0.5
## 5.2 VC 0.5
## 7.0 VC 0.5
## 16.5 VC 1.0
## 16.5 VC 1.0
## 15.2 VC 1.0
## 17.3 VC 1.0
## 22.5 VC 1.0
## 3
```

Note that for large PDF files, it is possible to run up against Java
memory constraints, leading to a `java.lang.OutOfMemoryError: Java heap
space` error message. Memory can be increased using
`options(java.parameters = "-Xmx16000m")` set to some reasonable amount
of memory.

Some other utility functions are also provided (and made possible by the
Java [Apache PDFBox library](https://pdfbox.apache.org/)):

  - `extract_text()` converts the text of an entire file or specified
    pages into an R character vector.
  - `split_pdf()` and `merge_pdfs()` split and merge PDF documents,
    respectively.
  - `extract_metadata()` extracts PDF metadata as a list.
  - `get_n_pages()` determines the number of pages in a document.
  - `get_page_dims()` determines the width and height of each page in pt
    (the unit used by `area` and `columns` arguments).
  - `make_thumbnails()` converts specified pages of a PDF file to image
    files.

### Installing Java on Windows with Chocolatey

In command prompt, install Chocolately if you don’t already have it:

    @powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin

Then, install java using Chocolately’s `choco install` command:

    choco install jdk7 -y

You may also need to then set the `JAVA_HOME` environment variable to
the path to your Java installation (e.g., `C:\Program
Files\Java\jdk1.8.0_92`). This can be done:

1.  within R using `Sys.setenv(JAVA_HOME = "C:/Program
    Files/Java/jdk1.8.0_92")` (note slashes), or
2.  from command prompt using the `setx` command: `setx JAVA_HOME
    C:\Program Files\Java\jdk1.8.0_92`, or
3.  from PowerShell, using the .NET framework:
    `[Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program
    Files\Java\jdk1.8.0_92", "User")`, or
4.  from the Start Menu, via `Control Panel » System » Advanced »
    Environment Variables` ([instructions
    here](http://superuser.com/a/284351/221772)).

You should now be able to safely open R, and use rJava and tabulapdf.
Note, however, that some users report that rather than setting this
variable, they instead need to delete it (e.g., with
`Sys.setenv(JAVA_HOME = "")`), so if the above instructions fail, that
is the next step in troubleshooting.

### Troubleshooting

Some notes for troubleshooting common installation problems:

  - On Mac OS and Linux, we tested with OpenJDK version 11. The package
    is configure to ask for that version of Java. If you have a
    different version of Java installed, you may need to change the
    `JAVA_HOME` environment variable to point to the correct version.
    You need to ensure that R has been installed with Java support. This
    can often be fixed by running `R CMD javareconf` on the command line
    (possibly with `sudo`, etc. depending on your system setup).
  - On Windows, make sure you have permission to write to and install
    packages to your R directory before trying to install the package.
    This can be changed from “Properties” on the right-click context
    menu. Alternatively, you can ensure write permission by choosing
    “Run as administrator” when launching R (again, from the
    right-click context menu).

## Meta

  - Please [report any issues or
    bugs](https://github.com/ropensci/tabulapdf/issues).
  - License: MIT
  - Get citation information for `tabulapdf` in R doing
    `citation(package = 'tabulapdf')`

[![rofooter](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
