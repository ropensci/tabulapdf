#' @title rJava logging
#' @description Toggle verbose rJava logging
#' @details This function turns off the default, somewhat verbose rJava logging, most of which is uninformative. 
#' @note This resets a global Java setting and may affect logging of other rJava operations, requiring a restart of R.
#' @return \code{NULL}, invisibly.
#' @author Thomas J. Leeper <thosjleeper@gmail.com>
#' @examples
#' \dontrun{
#' stop_logging()
#' }
#' @importFrom rJava J
#' @export
stop_logging <- function() {
    J("java.util.logging.LogManager")$getLogManager()$reset()
    invisible(NULL)
}
