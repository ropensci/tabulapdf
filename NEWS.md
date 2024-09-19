# CHANGES TO tabulapdf 1.0.5-4

* Faster Shiny interface (parts of PR #56, @jkeuskamp)

# CHANGES TO tabulapdf 1.0.5-3

* CRAN release after the previous package was archived.

# CHANGES TO tabulapdf 1.0.5-2

* Uses readr for a much faster parsing of extracted tables.
* The default output format is now a list of tibbles.
* All tests pass.

# CHANGES TO tabulapdf 1.0.5

* Package renamed to `tabulapdf`
* New maintainer: @pachadotdev
* Updated to use tabula-java 1.0.5
* Updated the methods in `extract_tables()`
* The version now follows the version of tabula-java

# CHANGES TO tabulizer 0.2.2

* `extract_tables()` gets `outdir` argument for writing out CSV, TSV and JSON
files.
* Fixes in vignette.
* avoid using reflection for Java 17 compatibility.

# CHANGES TO tabulizer 0.2.1

* `make_thumbnails()` and `split_pdf()` now use `tempdir()` as the default
output directory.
* `extract_` functions get `copy` argument for copying original local files to 
R session's temporary directory.
* PDF files used do not get copied to temporary directory by default.
* General clean-up for CRAN submission.

# CHANGES TO tabulizer 0.2.0

* Upgrade to PDFBox 2/Tabula 1.0.1 ([#48](https://github.com/ropensci/tabulapdf/issues/48))
* `method` argument is changed to `output` in `extract_tables()`.
* New `method` argument reflects method of extraction as in Tabula command-line Java utility.
* `extract_text()` accepts `area` as argument.

# CHANGES TO tabulizer 0.1.24

* Switch to using new document loading algorithm and localize all remote URLs. ([#40](https://github.com/ropensci/tabulapdf/issues/40))
* Removed kind of annoying message about overwriting a temporary file. ([#36](https://github.com/ropensci/tabulapdf/issues/36))

# CHANGES TO tabulizer 0.1.23

* Transferred source code repository to ropensci: https://github.com/ropensci/tabulizer

# CHANGES TO tabulizer 0.1.22

* Transferred source code repository to ropenscilabs: https://github.com/ropenscilabs/tabulizer

# CHANGES TO tabulizer 0.1.21

* Exposed a new option `widget` in `locate_areas()` to control which widget is used in locating areas. 

# CHANGES TO tabulizer 0.1.20

* Fixed bug in internal function `try_area_full()` introduced by changes in8.

# CHANGES TO tabulizer 0.1.19

* Further expand the `locate_areas()` interface to use a Shiny gadget when working within RStudio, or otherwise rely on the full functionality interface (based on graphics device events) or reduced functionality interface (relying on `locator()`). (#8)

# CHANGES TO tabulizer 0.1.18

* Completely rewrite the `locate_areas()` interface to rely on graphics device event handling where possible. This may behave differently across platforms or in RStudio. (#8)

# CHANGES TO tabulizer 0.1.17

* Fixed a bug in `extract_tables()` such that when no tables are found, an empty list is returned (for `method` values with list response structures). (h/t Lincoln Mullen)

# CHANGES TO tabulizer 0.1.16

* `split_pdfs()` and `make_thumbnails()` gain an `outdir` argument to specify where to save the output. The file numbering of output files is also now zero-padded.
* An warning in `merge_pdfs()` has been fixed.
* `stop_logging()` is called when the package is attached to the search path.
* `get_page_dims()` earns a `doc` argument and argument order in `get_n_pages()` is reversed.

# CHANGES TO tabulizer 0.1.15

* Added better support for specifying character encoding. (#10)

# CHANGES TO tabulizer 0.1.14

* Added support for password-protected PDF files. (#11)

# CHANGES TO tabulizer 0.1.13

* Expand file paths where needed. (h/t David Gohel)

# CHANGES TO tabulizer 0.1.12

* Improve handling of URLs when using `extract_areas()` by downloading PDF to temporary directory.

# CHANGES TO tabulizer 0.1.11

* Exposed new functions `split_pdf()` and `merge_pdfs()` to split and merge PDFs, respectively. (#9)
* Exposed a `get_n_pages()` to determine the page length of a PDF document.
* Moved tabula .jar file to separate package, tabulizerjars. (#2)

# CHANGES TO tabulizer 0.1.10

* Added a new function `extract_metadata()` to extract PDF metadata as a list.
* Added a new function `extract_text()` to convert PDF contents to an R character vector.
* Changed the internal `localize_file()` function to use PDFBox to natively read from a URL.
* Removed illogical default `file` argument value in `extract_tables()`.

# CHANGES TO tabulizer 0.1.9

* Expanded test suite to cover `areas` and `columns` arguments and utilities. (#3)
* Fixed the same bug in `make_columns()` as was corrected for `make_areas()`. (#5)

# CHANGES TO tabulizer 0.1.8

* Fixed a bug in `make_areas()` internal when `area` was specified as a length 1 list for a multi-page document. (#5, h/t Tony Hirst)

# CHANGES TO tabulizer 0.1.7

* Added a function, `extract_areas()`, to interactively identify and extract page areas. Another new function, `locates_areas()` implements the locator functionality without performing any extraction.
* Added a function, `make_thumbnails()`, to convert pages into individual image files.
* Added a function, `get_page_dims()`, to extract page dimensions.

# CHANGES TO tabulizer 0.1.6

* Fixed a bug in the repeating of the `area` argument when `length(area) == 1 & length(pages) > 1`. (#5, #6)

# CHANGES TO tabulizer 0.1.5

* Fixed a bug in the handling of the `area` argument. (#5, #6)

# CHANGES TO tabulizer 0.1.4

* Added vignette. (#4)
* Added tests of guess parameter. (#3)
* Added a `spreadsheet` argument, a la Tabula itself.
* Fixed bugs in parsing of `area` and `columns` arguments.

# CHANGES TO tabulizer 0.1.3

* Added multiple table writing options beyond the default list of matrices. (#1)

# CHANGES TO tabulizer 0.1.1

* Initial release.
