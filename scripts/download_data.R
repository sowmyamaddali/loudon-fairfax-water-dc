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


# -----------------------------------------------------------------------------
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

# For the year 2020
text_2020 <- pdf_text("data/raw/icprb/icprb_2020_appendix.pdf")
length(text_2020)

production_pages_2020 <- grep("Ave. annual production", text_2020)
print(production_pages_2020)

loudoun_pages_2020 <- grep("Loudoun Water", text_2020)
print(loudoun_pages_2020)

parse_monthly_production_v2 <- function(page_text, utility_name) {
  
  lines <- str_split(page_text, "\n")[[1]]
  
  months <- c("January","February","March","April","May","June",
              "July","August","September","October","November","December")
  
  # Find the real header line: must contain 5+ year-like numbers (title line only has 2)
  year_counts <- str_count(lines, "20\\d{2}")
  header_line <- lines[which(year_counts >= 5)][1]
  years <- as.numeric(str_extract_all(header_line, "20\\d{2}")[[1]])
  
  avg_start <- grep("Monthly ave\\.", lines)
  peak_start <- grep("Peak 1-day", lines)
  
  avg_lines <- lines[avg_start:(peak_start - 1)]
  month_lines <- avg_lines[str_trim(str_extract(avg_lines, "^\\s*[A-Za-z]+")) %in% months]
  
  parsed <- lapply(month_lines, function(l) {
    month <- str_trim(str_extract(l, "^\\s*[A-Za-z]+"))
    nums <- as.numeric(str_extract_all(l, "\\d+\\.?\\d*")[[1]])
    data.frame(
      utility = utility_name,
      month = month,
      year = years,
      production_mgd = nums[1:length(years)]
    )
  })
  
  do.call(rbind, parsed)
}

fairfax_monthly_2020 <- parse_monthly_production_v2(text_2020[[16]], "Fairfax Water")
loudoun_monthly_2020 <- parse_monthly_production_v2(text_2020[[19]], "Loudoun Water (Total Use)")

icprb_2020_monthly <- rbind(fairfax_monthly_2020, loudoun_monthly_2020)

table(icprb_2020_monthly$utility, icprb_2020_monthly$month)
nrow(icprb_2020_monthly)

# Save the dataset
write.csv(
  icprb_2020_monthly,
  "data/raw/icprb/icprb_2020study_monthly_production_2010_2018.csv",
  row.names = FALSE
)

# -----------------------------------------------------------------------------

# Downloading new data for 2025
download.file(
  "https://www.potomacriver.org/wp-content/uploads/2025/12/2025_WMA_Water_Supply_Study_ICPRB_Dec-2025-export.pdf",
  destfile = "data/raw/icprb/icprb_2025study_full_report.pdf",
  mode = "wb"
)

text_2025study <- pdf_text("data/raw/icprb/icprb_2025study_full_report.pdf")
length(text_2025study)

# Find production tables and the data center consumptive use table
production_pages_2025 <- grep(
  "Ave. annual production|Ave. annual use", 
  text_2025study
)

dc_pages_2025 <- grep(
  "Forecasted Upstream Consumptive Use by Data Centers",
  text_2025study
)

print(production_pages_2025)
print(dc_pages_2025)

fairfax_monthly_2025 <- parse_monthly_production_v2(
  text_2025study[[172]],
  "Fairfax Water"
)

loudoun_monthly_2025 <- parse_monthly_production_v2(
  text_2025study[[175]],
  "Loudoun Water"
)

icprb_2025_monthly <- rbind(fairfax_monthly_2025, loudoun_monthly_2025)

table(icprb_2025_monthly$utility, icprb_2025_monthly$month)
nrow(icprb_2025_monthly) # result: 216

# Overlap Check
overlap_check <- icprb_2025_monthly %>%
  filter(year %in% 2015:2018) %>%
  rename(production_2025study = production_mgd) %>%
  inner_join(
    icprb_combined %>% filter(year %in% 2015:2018) %>% rename(production_prior = production_mgd),
    by = c("utility", "month", "year")
  ) %>%
  mutate(diff = production_2025study - production_prior)

table(overlap_check$diff == 0)
overlap_check %>% filter(diff != 0)


# All 96 overlapping rows matched exactly. Safe to extend the combined dataset
# with the new 2019-2023 years data
icprb_combined_extended <- bind_rows(
  icprb_combined, # existing 2005-2018 data
  icprb_2025_monthly %>% filter(year %in% 2019:2023) # new years only
) %>%
  arrange(utility, year, match(month, month.name))

table(icprb_combined_extended$utility, icprb_combined_extended$year)

# Write to CSV
write.csv(
  icprb_combined_extended,
  "data/processed/icprb_monthly_production_2005_2023.csv",
  row.names = FALSE
)




















