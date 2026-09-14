# Pulls confounder data for water-use analysis:
# - Population (Census/ACS via tidycensus)
# - Drought index (planned)

# Run after: download_data.R
# Run before: clean_data.R

# Import libraries
library(tidycensus)
library(dplyr)


# One-time setup: register for a free Census API key at
# https://api.census.gov/data/key_signup.html
census_api_key(
  "",
  install = TRUE,
  overwrite = TRUE)


# ACS 5-year estimates start at 2009 (2005-2009 window)
years <- 2009:2018

population_by_year <- lapply(years, function(y) {
  get_acs(
    geography = "county",
    variables = "B01003_001",
    state = "VA",
    county = c("107", "059"),
    year = y,
    survey = "acs5"
  ) %>%
    mutate(acs_end_year = y)
}
  ) %>%
  bind_rows()

# print(population_by_year)


# Create a new directory for census data (raw)
dir.create(
  "data/raw/census",
  recursive = TRUE,
  showWarnings = FALSE
  )


# Write to CSV
write.csv(
  population_by_year,
  "data/raw/census/loudoun_fairfax_population_2009_2018.csv",
  row.names = FALSE
)

# ------------------------------------------------------------------------------
# Drought data: NOAA/NIDIS Standardized Precipitation Index or
# U.S. Driught Monitor, county-level, Virginia

library(httr2)

# URL
drought_url <- "https://data.cdc.gov/api/views/spsk-9jj6/rows.csv?accessType=DOWNLOAD"


# Create a directory under data/raw name it `drought`
dir.create(
  "data/raw/drought",
  recursive = TRUE,
  showWarnings = FALSE
  )


# Increase timeout since this file is large
options(timeout = 300)


# Download the file
download.file(
  drought_url,
  destfile = "data/raw/drought/usdm_county_2000_2016.csv",
  mode = "wb"
)


# Read CSV
drought_raw <- read.csv("data/raw/drought/usdm_county_2000_2016.csv")
str(drought_raw)


# Filter for Loudoun & Fairfax County
loudoun_fairfax_drought <- drought_raw %>%
  filter(
    statefips == 51,
    countyfips %in% c(51107, 51059)
    )
# str(loudoun_fairfax_drought)
# head(loudoun_fairfax_drought)


# Flag: `value = 9`, that's outside the expected D0-D4 (0-4) drought severity scale, so 9
# likely means something else
# Checking the range before trusting it
# table(loudoun_fairfax_drought$value)


# Recoding drought categories
# [U.S. Drought Monitor](https://droughtmonitor.unl.edu/About/AbouttheData/DroughtClassification.aspx)
loudoun_fairfax_drought <- loudoun_fairfax_drought %>%
  mutate(drought_category = case_when(
    value == 9 ~ "None",
    value == 0 ~ "D0 ~ Abnormally Dry",
    value == 1 ~ "D1 ~ Moderate Drought",
    value == 2 ~ "D2 ~ Severe Drought",
    value == 3 ~ "D3 ~ Extreme Drought",
    value == 4 ~ "D4 ~ Exceptional Drought",
    TRUE ~ NA_character_
  ))
# table(loudoun_fairfax_drought$drought_category)


# Write to CSV
write.csv(
  loudoun_fairfax_drought,
  "data/processed/loudoun_fairfax_drought_2000_2016.csv",
  row.names = FALSE
)

# ------------------------------------------------------------------------------
# Dominion Energy data center demand (MW), Dominion Energy service territory
# Source: Dominion Energy, "Dominion Energy Service Territory Data Center
# Forecasting," presented by PJM Load Analysis Subcommittee, June 26, 2023
# URL: provided in `data-sources.md`
# Retrieved: 2026-09-13
# Caveat: Dominion service territory, not exact Loudoun/Fairfax Water
# boundaries; per source, Loudoun County => 80% of this demand

dc_demand <- data.frame(
  year = 2013:2018,
  dc_demand_mw = c(462, 532, 636, 753, 931, 1113)
)

combined_annual <- combined_annual %>%
  left_join(dc_demand, by = "year")

# table(combined_annual)








