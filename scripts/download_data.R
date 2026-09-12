# Section 2: ICPRB Washington Metropolitian Area Water Supply
# Study appendices (Fairfax Water & loudoun Water production data)

# import libraries
library(pdftools)

# New directory for ICPRB Data
dir.create(
  "data/raw/icprb",
  recursive = TRUE,
  showWarnings = FALSE
)

# Download the file
download.file(
  "https://www.potomacriver.org/wp-content/uploads/2015/08/ICP15-04b_Ahmed.pdf",
  destfile = "data/raw/icprb/icprb_2015_appendix.pdf",
  mode = "wb"
)

download.file(
  "https://www.potomacriver.org/wp-content/uploads/2020/10/2020-WMA-Water-Supply-Study-Appendices-FINAL-September-2020.pdf",
  destfile = "data/raw/icprb/icprb_2020_appendix.pdf",
  mode = "wb"
)

text_2015 <- pdf_text("data/raw/icprb/icprb_2015_appendix.pdf")
length(text_2015)

fairfax_pages <- grep("Fairfax Water", text_2015)
loudoun_pages <- grep("Loudoun Water", text_2015)

print(fairfax_pages)
print(loudoun_pages)

# Looking at the tables
cat(text_2015[[12]])
cat(text_2015[[18]])

# Production pages for Fairfax -- redo
production_pages <- grep("Ave. annual production", text_2015)
print(production_pages)

# Looking at the tables
cat(text_2015[[1]])
cat(text_2015[[3]])
cat(text_2015[[4]])

# Above section confirmed what we need to see in the final output CSV
# -----------------------------------------------------------------------------
# Storing the viewed data in CSV

library(stringr)

# Function to parse a single utility's "Monthly ave. production" table
# from raw pdf_text page output
parse_monthly_production <- function(page_text, utility_name) {
  
  lines <- str_split(page_text, "\n")[[1]]
  
  months <- c("January","February","March","April","May","June",
              "July","August","September","October","November","December")
  
  # Find the header lines that bound the "average production" section
  avg_start <- grep("Monthly ave. production", lines)
  peak_start <- grep("Peak 1-day production", lines)
  
  # Keep only lines between the two headers (i.e., just the average table)
  avg_lines <- lines[avg_start:(peak_start - 1)]
  
  month_lines <- avg_lines[str_trim(str_extract(avg_lines, "^\\s*[A-Za-z]+")) %in% months]
  
  parsed <- lapply(month_lines, function(l) {
    month <- str_trim(str_extract(l, "^\\s*[A-Za-z]+"))
    nums <- as.numeric(str_extract_all(l, "\\d+\\.?\\d*")[[1]])
    data.frame(
      utility = utility_name,
      month = month,
      year = 2005:2013,
      production_mgd = nums[1:9]
    )
  })
  
  do.call(rbind, parsed)
}


fairfax_monthly <- parse_monthly_production(text_2015[[1]], "Fairfax Water")
loudoun_monthly <- parse_monthly_production(text_2015[[4]], "Loudoun Water (Purchased)")

icprb_monthly_production <- rbind(fairfax_monthly, loudoun_monthly)

# Should now show 9 per utility/month, not 18
table(
  icprb_monthly_production$utility, 
  icprb_monthly_production$month
)

nrow(icprb_monthly_production)  # should be 216

# str(icprb_monthly_production)
# head(icprb_monthly_production, 15)

# Save the dataset created
write.csv(
  icprb_monthly_production,
  "data/raw/icprb/icprb_2015study_monthly_production_2005_2013.csv",
  row.names = FALSE
)

# -----------------------------------------------------------------------------
# Section 1: USGS Data
# Note:
# USGS's readNWISuse() and dataRetrieval's newer water-use functions were non-functional
# as of September 2026.
# Data was manually downloaded from ScienceBase:https://www.sciencebase.gov/catalog/item/get/5af3311be4b0da30c1b245d8
# File: usco2015.csv ("All Data CSV")

# import libraries
library(dplyr)

# Verify the file is placed in the right directory
stopifnot(file.exists("data/raw/usco2015v2.0.csv"))

water_use_2015 <- read.csv(
  "data/raw/usco2015v2.0.csv",
  skip = 1 # the header row is being read as row 1 if skip = 1 is not present
)

str(water_use_2015)

# Filter for Loudoun & Fairfax counties
loudoun_fairfax_2015 <- water_use_2015 %>%
  filter(FIPS %in% c(51107, 51059))

loudoun_fairfax_2015 %>%
  select(COUNTY, FIPS, TP.TotPop, PS.Wtotl, IN.Wtotl)

# Clarification on the units
# Checking every field for Fairfax County
water_use_2015 %>% filter(FIPS == 51059) %>% t()