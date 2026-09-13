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
  "90d1c6061dcf4f3e5b26e75116f70973c4378af6",
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




