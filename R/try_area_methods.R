try_area_rstudio <- function(file, dims, area = NULL) {
    requireNamespace("shiny")
    requireNamespace("miniUI")
    ui <- miniUI::miniPage(
      miniUI::gadgetTitleBar("Click and drag to select an area. Click 'Done' to accept."),
      miniUI::miniContentPanel(padding = 0,
        shiny::plotOutput("plot", height = "100%", brush = shiny::brushOpts(id = "plot_brush"))
      )
    )
    server <- function(input, output, session) {
        thispng <- readPNG(file, native = TRUE)
        if (!length(area)) {
            startx <- NULL
            starty <- NULL
            endx <- NULL
            endy <- NULL
        } else {
            showArea <- function() {
                # convert from: top,left,bottom,right
                startx <<- area[2]
                starty <<- dims[2] - area[1]
                endx <<- area[4]
                endy <<- dims[2] - area[3]
                drawRectangle()
            }
            showArea()
        }
        drawPage <- function() {
            graphics::plot(c(0, dims[1]), c(0, dims[2]), type = "n", xlab = "", ylab = "", asp = 1)
            graphics::rasterImage(thispng, 0, 0, dims[1], dims[2])
        }
        drawRectangle <- function() {
            if (!is.null(endx)) {
                graphics::rect(startx, starty, endx, endy, col = grDevices::rgb(1,0,0,.2) )
            }
        }
        output$plot <- shiny::renderPlot({
            pre_par <- graphics::par(mar=c(0,0,0,0), xaxs = "i", yaxs = "i", bty = "n")
            on.exit(graphics::par(pre_par), add = TRUE)
            drawPage()
            if (!is.null(input$plot_brush)) {
                startx <<- input$plot_brush$xmin
                endx <<- input$plot_brush$xmax
                starty <<- input$plot_brush$ymin
                endy <<- input$plot_brush$ymax
                drawRectangle()
            }
        })
        shiny::observeEvent(input$done, {
            if (is.null(startx)) {
                area <- NULL
            } else {
                # convert to: top,left,bottom,right
                area <- c(top = dims[2] - max(c(starty, endy)),
                          left = min(c(startx,endx)),
                          bottom = dims[2] - (min(c(starty,endy))),
                          right = max(c(startx,endx)) )
            }
            shiny::stopApp(list(key = "right", area = area))
        })
    }
    shiny::runGadget(shiny::shinyApp(ui = ui, server = server))
}

try_area_reduced <- function(file, dims, area = NULL, warn = FALSE) {
    if (warn) {
        message("Graphics device does not support event handling...\n",
                "Entering reduced functionality mode.\n",
                "Click upper-left and then lower-right corners of area.")
    }
    if (grDevices::dev.capabilities()[["rasterImage"]] != "yes") {
        stop("Graphics device does not support rasterImage() plotting")
    }
    thispng <- readPNG(file, native = TRUE)
    drawPage <- function() {
        graphics::plot(c(0, dims[1]), c(0, dims[2]), type = "n", xlab = "", ylab = "", asp = 1)
        graphics::rasterImage(thispng, 0, 0, dims[1], dims[2])
    }
        
    pre_par <- graphics::par(mar=c(0,0,0,0), xaxs = "i", yaxs = "i", bty = "n")
    on.exit(graphics::par(pre_par), add = TRUE)
    drawPage()
    on.exit(grDevices::dev.off(), add = TRUE)
    
    tmp <- locator(2)
    graphics::rect(tmp$x[1], tmp$y[1], tmp$x[2], tmp$y[2], col = grDevices::rgb(1,0,0,.5))
    Sys.sleep(2)
    
    # convert to: top,left,bottom,right
    area <- c(dims[2] - max(tmp$y), min(tmp$x), dims[2] - min(tmp$y), max(tmp$x))
    return(list(key = "right", area = area))
}

try_area_full <- function(file, dims, area = NULL) {
    clicked <- FALSE
    lastkey <- NA_character_
    if (!length(area)) {
        startx <- NULL
        starty <- NULL
        endx <- NULL
        endy <- NULL
    } else {
        showArea <- function() {
            # convert from: top,left,bottom,right
            startx <<- area[2]
            starty <<- dims[2] - area[1]
            endx <<- area[4]
            endy <<- dims[2] - area[3]
            drawRectangle()
        }
        showArea()
    }
    
    devset <- function() {
        if (grDevices::dev.cur() != eventEnv$which) grDevices::dev.set(eventEnv$which)
    }
    
    mousedown <- function(buttons, x, y) {
        devset()
        if (clicked) {
            endx <<- graphics::grconvertX(x, deviceUnits, "user")
            endy <<- graphics::grconvertY(y, deviceUnits, "user")
            clicked <<- FALSE
            eventEnv$onMouseMove <- NULL
        } else {
            startx <<- graphics::grconvertX(x, deviceUnits, "user")
            starty <<- graphics::grconvertY(y, deviceUnits, "user")
            clicked <<- TRUE
            eventEnv$onMouseMove <- dragmousemove
        }
        NULL
    }

    dragmousemove <- function(buttons, x, y) {
        devset()
        if (clicked) {
            endx <<- graphics::grconvertX(x, deviceUnits, "user")
            endy <<- graphics::grconvertY(y, deviceUnits, "user")
            drawPage()
            drawRectangle()
        }
        NULL
    }

    keydown <- function(key) {
        devset()
        eventEnv$onMouseMove <- NULL
        lastkey <<- key
        TRUE
    }

    deviceUnits <- "nfc"
    if (Sys.info()["sysname"] == "Darwin") {
        grDevices::X11(type = "xlib")
    }
    if (grDevices::dev.capabilities()[["rasterImage"]] != "yes") {
        stop("Graphics device does not support rasterImage() plotting")
    }
    thispng <- readPNG(file, native = TRUE)
    drawPage <- function() {
        graphics::plot(c(0, dims[1]), c(0, dims[2]), type = "n", xlab = "", ylab = "", asp = 1)
        graphics::rasterImage(thispng, 0, 0, dims[1], dims[2])
    }
    drawRectangle <- function() {
        if (!is.null(endx)) {
            graphics::rect(startx, starty, endx, endy, col = grDevices::rgb(1,0,0,.2) )
        }
    }
        
    pre_par <- graphics::par(mar=c(0,0,0,0), xaxs = "i", yaxs = "i", bty = "n")
    on.exit(graphics::par(pre_par), add = TRUE)
    drawPage()
    on.exit(grDevices::dev.off(), add = TRUE)

    p <- "Click and drag to select a table area. Press <Right> for next page or <Q> to quit."
    grDevices::setGraphicsEventHandlers(prompt = p,
                                        onMouseDown = mousedown,
                                        onKeybd = keydown)
    eventEnv <- grDevices::getGraphicsEventEnv()
    grDevices::getGraphicsEvent()
    
    backToPageSize <- function() {
        # convert to: top,left,bottom,right
        if (!is.null(startx)) {
            c(top = dims[2] - max(c(starty, endy)),
              left = min(c(startx,endx)),
              bottom = dims[2] - (min(c(starty,endy))),
              right = max(c(startx,endx)) )
        } else {
            NULL
        }
    }
    return(list(key = lastkey, area = backToPageSize()))
}
