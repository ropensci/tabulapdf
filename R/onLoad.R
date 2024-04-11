.onLoad <- function(libname, pkgname) {
  rJava::.jpackage(pkgname, jars = "*", lib.loc = libname)
  rJava::J("java.lang.System")$setProperty("java.awt.headless", "true")
}
