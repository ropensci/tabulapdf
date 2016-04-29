.onLoad <- function(libname, pkgname) {
    rJava::.jpackage(pkgname, jars = "*", lib.loc = libname)
}
