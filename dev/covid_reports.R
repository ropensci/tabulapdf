library(glue)
library(rvest)
library(stringr)
library(dplyr)

url <- "https://www.aifa.gov.it/uso-degli-antivirali-orali-per-covid-19"

dout <- "dev/covid_reports"
try(dir.create(dout), silent = TRUE)

finp <- glue("{ dout }/links.txt")

if (!file.exists(finp)) {
  links <- url %>%
    read_html() %>%
    html_nodes("a") %>%
    html_attr("href") %>%
    str_subset("report_n")
  writeLines(links, finp)
} else {
  links <- readLines(finp)
}

links <- glue("https://www.aifa.gov.it{ links }")

finp <- glue("{ dout }/{ basename(links[1]) }")

if (!file.exists(finp)) {
  try(download.file(links[1], destfile = finp, quiet = TRUE))
}

# locate_areas(finp, pages = 4)

report1 <- extract_tables(finp,
  pages = 4, guess = FALSE, col_names = FALSE,
  area = list(c(140.75, 88.14, 374.17, 318.93))
)

report1 <- report1[[1]] %>%
  rename(region = X1, treatments = X2, pct_increase = X3) %>%
  mutate(
    treatments = as.numeric(str_replace(treatments, "\\.", "")),
    pct_increase = pct_increase %>%
      str_replace(",", ".") %>%
      str_replace("%", "") %>%
      as.numeric(.) / 100,
    date = finp %>%
      basename() %>%
      str_replace(".*antivirali_", "") %>%
      str_replace("\\.pdf", "") %>%
      as.Date(format = "%d.%m.%Y")
  )

report1

split_pdf(finp, dout)

file.copy(str_replace(finp, ".pdf", "04.pdf"), "inst/examples/covid.pdf")
