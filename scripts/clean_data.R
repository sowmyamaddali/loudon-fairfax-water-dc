# Script:
# Combines and cleans:
# - ICPRB 2015 study monthly production (2005-2013)
# - ICPRB 2020 study monthly production (2010-2018)
# - USGS county water-use data (2015), population/delivery fields only
# See decisions.md - withdrawal fields unreliable for Fairfax/Loudoun

# import libraries
library(dplyr)
library(readr)


# Load both raw datasets
icprb_2015 <- read.csv("data/raw/icprb/icprb_2015study_monthly_production_2005_2013.csv")
icprb_2020 <- read.csv("data/raw/icprb/icprb_2020study_monthly_production_2010_2018.csv")


# Check the overlap years (2010-2013) for consistency -- Fairfax Water
overlap_2015 <- icprb_2015 %>%
  filter(year %in% 2010:2013, utility == "Fairfax Water") %>%
  arrange(year, month)

overlap_2020 <- icprb_2020 %>%
  filter(year %in% 2010:2013, utility == "Fairfax Water") %>%
  arrange(year, month)

comparison <- overlap_2015 %>%
  rename(production_2015study = production_mgd) %>%
  inner_join(
    overlap_2020 %>% rename(production_2020study = production_mgd),
    by = c("month", "year")
  ) %>%
  mutate(diff = production_2020study - production_2015study)

# print(comparison)


# Check the overlap years (2010-2013) for consistency -- Loudoun Water
overlap_2015_loudoun <- icprb_2015 %>%
  filter(year %in% 2010:2013, utility == "Loudoun Water (Purchased)") %>%
  arrange(year, month)

overlap_2020_loudoun <- icprb_2020 %>%
  filter(year %in% 2010:2013, utility == "Loudoun Water (Total Use)") %>%
  arrange(year, month)

comparison_loudoun <- overlap_2015_loudoun %>%
  rename(purchased_2015study = production_mgd) %>%
  select(-utility) %>%
  inner_join(
    overlap_2020_loudoun %>% rename(total_use_2020study = production_mgd) %>% select(-utility),
    by = c("month", "year")
  ) %>%
  mutate(diff = total_use_2020study - purchased_2015study)

comparison_loudoun


# Combining into one clean dataset
icprb_combined <- bind_rows(
  icprb_2015 %>% filter(!(year %in% 2010:2013)), # keeping only 2005-2009 from 2015 study
  icprb_2020 # 2010-2018 from 2020 study
)


# Standardize utility labels across the full timeline
icprb_combined <- icprb_combined %>%
  mutate(utility = case_when(
    utility %in% c("Loudoun Water (Purchased)", "Loudoun Water (Total Use)") ~ "Loudoun Water",
    TRUE ~ utility
  ))

#table(icprb_combined$utility, icprb_combined$year)


# Write to CSV
write.csv(
  icprb_combined,
  "data/processed/icprb_monthly_production_2005_2018.csv",
  row.names = FALSE
)


# ------------------------------------------------------------------------------
# Combine ICPRB production, Census population, and USDM drought data
# into one annual dataset for Loudoun and Fairfax County
library(dplyr)

# Aggregate ICPRB monthly production to annual
icprb_annual <- icprb_combined %>%
  group_by(utility, year) %>%
  summarise(avg_production_mgd = mean(production_mgd),
            .groups = "drop"
            )


# Prepare population data (it's already annual)
population_annual <- population_by_year %>%
  mutate(
    county = case_when(
      GEOID == "51059" ~ "Fairfax Water",
      GEOID == "51107" ~ "Loudoun Water"
    )
  ) %>%
  select(county, year = acs_end_year, population = estimate)


# Aggregate weekly drought to annual
drought_annual <- loudoun_fairfax_drought %>%
  mutate(
    county = case_when(
      countyfips == 51059 ~ "Fairfax Water",
      countyfips == 51107 ~ "Loudoun Water"
    ),
    in_drought = value %in% c(1, 2, 3, 4)
  ) %>%
  group_by(county, year) %>%
  summarise(
    pct_weeks_in_drought = mean(in_drought) * 100,
    avg_drought_severity = mean(value[value != 9], na.rm = TRUE),
    .groups = "drop"
  )


# Combine all three via full join on utility/county + year
combined_annual <- icprb_annual %>%
  rename(county = utility) %>%
  full_join(population_annual, by = c("county", "year")) %>%
  full_join(drought_annual, by = c("county", "year")) %>%
  arrange(county, year)
print(combined_annual, n = 38)


# Write to CSV
write.csv(
  combined_annual,
  "data/processed/combined_annual_loudoun_fairfax.csv",
  row.names = FALSE
)

# ------------------------------------------------------------------------------
# Rebuild with extended sources
icprb_annual_extended <- icprb_combined_extended %>%
  group_by(utility, year) %>%
  summarise(avg_production_mgd = mean(production_mgd),
            .groups = "drop")

population_annual_extended <- population_by_year_all %>%
  mutate(
    county = case_when(
      GEOID == "51059" ~ "Fairfax Water",
      GEOID == "51107" ~ "Loudoun Water"
    )
  ) %>%
  select(county, year = acs_end_year, population = estimate)

# Extend dc_demand_mw from 2013:2022
dc_demand <- data.frame(
  year = 2013:2022,
  dc_demand_mw = c(462, 532, 636, 753, 931, 1113, 1421, 1808, 2302, 2767)
)

combined_annual_extended <- icprb_annual_extended %>%
  rename(county = utility) %>%
  full_join(population_annual_extended, by = c("county", "year")) %>%
  full_join(drought_annual, by = c("county", "year")) %>%
  full_join(dc_demand, by = "year") %>%
  arrange(county, year)

print(combined_annual_extended, n=40)

# Confirming the dc_demand - Fairfax
fairfax_dc_extended <- combined_annual_extended %>%
  filter(county == "Fairfax Water", !is.na(avg_production_mgd),
         !is.na(population), !is.na(dc_demand_mw))

# Confirming the dc_demand - Loudoun
loudoun_dc_extended <- combined_annual_extended %>%
  filter(county == "Loudoun Water", !is.na(avg_production_mgd),
         !is.na(population), !is.na(dc_demand_mw))

nrow(fairfax_dc_extended)
nrow(loudoun_dc_extended)

# Write to CSV
write.csv(
  combined_annual_extended,
  "data/processed/combined_annual_loudoun_fairfax_extended.csv",
  row.names = FALSE
)

# Re-check collinearity with the large sample
cor(fairfax_dc_extended$population, fairfax_dc_extended$dc_demand_mw)
cor(loudoun_dc_extended$population, loudoun_dc_extended$dc_demand_mw)

fairfax_dc_model2 <- lm(avg_production_mgd ~ dc_demand_mw, data = fairfax_dc_extended)
loudoun_dc_model2 <- lm(avg_production_mgd ~ dc_demand_mw, data = loudoun_dc_extended)

summary(fairfax_dc_model2)
summary(loudoun_dc_model2)











