library(tabulapdf)

# First try getting the text up to but not including the x-bar
out1 <- extract_text("dev/xbar.pdf", area = list(c(0,0,200,193)))
# This works

# Get the whole text
out2 <- extract_text("dev/xbar.pdf")
# This gives a fatal error

# Get the text for just the x-bar area
out3 <- extract_text("xbar.pdf", area = list(c(0,193,200,210)))
# This gives a fatal error
