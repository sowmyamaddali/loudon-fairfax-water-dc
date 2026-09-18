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

# ------------------------------------------------------------------------------

# Extend population data to match Dominion's 2022 cutoff
years_extended <- 2019:2022

population_by_year_extended <- lapply(
  years_extended, function(y) {
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

population_by_year_all <- bind_rows(
  population_by_year, population_by_year_extended
)
population_by_year_all

# Write to CSV
write.csv(
  population_by_year_all,
  "data/raw/census/loudoun_fairfax_population_2009_2022.csv",
  row.names = FALSE
)

# ------------------------------------------------------------------------------
# Downloading supporting data between 2017 and 2023
drought_2017_2023_url_loudoun <- "https://usdmdataservices.unl.edu/api/CountyStatistics/GetDroughtSeverityStatisticsByAreaPercent?aoi=51107&startdate=1/1/2017&enddate=12/31/2023&statisticsType=1"
drought_2017_2023_url_fairfax <- "https://usdmdataservices.unl.edu/api/CountyStatistics/GetDroughtSeverityStatisticsByAreaPercent?aoi=51059&startdate=1/1/2017&enddate=12/31/2023&statisticsType=1"

loudoun_new <- read.csv(drought_2017_2023_url_loudoun)
fairfax_new <- read.csv(drought_2017_2023_url_fairfax)

str(loudoun_new)
head(loudoun_new)

str(fairfax_new)
head(fairfax_new)

# Data formatting needs to be fixed in order to merge with existing data
library(dplyr)
library(lubridate)

process_usdm <- function(df) {
  df %>%
    mutate(
      year = as.integer(substr(MapDate, 1, 4)),
      in_drought = D1 > 0,
      # discrete area shares by exact category, area-weighted severity 0-4
      severity = (D1-D2)*1+(D2-D3)*2+(D3-D4)*3+D4*4
    ) %>%
    group_by(year) %>%
    summarise(
      pct_weeks_in_drought = mean(in_drought)*100,
      avg_drought_severity = mean(severity[in_drought])/100,
      .groups = "drop"
    )
}

loudoun_drought_2017_2023 <- process_usdm(loudoun_new) %>% mutate(county = "Loudoun Water")
fairfax_drought_2017_2023 <- process_usdm(fairfax_new) %>% mutate(county = "Fairfax Water")

drought_2017_2023 <- bind_rows(loudoun_drought_2017_2023, fairfax_drought_2017_2023)
drought_2017_2023

# Changing null values to NA from NaN
drought_2017_2023 <- drought_2017_2023 %>%
  mutate(
    avg_drought_severity = ifelse(is.nan(avg_drought_severity),
                                  NA, avg_drought_severity)
  )

# Merge with the existing 2000-2016 drought data
drought_annual %>% filter(year == 2016)
drought_2017_2023 %>% filter(year == 2016)
  
drought_2017_2023 <- drought_2017_2023 %>%
  filter(year != 2016)

# Combine: CDC (2000-2016) + USDM (2017-2023)
drought_annual_extended <- bind_rows(drought_annual, drought_2017_2023)

table(drought_annual_extended$county, drought_annual_extended$year)

# Write to CSV
write.csv(
  drought_annual_extended,
  "data/processed/drought_annual_loudoun_fairfax_2000_2023.csv",
  row.names = FALSE
)

combined_annual_full <- icprb_annual_extended %>%
  rename(county = utility) %>%
  full_join(population_annual_extended, by = c("county", "year")) %>%
  full_join(drought_annual_extended, by = c("county", "year")) %>%
  full_join(dc_demand, by = "year") %>%
  arrange(county, year)

write.csv(
  combined_annual_full,
  "data/processed/combined_annual_loudoun_fairfax_full.csv",
  row.names = FALSE
)




