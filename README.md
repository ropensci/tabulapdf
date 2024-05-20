
# tabulapdf: Extract tables from PDF documents <img src="man/figures/logo.svg" align="right" height="139" alt="" />

[![R-CMD-check](https://github.com/ropensci/tabulapdf/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ropensci/tabulapdf/actions/workflows/R-CMD-check.yaml)
[![](https://badges.ropensci.org/42_status.svg)](https://github.com/ropensci/software-review/issues/42)
[![BuyMeACoffee](https://raw.githubusercontent.com/pachadotdev/buymeacoffee-badges/main/bmc-donate-yellow.svg)](https://buymeacoffee.com/pacha)

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
library(tabulapdf)
f <- system.file("examples", "data.pdf", package = "tabulapdf")
out <- extract_tables(f)
out[[1]]

# # A tibble: 32 × 11
#      mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#  1  21       6  160    110  3.9   2.62  16.5     0     1     4     4
#  2  21       6  160    110  3.9   2.88  17.0     0     1     4     4
#  3  22.8     4  108     93  3.85  2.32  18.6     1     1     4     1
#  4  21.4     6  258    110  3.08  3.21  19.4     1     0     3     1
#  5  18.7     8  360    175  3.15  3.44  17.0     0     0     3     2
#  6  18.1     6  225    105  2.76  3.46  20.2     1     0     3     1
#  7  14.3     8  360    245  3.21  3.57  15.8     0     0     3     4
#  8  24.4     4  147.    62  3.69  3.19  20       1     0     4     2
#  9  22.8     4  141.    95  3.92  3.15  22.9     1     0     4     2
# 10  19.2     6  168.   123  3.92  3.44  18.3     1     0     4     4
# # ℹ 22 more rows
# # ℹ Use `print(n = ...)` to see more rows
```

The vignette provides more examples and details on how to use the
package.

## Installing Java on Windows with Chocolatey

In Power Shell prompt, install Chocolately if you don’t already have it.

Run `Get-ExecutionPolicy`. If it returns `Restricted`, then run
`Set-ExecutionPolicy AllSigned` or `Set-ExecutionPolicy Bypass -Scope
Process`. Then, install Chocolatey by running the following command:

    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

Install java using the following command:

    choco install openjdk11

You should now be able to safely open R, and use rJava and tabulapdf.
From PowerShell, you should see something like this after running `java
-version`:

    OpenJDK Runtime Environment (build 11.0.22+7-post-Ubuntu-0ubuntu222.04.1)
    OpenJDK 64-Bit Server VM (build 11.0.22+7-post-Ubuntu-0ubuntu222.04.1, mixed mode, sharing)

## Troubleshooting

### Mac OS and Linux

We tested with OpenJDK version 11. The package is configured to ask for
that version of Java. If you have a different version of Java installed,
you may need to change the `JAVA_HOME` environment variable to point to
the correct version.

You need to ensure that R has been installed with Java support. This can
often be fixed by running `R CMD javareconf` on the command line
(possibly with `sudo`).

### Windows

Make sure you have permission to write to and install packages to your R
directory before trying to install the package. This can be changed from
“Properties” on the right-click context menu. Alternatively, you can
ensure write permission by choosing “Run as administrator” when
launching R (again, from the right-click context menu).

## Meta

  - Please [report any issues or
    bugs](https://github.com/ropensci/tabulapdf/issues).
  - Get citation information for `tabulapdf` in R doing
    `citation(package = 'tabulapdf')`
  - License: Apache

[![rofooter](https://ropensci.org/public_images/github_footer.png)](https://ropensci.org)
